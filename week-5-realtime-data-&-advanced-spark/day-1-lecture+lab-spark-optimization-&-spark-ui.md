Advanced Spark Optimization

## Main Topics for the lecture

- Performance and Query Optimization
  - Catalyst Optimizer
  - Adaptive Query Execution
  - Memory Partitioning
- Spark UI

![Lecture 1 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-1.png)

- When you submit query using any syntax whether it is SQL, Python, Scala or R the first step is always checking if the syntax is valid
- Metadata Catalog is then used to check if the given dataframe contains whatever columns that we specified or not
- Catalyst Catalog helps with logical optimization which means that for example if I have a WHERE condition in the query then that is applied first before JOIN so that we do not have to go through all the data of the table etc.

![Lecture 1 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-2.png)

- Whenever you see the Exchange keyword in the .explain() physical plan it means that it is where shuffle happens

![Lecture 1 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-3.png)

![Lecture 1 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-4.png)

![Lecture 1 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-5.png)

![Lecture 1 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-6.png)

![Lecture 1 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-7.png)

![Lecture 1 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-8.png)

![Lecture 1 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-1-9.png)
