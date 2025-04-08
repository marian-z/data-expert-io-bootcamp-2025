# Spark Structured Streaming

## Main Topics for the lecture

- Streaming Query
  - Advantage
  - Use Cases
  - Sources and Sings
- Streaming Aggregates

![Lecture 2 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-1.png)

- Streaming is especially useful for low latency needs like stock trading, fraud detection, security, IoT
- Since streaming pipelines are harder to build and maintain, it is really important to consider the ROI of building a streaming system
- Build streaming pipelines for cases where you have the most and the fastest return value
- Airport operations are a good example

![Lecture 2 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-2.png)

![Lecture 2 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-3.png)

![Lecture 2 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-4.png)

![Lecture 2 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-5.png)

- .readStream instead of .read when connecting to Streaming Sources
- It is important to make sure that processing speed is faster than ingestion speed

![Lecture 2 6](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-6.png)

![Lecture 2 7](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-7.png)

![Lecture 2 8](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-8.png)

- Checkpointing is used for recovering if a pipeline fails

![Lecture 2 9](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-2-9.png)
