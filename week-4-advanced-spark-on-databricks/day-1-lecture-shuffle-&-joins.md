# Apache Spark Shuffle JOINs

**DE.IO Description:**

In this lecture, Zach discusses how we handle two petabytes of data daily at Netflix, focusing on different sampling techniques to optimize processing. He shares insights on the importance of precision in data analysis and how we managed to reduce processing time and costs significantly by using a 0.1% sample. He also touches on the challenges of dynamic IP addresses in our cloud environment and the need for collaboration with application owners to implement effective logging.

## Main Topics for the lecture

- How Zach JOINed 2 petabytes of data/day in two different ways
- Shuffle and JOIN fundamentals

## Netflix: Problem Statement

- Zach worked at PSI - People Security and Infrastructure
- Both issues used the same dataset (VPC Flow Logs)
- There were two issues that needed solving at Netflix
  - Measure the impact of AB tests on network traffic
  - Measure network traffic app-to-app communication for security blast radius analysis
- What is very important to mention here is that these 2 problems has fundamentally different business needs
- Understanding the business needs is crucial in Data Engineering and lot of times you can solve a problem at hand “without solving it”
  - If we need to measure the impact of AB tests on network traffic you don’t really need to analyze every single record
    - The exact precision did not matter and the most important thing for this problem was directionality
  - With the security analysis you actually need the exact numbers of app to app communication notifications

### Netflix: Issue 1

- For the AB tests problem instead of processing 2 PB/day the chosen approach was to take 0.1% sample and processed 2TB/day instead
- You have to care about what you are sampling - the sample had to be at user level - take 0.1% sample of the users and analyze all of their traffic, not 0.1% of the total traffic
  - Consulting with a data scientist might be useful in cases such as this
- Its can really help to learn to take a step back and think about the problems at hand without blindly solving them
- Sometimes the right solution to data engineering problems is to not process all the data

### Netflix: Issue 2

- In this case the whole dataset needed to be processed because security is about looking at the needle in the haystack

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-1.png)

- Flow Logs are measuring the tune from traffic
- IP LookUp Table “simply” adds the name of the APP to the Flow Logs  

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-2.png)

- The IP addresses lookup table was dynamic which means that IP addresses were being reused in different points in time for different APPs due to Amazon charging for the number of IP addresses
- The LookUp table was 14GBs for one hour since Netflix’s cloud environment was so dynamic

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-3.png)

- origin_ip is the IP address that started the request (you can think of it as YOUR IP address), where the ip_from and ip_to addresses are the services IP addresses that communicate with each other to complete your request
- This was the biggest fact data table / log datasets that Zach has ever worked while in BigTech - around 200TBs per hour
- Shuffle Hash JOIN was the default JOIN that was triggered for this pipeline
- In order to be able to do the Broadcast JOIN the approach which was chosen was to introduce a TRIE DATA STRUCTURE (do some research here)
- This trie data structure was broadcasted to every executor
- In the end this solution to the problem was short-lived because IP addresses in IPv4 format changed to IPv6 format which can’t be represented in a trie data structure
- In the end it was solved by a “side-car proxy” which logs directly which app talked to the recipient app when a request happens
- Solving problems directly in the logs is 99% times way better than solving it in the pipelines

## Spark JOIN Types

- There are 3 most often used joins in Spark, and usually when you see any other type of JOIN that can be a sign that someone is doing something quite wrong
- JOINs:
  - Sort Merge Join
  - Shuffled Hash Join (pretty rare)
  - Broadcast Join

### Sort Merge Join

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-4.png)

- Usually one table is in the factor of 3 of the other table
- The tables get mapped to the partitions based on the JOIN key
- The whole idea is that first each table shuffles the JOIN key - let’s say the user_id so the same user_ids are mapped to the same partition (even user_ids in Partitions 1, odd user_ids in Partitions 2)
- Then those Partitions (1:1, 2:2 etc.) get sorted so that the comparison is quick because the same user_ids are going to be roughly in the same position (i.e. user_id 1 in the same row on both sides etc.)
- It is this sorting part which is really expensive on Big Scale
- This JOIN fails at huge scale such as in the Issue 2 of the Netflix problem due to the sheer volume of data
- This type of JOIN is the default JOIN strategy in Spark

### Shuffled Hash Join

![Lecture 1 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-5.png)

- Is painful with bigger number of partitions

### Broadcast Hash Join

![Lecture 1 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-1-6.png)

- Default definition of small is 10MBs, but you can change this
- Upper end of this is however 8GBs
- If you decide to adjust it to a bigger number however but you have to do memory tuning for executors otherwise it's not going to work
- This is only JOIN that would work for the pipeline from Netflix: Issue 2 because it doesn’t cause no Shuffle

## Live Q&A

Q: On really big data can bucket partition join work?

A: Yes, but you need to keep in mind that bucketing is still shuffling. That means that in order for this to be worth it, it's usually good to make sure the JOIN on this table/bucketBy key happens multiple times/in multiple places - i.e. multiple tables get JOINed to our bucketed table by this key.

Q: Are there any cons/considerations of broadcast join?

A: Yes, It's a memory vs computation trade-off. Shuffle uses more CPU cycles (compute) but less memory. Broadcasting a table requires more memory as the table gets send to every executor.

Q: Can you use multiple broadcast join tables in one join?

A: Yes, if you have enough executor memory you can broadcast multiple tables to one executor.

Q: If a query includes many tables, what is the best way to identify the most expensive part in the plan after running?

A: Open up Spark UI and look for skew in Summary Metrics - MAX percentile will have a lot more records and such.

Q: So the “shuffle” is the keys going between clusters?

A: Shuffle is the keys being rearranged into correct PARTITIONS.

Q: If the issue we are dealing with technically has multiple approaches, what are the other things to keep in mind other than the cost? Is it something that can come from experience or are there any recommendations on how to learn this judgement?

A: Optimizing for cost will be the most important 90% of the time, however sometimes you might need to optimize for reliability - i.e. if you can’t predict the memory needed on a executor due to changing work loads, it might be better to ramp up the memory higher and waste it on some less heavy runs, but then make the resource heavy runs complete and thus save your engineering time cost. There are various different types of cost so infrastructure cost is not the only one to keep in mind.

Q: When we specify disk size, is it per executor?

A: Yeah, but you should never really be spilling to disk nowadays. Zach has never changed disk size configuration during the whole 8 years of working with Spark.

Q: At Big Tech companies that might not use cloud and have inhouse cloud storage, how do we know the cost efficiencies? Like the storage and optimization around that?

A: BigTech companies usually have very good cost tracking set up so that should be something that someone from the infrastructure team can provide to you.
