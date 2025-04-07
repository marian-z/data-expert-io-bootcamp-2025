# Apache Spark Fundamentals

**DE.IO Description:**

In this lecture, Yared dives into the fundamentals of Apache Spark, discussing its architecture and how it processes big data. He highlights the importance of Spark's DataFrames and the various programming languages it supports, such as SQL, Python, and Scala. He also touches on the execution process and the concept of lazy evaluation.

## Main Topics for the lecture

- What is Apache Spark?
- Spark Architecture Overview
  - Driver and Executors
  - Cluster Managers (YARN, Mesos, Kubernetes)
- Spark Components: Core, SQL, Streaming and Graph X
- Lab
- **Databricks version of Spark is the managed version which means that what is managed is:  
    **
  - **Cluster Management and Automation**
    - **Provisioning**: Databricks takes care of setting up Spark clusters with a few clicks or API calls. You don't have to manually configure or install Spark on virtual machines or physical hardware.
    - **Scaling**: They offer **autoscaling**, where clusters automatically adjust the number of nodes (or size of nodes) based on workload demand, ensuring efficient use of resources without manual intervention.
    - **Cluster Termination**: Databricks can automatically terminate idle clusters to save costs.  

  - **Infrastructure Management**
    - **Cloud Integration**: Databricks manages Spark clusters on cloud platforms like AWS, Azure, and Google Cloud. They handle all the interactions with underlying cloud infrastructure services, such as virtual machines, storage, and networking.
    - **Networking and Security**: They provide built-in security configurations, like secure network setups, role-based access control, and encryption. This reduces the effort needed to configure these manually.  

  - **Maintenance and Upgrades**
    - **Spark Versions**: Databricks provides and maintains optimized versions of Apache Spark. They ensure compatibility and apply performance improvements beyond the open-source version.
    - **Patches and Updates**: Databricks applies security patches, bug fixes, and feature updates without requiring manual intervention from users.
    - **Performance Optimizations**: Their Spark runtime includes custom optimizations for improved performance and reliability compared to the standard Apache Spark.  

  - **Job and Workflow Management**
    - **Job Scheduling**: Databricks provides tools to schedule and orchestrate Spark jobs and workflows, including retries and notifications for failures.
    - **Monitoring and Logging**: They offer integrated monitoring tools, dashboards, and logs for Spark applications, which simplifies troubleshooting and performance tuning.  

  - **Managed Libraries and Dependencies**
    - Databricks manages the Spark ecosystem libraries (like MLlib, Delta Lake, or GraphX) and provides tools like the Databricks Runtime. This ensures compatibility and reduces dependency conflicts.  

  - **Integration with Additional Services**
    - Databricks integrates Spark with data lakes, data warehouses, machine learning tools, and other ecosystem components. For example:
      - Delta Lake (their proprietary data format and engine).
      - Built-in connectors for various cloud storage services.
      - Integration with visualization tools like Power BI or Tableau.  

  - **Reliability and Availability**
    - **High Availability**: Databricks ensures that Spark clusters are fault-tolerant, leveraging cloud infrastructure features for backup and redundancy.
    - **Recovery**: They handle recovery from cluster failures, allowing jobs to resume or restart with minimal user involvement.  

  - **Simplified User Experience**
    - **UI and APIs**: Databricks provides an easy-to-use web-based interface for managing clusters, running Spark jobs, and analyzing results. It abstracts away much of the complexity of Spark's CLI or API usage.

## What is Apache Spark?

- Apache Spark is an open-source unified analytics engine designed for large-scale data processing
- It is widely used for distributed processing of big data and supports a wide range of tasks, including batch processing, streaming, machine learning, and graph processing
- If you are not working with BigData Spark is not really necessary because engines such as BigQuery or Snowflake can handle the workloads efficiently as well
- Within Spark you can however use any of these APIs: Spark, SQL, Scala, R or Java
- It is this wide-range of accepted APIs and workloads (ML, batch, streaming etc.) that Spark can handle that makes it really appealing
- When talking about Graph processing in the context of Spark what we mainly have in our hands with Spark is GraphFrames APIs
- Graph modeling is mainly used for mapping social media networks, network traffic etc.
- It can also be used in the use case such as you order a package that is composed of multiple items and the system needs to figure out the fastest way to get all its components from different warehouses/facilities and to be able to get it to you the fastest way possible (it looks for various paths that it could take to complete this order)
- From ML perspective Spark can process data in a sub second latencies in most cases, but if you want to go lower than that you need to look for other options
- When we mention that something is structured it means that it has a schema
- Dataframes in Spark are immutable which means that when creating something from a source dataset a new dataset is created and the old one is still kept in the background

## Spark Architecture Overview

![Lecture 2 Spark_Architecture_Overview](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-2-spark-architecture-overview.png)

- Whenever you create a Cluster on Databricks you have the option to define the Driver type and the number of Workers
- In this case the Workers are Executors (executors are nothing more than JVMs under the hood).
- A **worker node is not always an executor**, but it is responsible for hosting executors. Executors are processes that run on worker nodes to perform Spark tasks, and a worker node can host multiple executors if resources allow.
- The **Cores** are used to execute 1 tasks
- **Executors** have their own memory to do the work

![Lecture 2 Spark_Execution](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-2-spark-execution.png)

- In order to execute a script Spark creates a Job which can have multiple Stages and each Stage can have multiple tasks depending on the complexity of the task/script (narrow vs. wide transformations)

## Lab

- For running notebooks in Labs use DataExpertCluster which is a multi-node cluster and should be able to handle multiple people running it at the same time
- In order to copy content from other people’s workspace you can simply click on the 3 dots near the folder you wish to use in your own workspace, choose the option to Download as DBC archive which will download it and then you would simply import it

![Lecture 2 Magic_Commands](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-2-magic-commands.png)

- When you execute a cell in a Notebook you can click through to the Spark Jobs and below to Jobs and Tasks see the details of what happened in the background which is really useful when trying to optimize your queries

![Lecture 2 Execution](https://github.com/marian-z/data-expert-io-bootcamp-2025/raw/main/week-3-apache-spark-basics-&-databricks/images/lecture-2-execution.png)

- We will do a deep dive into into this view and how can you interpret the resource usage from this view in subsequent Lecture and Labs
- Single node cluster = Driver and Executor are on the same node
- Keep in mind to Toggle “Terminate after XYZ minutes of inactivity” to some low number such as 10-60 minutes so you don’t eat up the compute
- In Databricks you pay for the compute and storage to your cloud provider, and to Databricks for their DBCU (Databricks Capacity Units)
- If you run serverless clusters you also pay for storage/compute to Databricks
- When you are in the Compute pane and select a specific cluster you can see how many Notebooks are running on that Cluster and if you click on it you can see what Notebooks exactly those are and who to belong/where they are located (which workspace)
- When you use Serverless you are not able to see the Jobs when in the notebook
