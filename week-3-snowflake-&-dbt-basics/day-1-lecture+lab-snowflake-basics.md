# Snowflake Basics

**DE.IO Description:**

In this lecture, Bruno introduces Snowflake and DBT, focusing on basic concepts like time travel, fail safe, and data types. He also discusses the differences between Snowflake and Databricks, emphasizing the ease of scaling in Snowflake.

## Main Topics for the lecture

- Why is Snowflake so popular?
- Snowflake vs Databricks
- Types of Tables & Views
- Time Travel & Fail-safe
- Cloning
- Structured/Semi-Structured Data Types

## Why is Snowflake so popular?

- Snowflake gives the power of distributed compute to SQL users in a very comfortable way
- Back in the day you had to write tens of lines of code of Hadoop MapReduce Jobs in order to leverage the power of distributed compute

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-1.png)

- Nowadays a simple SQL query on a distributed compute platform like Snowflake (or BigQuery) abstracts all of that for you
- Besides the code complexity the issue with Hadoop MapReduce were also rooted in the fact that MapReduce wasn’t optimized to work with in memory computing like Spark nowadays

## Snowflake vs Databricks

- The answer to “Which is better?” question depends a lot on your needs and use cases
- Snowflake is a very to use distributed data warehouse, while Databricks is a full featured machine learning data lake platform
- Snowflake is a lot easier to set up and to use which means you can get the value out of it a lot faster than from Databricks
- Databricks on the other hand provides a lot more features and can go more in depth
- Databricks is more oriented towards “advanced” data engineering with Spark, offers Machine Learning features etc.
- Apple vs Android is a good comparison here if you think about it - one is easier to use and more user friendly, while other might offer you to dive deeper into advanced features while maybe not being as user friendly

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-2.png)

- **Warehouse** in Snowflake is a bit unlucky name as it can get mixed and confused with Data Warehouse, however in Snowflake **Warehouse means your compute resources (clusters etc.)**
- Snowflake allows you to scale up and down your Warehouse/compute power really easily

## Time Travel and Fail Safe

- **Time Travel**
  - Restoring data-related objects (tables, schemas and databases) that might have been accidentally or intentionally deleted
  - Duplicating and backing up data from key points in the past
  - Analyzing data usage/manipulation over specified periods of time

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-3.png)

- **Fail-safe**
  - Data can be recovered by Snowflake after deletion
  - If you deleted your table intentionally and the time travel period already passed you can still recover it via fail-safe however you can’t do it yourself and have to contact Snowflake to do that for you

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-4.png)

## Types of Tables and Views

![Lecture 1 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-5.png)

- There are also other types of tables in snowflake, however these 3 types above are the most used ones when working with Snowflake + dbt combination

![Lecture 1 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-6.png)

- **External tables** allow you to work with data stored externally without ingesting them to Snowflake directly
- **Hybrid tables** are more suited for OLTP use cases where you have a lot of updates, inserts etc.
- **Dynamic tables** are a bit more advanced and you have to understand Tasks and Streams in Snowflake in order to work with them
- **Iceberg tables** are the newest addition to Snowflake that is getting widely adopted

![Lecture 1 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-7.png)

- **Non-materialized views** do not store the data anywhere and every time you select from the view you have to process the SQL query based on which it is built
- **Materialized views** store the data physically as opposed to non-materialized views and that is why they are faster, however they are not always up to date and you have to refresh them periodically
- **Secure views** can be both materialized and non-materialized
- **Secure views** can be used in a way that they only show a subset of a certain table to allow users see the data that we want them to see

![Lecture 1 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-8.png)

- Main distinction that can help you when thinking about differences between Materialized Views and Permanent Tables is that tables are used to store and manage data, while materialized views are used to optimize expensive queries

## Cloning

- Allows for the creation of independent copies without replicating the underlying data, eliminating the substantial storage costs and time usually associated with traditional data copying methods
- You can also clone other things in Snowflake such as databases or schemas, not only tables
- When you clone a table you clone the metadata so the data is not replicated
- A clone is a writable and is independent of its source, where changes made to the source or clone aren’t reflected in the other object
- However, if you make some modification to a cloned table then new partitions are created, incurring storage costs
- Cloning allows developers to create isolated development environments that mirror the production environment which is its main intended use-case
- They are good for Continuous Integration (CI)
- Easy Sharing and Backup

![Lecture 1 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-9.png)

![Lecture 1 10](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-10.png)

![Lecture 1 11](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-11.png)

- The main idea behind is to emulate production environment when developing

## Structured/Semi-Structured Data Types

![Lecture 1 12](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-12.png)

- **When to use Array?**
  - Array is great for ORDINAL data (think calendar, positioning, ranking, etc.)
  - Arrays are useful because indices can encode information without using additional bytes
  - Snowflake can do ARRAY\[VARIANT\], Iceberg is more strict
  - Snowflake is quite flexible with Arrays and Variants
- **Objects (Snowflake data type) can be:**
  - Semi-Structured (like JSON)
    - Every key is a VARCHAR, every value is a VARIANT (just like JSON)
  - Structured (like Iceberg Structs)
    - Every key is defined, every value is defined (cannot be semi-structured, or VARIANT)
  - Fundamental limit of Objects in Snowflake is that they can be max 16MBs which is much less than Iceberg
  - **When to use Object in Snowflake?**
    - Use semi-structured when you’re working with a data model that can change rapidly because it’s essentially JSON
    - Use structured objects when the data model has hardened more and you want more compression (vs higher level columns)
  - **When should you nest a column in an object/struct?**
    - If you nest a column in an object/struct it says one or more of the following:
      - These columns are rarely used
      - These columns are part of a connected family but used infrequently enough to:
        - not be high-level columns
        - broken out into their own table
    - Good example of when this could be used would be in an example of a restaurant business when you have a meals table
      - You could either have 20 columns such as Ingredient 1, Ingredient 2 etc. or just have 1 Object/Struct column for Ingredients
  - **When to use Map data type?**
    - Maps are a lot like dictionaries in Python, so you have a key and value pairs
    - Iceberg is less flexible, no VARIANT shenanigans
    - You can think of Iceberg here as Snowflake’s less flexible, slower cousin
    - When using map, keep it to one layer of nesting MAP\[VARCHAR, VARCHAR\]
    - If you need multiple layers of nesting, using semi-structured Object would be a better approach
    - Maps are great when you have rapidly changing requirements that can fit into MAP\[VARCHAR, VARCHAR\] similar to semi-structured objects
    - Maps compress better than semi-structured objects since they have stronger guarantees
  - **What is a VARIANT data type in Snowflake?**
    - Snowflake is very flexible about the data type of things
    - VARIANT is a “chameleon” data type, where it’s whatever data type you want it to be  

  - **The compression hierarchy**
    - The more specific the data type, the better the compression
    - Compression is good for compute time
    - In terms of compression rates the general rule is:
      - Structured Objects > Map > Semi-Structured Objects > Variant

## Lab

![Lecture 1 13](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-13.png)

- **Data** tab allows you to see the databases, schemas and its tables, views, UDFs etc.
- It also allows you to Add Data via various connectors

![Lecture 1 14](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-14.png)

- **Monitoring** tab provides details on query history runs, their statuses, users who triggered them, their duration, warehouse compute used etc.
- Besides this you can get the same monitoring view of Copy activities, Tasks etc.

![Lecture 1 15](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-15.png)

- **Worksheets** under **Projects** tab is where you can write your SQL queries
- You can create folders and structure your project/queries that way
- Besides that you also work in Notebooks

![Lecture 1 16](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-16.png)

![Lecture 1 17](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-17.png)

- Running queries is the same as in other tools such as BQ for example where you can see the query execution times, and other details
- Creating views/materialized views, CTEs etc. follows the same syntax as in other SQL dialects
- **To create Clones** you can simply use the keyword **clone** when creating a table with a SQL query as below:
  - CREATE OR REPLACE TABLE database.schema.table **CLONE** database.schema.table;
    - As you can see on the example above what is different from the typical SQL syntax is that there is no **FROM** keyword when you are not specifying columns but want to use a whole table clone

![Lecture 1 18](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-1-18.png)

- SHOW TABLES IN SCHEMA is a very useful query that you can use in combination with keywords such as “starts with” to look for specific tables in your schema
- The query also shows data like tables retention times, time-travel period etc.
