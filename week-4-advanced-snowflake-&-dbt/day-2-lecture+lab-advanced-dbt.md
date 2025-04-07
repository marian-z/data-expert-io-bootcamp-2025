# Advanced dbt

**DE.IO Description:**

In this lecture, Bruno dives into advanced DBT concepts, focusing on Jinja, macros, and incremental models. He explains how to use Jinja for Python-like functionality in SQL and the importance of macros in creating reusable SQL code. He also discusses best practices for running DBT models, particularly the significance of selecting models to optimize costs.

## Main Topics for the lecture

- Jinja
- Macros
- Variables
- Incremental Models
- On-run-start & on-run-end hooks

## Jinja

- Jinja is like “using Python in SQL”
- With Jinja you can bring statements, expressions and comments to SQL
- Statements:
  - {%set = my_var %}
  - {% if condition %}, {% elif other_condition %}, {% else %}, {% endif %}
  - {% for item in list %}, {% endfor %}
- Expressions:
  - {{ ref() }} e {{ source() }
  - Used for calling macros among else
- Comments:
  - {# comment #}  

Example of Jinja in dbt:

![Lecture 2 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-1.png)

## Macros

- Macros are like “functions”
- You can also define default values in macros same as in python functions

![Lecture 2 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-2.png)

- Same as with functions you leverage this if you are doing some kind of operation multiple times
- This adheres with the DRY (Don’t Repeat Yourself) principle on which dbt is build
- Useful built-in macros:
  - log
  - run_query
  - dbt_utils.get_single_value
  - target
  - exceptions
  - adapter

## Variables

- You can set variables with {% set = my_var = 1%} like we mentioned above in the Jinja section
- But you can also pass variables through the CLI, or define them in the configurations

![Lecture 2 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-3.png)

- Passing variables in CLI is really useful i.e. when using dbt with Airflow to pass Airflow variables to your dbt models
- These CLI/config variables can be accessed through the var() function
- If we run the CLI command below, we have to have our model code set up as below
  - dbt run –vars ‘{event_type”: “activation”}’

![Lecture 2 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-4.png)

## Modules

- There are some Python packages you can use in dbt
  - datetime
  - itertools
  - pytz
  - re(regex)

![Lecture 2 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-5.png)

## Incremental Models

- Instead of recreating the table each time, you can load small amounts of data
  - Instead of CREATE OR REPLACE
  - You have INSERT / MERGE INTO / DELETE + INSERT / INSERT OVERWRITE / REPLACE WHERE
- The statement depends on the incremental strategy (which is how you define these DDL statements in dbt)
  - Append (INSERT)
  - Merge (MERGE INTO!
  - Delete+Insert (DELETE and INSERT)
  - Microbatch (new dbt v1.9)
- You can define dbt models configuration in 3 places: project.yaml, model.yaml file or model.sql file
- **is_incremental() macro**
  - Separates incremental from full refresh logic
  - You can have two logics in the same model
  - TRUE if:
    - materialized = ‘incremental’
    - the model already exists in the platform/DW
    - full-refresh flag is not used

![Lecture 2 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-6.png)

- The {{this}} variable is used to self-reference the model. It compiles to the same model where the code is running

![Lecture 2 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-7.png)

##

## On-run-start & On-run-end Hooks

- Allows you to run SQL queries before or after your dbt commands
- If you want to run commands before or after the run of specific models, you can use pre-hook and post-hook configurations

![Lecture 2 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-snowflake-&-dbt/images/lecture-2-8.png)

- On-run-end can be used i.e. for VACUUM query to optimize table size after running the model
