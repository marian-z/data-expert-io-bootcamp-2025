# dbt Basics

**DE.IO Description:**

In this lecture, Bruno dives into the importance of DBT for data transformation within cloud data warehouses like Snowflake and BigQuery. He discusses how the shift from ETL to ELT has changed the landscape, making it more cost-effective to store and process data. He also highlights best practices for using DBT and the challenges that come with it.

![Lecture 2 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-1.png)

- dbt is built on ELT approach of building data pipelines where the Cloud Data Warehouse and its compute is used to transform the data
- this is a new approach that developed with the advent of Cloud Data Warehouses due to the storage and compute now being a lot cheaper than before
- dbt connects to your Cloud Data Warehouse and helps you with the “T” transformation part of your pipeline
- **What is the problem that dbt wants to solve?**
  - Lack of testing and documentation
  - Easier to re-write stored procedures code than find or fix existing code
  - Analysts don’t know what to trust, hard to understand transformation code
  - Data Chaos

![Lecture 2 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-2.png)

## Pillars of dbt

- **Code Reigns**
  - dbt is SQL-first
  - data democratization
- **Software Engineering best practices**
  - Testing
  - Version Control
  - DRY code (Don’t Repeat Yourself)
  - Documentation
  - Others
- **Data Lineage/Dependency Management**

## What is dbt?

- A tool that enables anyone comfortable with SQL to work in transformation pipelines using the best practices in software engineering

![Lecture 2 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-3.png)

- A compiler: dbt compiles SQL code and sends it to your data warehouse to run it

![Lecture 2 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-4.png)

- With dbt the data does not leave your data warehouse - dbt does not store data and it has no compute power
- What dbt can do is what the Data Warehouse can do
- dbt code can be stored in your git provider for versioning
- There are 2 main ways of using dbt:
- **dbt-core**
  - free version of dbt
  - open-source code
  - all core functionalities (developing/testing/documentation)
  - python package (interact through CLI)
  - requires more knowledge
- **dbt cloud**
  - cloud-managed platform
  - runs dbt-core
  - more user-friendly
  - has its own IDE
  - handles complex features like CI/CD, RBAC, environments, notifications etc.
- dbt has a lot of adapters which are responsible for adapting dbt’s standard functionality to a particular database (BigQuery, Databricks, Postgres, Redshift, Snowflake, Spark, Starburst/Trino, MS Fabric etc.)
- At a higher-level, dbt Core adapters strive to give analytics engineers more transferable skills as well as standardize how analytics projects are structured.
- in January 2025 dbt made the acquisition of SDF company, which was one of its main competitors in the sector of bringing SE best practices to data engineering

## dbt project structure

- dbt projects are basically .sql and .yml files in a hierarchical folder structure

![Lecture 2 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-5.png)

- **Resources:**
- **Sources** (references to objects in your data platform)
- **Models** (SQL code that will create your objects)
- **Tests** (SQL code that will test your data)
- **Snapshots** (SCD type 2
- **Seeds** (CSV files)
  - with dbt it is not considered good practice to work extensively with CSVs
  - you want to mainly use them only for things like mappings etc.
- **Source and seed definition example:**

![Lecture 2 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-6.png)

- **Model example:**

![Lecture 2 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-7.png)

- Models are chunks of code that are materialized as an object in your DW
- SELECT statements only, the DDL/DML statements such as CREATE OR REPLACE TABLE etc. are handled by dbt “behind the scenes” when it compiles your code
- They can be written in SQL or Python (limited support)
- Models use Jinja (Python templating library that extends SQL possibilities)
- Models in dbt leverage Jinja functions that basically brings Python-like functionalities to SQL
  - {{ ref() }} and {{ source() }}: Jinja functions used for lineage and dependency management
  - You can create variables in your SQL code, create For Loops, do some more complex logic etc.

![Lecture 2 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-8.png)

![Lecture 2 0](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-9.png)

![Lecture 2 10](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-10.png)

![Lecture 2 11](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-11.png)

- One thing that is very handy that you can do with models is that via Governance you can define access to the models (which models can reference which models etc.)

![Lecture 2 12](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-12.png)

- Models can also have their own YAML file where you can define a lot of things

## Best Practices on Models

![Lecture 2 13](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-13.png)

![Lecture 2 14](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-14.png)

- Use CTEs

![Lecture 2 15](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-15.png)

## Problems/Challenges

- Streaming
- Hard to implement some best practices in dbt-core
- Over-reliance on the tool might lead to bad practices
- It can be hard to deal with custom DDL

## Useful commands

dbt debug: checks your DW connection, git connection and project file

dbt compile: compiles your project

dbt source freshness: checks the freshness of your sources

dbt run: runs models

dbt test: runs tests

dbt seed: runs seeds

dbt snapshot: runs snapshots

dbt build: all 4 above

dbt docs generate: creates documentation files

dbt docs serve \[--port &lt;port_value&gt;\]: generates a documentation static webpage

dbt show: shows a preview of your model’s data

## Lab

- profiles.yml and dbt_project.yml are necessary configuration files for running your dbt project and running _dbt debug_ command checks these two files for any errors

![Lecture 2 16](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-16.png)

- model-paths, seed-paths etc. configurations are just the name of the folders for models, seeds etc. You can rename then if you want to but it's not a good practice and almost everyone uses the default folder names
- **“models”** configuration at the end of the file/screenshot allows you to specify folder level configurations
  - With the configuration above dbt would know to materialize models as tables in the project, except for staging models where it would use views
- **name: “jaffle shop”** configuration at the top of the dbt_project.yml file provides a reference for dbt to know which profile to use for connection to the DWH from the profiles.yml file

![Lecture 2 17](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-17.png)

- packages.yml file contains extensions/plugins to extend your dbt functionalities

![Lecture 2 18](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-18.png)

- every time you are using dbt-core and are using some packages in the packages.yml file you have to install those packages by running **dbt deps**

![Lecture 2 19](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-19.png)

- sources are defined in a .yml file inside of models/staging folder
- you define the database, schema and tables
- you can specify tables metadata in .yml files such as stg_customers.yml
- you can configure freshness parameters specific or all tables to warn you or error out when running a model

![Lecture 2 20](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-2-20.png)

- as noted in the lecture, best practices in dbt recommend working with staging/intermediate/marts stages in the pipeline
- in staging it is recommended for the tables to be 1:1 to the source, with only minimal transformations
- intermediate layer is usually optional and depends on the complexity of your pipeline and on preference
- you can run your whole dbt project with **dbt build** which will run all the models, tests etc.
