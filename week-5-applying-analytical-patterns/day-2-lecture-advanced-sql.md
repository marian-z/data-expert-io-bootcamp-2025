# Advanced SQL

## Main Topics for the lecture

- How do data engineering SQL interviews differ from the actual job?
- What are some advanced language features that you can leverage?
- Are advanced SQL techniques a symptom of bad data modeling?

## The DE SQL Interview vs SQL on the job

![Lecture 2 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-1.png)

- The SQL code that you write in job interviews is very likely to be the most difficult/advanced SQL that you will get in contact with for the most part
- Things you’ll see in data engineering SQL interviews that you will almost never do on the job:
  - Rewrite the query without window functions
  - Write a query that leverages recursive common table expressions
  - Using correlated subqueries in any capacity
- The DE interviews get some stuff right though
  - Care about the number of table scans:
    - COUNT(CASE WHEN) is a very powerful combo for interviews and on the job
    - Cumulative table design minimizes table scans
  - Write clean SQL code:
    - Common table expressions are your friend
    - Use aliases
    - Stay consistent in either capitalization or non-capitalization of SQL keywords

## Advanced SQL techniques to try out

- GROUPING SETS / GROUP BY CUBE / GROUP BY ROLLUP
- Self-joins
- Window Functions
  - Lag, Lead, ROWS Clause
- CROSS JOIN UNNEST / LATERAL VIEW EXPLODE

### GROUPING SETS

![Lecture 2 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-2.png)

- GROUPING SETS allow you to essentially run multiple GROUP BY statements and multiple different aggregation levels all at the same time
- In the case above we would be doing 4 different GROUP BY statements / aggregation levels
- GROUPING SET gives you the most control on aggregation/grouping

![Lecture 2 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-3.png)

- CUBE gives you all the possible permutations of aggregation combinations that you specify
- The code above gives you 8 different cuts of the data in one line of code
  - This is both good and bad, because if you go up by 1 additional grouping condition (i.e. device_maker) the number of combinations goes up by combinatorial grade. This increases the amount of grains that it produces greatly which generates a bunch of data that you are probably not going to use.
  - By default, it's better to be explicit rather than implicit

![Lecture 2 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-4.png)

- ROLLUP does hierarchical dimensions
- It’s really nice where you have geographical data where you have i.e. country, state, city
- The query above produces 3 aggregation levels

![Lecture 2 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-5.png)

## Window Functions

- Window functions are super important
- We have either rolling or ranking functions
- The Function (usually RANK, SUM, AVG, DENSE_RANK)
- The Window
  - PARTITION BY
  - ORDER BY
  - ROWS

## Data modeling vs Advanced SQL

- If your data analysts need to do SQL gymnastics to solve their analytics problems, you’re most likely doing a bad job as a data engineer
- **Symptoms of bad data modeling:**
  - Slow dashboards
  - Queries with a weird number of CTEs
  - Lots of CASE WHEN statements in the analytics queries

## Lab Notes

- With grouping sets you have to be aware of the fact that for lower aggregation levels the columns outside of aggregation window get NULLed out
- It is also important to not have any NULL values in columns that we will be grouping by - hence the COALESCE queries
- The other COALESCE inside the SELECT where we replace values with (overall) is useful to make sure we also replace NULLs that can be introduced with the GROUPING SET

![Lecture 2 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-6.png)

- If we add GROUPING column inside the query then in the results we will be able to see which columns were used in the grouping of data for that specific row
  - 0 means that the column was used

![Lecture 2 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-7.png)

![Lecture 2 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-8.png)

- There are different ways that we can define our aggregation level column by

![Lecture 2 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-applying-analytical-patterns/images/lecture-2-9.png)
