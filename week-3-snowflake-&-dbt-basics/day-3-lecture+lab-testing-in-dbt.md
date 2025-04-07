# Testing in dbt

**DE.IO Description:**

In this lecture, Bruno dives into the functionalities of DBT, particularly focusing on its role in data transformation and testing. He discusses the importance of unit tests and data tests, explaining how they can help ensure data integrity and business logic. He also touches on the challenges DBT aims to solve, such as documentation and testing chaos.

- Tests in dbt are made for testing models to see if they are doing what you expect them to be doing

![Lecture 3 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-1.png)

- There are 2 types of tests in dbt:
- **Data Tests**
  - Audit tests
  - Run after your model is created
  - Test your assumptions about your data
  - You have to already have some data created so you can test it
- **Unit Tests**
  - Can be run before your model is created
  - Tests your SQL logic
  - Only supported for models

## Data Tests

![Lecture 3 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-2.png)

- Generic tests are made to be parametrized and reused for multiple models/cases
- Singular tests are very specific and tailored for specific models
- dbt has 4 built-in generic tests:
  - not_null
  - unique
  - accepted_values (enum test)
  - relationship
- There are plenty of other tests in packages developed by the community like dbt_utils and dbt_expectations
- You can store the tests failures in your database for debugging
- You can adjust the “severity” of your test (Error/Warning)

## Unit Tests

- By default run before your model gets created
- Requires inputs and expected rows
- Supports dictionary, csv and SQL (select + union all)

![Lecture 3 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-3.png)

- There are multiple ways/formats in which you can write expected data

## Summary

| **Unit Tests** | **Data Tests** |
| --- | --- |
| Test your **SQL LOGIC** | Test your **DATA** |
| Run **BEFORE** your model is materialized | Run **AFTER** your model is materialized |
| Defined in **YML** files | Defined in **SQL** files (Although they are written in SQL, generic tests must be added to a model’s YML config file to be applied to that model) |
| Currently **support only SQL** models | Available in **all versions** |
| Available from **v1.8** | Available in **all versions** |
| Input and Expected rows **written in ‘sql’, ‘csv’, or ‘dictionary’ format** | Can be **singular** (specific to a model) **or generic** (works for any model) |


## Tests Best Practices

- **Data Tests:**
- Generic
  - unique and not_null, accepted_values, sets and ranges, table shape (row count), etc. (dbt_expectations <https://hub.getdbt.com/calogica/dbt_expectations/latest/>)
- Singular
  - Business logic
- **Unit Tests:**
  - Complex JOINs/Filters, Regex functions, Incremental, Window Functions, Business logic

![Lecture 3 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-4.png)

## Snapshots

- Snapshots name is a bit misleading as in dbt they are the implementation of Slowly Changing Dimensions - Type 2

![Lecture 3 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-5.png)

![Lecture 3 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-6.png)

- Timestamp strategy uses the updated_at column for tracking slowly changing dimensions
- If you do not have the timestamp column (which is always preferred) you can use the Check strategy which checks the rows based on primary key definition and looks for changes
- Timestamp strategy is more efficient as it does not need to check everything if changes happened and knows this information from the updated_at column
- This is the old way of doing snapshots
- There is a new way of doing things that is very new as it came at the end of last year (2024)
- The new way of creating snapshots in dbt is by doing so in the .yml file configuration

![Lecture 3 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-7.png)

- The old version is still compatible for now before people get used to the new way of doing things (this might change in the future)

![Lecture 3 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-8.png)

## Snapshots Best Practices

- Snapshot source data
- Use the source function in your query (helps data lineage)
- Include as many columns as possible (you can’t add them later)
- Avoid JOINs in your snapshot query (makes it difficult to have a reliable updated_at column)
- Limit the amount of transformation in your query (logic can change in the future)

## Packages

- Packages are dbt ‘extensions’
- They can add models, tests, macros etc. to your project
- Some useful packages:
  - codegen: generates code
  - dbt_expectations: adds a bunch of tests
  - dbt_utils: adds tests and macros
  - dbt_project_evaluator: checks if your project follows best practices
- You can find more at <https://hub.getdbt.com/>

## SQLFluff

- Used for linting code
- Is a Python package
- Checks if your SQL code follows the defined rules
- Can fix the code

## Lab

- Adding generic tests for your models is really simple, you just go into the .yml model configuration file and specify **data_tests** for the column that you want to have tested

![Lecture 3 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-9.png)

- Adding other tests from packages is as easy, you just have to make sure you have dependencies installed via **dbt deps** command, specify **dbt_expectations.name_of_the_test** in the model .yml configuration and make sure you configure the test based on the documentation

![Lecture 3 10](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-10.png)

- To configure test severity (if it should be a warning or an error), you simply add the parameter/configuration in the model .yml file as below

![Lecture 3 11](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-11.png)

- **store_failures: True** configuration enables logging of test results and provides you the location where you can check this in the terminal after running the test

![Lecture 3 12](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-12.png)

- The **unique** test above would create a **UNIQUE_FACT_ORDERS_PAYMENT_METHODS** table in a **user_dbt_test_audit** schema where the data would show which fields were not unique and how many times they appeared

![Lecture 3 13](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-13.png)

- Creating custom generic tests can be done inside of **data-tests -> generic** folder, where the example of a test that would test for even numbers would look like the code below

![Lecture 3 14](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-14.png)

- It is important to keep in mind that the way testing works in dbt is that it catches Failing rows, which means you have to write your testing code that way
- As you can see for the example of is_even test it would mean that you would write a SQL code to catch rows/records that **are NOT** even
- Singular tests can be written simply in the **data-tests** folder

![Lecture 3 15](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-snowflake-&-dbt-basics/images/lecture-3-15.png)

- since it is a singular test meant for a specific model/table you don’t have to pass model and column_name arguments to the test but can reference the model directly
- You don’t have to add singular tests to the .yml configuration files, they are implemented automatically once created
