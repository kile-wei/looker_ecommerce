# Looker E-Commerce Data Warehouse (dbt)

![dbt Cloud](https://img.shields.io/badge/dbt-Cloud-orange)
![BigQuery](https://img.shields.io/badge/BigQuery-Google-blue)
![dbt CI](https://github.com/BigFlagger233/looker_ecommerce/actions/workflows/dbt_ci.yml/badge.svg)

A production-style analytics engineering project built with dbt and BigQuery, transforming raw e-commerce event data into a business-ready warehouse optimized for BI analytics and downstream reporting.

**Datasource:** Google BigQuery Public Dataset (`bigquery-public-data.thelook_ecommerce`)

**Dataset Overview:**
TheLook is a fictitious B2C eCommerce clothing site developed by the Looker team. The raw dataset provides a holistic view of the business, including:

- **Customers:** Demographics and geographic distributions.
- **Inventory & Products:** Product categories, cost, and distribution center tracking.
- **Transactions:** Order histories, fulfillment statuses, and item-level revenue.
- **Web Events:** Granular user session logs, page views, and conversion touchpoints.

### 🏗 Architecture & Lineage
<img width="3176" height="1606" alt="dbt_lineage" src="https://github.com/user-attachments/assets/fa96bfdb-707d-49ef-ae4d-0ecd41efbab6" />

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
- Implemented BigQuery-optimized incremental fact models using merge strategy, date partitioning, clustering, and lookback windows to handle late-arriving data

### 🛠 Engineering Best Practices
- **Data Quality:** Implemented business rule tests for primary keys and foreign key relationships. Created a custom `not_negative` generic test to prevent anomalous values for attributes like price and cost.
- **DRY Principle:** Applied Jinja macros to handle repetitive data cleaning tasks, session aggregations, and custom tests.
- **Documentation:** Built comprehensive YML schema descriptions for all core business models.

### 🛡️ CI/CD with GitHub Actions

This project includes a GitHub Actions workflow to automatically validate dbt changes before they are merged into the `main` branch.

The CI workflow is triggered on every pull request to `main`.

#### CI Workflow

The workflow runs the following dbt commands:

```bash
dbt deps
dbt compile --target ci
dbt build --target ci
```

#### What the CI Validates

The CI pipeline validates that:

- dbt package dependencies can be installed successfully
- SQL models and Jinja macros can be compiled
- dbt models can be built in BigQuery
- data quality tests pass before merging
- broken model dependencies are caught during pull request review

#### BigQuery Environment Isolation

CI builds dbt models into an isolated BigQuery dataset using the pull request number:

```text
dbt_ci_pr_<pull_request_number>
```

This prevents pull request validation from overwriting development or production tables.

#### Credential Management

BigQuery credentials are managed securely through GitHub Secrets.

The workflow uses:

```text
GCP_PROJECT_ID
GCP_SERVICE_ACCOUNT_JSON
```

No service account key or credential file is committed to the repository.

#### Current CI Scope

The current implementation uses a baseline CI approach:

```bash
dbt build --target ci
```

This ensures the full dbt project can be built and tested successfully in a controlled CI environment.

A future enhancement is to introduce slim CI with dbt state comparison:

```bash
dbt build --select state:modified+ --defer --state
```

This would reduce BigQuery cost by only building modified models and their downstream dependencies.

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
```

### 🔮 BI Semantic Layer Design

This project includes a LookML-style semantic layer design to demonstrate how dbt marts can be consumed by BI tools such as Looker.

The semantic layer focuses on:
- reusable metric definitions: GMV, net sales, AOV, return rate, conversion rate, and LTV
- clear explore design based on business analysis workflows
- explicit primary keys and join relationships to avoid fanout
- separation of responsibilities between dbt transformation logic and BI-facing metric definitions

| Metric | LookML Measure | Definition |
|---|---|---|
| GMV | `fct_order_items.gmv` | Sum of `sale_price` before excluding cancelled/returned items |
| Net Sales | `fct_order_items.net_sales` | Sum of `net_sales_amount` |
| AOV | `fct_order_items.aov` | Net sales / distinct orders |
| Return Rate | `fct_order_items.return_rate` | Returned order items / total order items |
| Conversion Rate | `fct_sessions.conversion_rate` | Purchased sessions / total sessions |
| LTV_7d | `mart_user_lifetime_metrics.avg_ltv_7d` | Average `ltv_7d` per user |
| LTV_360d | `mart_user_lifetime_metrics.avg_ltv_360d` | Average `ltv_360d` per user |

Note: The LookML files are provided as implementation-ready design artifacts. They were not deployed to a licensed Looker instance.
