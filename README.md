### Azure-Data-Factory-Pipeline-Tokyo-Olympics-2021

#### Project Overview
This document provides a comprehensive guide to the Azure Data Factory (ADF) pipeline designed for ingesting, transforming, and storing data from various sources into Azure Synapse Analytics and Snowflake, with integration into Power BI for data visualization. It also includes security implementations using Azure Key Vault, source control using GitHub, and CI/CD best practices.

---

## 1. Architecture Overview

![System Architecture](/architecture/high_level_architecture.png)

### 1.1 High-Level Design
The solution consists of the following major components:

- **Azure Data Factory (ADF)** for orchestrating data movement and transformation.
- **Azure Synapse Analytics** for large-scale data processing and reporting.
- **Snowflake** as an alternative data warehouse for specific use cases.
- **Azure Key Vault** for secure credential storage.
- **Azure Data Lake Storage Gen2 (ADLS Gen2)** as the primary data lake.
- **GitHub Integration** for version control and CI/CD.
- **Power BI** for dashboarding and data visualization.

### 1.2 Data Flow Diagram
#### Data Ingestion
- Data is extracted from JSON, CSV, Parquet, and REST APIs.
- Sources include Azure Blob Storage, SQL databases, and external APIs.
- Ingested data is stored in ADLS Gen2 raw zone.

#### Data Transformation
- ADF data flows process the raw data using mapping data flows.
- Transformations include column renaming, type casting, aggregation, and ranking.
- The cleaned data is stored in ADLS Gen2 publish zone.

#### Data Storage & Processing
- Processed data is loaded into Azure Synapse and Snowflake for analytics.
- **External tables** are created in Synapse for direct Power BI access.

#### Data Visualization
- Power BI fetches the data from Synapse and Snowflake.
- Dashboards display medal counts, athlete demographics, and country-wise performance.

---

## 2. Data Pipelines

### 2.1 Master Pipeline - Gen2 to Sink
- **Source:** ADLS Gen2 (DelimitedText, Parquet, JSON files)
- **Transformations:** Mapping Data Flows for data cleansing and enrichment
- **Sink:** ADLS Gen2 Publish Zone & Azure Synapse Analytics
- **Notifications:** Email alerts on success/failure via Azure Logic Apps

### 2.2 Master Pipeline - Snowflake Sink
- **Source:** ADLS Gen2
- **Transformations:** Data conversion and enrichment
- **Sink:** Snowflake database
- **Error Handling:** Retry policies and failure notifications

### 2.3 REST API Data Ingestion
- **Source:** REST API calls (using Web Activity)
- **Security:** Authentication via Azure Key Vault
- **Processing:** Data transformation and JSON flattening
- **Sink:** Synapse & Snowflake

---

## 3. Data Transformation Logic

### 3.1 Derived Column Transformations
- `initCap(PersonName)`: Capitalizes the first letter of each word.
- `coalesce(Event, 'N/A')`: Replaces NULL values with 'N/A'.

### 3.2 Data Type Casting
- Converts numeric columns to BIGINT for consistency.
- Ensures DATE columns are properly formatted.

### 3.3 Ranking Operations
- Rank by Gold, Silver, Bronze Medals using the Rank transformation.
- Dense Ranking to avoid duplicate rank values.

### 3.4 Aggregation
- Groups data by Team, Discipline, Country to compute total events.

---

## 4. **External Tables** (NEW SECTION)

### 4.1 What are External Tables?
External tables allow querying data stored outside of Synapse, such as in **Azure Data Lake Storage (ADLS Gen2)**, without physically moving the data.

### 4.2 How Are They Used in This Project?
- **Stored in ADLS Gen2** and referenced in **Synapse Analytics**.
- Created using `CREATE EXTERNAL TABLE` statements in Synapse.
- Used for **direct Power BI access**, reducing data duplication.

### 4.3 Persistence Across Sessions
- **Yes**, external tables remain available after a session ends because they are stored in the database’s metadata.
- However, **external data sources** (e.g., ADLS Gen2 paths) must be accessible.

### 4.4 Benefits
- **Faster queries** by avoiding unnecessary data movement.
- **Cost savings** by not duplicating data.
- **Flexibility** to analyze external data without ingestion.

### 4.5 Best Practices
- Store data in **Parquet format** for better performance.
- Optimize queries using **partitioned external tables**.
- Secure data with **RBAC and Azure Key Vault integration**.

---

## 5. Security and Access Control

### 5.1 Azure Key Vault Integration
- Stores API keys, database credentials, and storage access keys securely.
- Secrets are accessed dynamically in ADF pipelines using Linked Services.

### 5.2 Role-Based Access Control (RBAC)
- **ADF Contributor Role:** Allows pipeline development and execution.
- **Synapse Administrator:** Full control over Synapse workspaces.
- **Snowflake User Roles:** Grant access to specific schemas/tables.

### 5.3 Data Encryption
- Transparent Data Encryption (TDE) enabled for Azure SQL.
- Geo-backup activated for disaster recovery.

---

## 6. GitHub Integration & CI/CD

### 6.1 Git Configuration
- **GitHub Repository:** Azure-Data-Factory-Pipeline
- **Collaboration Branch:** Development
- **Publish Branch:** adf_publish

### 6.2 CI/CD Pipeline
- **Development:** Code changes are committed to Development.
- **Validation:** Pipelines are validated and debugged before merging.
- **Deployment:** `adf_publish` branch triggers an ARM template deployment.

---

## 7. Power BI Dashboard

### 7.1 Data Source Configuration
- **DirectQuery Mode** for Synapse external tables.
- **Snowflake Connector** for real-time data visualization.

### 7.2 Dashboard Features
- **Medal Breakdown:** Gold, Silver, Bronze distribution per country.
- **Athlete Demographics:** Gender-based statistics.
- **Event Map:** Global distribution of Olympic events.

---

## 8. Performance Optimization

### 8.1 Pipeline Performance
- **Parallel Processing:** Data flows utilize parallelism for faster execution.
- **Partitioning Strategy:** Ensures large datasets are efficiently processed.

### 8.2 Query Optimization
- **Synapse Optimized Tables:** Uses columnstore indexes for improved query performance.
- **Snowflake Clustering:** Reduces query scan times.

### 8.3 Storage Optimization
- **Delta Lake Format:** Ensures efficient data versioning.
- **Parquet Compression:** Uses Snappy for better compression ratios.

---

## 9. Error Handling and Logging

### 9.1 Failure Notification
- Logic Apps trigger email alerts for failed pipeline runs.
- Error details are captured in a logging table.

### 9.2 Retry Mechanism
- **Exponential Backoff** for API retries.
- **Max Retries** set to 3 for data ingestion failures.

---

## 10. Future Enhancements

### 10.1 Machine Learning Integration
- Deploying an ML model to predict Olympic medal counts.
- **Azure Machine Learning** service integration.

### 10.2 Data Governance
- Implementing **Azure Purview** for lineage tracking.

---

## 11. Conclusion
This detailed documentation outlines the entire Azure Data Factory pipeline, from **data ingestion to transformation, storage, security, and visualization**. The project integrates **best practices for scalability, security, and automation** while ensuring seamless analytics through Power BI.

---

