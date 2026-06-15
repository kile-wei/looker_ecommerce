view: mart_user_lifetime_metrics {
  sql_table_name: `my-project-20260419-493813.dbt_bigflagger233_marts.mart_user_lifetime_metrics` ;;

  # ==========================================
  # Dimensions
  # ==========================================
  dimension: user_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: gender { type: string sql: ${TABLE}.gender ;; }
  dimension: country { type: string sql: ${TABLE}.country ;; }
  dimension: state { type: string sql: ${TABLE}.state ;; }
  dimension: city { type: string sql: ${TABLE}.city ;; }
  dimension: traffic_source { type: string sql: ${TABLE}.traffic_source ;; }

  dimension_group: user_created {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.user_created_at_utc ;;
  }

  dimension_group: first_order {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.first_order_time ;;
  }

  # ==========================================
  # Measures: User Counts
  # ==========================================
  measure: users {
    type: count
    description: "Total number of users."
  }

  measure: purchasing_users {
    type: count
    filters: [first_order_time: "-NULL"]
    description: "Number of users who have made at least one purchase."
  }

  # ==========================================
  # Measures: LTV (Lifetime Value)
  # ==========================================
  measure: avg_ltv_7d { type: average sql: ${TABLE}.ltv_7d ;; value_format_name: usd description: "Average 7-day user lifetime value." }
  measure: avg_ltv_30d { type: average sql: ${TABLE}.ltv_30d ;; value_format_name: usd description: "Average 30-day user lifetime value." }
  measure: avg_ltv_90d { type: average sql: ${TABLE}.ltv_90d ;; value_format_name: usd description: "Average 90-day user lifetime value." }
  measure: avg_ltv_180d { type: average sql: ${TABLE}.ltv_180d ;; value_format_name: usd description: "Average 180-day user lifetime value." }
  measure: avg_ltv_360d { type: average sql: ${TABLE}.ltv_360d ;; value_format_name: usd description: "Average 360-day user lifetime value." }

  # ==========================================
  # Measures: LTV Margin
  # ==========================================
  measure: avg_ltv_margin_7d { type: average sql: ${TABLE}.ltv_margin_7d ;; value_format_name: usd description: "Average 7-day user lifetime gross margin." }
  measure: avg_ltv_margin_30d { type: average sql: ${TABLE}.ltv_margin_30d ;; value_format_name: usd description: "Average 30-day user lifetime gross margin." }
  measure: avg_ltv_margin_90d { type: average sql: ${TABLE}.ltv_margin_90d ;; value_format_name: usd description: "Average 90-day user lifetime gross margin." }
  measure: avg_ltv_margin_180d { type: average sql: ${TABLE}.ltv_margin_180d ;; value_format_name: usd description: "Average 180-day user lifetime gross margin." }
  measure: avg_ltv_margin_360d { type: average sql: ${TABLE}.ltv_margin_360d ;; value_format_name: usd description: "Average 360-day user lifetime gross margin." }

  # ==========================================
  # Measures: Orders Amount
  # ==========================================
  measure: avg_orders_amount_7d { type: average sql: ${TABLE}.orders_amount_7d ;; description: "Average number of orders placed within 7 days of user creation." }
  measure: avg_orders_amount_30d { type: average sql: ${TABLE}.orders_amount_30d ;; description: "Average number of orders placed within 30 days of user creation." }
  measure: avg_orders_amount_90d { type: average sql: ${TABLE}.orders_amount_90d ;; description: "Average number of orders placed within 90 days of user creation." }
  measure: avg_orders_amount_180d { type: average sql: ${TABLE}.orders_amount_180d ;; description: "Average number of orders placed within 180 days of user creation." }
  measure: avg_orders_amount_360d { type: average sql: ${TABLE}.orders_amount_360d ;; description: "Average number of orders placed within 360 days of user creation." }

  # ==========================================
  # Measures: Number of Items
  # ==========================================
  measure: avg_num_of_item_7d { type: average sql: ${TABLE}.num_of_item_7d ;; description: "Average number of item units purchased within 7 days of user creation." }
  measure: avg_num_of_item_30d { type: average sql: ${TABLE}.num_of_item_30d ;; description: "Average number of item units purchased within 30 days of user creation." }
  measure: avg_num_of_item_90d { type: average sql: ${TABLE}.num_of_item_90d ;; description: "Average number of item units purchased within 90 days of user creation." }
  measure: avg_num_of_item_180d { type: average sql: ${TABLE}.num_of_item_180d ;; description: "Average number of item units purchased within 180 days of user creation." }
  measure: avg_num_of_item_360d { type: average sql: ${TABLE}.num_of_item_360d ;; description: "Average number of item units purchased within 360 days of user creation." }