# Looker E-Commerce Data Warehouse (dbt)

![dbt Cloud](https://img.shields.io/badge/dbt-Cloud-orange)
![BigQuery](https://img.shields.io/badge/BigQuery-Google-blue)

A production-style analytics engineering project built with dbt and BigQuery, transforming raw e-commerce event data into a business-ready warehouse optimized for BI analytics and downstream reporting.

**Datasource:** Google BigQuery Public Dataset (`bigquery-public-data.thelook_ecommerce`)

**Dataset Overview:**
TheLook is a fictitious B2C eCommerce clothing site developed by the Looker team. The raw dataset provides a holistic view of the business, including:

- **Customers:** Demographics and geographic distributions.
- **Inventory & Products:** Product categories, cost, and distribution center tracking.
- **Transactions:** Order histories, fulfillment statuses, and item-level revenue.
- **Web Events:** Granular user session logs, page views, and conversion touchpoints.

### 🏗 Architecture & Lineage
<img width="3304" height="1622" alt="dbt_lineage" src="https://github.com/user-attachments/assets/8b5794b9-73c5-4573-90d7-baa320c0f852" />


- **Staging Layer:** Basic data cleaning. Unifies naming conventions and standardizes timestamp handling into UTC format.
- **Intermediate Layer:** Processes complex join and aggregation logic.
- **Marts Layer:** Final One Big Tables (OBTs) prepared for downstream BI tools and applications.

### 💡 Dimensional Modeling & OBT Delivery
Designed a Kimball-inspired dimensional architecture to organize business entities (identifying core facts and dimensions). To optimize for modern columnar databases and downstream BI tool performance, the final marts layer is delivered as highly denormalized **One Big Tables (OBTs)** (e.g., `fct_order_items`), eliminating the need for complex joins at the BI layer.

### 📊 Core Business Assets
- `dim_users_metrics`: Calculates LTV, margin, and order frequency across 7, 30, 90, 180, and 360-day windows. Empowers marketing teams to conduct cohort analysis by various dimensions effortlessly.
- `fct_sessions`: Aggregates raw event logs and constructs funnel statuses based on the session grain. Supports conversion funnel and abandoned cart rate analysis.
- `fct_order_items`: Applies the OBT schema, integrating transactional metrics with user and product dimensions. Supports GMV and margin analysis directly.

### ⚙️ Technical Highlights
- Processed ~2.4M raw event records across user activity and transactional workflows
- Built session- and order-item-grain models to ensure analytical consistency and prevent metric fan-out
- Applied dbt materialization strategies optimized for BigQuery and downstream BI workloads

### 🛠 Engineering Best Practices
- **Data Quality:** Implemented business rule tests for primary keys and foreign key relationships. Created a custom `not_negative` generic test to prevent anomalous values for attributes like price and cost.
- **DRY Principle:** Applied Jinja macros to handle repetitive data cleaning tasks, session aggregations, and custom tests.
- **Documentation:** Built comprehensive YML schema descriptions for all core business models.

### 📂 Repository Structure
The project directory strictly follows the dbt-labs recommended structure for scalable modeling:

```text
looker_ecommerce/
├── models/
│   ├── staging/          # Base layer: Casting, renaming, and light cleaning
│   │   ├── schema.yml
│   │   ├── stg_users.sql
│   │   └── stg_orders.sql ...
│   ├── intermediate/     # Logic layer: Entity-level aggregations and complex joins
│   │   └── int_users_purchase.sql ...
│   └── marts/            # Business layer: Highly denormalized OBTs & Kimball dimensions
│   │   ├── fct_order_items.yml
│   │   ├── fct_order_items.sql
│   │   ├── dim_users_metrics.yml
│   │   └── dim_users_metrics.sql ...
├── macros/               # Jinja macros for DRY code
│   └── not_negative.sql  # Custom generic test macro
├── tests/                # Custom singular data tests
├── dbt_project.yml       # Global project configurations
└── packages.yml          # dbt-utils and other package dependencies
```

### 🚀 How to Run
Use the following dbt commands to get started:

```bash
# Prerequisites
# - dbt Cloud account with a BigQuery connection configured
# - Access to the BigQuery public dataset: bigquery-public-data.thelook_ecommerce

dbt deps
dbt run
dbt test


