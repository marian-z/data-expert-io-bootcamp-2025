# Advanced dbt pt.2

**DE.IO Description:**

In this lecture, Bruno dives into advanced techniques for running DBT projects, particularly focusing on integrating with Airflow. He discusses the importance of selecting specific models and the implications of running stale data. He also covers the benefits of using CI/CD for testing changes in isolated schemas to avoid merging bad code.

## Main Topics for the lecture

- Advanced Pipelines
- How to run dbt with Airflow

## (Not) Advanced Pipelines

- Regular Refresh (runs and tests your whole project)
  - dbt build
- Partial Regular Refresh (runs and tests part of your project)
  - dbt build -s &lt;some selection method&gt;
  - Examples:
    - dbt build -s ‘tag:my_tag’
    - dbt build -s ‘source:my_source+’
    - dbt build -s +fact_orders
- There are other selection methods that you can look at in the official documentation to only select distinct models to run
  - I.e. all models that are incremental
  - all models that belong to specific folder (staging etc.)

## Advanced Pipelines

- Source freshness runs enable us to run models only when there is new(fresh) data in our sources
  - dbt source freshness
  - dbt build -s source_status:fresher +
  - You first run the “dbt source freshness” command to check the source freshness and then the second command to only run models where the sources have fresh data compared to previous run

![Lecture 3 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-1.png)

### WAP Pipelines in dbt

![Lecture 3 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-2.png)

- Be careful here because Staging means something different in the context of WAP and in the context of dbt
- In order not to confuse it we can call WAP “staging” as an “audit” table
- WAP in dbt:
  - Write: dbt run -s audit_table
  - Audit: dbt test -s audit_table
  - Publish: dbt run -s production_table
- dbt build does everything at once

### CI/CD in dbt

- CI/CD = Continuous Integration/Continuous Deployment
- You can configure github actions to build your project and see if everything is fine
- CI: build modified models in a test schema when a PR is created
- CD: build modified models in prod schema when code is merged into main
- To run only the models that you modified you can run the command below:
  - dbt build -s ‘state:modified+’ –state /path/to/artifacts
- Everytime you run dbt it creates a file “manifest.json” which keeps the artifacts (what changed etc.) that are useful for running state:modified commands etc.

![Lecture 3 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-3.png)

## Running dbt with Airflow

- **Bash Operator**
- The old way to run dbt in Airflow
- Uses the bash operator to run commands the same way you run dbt commands locally
- Each task is a dbt command
- **Cosmos**
- Built to simplify the dbt Airflow integration
- Has dbt operators
- You have a better lineage view in the Airflow UI
- Each task is a dbt model (or a test, or a seed, etc.)
- In dbt cloud you can orchestrate your dbt jobs without Airflow as it haves its own orchestrator

**Comparison Table**

| **Bash Operator** | **Cosmos** |
| --- | --- |
| Harder to identify problems | Easier to identify problems |
| Inefficient retries | Efficient retries |
| Faster DAG generation | Slower DAG generation |
| Fewer Workers (saving resources) | More Workers (spending resources) |

### BashOperator

![Lecture 3 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-4.png)

- You can create separate BashOperators so you have task specific to a single model however this can quickly get out of hand as your project grows

![Lecture 3 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-5.png)

### Cosmos DbtDag

![Lecture 3 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-6.png)

- The syntax is a bit strange compared to how you do it with BashOperator however once you get the hang of it its way better than running dbt with BashOpetaror
- With DbtDag you can’t have a pre- or post- dbt workflow as its a closed DAG
- You can however use DbtTaskGroup to do that
  - This is why DbtTaskGroup is used a lot more often than DbtDag

## Lab Notes

- In our audit tables we generally want to test only the latest “added” data, especially when we are dealing with some huge fact tables or in general for tables where we have already tested the previous data
- You can use “dbt compile -s name_of_dbt_model” which compiles your model code so that you can see how it will look like when you actually run the model
  - This is extra useful when you want to double check your ref{{}} notations, how your variables are translated to SQL etc.

![Lecture 3 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-3-7.png)
