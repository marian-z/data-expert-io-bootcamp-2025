# Applying Analytical Patterns

- **Repeatable analyses are your best friend**
- There are like 10 patterns that if you learn, then when building the pipeline you don’t have to think about the SQL code specifics but only about the patter that you are going to apply
- What are the common patterns that you need to learn?
  - **Aggregation-based Analyses**
  - **State change tracking**
  - **Survivorship Analysis**
- Repeatable analysis reduce the cognitive load of thinking about the SQL and streamline your impact as when building the pipelines you don’t have to think about recreating the wheel
- These patterns are so repeatable that you can actually build python APIs that will build the SQL code for you from predefined schema
- **Common patterns:**
  - **Aggregation-based** patterns
  - **Cumulation-based** patterns (State Transition Tracking + Survivorship Analysis)
  - **Window-based** patterns
  - **Enrichment-based** patterns

## Aggregation-based Analyses

- The most common type of analysis
- **GROUP BY** is your best friend
- **GROUPING SETS** vs **CUBE** vs **ROLLUP**
- Upstream dataset is often the “daily metrics”
- Common types of analysis:
  - **Root cause analysis** (why is this thing happening)
    - Trying to pinpoint why something is happening
    - By slicing and dicing the data you are able to tell why something might be happening
  - **Trends**
    - Time is the dimension that you will be grouping on here
  - **Composition**
    - Composition is going to have multiple layers (dimensions) to it
- You generally want to do this on fact data that is already somehow pre-aggregated on some entity level (i.e. website actions per user)
- Think about the combinations that matter the most
- Be careful looking at many-combination, long-time frame analyses (>90 days)
  - You don’t generally want to bring in all the dimensions and have too many combinations because if you have so many dimension combinations the aggregations are not going to be small anymore and the point of aggregating to get “less” data is no longer there
- Most of the time you want to avoid high-cardinality dimensions
  - I.e. use age groups instead of age etc. - bucketize
- As you increase the time-frame you might want to reduce your granularity
  - If you are doing analysis on last 90 days then daily grain aggregation might make sense, however if you are doing the analysis on the whole last year you might want to aggregate on monthly grain
- As your datasets get bigger you should think of these dimensional problems in terms of combinatorics where with higher number of combinations the data grows

## Cumulation-based Patterns

- Cumulation is the study of what happened before, or the study of dragging history forward
- Time is a significantly different dimension here vs in the other types of patterns
  - When you are doing aggregation you can basically treat time as any other dimension
  - In Cumulation time matters a lot more because you are looking at continuity (yesterday vs today) where you compare two datasets where one is previous and one is current
- **FULL OUTER JOIN** is your friend here (built on top of cumulative tables)
- Common for these following patterns:
  - State change tracking
  - Survival/Survivorship analysis (also called Retention or J-Curves)

### Growth Accounting

- Is a special version of state transition tracking
  - **New** (didn’t exist yesterday, active today)
  - **Retained** (active yesterday, active today)
  - **Churned** (active yesterday, inactive today)
  - **Resurrected** (inactive yesterday, active today)
  - **Stale** (inactive yesterday, inactive today)
- Your data only registers on the date that your state changes
- If you have any machine learning model then what it does is basically classifies things and put them into buckets
- This pattern is a great tool to monitor health of those kind of machine learning models
- You can use this pattern to partition the data per machine learning model to compare the performance of different models of how they are classifying stuff

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-1-1.png)

- The states are supper important to track because as a i.e. website you want to maximize new and resurrected users

### Survivorship Analysis and Bias

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-1-2.png)

- In WW2 there were these planes that would go out in fight and then they would go back
- They would have all these holes from the fighting, so the engineers were like ok we need to reinforce these parts with the holes
- The interesting thing thing here is that the holes were on the planes that actually came back so they didn’t actually need to reinforce the parts with the holes as the airplanes survived with them being shot, but to reinforce the parts with no holes because those parts being shot is what is making the planes go down and not come back
- This Bias is incredibly important to keep in mind in Analytics and Data in general
- Survivorship analysis is ultimately going to give you one of 3 curves (J-Curves)

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-1-3.png)

- Depending on the health of your company you are going to have one of 3 lines when tracking user growth
- Both Orange and Green lines are actually good as that means that you have a sticky product that is making people stay
- You have a reference date, which is a point in time where you are at 100% (i.e. KickOff of the bootcamp before people start dropping off)

| Curve | State Check | Reference Date |
| --- | --- | --- |
| Users who stay active | Activity on the app | Sign up date |
| Cancer patients who continue to live | Not dead | Diagnosis date |
| Smokers who remain smoke-free after quitting | Not smoking | Quite date |
| Boot camp attendees who keep attending all the sessions | Activity on Discord | Enrollment date |

##

## Window-based Analyses

- Always done with Window functions
- **DoD / WoW / MoM / YoY** - also called “**derivative functions**” because they are measuring change over time
  - Capture immediate/more sensitive changes
  - Sometimes anomalous things happen that breaky YoY
  - Airbnb’s business was ricked in 2020, so in 2021 they couldn’t use YoY analysis because the numbers looked too good
  - In those circumstances we can use Year over 2 years to compare 2019 and 2021 etc. so have more of a fair assessment
- **Rolling Sum / Average** - also called “**integral functions”**
  - Summing things up over time and averaging things over time etc.
  - Capture slow moving trends
  - Keyword here is **rolling**
  - Mostly solved using window functions
    - FUNCTION() OVER (PARTITION BY keys ORDER BY sort ROWS BETWEEN n PRECEDING AND CURRENT ROW)

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-1-4.png)

- **Ranking** - the things that show up **in every damn SQL interview**
