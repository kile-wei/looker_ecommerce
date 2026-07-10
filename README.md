# Production-Style E-Commerce Analytics Warehouse with dbt and BigQuery

![dbt Cloud](https://img.shields.io/badge/dbt-Cloud-orange)
![BigQuery](https://img.shields.io/badge/BigQuery-Google-blue)
![dbt CI](https://github.com/BigFlagger233/looker_ecommerce/actions/workflows/dbt_ci.yml/badge.svg)

### 🇯🇵 プロジェクト概要（日本語）

本プロジェクトは、dbt と BigQuery を用いた本番運用を想定したECサイト向けアナリティクス基盤のポートフォリオです。約240万件のイベント・トランザクションデータを対象に、staging / intermediate / marts の3層アーキテクチャでモデリングを行い、BIツールでそのまま利用可能な非正規化マート（OBT）を提供しています。

主なポイント：

- **コスト最適化**：incremental モデル（merge戦略）、日付パーティショニング、クラスタリングにより、BigQuery のスキャン量とフルリビルドを削減。遅延到着データにも lookback window で対応
- **データ品質**：source freshness チェック、スキーマテスト、Jinja による独自 generic テスト（`not_negative` 等）を実装し、下流レポートの信頼性を担保
- **CI/CD**：GitHub Actions により、PR ごとに独立した BigQuery データセット上で `dbt build` を実行。テスト失敗時はマージをブロックする品質ゲートを構築
- **セマンティックレイヤー**：GMV・純売上・AOV・返品率・CVR・LTV などの指標を LookML 形式で定義し、dbt の変換ロジックと BI 側の指標定義の責務を分離
- **冪等性の担保**：安定した unique key に基づく設計により、incremental パイプラインの安全な再実行が可能

<img width="3176" height="1606" alt="dbt_lineage" src="https://github.com/user-attachments/assets/fa96bfdb-707d-49ef-ae4d-0ecd41efbab6" />

詳細は以下の英語ドキュメントをご覧ください。

A modern analytics engineering portfolio project demonstrating dbt modeling, BigQuery optimization, CI/CD, data quality, and LookML-style semantic layer design.

### 💪 What This Project Demonstrates
- **Scalable dbt Architecture:** Built an end-to-end dbt project using staging, intermediate, and marts layers, following dbt-labs recommended structure and modular SQL modeling patterns.
- **Cost-Aware BigQuery Engineering:** Implemented incremental materializations, date partitioning, clustering, and lookback windows to reduce unnecessary full-table rebuilds and handle late-arriving records.
- **BI-Ready Mart Design:** Defined clear analytical grains such as order-item and session grain, then delivered selected denormalized OBT-style marts to simplify BI consumption and reduce repetitive joins.
- **Data Quality & Governance:** Added source freshness checks, schema tests, relationship tests, and custom Jinja-based tests such as `not_negative` to improve trust in downstream reporting.
- **Semantic Layer Design:** Created LookML-style modeling artifacts to define governed BI metrics such as GMV, net sales, AOV, return rate, conversion rate, and LTV without claiming production Looker deployment.

**Datasource:** Google BigQuery Public Dataset (`bigquery-public-data.thelook_ecommerce`)

**Dataset Overview:**
TheLook is a fictitious B2C eCommerce clothing site developed by the Looker team. The raw dataset provides a holistic view of the business, including:

- **Customers:** Demographics and geographic distributions.
- **Inventory & Products:** Product categories, cost, and distribution center tracking.
- **Transactions:** Order histories, fulfillment statuses, and item-level revenue.
- **Web Events:** Granular user session logs, page views, and conversion touchpoints.

### 🏗 Architecture & Lineage
- **Staging Layer:** Basic data cleaning. Unifies naming conventions and standardizes timestamp handling into UTC format.
- **Intermediate Layer:** Processes complex join and aggregation logic.
- **Marts Layer:** Final One Big Tables (OBTs) prepared for downstream BI tools and applications.

### 💡 Dimensional Modeling & OBT Delivery
Designed a Kimball-inspired modeling approach to define clear business entities, analytical grains, facts, and dimensions. Instead of serving a fully normalized star schema to BI users, selected marts are delivered as denormalized OBT-style models optimized for BigQuery and dashboard consumption.

For example, `fct_order_items` is an order-item-grain denormalized fact model that combines transactional measures with commonly used user, order, and product attributes. This reduces repetitive joins in BI tools while preserving a clear analytical grain.

### 📊 Core Business Assets
- `mart_user_lifetime_metrics`: Calculates LTV, margin, and order frequency across 7, 30, 90, 180, and 360-day windows. Empowers marketing teams to conduct cohort analysis by various dimensions effortlessly.
- `fct_sessions`: Aggregates raw event logs and constructs funnel statuses based on the session grain. Supports conversion funnel and abandoned cart rate analysis.
- `fct_order_items`: Applies the OBT schema, integrating transactional metrics with user and product dimensions. Supports GMV and margin analysis directly.

| Model | Grain | Primary Key | Refresh | Downstream Use |
|---|---|---|---|---|
| fct_order_items | One row per order item | order_item_id | Incremental daily | Revenue, GMV, margin analysis |
| fct_sessions | One row per session | session_id | Incremental daily | Funnel and conversion analysis |
| mart_user_lifetime_metrics | One row per user | user_id | Daily | LTV, retention, customer segmentation |

### ⚙️ Technical Highlights
- Processed ~2.4M raw event records across user activity and transactional workflows.
- Built session-grain and order-item-grain models to ensure analytical consistency and prevent metric fan-out.
- Implemented BigQuery incremental models using `merge` strategy, date partitioning, clustering, and lookback windows to handle late-arriving records.
- Designed denormalized OBT-style marts to reduce repetitive BI-layer joins and leverage BigQuery's columnar storage for selective column scanning.
- Configured idempotent transformation patterns with stable unique keys so incremental pipelines can be safely rerun without creating duplicate records.


### 🛠 Engineering Best Practices
- **Data Quality:** Implemented business rule tests for primary keys and foreign key relationships. Created a custom `not_negative` generic test to prevent anomalous values for attributes like price and cost.
- **DRY Principle:** Applied Jinja macros to handle repetitive data cleaning tasks, session aggregations, and custom tests.
- **Documentation:** Built comprehensive YML schema descriptions for all core business models.

### 🛡️ CI/CD & Data Quality Gates

This project uses GitHub Actions to validate dbt changes before they are merged into `main`.

- **Automated PR Validation:** Runs `dbt deps`, `dbt compile`, and `dbt build` on every pull request to validate model dependencies, SQL compilation, and data tests.
- **Isolated BigQuery CI Environment:** Builds PR changes into a temporary dataset named `dbt_ci_pr_<PR_NUMBER>` to avoid overwriting development or production datasets.
- **Quality Gates:** Blocks merges when dbt model builds, schema tests, custom tests, or dependency checks fail.
- **Secure Credential Management:** Uses GitHub Secrets to manage BigQuery service account credentials. No credential files are committed to the repository.
- **Future Improvement:** Introduce dbt Slim CI with state comparison to reduce BigQuery cost by building only modified models and downstream dependencies.

### 📂 Repository Structure
The project directory strictly follows the dbt-labs recommended structure for scalable modeling:

```text
looker_ecommerce/
├── models/
│   ├── staging/          # Base layer: renaming, and light cleaning
│   │   ├── schema.yml
│   │   ├── stg_users.sql
│   │   └── stg_orders.sql ...
│   ├── intermediate/     # Logic layer: Entity-level aggregations and complex joins
│   │   └── int_user_order_metrics.sql ...
│   └── marts/            # Business layer: Highly denormalized OBTs & Kimball dimensions
│   │   ├── fct_order_items.yml
│   │   ├── fct_order_items.sql
│   │   ├── mart_user_lifetime_metrics.yml
│   │   └── mart_user_lifetime_metrics.sql ...
├── macros/
│   ├── clean_string.sql
│   └── first_not_null_value.sql
├── tests/
│   ├── assert_funnel_time_is_sequential_in_sessions.sql
│   ├── assert_ltv_is_cumulative_in_users_metrics.sql
│   └── generic/
│       └── not_negative.sql
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
| GMV | `fct_order_items.gmv` | Sum of `sale_price` including cancelled/returned items |
| Net Sales | `fct_order_items.net_sales` | Sum of `net_sales_amount` |
| AOV | `fct_order_items.aov` | Net sales / distinct orders |
| Return Rate | `fct_order_items.return_rate` | Returned order items / total order items |
| Conversion Rate | `fct_sessions.conversion_rate` | Purchased sessions / total sessions |
| LTV_7d | `mart_user_lifetime_metrics.avg_ltv_7d` | Average `ltv_7d` per user |
| LTV_360d | `mart_user_lifetime_metrics.avg_ltv_360d` | Average `ltv_360d` per user |

Note: The LookML files are provided as implementation-ready design artifacts. They were not deployed to a licensed Looker instance.
