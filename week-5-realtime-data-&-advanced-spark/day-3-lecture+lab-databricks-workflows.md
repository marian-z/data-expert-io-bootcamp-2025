# Databricks Workflows

## Main Topics for the lecture

- Introduction to Lakehouse and Workflows
- Workflow Orchestration Services
  - Workflow Jobs
  - Delta Live Tables
- Use Cases
- Workflow Patterns

![Lecture 3 1](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-3-1.png)

- Databricks developed Workflows to enable to save costs and have everything in one space
- It does that by enabling running of multiple tasks/notebooks in 1 Job
- **Databricks has two main tasks Orchestration Services**
  - Workflow jobs
  - Delta Live Tables
- Delta Live Tables were mainly built for Streaming use cases but that is not their only use
- Key advantage of Delta Live Tables is the ability to build data quality metrics report on top of the datasets (how is it behaving when moving from bronze to silver to gold)
- **Workflows Use Cases**
  - Orchestration of Dependent Jobs (Jobs)
  - Machine Learning Task (Jobs)
  - Arbitrary API calls or custom Task (Jobs)
  - Data Ingestion and Transformation (DLT)
- **Workflows Features**
  - Orchestration Anywhere (GCP, Azure, AWS)
    - Notebooks
    - ML Models
    - DLT
    - Jobs
- Fully Managed - not managing infrastructure
  - Whenever you spin up a Workflow Job it will create its own cluster for the Job, without you needing to provision it

![Lecture 3 2](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-3-2.png)

![Lecture 3 3](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-3-3.png)

![Lecture 3 4](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-3-4.png)

- The interface is similar to Airflow

![Lecture 3 5](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-5-realtime-data-&-advanced-spark/images/lecture-3-5.png)

- Data Quality in Delta Live Tables can be defined using CONSTRAINT keyword
