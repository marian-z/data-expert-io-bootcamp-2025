# Apache Iceberg and its place in History

**DE.IO Description:**

_In this lecture, we explore the evolution of big data processing technologies, starting with Java MapReduce, the impact of Hive, and the rise of Spark. Zach shares experiences from adopting Scala and Spark at Airbnb, discuss the power of Iceberg in data engineering, and how object storage technologies like S3 have changed the game. We also look at the benefits of Iceberg, its role in data restoration, and why partitioning strategies are so important for data engineers._

## Main Topics for the lecture

- Big Data History Lesson
- Iceberg

## Big Data in 2010

- The code to distributed computing was cracked with Java MapReduce so we could then process arbitrarily large amounts of data
- Keeping track of the data however was a huge mess and writing data pipelines was a huge pain for non-software engineers

## Brief History of Big Data

1. MapReduce birthed Big Data
2. Hive unlocked metadata & pipelines
3. Spark puts pressure on Hive
4. Spark crushes Hive (the execution model, not the Hive metastore)
5. Hive Metastore is king for 6-7 years
6. A new icy kid on the block - Apache Iceberg

## Hive

- MapReduce allowed Big Data to work but was truly complicated
- Hive was created at Facebook to solve the following problems:
  - Allow SQL big data pipelines to be translated into MapReduce
  - Manage the file metadata in the Hadoop ecosystem
- **_Hive is two things: a metadata layer and a MapReduce execution engine_**
- Hive was a smash hit, where it spread like wildfire at companies because data analysts and scientists could now write big data pipelines
- That however was not the greatest thing at times, because simply because everyone can now write pipelines does not mean that everyone should
- AirBnb in 2021 shifted and said **“pipelines written in HQL canot be gold standard”**
- NOT EVERYBODY WHO CAN WRITE SQL IS A DATA ENGINEER
- The requirements for pipelines at Airbnb to be considered gold standard were:
  - Has to be written in Spark
  - Must have data quality checks
  - Has to be scheduled with Airflow
  - Has to have good documentation
  - Has to have a business reason to exist
- Why was the Hive execution engine bad?:
  - It fell out of favor in 2016-2017
  - There was a new kid on the block from Berkeley - **Apache Spark**
  - Spark made Hive look slow, expensive and archaic
  - **The key differences are:**
    - Spark used memory for calculations where Hive used disk which was a huge problem for queries that used shuffle - JOIN, GROUP BY, ORDER BY clauses in queries.
      - Example from Zach: Query that took 9 hours in Hive suddenly took 10 minutes in Spark
    - Spark had more flexible APIs (DataFrame, Dataset and SparkSQL)
  - This is a thing in technology, where if a new technology is multiple times better than the older version it really quickly replaces the old technology
  - Hive metastore hung on as king longer than everyone it would initially
  - The usual paths from Hive metastore are these:
    - The Databricks Path: Hive -> Delta Lake
    - The Open Source Path: Hive -> Iceberg
    - The Less Traveled Path: Hive -> Apache Hudi
  - Why is Hive (the metastore) bad?:
    - No APPEND operation
      - Think of Hive like a set of folders, where Partitions are IMMUTABLE:
        - &lt;namespace&gt;/&lt;table_name&gt;/&lt;partition&gt;/data.parquet
      - A problem mainly for partitions where we can’t insert into a partition, the only option is to INSERT-OVERWRITE
      - Since partitioning is in the file path, the only way to repartition is by making a new table and moving the data yourself
      - It is not only a bad thing as it forced people to a “functional” data engineering
      - Iceberg allows for append
      - For batch it was not that huge of a problem, but it was the main reason for move to Iceberg for streaming use-cases
    - Very limited schema evolution support
      - Can add columns to the end
      - Can’t rearrange columns, can’t change data types of columns, can’t add partitions
      - Back in the day it worked so that you if you wanted to change a schema of a table you first had to make a new table and then you moved data from the old table to a new table (had to ETL it there)
    - Slow File List operation
      - Imagine reading 30 seasons of data which would require 30 file list operations
    - No “undo” or “time-travel” support
      - Iceberg supports time-travel

## Iceberg

- Iceberg was developed at Netflix in 2018 to overcome the limitations of Apache Hive (mainly time-travel and S3 file list) by Ryan Blue and Dan Weeks
- Initially Iceberg was pretty bad as it required your data to be sorted which as you can imagine can be a problem for 2PB/day pipeline = EVEN THE BEST TECH HAS PIONEER TAX
- Databricks paid 2 BILLION DOLLARS to hire Ryan Blue and Dan Weeks when acquiring Tabular (the data lake metastore that we will be using for this bootcamp)
- Databricks goal is to combine Delta Lake and Iceberg into a single open source standard so we can go back to the good ol’ Hive days when there was only one metastore
- It is more important to understand the low-level detail on why we are using either Delta or Iceberg rather than learning one or the other as they might merge anyway and the underlying concepts are similar
- Iceberg Architecture:

![Lecture 1 Iceberg Architecture](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-1-iceberg-trino/images/lecture_1_iceberg_architecture.png)

- - Every schema and data mutation creates a new “snapshot”
    - That enables TIME TRAVEL and removes the fear of accidentally deleting
      - SELECT \* FROM table$snapshots
      - The pointer is always the latest version
      - You can also think of this kind of like Git for data in your tables
      - Query after insert but before the update: SELECT \* FROM table FOR TIMESTAMP AS OF TIMESTAMP ‘2022-09-03 09:45:01.005Z’
      - You can check i.e. what records were deleted by CROSS JOINing older version of table with the latest version
    - Almost every table should be partitioned on date, because almost all other dimensions can change over time
    - The only exception to partitioning can be small dimension tables that are not slowly-changing
    - Good partition candidates:
      - Timestamp or date stamp (in 95%+ tables)
      - Low cardinality dimensions (to increase partition pruning)
        - Might be useful in case of a table at the end of the pipeline that analysts are going to query - i.e. notifications table where there are 4 main types of notifications etc.
        - Country is on the edge of whether it is a low cardinality data and if we should partition on it - mostly not
    - **95% of tables in big tech are partitioned on “ds” which is the date stamp of the pipeline run that generated it**
    - **Fact data should be partitioned based on when it happened**
    - **Dimension data should be partitioned based on the snapshot (snapshot date on when you pulled in the data from the source)**
    - Hour/Date/Week/Month/Year are good partitioning candidates, anything lower such as Minute is bad
    - **Difference between Delta and Iceberg at the moment is that in Delta you can only partition on a column that is already in the table, and not on a transformed column such as i.e. in the query below:**
      - CREATE TABLE orders_iceberg (order_id BIGINT, order_name VARCHAR, transaction_dt TIMESTAMP) with (partitioning=ARRAY\[‘day(transaction_dt)’\])
    - Zach’s idea of a good engineering - good engineering should be explicit not implicit
- **Week 1 Lab 1 content:**
  - Partitioning deep dive
  - Time Traveling for root cause analysis
  - Deep Dive into Iceberg metadata tables

## Live Q&A

Q: What is Trino?

A: Trino is a distributed compute engine, something like an opensource version of Snowflake.

Q: What are some of the downsides of hidden partitioning you have faced while working with Iceberg?

A: Generally you should be able to look at DDL and see what the table is partitioned on, where in Iceberg this can not be the case.

Q: What is good practice for clearing partitions? What is the cadence? How does that affect companies who face compliance requirements for data retention?

A: Depends on company privacy policies. Some companies might have more strict policies.

Q: Databricks encouraged us to avoid partitioning because of this new thing called liquid clustering- should we still be partitioning?

A: You should still be partitioning + liquid clustering is a solution for high cardinality columns.

Q: Is there a limitation on concurrent writes to an iceberg table?  
A: Probably, look up documentation just to be sure.

Q: Where is the metastore for iceberg tables, is it similar to delta transaction logs in delta tables?

A: Meta data is in the tables itself and delta transaction logs and iceberg snapshots are very similar.

Q: Are there datasets too small to be worth using iceberg vs redshift or postgres?

A: Not really. The main point is to have all the data in one place - i.e. Iceberg.

Q: Would you consider using Iceberg for things like “single view of customer” for Customer Service and similar teams (i.e. need to see non-aggregate customer data with sub-second retrieval times). Or is this just “put it back in Postgres”?

A: Definitely not Iceberg for this. Iceberg uses S3, and S3 is a file store and file store is considered high latency.

**Examples:**

Low Latency & Expensive: Redis

- Blazing fast look-ups

Medium Latency & Expense: Postgres, Snowflake

High Latency & Cheap: S3, Iceberg, Trino, Spark
