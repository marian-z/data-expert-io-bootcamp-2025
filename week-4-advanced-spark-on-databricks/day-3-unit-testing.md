# Apache Spark Unit Testing

**DE.IO Description:**

In this lecture, Zach discusses the critical aspects of data engineering, focusing on the importance of maintaining data quality and minimizing customer pain. He highlights the challenges we face in balancing speed and quality, especially when dealing with machine learning models. He also emphasizes the need for best practices and frameworks to ensure efficient data pipelines.

## Main Topics for the lecture

- How to catch quality errors BEFORE they enter production
- How to use software engineering best practices in data engineering

![Lecture 3 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-1.png)

## Catching bugs In Development

![Lecture 3 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-2.png)

- Best case scenario to catch bugs from all of those mentioned
- Pipeline is considered hardened when it is not experiencing a lot of changes
- What will happen if one of the JOIN side is null, what will happen when there are duplicates etc.
- Try to think about edge cases such as what would happen to your code/queries if the data changes a little bit and how could you make the code/pipeline more resilient
- Unit and Integration tests are your best friends because they force you to think about WHAT IF your data is NOT perfect
- No matter how good of an engineer you are, always get a code review

## Catching bugs In CI/CD before Production

![Lecture 3 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-3.png)

- CI/CD is the step in between when you make a change and when that change is in the main repository that is running in production
- CI/CD bans changes to production unless they are high quality
- You can set up a suite of unit and integration tests that will then act as guardrails so that if other engineers try to make changes to your code that would break something else then the change would be blocked from deployment
- Setting up CI/CD is very important and makes you less on edge when merging
- NEVER PUSH/MERGE DIRECTLY TO MAIN

## Catching bad data in a staging table in production

![Lecture 3 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-4.png)

- Keep in mind that audits are never going to be perfect and that's something that happens all the time and is fine

## Bad data in a Production table

![Lecture 3 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-5.png)

- This will still happen if you do the previous steps, however same as with car crashes the fatal ones happen way less if you wear a seatbelt
- Bad data in production ruins the mood, trust and makes it so that nobody wins

## Software Engineering best practices in DE

- Software engineering has higher quality standards than data engineering because of multiple reasons (is around longer, the speed by which the errors get to the customer is a lot faster)

![Lecture 3 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-6.png)

- As you march towards the rabbit the more money you make as a data engineer which makes sense as the speed of customer pain (when they feel the error in your pipelines) is much faster and thus the impact is a lot bigger

![Lecture 3 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-7.png)

- Very slow to hurt customers as it usually impacts human decision making processes inside the company
- Do not underestimate this though because it can happen that the decision being taken on this can be a multimillion dollar investment etc. etc.
- It is usually due to this “slow” time to reach and hurt customers that Data Engineers usually work with less rigor in their work because they know they can get away with it as compared to Software Engineers which are going to feel the pain a lot faster since i.e. Netflix coming down will be heard really fast around the world

![Lecture 3 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-8.png)

- This are the pipelines that produce data that the customer sees directly
- Customers are more forgiving for stale data than they are for incorrect data
- It's better for the pipeline to break rather than publish bad data (WAP!)
- You don't want your customers to lose trust because you are publishing data that is not correct

![Lecture 3 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-9.png)

- While working at SmartPricing at Airbnb, for every day that the Smart pricing pipeline was delayed, the Smart Pricing recommendation algorithm degraded about 5%
- If you are working in a space where you are using DE to feed data for machine learning algorithms then you should definitely follow the Software Engineering best practices as the impact of pipeline breaking or bad data in production is going to be of a much bigger impact
- It all depends on what type of model is in question as for example ChatGPT is not getting updated/retrained all of the time so you have more time to catch/correct the pipeline error or bad data that pipeline produced
- The more latency sensitive your ML model is, usually that means that you need to retrain the model more quickly and make predictions faster
- It also depends a lot on what are you working on such as an error in Security pipelines based on which breaches and detections are getting discover will have a much more severe impact on everyone involved

![Lecture 3 10](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-10.png)

- Think of the negative backlash that Netflix received when it went down during the Jake Paul vs Mike Tyson fight
- This is definitely where you hurt the customers trust the most if your pipelines causes issues such as this
- Engineer for quality and for edge cases

![Lecture 3 11](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-11.png)

- In most Analytical Organizations Data Engineers are usually the champions of Data Quality and Excellence because they have the possible skills to do this (Data Analysts do not know how to do this, and Data Scientists usually don’t want to do this)

![Lecture 3 12](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-12.png)

- Having strong Engineering leaders is really important here
- **DATA ENGINEERING IS ENGINEERING** which means we need to follow engineering best practices and step in this new world so that we don't crumble under the weight of all the shitty pipelines that we have to write quickly to answer all the analytics questions
- We can either help Analysts answer questions robustly or quickly
- If we answer the questions robustly we can go faster further
- Of course we might not have all the answers right at the beginning but if we are able to build frameworks that are sustainable then the next time when somebody asks a business questions we might not have to build any pipeline at all because we already prepared for it
- Engineering leaders have to focus on this problem
- Learn to say no to immediate answers for long-term and sustainable answers

![Lecture 3 13](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-13.png)

- Data Engineering is Engineering and we have to look at it from that point of view to drive the industry forward
- There is no other option as unless we do better we will get depreciated, especially now in the era of AI
- **Latency:**
  - Being able to build Streaming and Real-Time pipelines that are used to feed ML models to help with fraud and thread detection is going to be a lot more important for you as an engineers in the future if you want to make a lot of money
- **Completeness:**
  - The concept of Data Mesh is basically build on the idea that data engineers are not really necessary and the domain experts should be the ones doing the data engineering
  - There are 2 possible scenarios here: Domain experts are going to learn Data Engineering and make engineers not necessary **OR** Data Engineers are going to learn domain specifics. This is definitely a space that is going to be fought over  

- **Ease-of-access and usability:**
  - Why use Databricks if you can use Snowflake + DBT more easily is a valid point due to ease-of-access and usability

![Lecture 3 14](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-14.png)

- Always write your code as if it was meant to be read by humans not executed by machines (structure the code better, use relevant frameworks, comment appropriately etc.)
- Always aim for loud failures because they at least shout in your face that something is broken and there is no hidden imp in the data due to bad data pipelines
- The louder that your DQA frameworks are the more possible is that you are actually going to troubleshoot it

![Lecture 3 15](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-15.png)

- These principles are going to be your best friend
- DRY = Don't Repeat Yourself
- Writing DRY and modular code is going to be significantly easier in PySpark/Python and other more object oriented stuff such as compared to i.e. SQL, but there are way to go around this even in SQL with Jinja, dbt and other tools
- YAGNI = You are not going to need it
- Do not add functionality that is not explicitly necessary because you are probably not going to need it
- Do not aim for unattainable architecture that addresses all the possible problems that can and will arise
- **Design documents are your best friend**
  - Get feedback!!!
  - So many data engineers are just writing code in the dark without understanding the business problems and requirements
  - What are the tables that you are going to build, what are the schemas, what are the business problems that we are going to solve
  - This way you will build datasets that are much better
- **Care about efficiency**
  - Think about the data structures, the algorithms, the [Big O notation](https://www.geeksforgeeks.org/analysis-algorithms-big-o-analysis/), the space-time tradeoff, how much memory is being used and how much compute is being used (cloud costs)
  - Think about compression, how we are storing data, how we are sorting data, how we are partitioning data and writing queries on partitioned data
  - Think about if we are even using the right data store
  - Understand JOIN, shuffle and other important concepts  

![Lecture 3 16](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-4-advanced-spark-on-databricks/images/lecture-3-16.png)

- The answer is becoming a more and more evident YES with LLMs and other things that will make the analytics and SQL layer of data engineering job more susceptible to automation so you need to find as many spots where you are able to bring value
- Not that many people want to do this and that is fine as its not “sexy” and as we have explained already you have to move slow (SE best practices) to move fast
- The other option is getting closer to the business and getting more into Analytics Engineering
