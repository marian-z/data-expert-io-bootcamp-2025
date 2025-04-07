# Apache Spark Memory Tuning & Partitioning

**DE.IO Description:**

In this lecture, Zach dives into how to troubleshoot slow Spark jobs, particularly focusing on common bottlenecks that can occur in big tech environments. He discusses the impact of upstream data formats like JSON and CSV, and how they can hinder performance. He also shares insights on optimizing data processing and managing skew data effectively.

## Main Topics for the lecture

- What makes Spark jobs slow?

![Lecture 2 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-1.png)

- Generally speaking, these are the 4 places where Spark jobs are going to be slow

## Source File Bottlenecks

![Lecture 2 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-2.png)

- Too few non-splittable files could be one huge CSV that you can’t split and have to read line-by-line
- **Possible solutions:**
  - Work with upstream teams to change format, number of files
- Since a lot of the time you are not in control of the upstream systems you can’t really influence this bottleneck point other than trying to get these upstream teams to change the format or number of files
- **Example from Airbnb:**
  - Upstream to Smart Pricing there was a Hive process that was incorrectly outputting a single CSV file that was 250 GBs
  - Downstream Spark job took 4 hours to read it in
- If the upstream team just used format such as Parquet then this whole problem would be non-existent
- The Smart Pricing team spent weeks trying to optimize their Spark Jobs
- There is nothing you can do if your upstream data is shit
- Luckily for the Airbnb team this was a case where the people dealing with this were in control of the upstream process
- **Solution:**
  - Zach identified bad practice Hive pipeline and changed it to output 50 parquet files instead of 1 CSV file and the results were Dramatic
  - The downstream job went from 4 hour to 5 minutes
- If the first step in your Telemetry for the Spark job takes too long it's a sign that the source data is not in the ideal format and that's where you should look at

![Lecture 2 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-3.png)

- **Bad Choices:**
- TXT is completely batshit bad
- XML is a bit better because there is at least some structure
- JSON has a bit better structure than XML
- CSV is ok but is definitely not great since you have a lot of better options.
- By default any branded file format (i.e. XLSX for Excel) is generally bad
- **Good Choices:**
  - Avro is fine for Streaming use-cases if you want to insert/update individual rows when talking outside of Delta/Iceberg context
  - ORC (Optimized Row Columnar) is the Hive/Hadoop era file format which is quite good as it is columnar based
  - Delta/Iceberg (or Hudi) which is actually additional system on top of the data
- **Lesson:**
  - Sometimes Spark tuning can be a red herring as just because you can tune something doesn’t mean that you can overcome the bottleneck in the correct spot
  - Spark job tuning does not always mean optimizing the configuration or query itself

## Platform Misconfiguration / Congestion

![Lecture 2 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-4.png)

- **Solutions:**
  - **Wait until congestion dies down**
    - Unfortunately this is usually the main one at times
  - **Get a bigger cluster**
  - **Increase the utilization of cluster**
    - Sometimes the cluster is not using all of the job cores because the math is weird on it
    - Generally speaking 1 executor has 4 tasks that it can run. If you have say 8 cores on your Cluster that means you can run 32 tasks at once.
    - There can be some orphaned executors
  - **Put critical jobs in their own resource queues**
    - Put the most business critical pipelines on clusters like this so if they fail the business does not go bonkers
    - Other types of clusters can be Shared (for multiple pipelines for example) and AdHoc (for pipelines and query users)

## Spark Misconfiguration Bottlenecks

![Lecture 2 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-5.png)

- **Solutions:**
  - **Break the job up with a staging step**
    - This is a general advice for Data Engineering as a whole where it makes the most sense to separate the processing logic with thinner and simpler jobs
    - You can think of this as an assembly line where 1 box is passed down into another one down the line
  - **Configure spark.sql.shuffle.partitions**
    - Keep in mind that this number is less important if you have Adaptive Execution on (Databricks has this enabled by default, other platforms might not have)
    - There are 2 methods that you can call:
      - Repartition() allows you to change the number of partitions to a number that you want to. Causes shuffle.
      - Coalesce() allows you to reduce the number of partitions that you are working with if you have too many. If you go from 1000 partitions to 100 then there is no Shuffle but this only works when going down in the partition number
  - **Avoid calling collect() on the driver**
  - **Configure the memory settings of your cluster**
    - Executor or driver memory is what you want to look at
    - You want to avoid to ever spill data from jobs to disk
    - Spilling to disk can happened when the number of partitions is too low, memory setting is too low or there is data skew where one partition has way too much data
    - Fewer partitions the more memory you need because a partition is going to be bigger/contain more data
  - **Skew: Enabled Adaptive Execution**
    - Basically a silver bullet
    - Enabled by default in Databricks

### How to tell if your data is skewed?

- Most common is a job getting to 99%, taking forever and failing
- Another, more scientific way is to do a box-and-whiskers plot of the data to see if there’s any extreme outliers
- You can also do it by a GROUP BY and seeing if one key that you GROUP BY has way more data than the others

## Output file bottlenecks

![Lecture 2 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-2-6.png)

- Essentially the same as Input file bottleneck but in reverse
- **Solutions**
  - Think about the concurrency constraints of your output store!
  - Use COALESCE to minimize the number of output files
  - Iceberg file autocompaction solves the downstream issues of this

## Live Q&A

Q: What is the recommended partition size?

A: Around 100-200MBs per file.

Q: When we read one big parquet file, does spark read it parallely or serially?

A: Spark can automatically optimize for this by splitting the parquet file into multiple smaller files.

Q: What is the role of block size in Spark? The default is 128MB, how can we optimize that number for performance?

A: Do not feel the need to touch this, this was mainly relevant back in Hadoop days.

Q: Does Spark have built-in telemetry so you can notice it was the 250GB csv ingestion step?

A: Spark UI.

Q: How does databricks manage skewed data in the backend?

A: You can google AQE - Adaptive Query Execution and you can find a lot of technical details on this.

Q: Is it a good idea to do REST calls and use response data to load data to a graph database using Spark?

A: It is if that’s your only option. Better way would be to ingest the backend graph data by having the backend system write you CDC deltas, then dump them to Kafka and read the data from Kafka.

Q: When building a pipeline that populates from a REST API, do you just use Python requests or is there a better way to do this when using Spark?

A: Python requests fine for this case. There are a lot of headaches that you can get into when trying to parallelize REST API calls with Spark.

Q: Do you have any suggestions on how to use dynamic partition pruning in optimizations?

A: It's all in the DDL, you want to make sure you have your partitioning set up in the right way (on the right columns). Most of the time you just wanna partition by date, at times also on some low cardinality dimension if the dataset is big.

Q: How would you tune a near-real time/micro-batch pipeline with bursty inserts to a single table in an Iceberg table?

A: This will be covered next week on a Delta Live Table example.

Q: Do you partition only on one column (day) or are there cases to partition by 2+ keys (day, country)?

A: It depends a lot on the use-cases and if there are enough people that would benefit from having the additional dimension in the partition. Keep in mind that the additional partitioning key should ideally be low cardinality.
