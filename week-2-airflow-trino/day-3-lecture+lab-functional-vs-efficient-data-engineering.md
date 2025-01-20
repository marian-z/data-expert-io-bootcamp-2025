# Functional vs Efficient DE & Cumulative DAGs in Production

## Main Topics for the lecture

- The battle between Functional and Efficient Data engineering
- Cumulative Table Design
  - Why it matters
  - How it works
  - What are the drawbacks
  - How it relates to slow-changing dimensions
- Cumulative table/DAG design is quite polarizing in the Data Engineering community and some people swear by it while others absolutely hate it
- Today we are going to cover the arguments for both sides to better understand it’s advantages and drawbacks

## Functional DE vs Efficient DE

- **Efficient Data Engineering = SCDs and Cumulation**
- What should you pick?
  - Is it better to make purely idempotent and functional pipelines?
  - Or efficient and compact pipelines that are harder to reproduce?
- SCDs are slowly-changing dimensions that have a list of start dates and end dates of each dimension. They are a mutation that you have to apply to the data
- It is not necessarily needed as you can have all the snapshots of what the dimensions were at that date
- On one hand you have the Efficient Data Engineering which cares about minimizing the memory footprint (storage) and cloud compute but produces pipelines that are harder to reproduce
- On the other hand you have Functional Data Engineering that is built on the idea of having simple pipelines that are purely idempotent and functional which means they are more predictable and always return the same outputs with the same inputs, plus keeping the cost low by having the pipelines easy to reproduce and thus save engineering time/costs. This however comes at the cost of some additional storage and cloud compute.
- **Functional pipelines:**
  - Are easily backfilable
  - Easily reproducible
  - Contain data duplication (especially on the snapshotting side)
    - This is why the SCDs were created to solve this
- Dimensional data by itself is not that big to begin with, so that is where the argument between SCDs and Snapshotting comes up
- **Efficient (SCD + Cumulation) pipelines:**
  - Compact
  - Minimize data duplication
  - Hard to recreate, error prone
- **What is more expensive:**
  - Paying a little more in the cloud to Jeff Bezos or Engineering time and maintenance time?
- **Just like with most things in data engineering - IT DEPENDS!**
- Airbnb went back and forth between functional and efficient data engineering
- The argument for efficient data engineering is often due to the fact that it’s easier to measure your cloud costs vs the engineering and maintenance time
- It feels like most Big Tech companies tend to gravitate towards efficient data engineering due to this reason

## ED - Cumulative Table Design: Why does it matter?

- The best predictor of future behavior is past behavior
  - Your toxic boyfriend is **probably** going to stay toxic in the future
  - Those active users are **probably** going to stay active in the future
- The problem that we run into is that THE PAST IS GIGANTIC
  - Although your spouse remembers the mean thing you said on November 13, 2014 at 3:13 PM because their brain LEVERAGES CUMULATIVE TABLE DESIGN which enables them to BRING IMPORTANT PIECES OF THE PAST INTO THE CURRENT PARTITION OF THE DATA.
- **Example: User Growth at Facebook**
  - How many actions does the average Facebook user take each day?
    - ~50
    - 50 \* 2 billion users = 100 billion rows per day
    - 100 billion rows \* 365 days = 36 trillion rows per year
  - Usually, especially in Big Tech the Fact data is extremely big
  - **My note for the numbers above**: _It seems to me a lot like the efficient vs functional data engineering depends on the volume of data you are dealing with where with low volumes you could get away with functional data engineering pipeline design that recomputes all of the history each day/run_

| **user_id** | **event_time**          | **action** | **date**     | **other_properties**               |
|-------------|-------------------------|------------|--------------|-------------------------------------|
| 3           | 2023-07-08T11:00:31Z   | like       | 2023-07-08   | {“os”: “Android”, “post”: 1414}    |
| 3           | 2023-07-08T11:00:31Z   | comment    | 2023-07-09   | {“os”: “iPhone”, “post”: 111}      |
| 3           | 2023-07-10T03:33:11Z   | comment    | 2023-07-10   | {“os”: “Android”, “post”: 3434}    |


- Imagine running a “yearly active users query”
  - SELECT COUNT(DISTINCT user_id) AS yearly_active_users  
        FROM user_actions  
        WHERE ds BETWEEN ‘a year ago’ AND ‘today’
- **The query would need to scan 36 trillion rows and make you cry**
- 1 to 10 billion rows Spark can handle without bigger issues
- 10 to 100 billion rows you have to start thinking about memory tuning
- 100 to 1 trillion rows your life becomes a living hell
- \> 1 trillion rows = pure suffering
- Think about how unbelievably expensive would the query above be in terms of the cloud compute
- There are so many different approaches to this, where sampling could be an interesting debate to have in this context however it all comes down to your use cases (how exact the number needs to be)
  - If the number is reported to Wall Street it would probably not be a wise idea to sample
  - If it is for the context of some Analysts experiment then sampling could be a way to go here
  - As with everything, it depends a lot on the use case
- **Maybe we could aggregate daily?**

| **user_id** | **metric_name** | **date**     | **value** |
|-------------|-----------------|--------------|-----------|
| 3           | likes_given     | 2023-07-08   | 34        |
| 3           | likes_given     | 2023-07-09   | 1         |
| 3           | likes_given     | 2023-07-10   | 3         |


- This is going to make a dramatic difference in size of the dataset
- That would reduce it: 36 trillion / 50 average user actions per day = 720 billion rows
- **Now the query would probably run (Trino probably, Spark for sure), but still slowly**
- **Long-Array Metrics example**
  - What if we preserved daily values in a month or year?

| **user_id** | **metric_name** | **month_start** | **value_array**                                                                                   |
|-------------|-----------------|-----------------|---------------------------------------------------------------------------------------------------|
| 3           | likes_given     | 2023-07-01      | \[34, 3, 3, 4, 5, 6, 7, 7, 3, 3, 4, 2, 1, 5, 6, 3, 2, 1, 5, 2, 3, 3, 4, 5, 7, 8, 3, 4, 9\]       |
| 3           | likes_given     | 2023-08-01      | \[34, 3, 3, 4, 5, 6, 7, 7, 3, 3, 4, 2, 1, 5, 6, 3, 2, 1, 5, 2, 3, 3, 4, 5, 7, 8, 3, 4, 9\]       |


- The array metrics are great in the sense that they can be built incrementally and you can add each day as it comes in
- This array dataset actually still keeps the daily granularity
- Using this approach the dataset would shrink as so:
  - 36 trillion / 50 / 30 = 24 billion rows (monthly arrays)
  - 36 trillion / 50 / 465 = 2 billion (yearly arrays)
- **The query would probably run quickly now**
- This was the framework that Zach came up with while working in Facebook when the first ever decline in user growth happened
- Data Scientists were sure that it was a “slow-burn” that happened over time
- Data Engineering was tasked with coming up with a metric framework that would allow Data Scientists to play with metrics over decades quickly
- **The past is really big but if you are careful with what you surface from the past then you can work around it**
- The arrays in this approach were built incrementally where each day a new record was added to the array
- This changed the analysis pattern for Data Scientists/Analysts because if you wanted to do a decade long analysis on this data you can go with the yearly array pattern that still produces only 20 billion rows. Keep in mind that you still have user_id there so you can do a lot of joins on this data such as what was their primary user device etc.

![Cumulative_Table_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-3-cumulative-table-design-1.png)

![Cumulative_Table_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-3-cumulative-table-design-2.png)

- You have 2 tables: today + yesterday (yesterday already has the array in it)
- You coalesce your **user_ids** because if you FULL OUTER JOIN the tables one of them is going to have a user_id in it
  - When yesterdays user_id IS NULL and today’s user_id IS NOT NULL then that means its a new user
  - When yesterdays user_id IS NOT NULL and today’s user_id IS NULL then that means that it means that it is user that was not active today
  - When they are both NOT NULL that means that the user was active in the past and also today
- Then you have the nasty ARRAY construction
  - If the y.user_id IS NULL then it means that the user_id is NEW and you want to build a new array
  - When t.user_id IS NULL then you want to APPEND 0 to yesterdays data array
  - Otherwise it means that the user was active today and also yesterday and we need to APPEND their todays data to already existing yesterdays event_count array
    - You can do it both ways - append at the beginning or at the end of the array
    - **My note**: Seems to make more sense to load it backwards to have the values go from 1 to 31 like the days in a calendar
- You can then also do life_time_metrics where you just add up what is available
- **In Airflow, you HAVE to set:**
  - depends_on_past = True
    - Pipeline won’t run until yesterdays was successful
    - When at the beginning it was mentioned that cumulative table designs are not good for backfilling this is what was meant. As the data depends on the past (you have to set it up that way in Airflow otherwise it won't work) you can’t parallelize the backfill runs
    - This pipeline has to run sequentially which is probably the Cumulative Table Design’s biggest drawback
    - Cumulative Table Design runs have a “seed” run which is the first run of the pipeline, otherwise you could go all the way to the big bang (or to the beggining of your available data)
  - max_active_runs = 1
- **Cumulative Table Design Drawbacks:**
  - The “seed” run is awkward
    - If you have your partition sensors set up right then today's run will always have previous data that it's dependent on. You have to start somewhere.
  - The dependence on “yesterday” means we can’t backfill efficiently
  - We add additional calculations based on how we add things to arrays. NULL vs 0 gets trickier here
    - User showed up but did nothing vs the user didn’t show up is different.
  - We bring history forward. EVEN FOR DELETED USERS. You need to actually think about removing them.
    - In the other way of modeling data it is much easier to delete user data
  - One of the drawbacks can also be that you need to teach your Analysts and Data Scientists how to efficiently query this

## Cumulation & Slowly-Changing Dimensions

- Generating SCD TYPE 2 and Cumulative Tables is done in the exact same way
- If you think about it from SCD perspective
  - You have your first snapshot (yesterday's data)
  - Then you compare the first snapshot with next snapshot (today's data) and you look at what changed
  - Anything that changed you add a new row
  - Then you continue this cycle all over again
- SCDs are cumulative

![SCD_Type_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-3-scd-type-2.png)

## Live Q&A

Q: You mentioned handing off cumulative table design to a data scientist. Would a ML engineer treat an array as a singular feature or break that back out into multiple features for training?

A: It depends on the model.

Q: Why would you choose an array with the number of interactions instead of a dict with the days as keys and the numbers as the values?

A: A dict is not really space efficient because it stores the key as well. They both work pretty well though.

Q: What are some of the data quality tests you can write specifically to test if the cumulative table is created correctly after each pipeline run?

A: Part of that is you want to do JOINs with yesterday's data on today's data where the yesterday's data is already appended so that you can check that it is all there.

Q: How did you handle deleting data to maintain user privacy, for example if a user doesn’t want their record in the system?

A: There are 2 ways to go about it. First one would be to do the cumulation on anonymized data, the second one being to do anonymization on the accumulated data. In Facebook what they did was not pulling PII data at all which is the first example.

Q: If we do not have any array type metrics, how does union and dedupe by window functions perform vs a full outer join in cumulative table design?

A: If you are not building any array metrics you probably want to use window functions with LAG() and stuff.

Q: I understand the reason for using arrays due to storage, but how do you handle users who joined in the middle of a month/year?

A: The sign up date for the user was stored. Then based on that you would know that for example for users that joined on 15th you would add in 15 0s in the array. You want to have all the users have all the values in the arrays.

Q: How do you make this cumulation idempotent when running for a day in the past? Do we need to add some temporary aspect to the query?

A: You have to start over and rebuild it from the beginning. This question is literally one of the main pain points of this whole pattern. This is something that you need to be very careful about.

Q: For historic backfilling - can we like partition the users and window them with row_number and then go row over row with cumulating them. This way we may not need to go day over day and increase parallelism.

A: Yeah you can do that with GENERATE_SERIES(). Or by SEQUENCE in Trino.

Q: Isn’t cumulation idempotent by default? The data for yesterday is the same and the data available today is the same, when we do a cumulation shouldn’t it be the same?

A: Yes and no. Because of that dependency tree it is not that functional and has these state mutations in it. Output from yesterday is the input for today so its like a big snake. In the more traditional functional way of doing things the output of today has no bearing on input of tomorrow.

## Lab

- The goal of today’s lab is to dive deeper into Airflow DAGs code and inspect/create a cumulative DAG
- In order to do this we are going to leverage 2 DAGS:
  - 1) **aggregate_dag.py**
  - 2) **cumulate_events_dag.py**
- The DAGs are composed of these tasks:
  - 1) **aggregate_dag.py**
    - **wait_for_web_events**
      - task that uses poke_tabular_partition python callable code from Lab 2 that keeps checking for the partition in a specific table until the partition date = DAGs logical date {{ds}}
    - **create_production_step**
      - task that uses execute_trino_query python callable from Lab 2 and runs a DDL statement to create a production table
      - The DDL statement is CREATE TABLE IF NOT EXISTS to make sure this task runs correctly even after the table was created in the DAGs first run
    - **create_staging_step**
      - task that also uses execute_trino_query python callable from Lab 2 and runs the same DDL CREATE TABLE statement but appends the logical date {{ds}} to the end of the created staging table name
    - **clear_production_table**
      - task uses execute_trino_query python callable and runs a DELETE FROM statement against the production table from which it deletes the partition of the data that is equal to the logical date (WHERE ds = DATE('{ds}'))
    - **clear_staging_table**
      - same as the clear_production_table task above, this task uses execute_trino_query python callable to execute the same DELETE FROM statement but this time against the staging table
    - **load_to_staging_step**
      - We load the data first into the staging table as a part of the WAP data quality process
    - **run_dq_check**
      - We run custom DQ checks to make sure the data is production ready
    - **exchange_data_from_staging**
      - If the DQ task passes we run INSERT INTO statement into the production table FROM the staging table
    - **drop_staging_table**
      - At the end we run a statement to DROP the staging table
      - During the next DAG run the table will be recreated again
  - 2) **cummulate_events_dag.py**
    - **wait_for_web_events**
      - Task uses the same poke_tabular_partition python callable but in this case it checks the partition in the user_web_events_daily table which is the output table from the previous **aggregate_dag.py DAG**
    - **create_step**
      - We create the production table with execute_trino_query python callable and CREATE TABLE IF NOT EXISTS DDL statement
    - **clear_step**
      - We clear the production table to make sure the DAG is idempotent by leveraging execute_trino_query python callable and DELETE FROM production table with the condition that deletes the partition of the data that is equal to the logical date (WHERE ds = DATE('{ds}'))
    - **cumulate_step**
      - Task that runs the main cumulation query that INSERTS new data into the production table
      - The query used for this:
        - 'query': f"""  
            INSERT INTO {production_table}

            WITH yesterday AS (
            
            SELECT \* FROM {production_table}
            
            WHERE ds = DATE('{ yesterday_ds }')
            
            AND academy_id = 2
            
            ),
            
            today AS (
            
            SELECT user_id, academy_id, MAX(event_count) as event_count
            
            FROM {upstream_table}
            
            WHERE ds = DATE('{ds}')
            
            AND academy_id = 2
            
            GROUP BY user_id, academy_id
            
            ),
            
            event_arrays AS (
            
            SELECT
            
            COALESCE(t.user_id, y.user_id) as user_id,
            
            COALESCE(t.academy_id, y.academy_id) as academy_id,
            
            CASE
            
            WHEN y.user_id IS NULL THEN ARRAY\[t.event_count\]
            
            WHEN t.user_id IS NULL THEN ARRAY\[0\] || y.event_count_array
            
            ELSE ARRAY\[t.event_count\] || y.event_count_array
            
            END as event_count_array,
            
            COALESCE(y.event_count_lifetime,0) as event_count_lifetime
            
            FROM today t
            
            FULL OUTER JOIN yesterday y ON t.user_id = y.user_id
            
            )
            
            SELECT user_id,
            
            academy_id,
            
            event_count_array,
            
            reduce(
            
            slice(event_count_array, 1, 7),
            
            0,
            
            (acc, x) -> acc + coalesce(x, 0),
            
            acc -> acc
            
            ) AS event_count_last_7d, as event_count_last_7d,
            
            event_count_lifetime + ELEMENT_AT(event_count_array, 1) as event_count_lifetime,
            
            DATE('{ds}') as ds
            
            FROM event_arrays
            
            """

- The task dependencies are exactly in the order of those tasks where each preceding task needs to run first in order for the other task to be able to run (>>)
