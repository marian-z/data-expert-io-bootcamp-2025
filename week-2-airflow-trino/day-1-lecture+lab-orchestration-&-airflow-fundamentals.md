# Orchestration & Airflow Fundamentals

**DE.IO Description:**

In this lecture, Zach breaks down the key aspects of orchestration, focusing on why it's crucial to understand the orchestration process for effective data engineering. He covers what orchestration isn't, the role it plays in data pipelines, and highlights common mistakes to avoid for smooth orchestration.

## Main Topics for the lecture

- What is orchestration?
- Where does orchestration go wrong?
- ETL best practices
- What is Airflow? And why?
- How to host Airflow

## What is not orchestration?

- ETL != orchestration
- CRON != orchestration
- Airflow != orchestration
- Dagster, Prefect, Mage != orchestration

## What is orchestration?

- The automations put in place to make businesses more money through data
- If you have pipelines that produce data that nobody uses you can actually cost the company money
- Orchestration is the higher level component not some specific tool
- Orchestration is the conductor in the orchestra that tells different parts of the troupe what to do to make the magic happen

![Lecture 1 What_Is_Orchestration](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-1-what-is-orchestration.png)

- **4 pillars of data orchestration:**
  - Collection
  - Transformation
  - Analysis
  - Save Cost / Produce Revenue
- Generally speaking you can skip some of these steps and kind of collapse them but the first and last step need to exist
- The main thing to remember is that we as data engineers are here to use data and information to make money and save costs and the sooner you learn how to get to a ROI the faster your value as a data engineer is going to increase

## Where orchestration goes wrong

### **Collection Phase**

- If you can solve any problem already at the collection phase that is going to be the best place to solve it and is going to save you a lot of headaches down the line
- **Bad/incomplete logging**
  - software engineers might have incomplete loggins or they might duplicate loggins
  - If the table with notifications already has 1 billion rows and suddenly grows to 300 billion rows that's going to be an issue for any event processing system downstream and for the compute needed to do so (big-ass inefficient GROUP BY statement required)
  - **fix: conversations with SWEs**
- **Schema change on APIs**
  - There are ways of how you can protect yourself as a data engineer against these changes which you can’t influence and we will discuss them later on
  - **fix: pre-checks**
  - Possible way would be to do a pre-call to an API before the actual data collection call where you verify that the API response contains all the relevant fields that we need
  - Also think about things like rate limits when calling an API etc.
- **Bad data modeling upstream**
  - [3rd Normal Form](https://www.geeksforgeeks.org/third-normal-form-3nf/) is your friend here
  - These things should be solved with a conversation not by a CASE WHEN
  - **fix: design docs and talking with software engineers which model the source data!**

### **Transformation Phase**

- **Fires too early**
  - Triggers without all the requisite dependencies which is a very common thing
  - **fix: partition/task sensors**
  - Partition sensors wait for the data to exist before running
  - Task sensors wait for a specific task to finish before running
  - At this point we are able to do things like cross-DAG task sensing which was not possible back a few years ago
- **Is not idempotent**
  - Pipelines that are idempotent produce the same results/data with the same inputs:
    - Regardless of the day you run it
    - Regardless of how many times you run it
    - Regardless of the hour that you run it
  - You can almost think of it as a mathematical function
  - Pipeline that are not idempotent are unpredictable and not consistent with their results
  - Pipelines that are not idempotent have these issues:
    - Backfilling causes inconsistencies between the old and restated data
    - Very hard to troubleshoot bugs
    - Unit testing cannot replicate the production behavior
    - Silent failures
  - **fix: a lot of things**
- **Logic bugs create bad data**
  - SQL/Python code related
  - Bad JOINs, CASE WHEN statements etc.
  - **fix: write-audit-publish**
  - Good suite of data quality checks against your pipeline data decreases drastically
  - Another way to do this, especially in Spark is by unit and integration testing
- **Transformation (ETL) Best Practices**
- Always wait for and process based on the logical date
  - {{ds}} in Airflow
  - Example: Pipeline that was supposed to run on January 1st got delayed and could be triggered only now. If we ran it with the execution date it would run for data as of today (January 15th) as opposed to the logical date which would still be the date when the pipeline should have run! This would cause a lot of problems with incremental backfilling.
- Design your pipelines to be backfillable and idempotent
  - Always process bounded windows
- Opt for INSERT OVERWRITE or MERGE when possible
  - Don’t use INSERT INTO without TRUNCATE/DELETE
- Use pre-checks for third party sources
- ALWAYS use the write-audit-publish pattern!
- Don’t fix in the pipeline what you can fix in the logs!
  - “When you have a hammer everything looks like a nail”

### **Analysis**

- **Pipeline breaks = slow analytics**
  - **fix: set reasonable SLAs**
  - SLA = Service Level Agreement which tells other people when can they expect the data
  - 95% of the time you should be able to meet your SLAs
  - Don’t be unreasonably strict with the SLAs and set them reasonably
- **Bad data = incorrect analysis**
  - **fix: blameless post-mortem**
  - Everyone needs to be able to calmly talk about the bad data experience and what can we all to do to make it work in the future
  - Be careful of both companies where people or the company itself bury their heads in the sand or on the other hand when people are just toxic and start pointing fingers
- **Duplicative metric definitions and pipelines**
  - **fix: better data modeling**

### **Save Cost / Produce Revenue**

- The most important step - the impact of your pipelines
- **Bad data = expensive mistakes**
  - Incomplete data might also be bad data so keep that in mind during decision-making
- **Duplicate pipelines = unnecessary costs**
  - Stop running expensive pipelines that bring no value or bring value but are not cost-effective
- **Delayed data = wasting analytics time**

## What is Airflow?

- Airflow is a **CRON-powered way** to build pipelines with Python
- Was developed initially at Facebook by Maxime Beauchemin under the name Dataswarm
- He then memorized the entire codebase, went to Airbnb and open sourced the code as Airflow
- Before Airflow there were not really that many great/reliable options with which you could not express a ton of more complex pipelines
- **Airflow components:**
  - **DAGs** \= pipelines
    - Defined in code
  - **Tasks** = pieces of a pipeline
    - Defined in code
  - **DAG runs** = one time the pipeline runs
    - Defined in data
  - **Task State** \= succeeded, failed, up-for-retry
    - Defined in data
- **Airflow hosting options:**
  - via Astronomer
  - GCP Composer
  - AWS managed Airflow
  - Yourself on EC2
  - Locally

## Live Q&A

Q: Is AWS Athena the same as Trino (except that it is AWS specific)?

A: Yes.

Q: What are the differences between Trino and Spark?

A: Trino when you need to query data directly from multiple sources without moving or transforming it extensively. Spark when the aim is to build complex ETL pipelines or perform extensive data transformations.

## Lab Notes

- DAGs folder is where you actually write python code and that is the core thing that you are building
- In today's lab we are going to write PySpark code for Airflow
- With Airflow you can use decorators to define DAGs
- Each DAG has to have:
  - A **name** which needs to be **unique**
  - **description**
  - **default_args** where start_date matters a lot for cumulative tables and DAGs (so it starts on a specific date and goes on sequentially from then)
  - **max_active_runs = 3** is a good practice to leave it at 3 for now to have some concurrency but be careful with this based on what underlying infrastructure you have
  - **schedule_interval** \- CRON interval which defines the schedule based on which the DAG should run (can also be noted as @daily, @monthly etc.)
  - **catchup -** if the start date is set to True it will fill out any runs in between the designated start date and the date where we wish to start it manually (e.g. if the start date is 1st May and we run it manually on 15th it will try to fill out the runs for dates in between)
  - **tags** \- to make it easier to find your dags. It is a good practice to use your name as a tag as well
  - **template_searchpath**
- anything in the “include” folder of the git repository is job related and glue_job_submission.py in the scripts folder enables us to run the DAGs against Iceberg tables in AWS (Tabular)
- **DAG definition** start with **def xyz_dag()** as in regular Python code with defining functions
- **DAG definition:**
  - Each DAG should have a **default_output_table** defined and we will comment on it later on
  - Each DAG is composed of its underlying **tasks**
  - The very first step of writing DAGs in this bootcamp is going to be to basically copy the first task in **backfill_pyspark_example.py** that uploads the script to S3 which is a requirement for this bootcamp that the script needs to be there
  - The idea behind **run_glue_job** task is that the python callable create_glue_job that keeps writing logs in the terminal until it succeeds or fails
  - Each task_id has its op_kwargs where you define the variables/credentials/etc.
  - When submitting DAGs the **“job_name”** kwarg in the run_glue_job task_id needs to include your name
  - **{{ds}} in “arguments” is what we have discussed in lecture with logical vs execution date**
- Astronomer (ASTRO CLI) is basically a managed Airflow service that allows you to orchestrate your Airflow DAGS in the cloud infrastructure and it also starts up your Airflow instance for you by running **astro dev start** in CLI (after having Astro CLI installed) it will spin up 4 docker containers on your machine (you need to have Docker Desktop running)
  - Container 1: Postgres - Airflow’s metadata database, storing internal state and configurations
  - Container 2: Webserver - Renders the Airflow UI
  - Container 3: Scheduler - Monitors, triggers, and orchestrates task execution for proper sequencing and resource allocation
  - Container 4: Triggerer - Triggers deferred tasks
- You can verify container creation with docker ps
- Access to the Airflow UI is through [http://localhost.8081](about:blank) and “admin” for both Username and Password
  - Note: Running astro dev start exposes the Ariflow Webserver at port 8081 and Postgres at port 5431. If these ports are in use, halt existing Docker containers or modify port configurations in .astro/config.yaml
- To stop the Astro Docker container run **astro dev stop**
- **TL;DR - Astro CLI Cheatsheet**
  - astro dev start # Start airflow
  - astro dev stop # Stop airflow
  - astro dev restart # Restart the running Docker container
  - astro dev kill # Remove all astro docker components
- For further instructions about debugging and **dbt setup** go [here](https://github.com/DataExpert-io/airflow-dbt-project)
- When we want to compare tables while backfilling we can do query like the one below to compare the data that we just backfilled to another table:
  - SELECT ‘new’ AS table_type, \* FROM schema.prod_table_backfill  
        UNION ALL  
        SELECT ‘old’ AS table_type, \* FROM schema.prod_table_example
  - This is a very common way to be able to view the tables side by side so we can see what records are new, which are updated etc.
  - We can then do summary statistics on this such as:
    - _SELECT table_type, some_column, COUNT(1) FROM (SELECT ‘new’ AS table_type, \* FROM schema.prod_table_backfill)  
            UNION ALL  
            SELECT table_type, some_column, COUNT(1) FROM (SELECT old AS table_type, \* FROM schema.prod_table_example)_
  - If we notice that some records are missing we can do a query such as this to compare and see which dates are missing
    - _SELECT table_type, some_column, COUNT(1), ARRAY_AGG(DISTINCT date) FROM (SELECT ‘new’ AS table_type, \* FROM schema.prod_table_backfill)  
            UNION ALL  
            SELECT table_type, some_column, COUNT(1) FROM (SELECT old AS table_type, \* FROM schema.prod_table_example)_

![Lecture 1 Lab_Results](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-1-lab-results.png)

- We can see that we are missing one day of data in the backfill
- In BigTech you usually don’t have a Staging environment. Everything is done in Production and works in a way that you have an overwriting “output_table” flag in your Airflow/Spark code which basically has a default table to which the airflow DAG writes but allows you to change the table to which you are writing directly in the command line when running the DAG. That means that you don’t write to the heavily used production table but to a different one which you then rename after it’s correctly backfilled and start using that one.
  - _astro dev run dags backfill -s 2024-05-20 -e 2024-05-20 backfill_spark_example_dag_ **_–conf ‘{“output_table”:”schema.prod_table_backfill”}’_**
