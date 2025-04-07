# Apache Spark Execution

**DE.IO Description:**

In this lecture, Yared dives into the Query Execution Engine and explores the different types of transformations in Spark SQL, specifically narrow and wide transformations. He provides examples to illustrate these concepts and discuss the importance of schema inference for performance. He also touches on how to configure clusters for optimal data processing.

## Main Topics for the lecture

- Query Execution Engine
- Types of Operations in Spark
- Narrow and Wide Transformations
- Schema Inference
- Cluster Configurations for Optimal Data Processing

## Query Execution Engine

- Spark SQL is Apache Spark’s module for working with structured data
- Query Execution plan flow: **1\.** Query Plan -> **2\.** Optimized Query Plan -> **3\.** RDDs -> **4\.** Execution

![Lecture 3 Query_Execution](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-query-execution.png)

## Operation types

- The main abstraction Spark provides is a resilient distributed dataset (RDD), which is a collection of elements partitioned across the nodes of the cluster that can be operated on in parallel
- Apache Spark RDD supports two types of Operations:
  - Transformations - Examples Filter, Union, GroupBy, and others
  - Actions - Examples include count(), collect(), show() etc.
- Transformations are lazy operations i.e. will not start the execution of the process until an Action is called
- Until an action is called the driver just eagerly evaluates the schema

## Transformations

- Narrow Transformations do not require data to be shuffled across the network
  - Examples include map(), filter(), and union()
- Wide Transformations require data to be shuffled across the network
  - Examples include groupBy(), reduceByKey(), sort(), distinct(), and join()

![Lecture 3 Transformations](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-transformations.png)

![Lecture 3 Transformations_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-transformations-2.png)

- Action executes all the related transformations to obtain the required data

![Lecture 3 Transformations_3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-transformations-3.png)

![Lecture 3 Transformations_4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-transformations-4.png)

## Schema Inference

![Lecture 3 Dataframe_Reader](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-3-dataframe-reader.png)

- It is always a good practice to explicitly define the schema for better performance purposes
- Each new Stage in a Job happens mostly when shuffle is necessary, but there are also other cases which would make Spark create a new job within a task:
  - Wide dependencies (e.g., joins, aggregations).
  - Actions triggering the need for stage boundaries.
  - Caching or checkpointing data.
  - Barrier execution mode or other synchronization points.
  - Optimizations in the DAG to allow for parallelism.

##

##

## Lab

**DE.IO Description:**

In this lab, Yared walks you through the basics of Spark SQL and the DataFrame API, highlighting how to create and interact with DataFrames. He explains the difference between transformations and actions, and how they affect job creation in Spark. He also emphasizes the importance of understanding narrow and wide transformations, as well as schema inference.

- Unless you trigger an action, Spark will only just eagerly validate the schema after running code where you only have transformations
- As dataframes in Spark are immutable and each new transformation requires creation of a new dataframe that is kept in memory for fault tolerance purposes, it is highly likely that you will run out of memory if you do not size your cluster correctly
- Wide transformation = you need to exchange data across multiple executors

![Lab 3 Spark_Jobs](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-spark-jobs.png)

- When you take a look at jobs that were triggered, the numbers that you see near the Stages mean how many cores were necessary to complete the job
  - I.e. **Stage 5 16/16 succeeded** means that 16 tasks were needed to run this job in Stage 5
- If we inspect the Spark UI by clicking on **View** near the Job 4 from the screenshot above -> Then on the **Link in the description of the Stage**

![Lab 3 Job_Details](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-job-details.png)

- And **Open** up the **Event Timeline** dropdown menu

![Lab 3 Spark UI](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-spark-ui.png)

- From the visual representation we can see that the 2 “Rows” mean that 2 cores were necessary for this Job, where each core triggered 8 tasks that were able to be ran in parallel
- In the Tasks menu displayed in the same view when you scroll down, you can see how much memory each Task took/required (**Input Size / Records)**

![Lab 3 Tasks](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-tasks.png)

![Lab 3 Tasks_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-tasks-2.png)

- During Wide transformations such as in the example below you can see that Spark skipped a certain stage, because it was not necessary as it was done already as a Part of the previous job (or/and was cached thus there was no need)

![Lab 3 Tasks_3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lab-3-tasks-3.png)
