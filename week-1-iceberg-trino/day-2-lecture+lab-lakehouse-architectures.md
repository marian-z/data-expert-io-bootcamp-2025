Data Lake Architectures

**DE.IO Description:**

In today’s lecture, Zach dives into the world of data lake architectures, covering Iceberg, Delta Lake, and Hive. He highlights their key features, including the flexibility of file formats, transactional capabilities, and seamless integration with various platforms.

## Main Topics for the lecture

- Data Lake architectures: Agnostic Storage
- Data Lake Architectures: Lambda vs Kappa Architecture
- Data Lake Architectures: Hot vs Warm vs Cold Storage
- File compaction with Iceberg and single row updates

## Agnostic Storage

|                       | **Hive ACID Tables**                   | **Delta Lake**                             | **Apache Iceberg**                         |
|-----------------------|-----------------------------------------|--------------------------------------------|--------------------------------------------|
| **Who is Driving?**   | Hive                                   | Databricks                                 | Netflix, Apple, and other community members |
| **File Formats**      | ORC                                    | Parquet                                   | Parquet, ORC, Avro                         |
| **Transactional**     | Yes                                    | Yes                                       | Yes                                        |
| **Engine-Specific**   | Yes (only Hive can update)             | Yes (only Spark can update)               | No (Any)                                   |
| **Fully Open Source** | Yes                                    | No (performance and cloud support are not OSS) | Yes                                        |


- Agnostic storage means that you have a storage format that can be read anywhere - by any engine, from any source (Snowflake, Databricks, Confluent etc.)
- Both Spark and Trino work well with Iceberg, same as Kafka & Flink with Iceberg (since Iceberg solves append problems that Hive had previously you can now write directly to Iceberg tables)
- The main power of Iceberg is that it breaks silos by being able to be used anywhere thanks to being agnostic
- **TO DO: Look deeper into Shift-Left Paradigm**

## Lambda vs Kappa Architecture

### **Lambda**

![Lambda Architecture_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_lambda_architecture_1.png)

![Lambda Architecture_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_lambda_architecture_1.png)

- Standard architecture being used nowadays for Batch Analytics (Facebook, Netflix, Airbnb etc.)
- Lambda Architecture requires two code bases - one for batch and one for streaming data
- The advantage of having a batch pipeline like that is way easier data quality checks implementation
- Merge Access layer serves to provide a complete view of the data - both Batch and Stream
- How Lambda architecture deals with drawbacks?:
  - Batch pipeline does a “true up” step on a daily and hourly basis. The streaming pipeline only generates small files WITHIN a day or an hour
  - Data quality constraints are pushed to the batch pipeline which is way better at data quality

### **Kappa**

![Kappa Architecture_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_kappa_architecture_1.png)

![Kappa Architecture_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_kappa_architecture_1.png)

- Future State of Analytical Architecture
- You don’t do daily snapshots anymore
- Treats all data as events
  - How many times does data actually change during one day? In the previous version of the architecture you are basically pulling lot of the same data every day
- In the Kappa architecture any changes to the data are sent as events to Kafka/Event Queue
- How do you speed up a data pipeline?
- The answer is usually streaming, however that comes with a lot of complications and two major drawbacks:
  - Small files
  - Data Quality Checks - WAP, data contracts etc. are a lot harder to implement
- Both of these drawbacks are something that Iceberg is trying to address
- How Kappa deals with drawbacks:
  - Streaming pipeline generates small files. These files are compacted (by something like Iceberg)
  - Data Quality is done:
    - Simple checks in the streaming pipeline (anything that is related to a single row of data is quite easily doable - enumeration checks, NULL checks etc.)
    - Volumetric checks via observability tools
    - Complex checks later in the batch fact layer

## Iceberg Compaction

- Iceberg supports INSERT INTO, not just INSERT OVERWRITE (as opposed to Hive)
- This however creates the small file problem all over again
  - Logically more files should increase parallelism, however its a tradeoff between network overhead and parallelism
  - _Having a million cooks in the kitchen is not great, same as having only 1 cook in the kitchen is not great either_
- **There is a sweet spot - the optimal number of files for your job based on the data volume**

![Small_File_Problem](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_small_file_problem.png)

- **If you start thinking about the data in this physical layer level you will become much better data engineer because you can work on a layer lower than you usually do and make massive savings on cloud costs for the company (leverage compaction and read optimization techniques)**
- Tabular handles small files by using Automatic compaction
  - Any Iceberg table you create on Tabular has this automatically enabled
  - _“Automatically combine small files and apply the currently configured compression codecs and table write order. Compaction will attempt to produce files according to the configured target file size (default is 512MB)”_
  - Keep in mind that is only within the partition scheme - it will only merge/split files within a partition
- In Spark you can do this manually:
  - CALL system.rewrite_data_files(table=>’bootcamp.nba_player_seasons’)
- Things to consider when compacting datasets:
  - target-file-size-bytes (defaults to 512 MB)
  - Which strategy you should pick:
    - **binpack** (the default)
      - Straightforward file combining - looks at the file size of 2 files and if its under 512 it will go on and combine them
      - Very fast, efficient and cheap
    - **sort**
      - File combining AND sorting to leverage Parquet run-length encoding!
      - This is both good and bad, because you need some compute to sort the files - You need to consider the tradeoff between compute and storage here
      - You need to think of how the dataset is being used
        - Even if the compaction is better only by 15-20% but has 10 downstream pipelines that read from it and will benefit from the sorting then the compute needed to sort the dataset is worth it
        - **Think of the cost of compute vs savings on read**
      - You can use z-order like Delta Lake here as well!
- Row-level deletes/updates:
  - This became supported only in Iceberg 2.0 and higher
  - It allows for non-partition deletes
  - The snapshot stacking has two flavors
    - Copy-on-write
    - Merge-on-read
  - More detailed write up [here](https://www.dremio.com/blog/row-level-changes-on-the-lakehouse-copy-on-write-vs-merge-on-read-in-apache-iceberg/)
  - This is going to be one of the most important things in Iceberg in the upcoming years and being able to differentiate between these 2 strategies and leverage the best approach is what is going to set you apart
  - Copy-on-Write:
    - When a delete/update happens we copy the mutated data file over
    - You pay the cost on **WRITE** so that **READs** are fast
    - Really good for: Big batches of updates
    - Really bad for: Small batches of updates
      - Even if you have a few changed rows (i.e. 10MB) you still have to copy over the whole file that can be x times bigger. Thus the operation becomes a lot more expensive and that is why its not suitable for small updates
      - For big infrequent updates its worth considering using INSERT OVERWRITE to simply replace the file instead of inserting into it
        - When you are replacing more than 50% of the file then why not just overwrite it
  - Merge-on-Read:
    - Keep track of the deleted records, remove them on every read
    - You pay the cost on **READ** so that **WRITE**s are fast
    - Really good for: small, frequent updates
    - Really bad for: big, infrequent updates

## Hot, Warm and Cold Data

![Hot_Warm_Cold_Data](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_2_hot_warm_cold_data.png)

- The slower it is to get your data the cheaper is to store it
- Iceberg is essentially going to be the coldest data that you REGULARLY use - latency in the order of seconds to minutes
- Snowflake latency - milliseconds to seconds
- Postgres - great for high latency because it is single node
- Apache Druid - best dashboarding technology - almost always milliseconds especially if its pre-aggregated
- Redis - we are talking nanoseconds
- **Key takeaway: Iceberg should not power your applications or dashboards because it is too slow!**
- Iceberg is for analytics, analysts, machine learning, batch pipelines etc.
- Dashboard should be pre-aggregated and loaded into a low latency store
- For dashboards pick at least Snowflake
- **Week 1 Lab 2 content:**
  - Cover Iceberg file compaction with Spark
  - Compare binpack to sort, explore z-order
  - Look at how it impacts the Parquet files
  - Do a load and latency test between Trino and Snowflake

## Live Q&A

Q: What low latency store do big tech companies use to power dashboards?

A: Apache Druid.

Q: Snowflake external table vs Iceberg table on Snowflake? In what scenarios would you use external tables?

A: Never use External Tables. The performance sucks and there is no need as there are better ways.

Q: How does Tableau fit into this, as we’re speaking on dashboards and storage?

A: You can point Tableau to point to any dataset (Iceberg, Postgres or whatever) and have Tableau generate an extract and that is going to be the better way to do it. Do not have Tableau use something a live Trino query as the source because the dashboards are going to be slow as hell.

Q: Query engine doesn’t make up for the latency?

A: No, because it depends on the data store that is serving the data.

## Lab Notes

- Choosing the correct engine based on what you want to do with the data and how big is the data is crucial
- Rule of thumb based on the volume of data:
  - A couple of TBs up until let’s say 4TB - Snowflake & BigQuery will perform OK
  - 4-50TB - Trino is going to stump Snowflake and BigQuery here
  - 50TB+ - Basically only Spark for anything above this range
- It is an interesting trade-off because less scalable engines such as Snowflake or BigQuery have less latency which means better user experience for the data volumes you are working with
- A funny thing is that “If all all fails just use Spark but get the tuning right” is actually still true even after some years that Spark is around
- If you actually for some reason want to go ahead and build your dashboards on top of let’s say Iceberg and Trino then at least pre-aggregate the data so help with the dashboard latency
- If you want really lighting speed dashboards you pre-aggregate in Snowflake or Druid
