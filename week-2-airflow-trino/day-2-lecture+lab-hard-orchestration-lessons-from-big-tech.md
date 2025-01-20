# Hard Orchestration Lessons & Idempotent Pipelines

**DE.IO Description:**

In this lecture, Zach explores the complexities of Airbnb's PNA system, focusing on key issues and solutions. He discusses challenges related to availability definitions, backfilling historical data, and optimizing pipeline designs. Zach suggests actions around communication frequency, stakeholder engagement, and iterative design improvements.

## Main Topics for the lecture

- Airbnb
  - Pricing and Availability pipelines
- Netflix
  - Real-time threat detection pipelines
- Facebook
  - Notifications deduped pipelines
  - Fake Accounts Pipelines

## Airbnb

- Zach was the owner and Staff Engineer of Marketplace Dynamics which includes everything in terms of price, availability, profitability, listings etc., but especially pricing and availability
- Airbnb had a less-than-ideal definition of availability
- The old definition:
  - Available = “Host has not blocked this night and it is not reserved”
- More accurate definition
  - Available = “A trip can be booked that contains this night”
- These definitions might sound like the same thing and in fact in data they are 96% the same but the 4% change in the dataset had a massive impact
- They are different in a few cases:
  - City regulations force minimum length of stay
  - “Sandwich nights”
    - Host has a 7 days minimum length of stay, upcoming reservation in 4 days. The first 3 days are unavailable.
    - In the old definition if the host has not blocked the night but there is a minimum required length of 30 days, then that means that if there is a reservation in 28 days you can’t actually book any day before that.
    - In the old definition they were however listed as available nights anyway because they were not specifically blocked by the host, but were in fact unavailable
  - Bugs with “last minute” bookings
    - All availability is calculated at the moment of looking
- These are all examples of why it is important to backfill

![Lecture 2 Airbnb_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-airbnb-1.png)

- P&A Rules = block nights, calendar, regulations etc. (around 50 datasets)
- P&A libraries = the same libraries that the app uses
- This caused a lot of pains and was kinda slow because if you wanted to change the dataset you had to change all of it = change all the partitions up to 2016 (all of history)
- If they wanted to fiddle with the definition of how it is calculated you had to keep doing all of these JOINs all over again
- Backfilling all of history took 2 ½ weeks

![Lecture 2 Airbnb_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-airbnb-2.png)

- The main changes were happening in the “Pass inputs to P&A library”
- The main change that was done while was Zach was there was to create a staging table
- A lot of time when you are backfilling and need to run you pipelines all over and over again you want to segment it so that the piece that is not going to change as much is going to be done first and you don’t have to run it all over again (the staging table mention above)
- In the picture above it is the “Create P&A inputs” which was done by data vault modeling
- Backfilling all of history now took 3-4 hours instead of weeks
- Putting a Staging step in your pipelines can dramatically change the speed of your pipelines
- Sometimes when things take too long it's about segmenting them and thinking of creating these staging steps in between
- Data engineering is all about putting things in boxes and making sure that those boxes fit that work
- The difference is this:
  - Previously: Join and pass to P&A libraries was doing both combining all the steps and calculating on them
  - After Improvement: Combine step was done first and then the calculation step happened later on which means that the process was separated into more steps
- Build your pipelines and datasets incrementally
- **Lessons learned:**
  - Segmenting your pipelines can have a dramatic effect on the agility of your pipeline’s backfills
  - Communicate more often before you backfill
  - Get another set of eyes on your pipeline design before you backfill
  - When you inherit pipelines try to put yourself in a state of curiosity and dive deeper on the pipeline design to see if there is anything that you can do on the design to improve it
- **Impact:**
  - Airbnb availability was reduced by about 4.5% which allowed Smart Pricing to raise prices without impacting occupancy!
  - Zach “greatly exceeded” expectations at the staff level for these changes
  - He left Airbnb shortly after landing these changes

## Netflix

- Netflix wanted to detect threats in real-time
  - The old system used “psycho” pattern which added 5-7 minutes of latency
  - They wanted Flink and “real-time” to minimize the latency to 1-2 minutes
- Psycho Pattern explained:
  - It runs “continuously”
  - Only one run at a time
  - It tracks a high watermark which is a timestamp of “the most recent files that were processed”

![Lecture 2 Netflix_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-netflix-1.png)

- This was done with batch Spark not Spark Streaming
- What adds the latency is the step where the pipeline (Spark) has to wake up and go back to sleep and wake up again
- Psycho Pattern was painful because:
  - When it was delayed, the memory footprint would become unpredictable
  - It was “real-time” but also “batch” at the same time (“micro-batch”)
- Instead of Airflow and Spark, the security team wanted real-time and Flink and without asking deeper questions the DE team got to work
- Initial results were 4 minutes of latency instead of 6 which wasn’t very fruitful because if you count in the engineering time the 2 minute lower latency is not a big pay off
- **Lessons learned:**
  - Forgetting to dip deep into requirements, creates “false constraints”
  - True real-time + ML detection is hard in security, needle in a haystack problem
  - The old pattern was good enough. They needed to make that architecture more accurate
  - It wasn’t a question of latency, but a question of accuracy
  - You have to get stakeholders what they need not what they want!

## Facebook

### Deduping Notifications

- **Problem:**
  - Notif_delivery table has duplicates
  - The Hive GROUP BY at UTC midnight took 9 and ½ hours
  - This was the bottleneck for many master data sets in growth
- **Manager suggested:**
  - Dedupe it in real-time
    - Zach tried and realized it would require a streaming job with 50TBs of RAM
  - Deduping hourly was the other option so that at the end of the day you would only have to dedupe the last hour
  - Deduping hourly had its own problems

![Lecture 2 Facebook_1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-facebook-1.png)

- This approach actually worked as opposed to the real-time one but used **15 times more compute than the old group by method**
- Why is that the case:
  - In the first hour you have 1 hour of data, then you have 2 hours of data, then 3 etc.
  - Every hour you are reading in and merging against a bigger and bigger dataset
  - When you are at 22nd hour you are reading in 90% of the data already and merging in another piece of data
  - It results in more and more I/O than if you just read all of the data at once and did a group by
  - It is a very simple but really expensive design
- This is why it was concluded that it is not a valid approach even if it “worked”

![Lecture 2 Facebook_2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-facebook-2.png)

- This was the design that the team came up with in place of the previous one
- You can think of it going down to the 24th hour like a tree
- This allows you to minimize the amount of I/O that happens when you are reading in your datasets and working on them
- The tricky thing with this design was that it had to be a daily dag instead of hourly because of all the dependencies
- This worked and reduced latency from 9 ½ hours to 45 minutes and it actually used 15% less compute than the old GROUP BY because the duplicates are closer together
- If you think about it, if you click on a notification it is more likely that you are going to click on it again in an hour than in 7 hours etc.
- **Lessons learned:**
  - Sometimes a more complex DAG is going to be cheaper if you are very mindful in how much data you are reading and writing
  - Hourly DAGs can work but sometimes you have to go back to Daily to have a bigger scope
  - Be resilient
  - Workshop a lot and bounce off your pipeline design ideas

### Fake Accounts

- **Problem:**
- Facebook wants to know how many fake accounts are:
  - unlabeled as fake
  - relabeled as fake
  - fake for the first time
  - staying fake

![Lecture 2 Facebook_3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-facebook-3.png)

- Zach worked on the cumulation part of the pipeline (fake accounts yesterday, fake accounts, join datasets comparing yesterday to today)
- This architecture was broken because fake accounts waited for the “latest” partition of the users table. Any delays from that table would result in using the wrong days data
- The pipeline was not idempotent
- Fake accounts dataset was not generated correctly in production, it was generated sometimes with today's data, sometimes with yesterdays or from 2 days ago
- **The fall out:**
  - Analysts tried to reconcile the fake account flows with the users table
  - The numbers didn’t match up

![Lecture 2 Facebook_4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-2-airflow-trino/images/lecture-2-facebook-4.png)

- The solution was to have fake accounts wait for yesterday’s data so it can land quickly but still be produced deterministically
- It was important to get consistent outputs, even if there was a latency trade off
- It is important to get to know better the downstream use cases
- **Drawback**: Fake account flows are 1 day delayed
- **Pluses**: You can actually recreate the data to get all the right matches, connections and idempotent
- **Lessons learned:**
  - Sometimes data quality errors are from non-deterministic pipelines and these non-deterministic errors can be introduced very easily because they are not caught by unit or integration tests
  - Don’t blindly trust your upstream data
  - Having an extra day of delay all of the time is better than having it some of the time (reproducibility)

## Live Q&A

Q: What is memory tuning?

A: It is how much memory each job is given. With Spark you have executor memory and driver memory.

Q: How would you describe a data model to a non technical stakeholder?

A: Data model is a view of the world where you are tracking the nouns and the verbs.

Q: What is the difference between dimension modeling and data vault modeling?

A: Data Vault modeling is a lot about keeping the data as raw as possible.

Q: When would you use dimensional modeling and when a Data Vault?

A: Mostly just use dimensional modeling. You use Data Vault when you want to have access to the data in the most raw format but in a compact way. Also use Data Vault when you want to make Analysts cry.

## Lab Q&A

Q: Why didn’t you use a unique key for deduplication when dealing with duplicates?

A: Because that concept (primary_key/foreign_key) concept doesn’t exist in data lakes. It might be in the future with Iceberg as per Jason Reid.

Q: Is ds the day that DAG runs or the partition date.

A: Kind of both in our code but in the context of airflow the {{ds}} is the macro forIt the logical day, or the date for which the pipeline is running for.

Q: How do we configure different compute for each step of the DAG?

A: If you look into other DAGs you can see that there is a python_callable that uses “execute_trino_query” script and you can configure this to be whatever else for example some snowflake trigger callable or such.

Q: Can we rerun the DAG from the failed step as in Databricks workflows?

A: Yes, that is called Clear task in Airflow which will rerun the DAG.

Q: What is the role of the Astronomer here? We are running DAGs locally only right?

A: It helps with deploying the DAGs in the cloud.

Q: Why use the poke data (python callable inside wait_for_web_events_daily), and not a sensor to the kafka DAG?

A: Yeah that could definitely work too. It depends on your use case.

## Lab

- The goal of today’s lab is to dive deeper into Airflow DAG code and fix those parts of the code that are making this DAG non-idempotent
- The DAG is composed of these tasks:
  - **wait_for_web_events_daily**
    - task that uses poke_tabular_partition python callable code that keeps checking for the partition in a specific table until the partition date = DAGs logical date {{ds}}
    - This task was added as a part of the process to make the DAG idempotent
  - **academy_summary_create**
    - task that uses execute_trino_query python callable code and runs a DDL statement to create a production table
    - The DDL statement is CREATE TABLE IF NOT EXISTS to make sure this task runs correctly even after the table was created in the DAGs first run
  - **clear_summary_step**
    - Task that clears the summary table that we have created in the previous task above
    - This task is important because in the **insert_academy_summary** task we are using INSERT INTO statement which is not inherently idempotent without DELETE/TRUNCATE clause with a range
    - task uses execute_trino_query python callable and runs a DELETE FROM statement against the production table from which it deletes the partition of the data that is equal to the logical date (WHERE ds = DATE('{ds}'))
  - **insert_academy_summary**
    - Task that uses execute_trino_query_python callable and users INSERT INTO statement to insert data in the destination output_table
    - Task that was the part of the initial DAG design but we had to make changes here to address the non-idempotency
    - The changes that we had to make were:
      - The initial INSERT INTO query contained WHERE ds > DATE(‘{thirty_days_ago}’) condition which would probably work fine in production however during backfilling we will have a lot more data than 30 days. This condition was thus changed to WHERE ds > BETWEEN DATE(‘{date}’) AND DATE (‘{thirty_days_ago}’) AND DATE(‘{ds}’)
      - {date} is a configurable variable that can be change during configuration setting when running airflow in terminal
      - The second change was to create a bounded window because the COUNT(DISTINCT user_id) is a ticking time bomb when it is only bounded on one side by WHERE ds > DATE(‘{thirty_days_ago}’).
      - This was changed to the WHERE condition above (WHERE ds > BETWEEN DATE(‘{date}’) AND DATE (‘{thirty_days_ago}’) AND DATE(‘{ds}’))
      - Keep in mind you should always be using both &lt;/&gt; operators or BETWEEN. It is really important when processing your summaries etc.
- The python scripts used as callables that are used in these task are:
  - **trino_queries.py**
    - The script establishes connection with Trino engine and uses a query given by user configuration to query the data
  - **poke_tabular_partition.py**
    - The script retrieves the access token fro Tabular that serves as the main data platform for the project and uses it to query user defined warehouse, table and partition
    - If a partition was found it returns the result of existing date partition within the table, if it does not find the partition the script keeps trying to look for the partition in predefined intervals
  - The main idea with these how these python callables/scripts are written is to isolate the logic in a separate “box” as to be able to be used within different DAGs, in different tasks and with different configurations
