# Recognizing Business Value

## Main Topics for the lecture

- The hierarchy of pipeline value
- How to determine and prioritize the business value of your pipelines
- How analytics engineers should plug into experimentation and machine learning

## Hierarchy of pipeline value

- Frequency of decisions (how often are decisions being made with the data that you are producing) = a good proxy of value
- 75% of dashboards that are created are looked at once!
  - If you want to grow as a data engineer make sure to avoid this as much as possible when picking projects and being assigned work. If you feel like this is going to be the result of your pipeline, simply tell your manager and work on something that is higher value

![Lecture 3 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-1.png)

![Lecture 3 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-2.png)

- Make sure to keep this pyramid of values in mind if you want to grow as a Data/Analytics Engineer and understand the risk/value tradeoff that applies to different stages

### Analytical & Exploratory Dashboards

- With **anything “exploratory”** the decisions that are being made based on this are usually very infrequent, and the result is not really any added value for the business
- Exploratory dashboards are good at:
  - Finding new opportunities
  - Understanding smaller segments
  - Troubleshooting problems
- **Exploratory dashboards are risky when:**
  - Bad UX
    - Causes analyst to go back to SQL
    - Too many filters
  - Waste analysts time
  - Go unused (75% of the time!)

### Summary Dashboards

- **Summary dashboards** are great because you get large, infrequent, executive decisions and can bring value
- Summary dashboards are good at:
  - Monitoring health
    - Notifications health Dashboard at Facebook to make sure that FB is still growing (Click-through Rate, Incremental Growth, Conversion and other metrics.)
  - Minimizing cognitive load
    - If you look at summary dashboard which is done correctly you can very quickly understand what is going on
  - Showing strategic opportunities
    - If you have that bigger picture you can see the possible opportunities that might be on the horizon from the past trends
- **Why/when are summary dashboards risky?**
  - When they waste time
    - Complex picture
      - You should be able to look at it and quickly understand what you are looking at
      - Do not put millions of charts on summary dashboards that will only result on clouding the view for people who use it
    - Loads slowly
      - Pre Aggregated datasets with the agg_level column from the Lab that make sure the dashboards do not have to do any grouping
      - Same thing applies to dashboards as to the web pages - if your web page takes more than 2 seconds to load then you have already lost 80% of users
      - Care about analytics UX
  - Bad data = goose chase for decision makers
    - Don’t waste leaders time and make sure to do enough DQ checks to not come off as incompetent if you provide them with wrong data
  - Incomplete picture
    - False sense of security

### Experiments

- **Experiments** are very powerful, and for a lot of data engineers that is the space where you can make a lot of money
- If you want to be successful as a business you have to do a lot of experiments to understand the reality of your customer base and find out what works for you (Facebook, Netflix, Nvidia)
- You are going to be supplying data that then impacts the decisions that actually change the product
- If you can plug into experiments as a Data/Analytics Engineer this is where you can tie your data work to company wide impact and secure the bag/promotion
- **Experiments are one of the only ways to:**
  - Understand **cause/effect** \- Correlation is not Causation
  - **Reduce risk** of big changes
  - Understand **user behavior more deeply**
- **Why are experiments risky?**
  - Not enough metrics = bad decisions
  - Bad data = bad decisions
  - Metrics can be gamed
  - Picking short-term win for long-term loss

### ML

- Producing **data that gets used to feed ML algorithms** is usually at the top of the hierarchy because a lot of times these ML algorithms are what powers the business (pricing strategy at Airbnb etc.)
- With this also comes a lot of responsibility because feeding bad data to the models that impact how the business runs can cause business millions of dollars
- ML impacts the product immediately
- ML in production rarely goes unused
- ML is the combustion engine of the oil (data) that we refine as data engineers
- **Why is ML risky?**
  - ML can be “elevated” because it’s fancy
    - You can be busting your ass off producing data for a ML model that does worse job than a simple algorithm
  - Bad data in production = bad user experience
    - You have to care about Data Quality here and do not cut any corners when working in this area of DE
  - ML can suffer “feature drift” overtime

### Master Data

![Lecture 3 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-3.png)

- At Facebook, there is dim_all_users table that is a part of the Master Data that has 100,000 downstream pipelines
- If you fuck up here you will fuck up all the stages of the pyramid below because the bad data is going to get propagated everywhere

## Prioritize the business value of your pipelines

- **What if you can’t work on master data or machine learning? Are you cooked?**
  - **Not at all, because there is value in all of this and part of it is understanding where you fit and what decisions you can impact from where you are at in your current role**
- Important questions to ask and keep in mind:
  - Is this an ongoing or one-off request?
    - If its a on-off request it's usually a thumbs down, if ongoing a thumbs up
    - One-off requests should take up to 10% or less of your time, which is still a half day per week!
  - What intuitions or assumptions will this data challenge?
    - Is the data there only to support assumptions and not challenge? If yo, it’s probably worthless
    - Not challenging assumptions = low ROI
  - What bad decisions will this data prevent?
  - What good decisions will this data encourage?
- It should be a common practice and a sign of a healthy relationship between you and your stakeholders if it's ok to ask your stakeholders to do their homework before you do what they say and they accept it as a sign that you are not a brainless monkey and actually want to work on something that brings value to the company and do not get offended

|                                | **What is the upside?**                                                                                   | **What is the downside?**                                                                                  |
|--------------------------------|------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| **Encourage Good Decision**    | - AB Test shows positive revenue growth  <br> - AB Test shows positive user growth                        | - AB Test is showing increased infrastructure efficiency  <br> - ML model is limiting bad behavior more effectively |
| **Discourage Bad Decision**    | - AB Test shows declining user growth  <br> - ML model is malfunctioning defining too many fake users     | - ML model is being too lax and letting bad behavior propagate  <br> - AB Test shows massive bump in infrastructure costs |

- If you want to make more money you have to impact the business in more profound way, and this is the way!

## Plugging into experimentation

- Analytics engineers should:
  - Provide daily metrics (at user grain)
    - To see how A/B testing impacts these metrics
  - Rich dimensions (at user grain)
    - The richer metedata you have about your users, the more context can A/B tests have
  - Guidance on complexity of metrics
    - Data Scientist might suggest metric that can be statistically most relevant, however might be close to impossible to produce or need 10 additional datasets which in the end is not going to be worth it

## Plugging into ML

- Analytics engineers should:
  - Contribute to the feature engineering step of machine learning
  - Contribute via:
    - Brainstorming new features
    - Encoding features
    - Building feature stores

### What is a feature store?

- Feature store:
  - Holds onto specific user values that will be used for model training and inference later on
  - Feature stores require flexibility

![Lecture 3 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-4.png)

- This is just a simple example

![Lecture 3 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-5.png)

- This is more often used

![Lecture 3 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-6.png)

- This way allows all the features to be able to load asynchronously due to the feature_group column on which the table is partitioned

### What about categorical features?

- Categorical features can be encoded into numerical features via a few techniques:
  - One Hot Encoding and Dummy Encoding
  - Label Encoding and Ordinal Encoding

#### One Hot Encoding

- One Hot Encoding is very easy
- If you have a feature “Android” you simply turn it into a column “is_android” which is a 0 or a 1
- The issue here is for high cardinality categories this becomes painful and BUCKETIZING is a way to go

#### Dummy Encoding

- Dummy encoding is just one hot encoding, except it excludes the first feature
- If something isn’t Android and isn’t Iphone and isn’t every other phone operating system, then IT MUST BE A WINDOWS PHONE
- It uses the idea of the pigeonhole principle to pull this off
  - If it’s nothing else then it has to be the last thing
- This only works for features that are mutually exclusive

#### Labeled Encoding

![Lecture 3 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-3-7.png)

- Assign a label to each place
- Only one feature per column
- ML might mistake the relationship to be ordered

#### Ordinal Encoding

- Exactly the same as label encoding, EXCEPT the categories are actually ordered
- Maybe it’s “good”, “medium, “bad”
- Or “data engineering”, “data science”, “data analyticsL
