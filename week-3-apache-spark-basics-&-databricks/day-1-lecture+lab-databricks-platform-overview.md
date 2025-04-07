# Databricks Platform Overview

**DE.IO Description:**

In this lecture, Yared delves into the intricacies of data architecture, focusing on the concept of lake house architecture, Delta Lake, and Databricks Data Intelligence. He breaks down the evolution from data warehousing to the innovative lake house architecture, highlighting the benefits and applications in real-world scenarios. We dive into the world of structured and unstructured data, the role of data lakes, and the integration of advanced analytics for a comprehensive understanding of modern data management.

## Main Topics for the lecture

- Lakehouse Architecture
- Delta Lake
- Data Intelligence Platform Overview
- Platform Overview Demo

## Lakehouse Architecture

![Lecture 1 What_Is_a_Lakehouse](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-1-what-is-lakehouse.png)

- **Data Warehouse**
  - Structured data only
  - Schema-on-write (data is structured before loading)
  - Optimized for data analysis
  - More expensive storage
  - Examples: Snowflake, Amazon Redshift, Google BigQuery  

- **Data Lake**
- A **cloud data lake** is a centralized repository that stores large amounts of raw, structured, semi-structured, and unstructured data
- In Databricks, the data lake typically resides in a cloud storage service (e.g., AWS S3, Azure Data Lake Storage, Google Cloud Storage)
  - All data types (structured, semi-structured, unstructured)
  - Schema-on-read (data stored in raw format)
  - Lower-cost storage
  - Can be messy and harder to manage
  - Examples: Amazon S3, Google Cloud Storage  

- **Key features:**
- **Scalability**: Cloud data lakes can store massive amounts of data.
  - **Flexibility**: You can store data in its native format (e.g., JSON, CSV, images, etc.).
  - **Cost Efficiency**: Cloud data lakes decouple storage and compute, which makes storage costs relatively low.  

- **Data Lakehouse:**
- The **cloud data lake** is the foundation for raw data ingestion and storage
- It allows you to perform batch or streaming data ingestion before processing and transforming it with Databricks.
  - Combines the best of both worlds
  - Supports all data types
  - Adds structure and data management features to data lakes
  - Enables both BI and ML workloads
  - Examples: Databricks Delta Lake, AWS Lake Formation

## Delta Lake

- Delta Lake is an open-source storage layer built on top of your cloud data lake
- It adds ACID transactions (Atomicity, Consistency, Isolation, Durability) and data management features to data lakes, making them more reliable for analytics and machine learning  

- **Key Features:**
  - ACID Transactions: Maintains data consistency during concurrent reads and writes
  - Schema Enforcement and Evolution: Ensures data integrity while allowing schema changes
  - Time Travel: Lets you query previous versions of your data
  - Performance Improvements: Enhances query speed through data compaction and caching
  - Support for Batch and Streaming: Handles both real-time and batch data processing in unified pipelines  
        <br/><br/>
- **In the Lakehouse Platform:**
  - Delta Lake serves as the core storage format, combining data warehouse reliability with data lake flexibility
  - It enables fast, direct analytics on the data lake

## Unity Catalog

- **Unity Catalog** is a unified governance solution for all data and AI assets in Databricks. It provides a **centralized metadata management and security layer** across your lakehouse platform.  

- **Key Features:**
  - **Centralized Governance**: Manage user access and permissions for all your data and AI assets.
  - **Fine-Grained Access Control**: Define permissions at the table, row, or column level.
  - **Data Lineage**: Track the origin and transformations of data, making it easier to debug and audit.
  - **Catalogs and Databases**: Organize your data into **catalogs**, which can contain multiple databases and tables.
  - **Cross-Cloud Support**: Manage data across multiple cloud environments seamlessly.  

- **In the Lakehouse Platform:**
  - **Unity Catalog** ensures that data governance and compliance requirements are met.
  - It simplifies **multi-tenant data access** and enhances security by providing a consistent governance layer for structured and unstructured data.  

- **Running Queries with Databricks SQL Execution Engine:**
  - The engine processes the query results, applies any transformations or aggregations, and returns the results to the user
  - When a query is executed, Databricks SQL first interacts with **Unity Catalog to:**
    - **Check permissions:** It ensures the user or group running the query has the appropriate access to the catalog, schema, table, or even specific rows/columns
    - **Retrieve metadata**: Unity Catalog holds metadata about the Delta Lake tables, such as table schemas, column types, and table locations in storage
  - Once permissions are verified and metadata is retrieved, the query is executed against the **Delta Lake tables**:
    - **Optimized Query Execution**: The Databricks engine performs partition pruning, Z-order indexing, and caching to speed up query execution.
    - **Read Data**: The actual data resides in the cloud data lake (e.g., AWS S3, Azure Data Lake Storage, GCS) in the form of **Parquet files** managed by Delta Lake.

Diagram of query flow:

1. **User Query** → 2. **Unity Catalog (Permissions + Metadata)** → 3. **Delta Lake (Data Access)** → 4. **Query Engine**→ **Results**

## Data Intelligence Platform

![Lecture 1 Data_Intelligence_Platform](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-1-data-intelligence-platform.png)

- The Data Intelligence Engine came about with the advent of Large Language Models that are getting integrated into every Data Platforms nowadays
- **Mosaic AI**
  - Data Science + ML + GenAI part of Databricks
- **Notebooks**
  - Allows you to write Python, SQL, R or Scala on top of Spark to run specific transformations
- **Databricks SQL**
  - Reporting part of the house - the Data Warehouse
- **Dashboards**
  - AI & BI Dashboards
  - Not a replacement for Tableau/PBI etc. but you can build simple reporting on top of this
- **Workflows**
  - Orchestration tool within Databricks
- **DLT - Delta Live Tables**
  - Abstracted part of Spark Streaming that uses declarative syntax

## Lab

### Overview

- Left Panel menu is structured based on different personas that might be using Databricks for their use-cases
  - Data Engineering
    - Self explanatory
  - SQL:
    - Playground Data Analysts
    - **Genie** is a way to input data into an AI assistance framework that is already abstracted and it basically allows you to talk to your data in natural language
    - **Alerts** serve as a way of notification/alerting system if the end goal is not about data processing. Can be used more so for monitoring KPIs to see if they deviate from expected values etc.
  - Machine Learning
    - **Experiments** offers low-code and no-code options to create and train various kinds of machine learning models based on your use-cases. Contains a lot of models for you to play with
    - **Playground** allows you to build AI framework Agent (RAG Agent) directly in Databricks. You pick a large language model from those available and then use Tools to Add Tools into the agent based on your use-case. Once built, you register it as a model (it will be saved in **Models**) and then deploy it in the Serving panel.

### Catalog

- Used for segregating Data and Users
- The hierarchy: Catalog -> Schema -> Tables
- Unity Catalog doesn’t govern only tables but also raw data (the files itself) which means you can restrict permissions also on file level
- Catalog also governs Machine Learning models, as well as ML functions
- It kind of creates documentation for you by reading metadata tables, column names, and schema

![Lecture 1 Catalog_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-1-catalog.png)

- For you to see sample data you need permissions
- History tab when viewing tables in Catalog allows great overview of operations on the table

![Lecture 1 Catalog_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-1-catalog-2.png)

- Lineage allows you to see how the table was created and also what are the upstream datasets created from this

### Compute

- **All-purpose compute** is shared by developers to do specific set of tasks
- **Job-compute** is used for building data engineering pipelines for running production workload
- **SQL warehouses** is for reporting search as already explained
- **Vector Search** is for creating vector database for your ML use cases

### Workspace

- Main playground for organizing work between multiple people etc.
