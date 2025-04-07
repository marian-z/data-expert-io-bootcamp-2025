# Change Data Capture (CDC) in Snowflake

**DE.IO Description:**

In this lecture, Bruno dives into the concept of Change Data Capture (CDC) and how it can be effectively implemented in Snowflake. He explains the importance of logging updates, deletes, and inserts, and how CDC can help manage high-volume data without slowing down the pipeline. He also touches on the use of streams and merging data to avoid duplication.

## Main Topics for the lecture

- What is change data capture (CDC)
- Why is the MERGE keyword so good?
- What is clustering?
- What are good candidate columns for clustering?
- How do you manage costs in Snowflake?

## What is CDC?

- When an update, delete or insert happens, it’s logged somewhere like a journal
- This is similar, but a bit more powerful than SCDs type 2 because you are tracking more information
- You can however have CDC that is done only daily and SCDs type 2 that happen more often so it all depends
- **How is CDC implemented in Snowflake?**
  - Change Streams in Snowflake
    - Example: CREATE STREAM changes ON TABLE bootcamp.table;
    - This creates a stream of deltas between now and the next time the stream is consumed
    - Considerations:
      - What do we do about multiple updates that happen before the stream is consumed?
      - What do we do about updates that aren’t captured in the data lake?
  - In API layer
  - Database Triggers

Change Streams in Snowflake example:

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-1.png)

PostgreSQL CDC implementation example:

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-2.png)

- This PostgreSQL example captures every delta
- Considerations to keep in mind:
  - Why are we storing analytical data in production?
  - How will this impact production’s performance?
  - How will this impact database connections?

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-3.png)

- API CDC implementation considerations:
  - What do we do about updates that don't happen through API?
  - How do we make sure this doesn’t impact API performance?

### CDC Summary table

| **Method** | **Pros** | **Cons** |
| --- | --- | --- |
| Change Streams in Snowflake | Extremely easy to set up | Can miss intraday changes<br><br>Data has to be in lake |
| In API layer | Most scalable<br><br>Logs changes to Kafka | Complex setup<br><br>Increase server response time |
| Database Triggers | Captures 100% of changes<br><br>Simple setup | Puts pressure on production database |

## Why is MERGE awesome?

- It handles all data mutations gracefully while maintaining idempotency

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-4.png)

- The larger your target table is the more compute heavy is the MERGE operation going to be
- MERGE is mostly used for dimension data where you are “more concerned” about data duplication

Sample MERGE syntax:

![Lecture 1 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-5.png)

**When you MERGE, make sure:**

- Target table is deduped on the MERGE key!
  - Non-deduped means non-deterministic and non-idempotent which makes Zach sad
- Handle all the cases!
  - ON MATCHED - usually means an UPDATE
  - ON NOT MATCHED - usually means an INSERT

## What is clustering?

- Snowflake does not support partitioning
- Clustering is how Snowflake can make large table queries more efficient
- Clustering tells Snowflake how to make the “micro partitions”

Databricks example:

![Lecture 1 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-6.png)

**What is query pruning?**

- Query pruning is Snowflake’s flavor of partition pruning
- Every micropartition stores metadata about what values are inside (similar to partitions folder names)

**More control doesn’t necessarily mean better!**

- Micropartitions in Snowflake can be better because of automatic reclustering based on query pattern
  - Reclustering is expensive though
- If you know what you’re doing Iceberg will get you 80-90% of the optimizations without reclustering and being much less expensive

**When should you cluster?**

- Treat clustering like creating an index, it’s faster but more expensive
- Clustering is useful in the following cases:
  - You need fast response times and cost is less of a concern
  - Query patterns generally access a small amount of data

## Good columns types for clustering

- Clustering on columns like:
  - Time-based columns like: Date
  - Low-cardinality dimensions like: Country, phone os
  - Entity-based columns like: User_id
- Bad candidates are:
  - Extremely low cardinality columns: booleans
  - Extremely high cardinality columns: nanosecond timestamps

## Managing costs in Snowflake

- **Snowflake charges you based on the time that a Warehouse is active:**
  - Suspend Warehouse after 1 minute of inactivity
  - Right-size your warehouse (the smaller the better usually)
- Make sure to respond to Cost insights alert from Snowflake which provides great tips

![Lecture 1 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-7.png)

- Keep in mind that Snowflake also charges you for storage, not compute only
- **Query:**
  - INFORMATION_SCHEMA.TABLE_STORAGE_METRICS
    - Absolute size of your data sets
    - How much data you are holding onto in time-travel
  - SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
    - How often are your tables reclustering?
    - What are the longest running queries?
    - What are the biggest IO queries?
- Offload cold data to Iceberg
- Sample data
- **Clustering:**
  - Can reduce query time
  - What you pay for automatic reclustering is usually much more than the query time savings though
- **Good retention policies:**
  - Time travel retention policy
  - Fail Safe Storage policy

## Lab Notes

- Below you can find a simple example of MERGE statement in Snowflake, which as you can see is basically the same as anywhere else

![Lecture 1 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-8.png)

- Below you can find example of queries that you could use either to CLUSTER a table by a specific column, or to check which column was used for clustering in a specific table

![Lecture 1 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-9.png)

- When clustering, it is generally better to have the lowest possible clustering depth
- As explained in the Lecture, clustering is an alternative in Snowflake to partitioning which you can’t do
- If you have your table clustered by correct key you can lower the amount of data scanned during query execution drastically
- You can use use Streams to create SCD type 2 tables in Snowflake as in the queries on screenshots below:

![Lecture 1 10](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-10.png)

![Lecture 1 11](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-11.png)

![Lecture 1 12](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-1-12.png)
