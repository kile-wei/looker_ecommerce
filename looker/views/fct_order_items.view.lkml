view: fct_order_items {
  sql_table_name: `my-project-20260419-493813.dbt_bigflagger233_marts.fct_order_items` ;;

  dimension: order_item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.order_item_id ;;
  }

  dimension: order_id { type: string sql: ${TABLE}.order_id ;; }
  dimension: user_id { type: string sql: ${TABLE}.user_id ;; }
  dimension: product_id { type: string sql: ${TABLE}.product_id ;; }

  dimension: status { type: string sql: ${TABLE}.status ;; }
  dimension: product_category { type: string sql: ${TABLE}.product_category ;; }
  dimension: product_department { type: string sql: ${TABLE}.product_department ;; }
  dimension: product_brand { type: string sql: ${TABLE}.product_brand ;; }
  dimension: user_country { type: string sql: ${TABLE}.user_country ;; }
  dimension: user_traffic_source { type: string sql: ${TABLE}.user_traffic_source ;; }

  dimension_group: order_created {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.order_created_at_utc ;;
  }

  dimension: is_completed_item {
    type: yesno
    sql: ${TABLE}.is_completed_item ;;
  }

  dimension: is_cancelled_item {
    type: yesno
    sql: ${TABLE}.is_cancelled_item ;;
  }

  dimension: is_returned_item {
    type: yesno
    sql: ${TABLE}.is_returned_item ;;
  }

  measure: order_items {
    type: count
    description: "Count of order item rows."
  }

  measure: orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

  measure: customers {
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: gmv {
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    description: "GMV = Sum of sale_price including cancelled/returned items."
  }

  measure: net_sales {
    type: sum
    sql: ${TABLE}.net_sales_amount ;;
    value_format_name: usd
    description: "Net sales excluding cancelled and returned order items."
  }

  measure: gross_margin {
    type: sum
    sql: ${TABLE}.net_gross_margin ;;
    value_format_name: usd
    description: "Net gross margin excluding cancelled and returned order items."
  }

  measure: aov {
    type: number
    sql: SAFE_DIVIDE(${net_sales}, ${orders}) ;;
    value_format_name: usd
    description: "Average order value = net sales / distinct orders."
  }

  measure: return_rate {
    type: number
    sql: SAFE_DIVIDE(
      SUM(CASE WHEN ${TABLE}.is_returned_item THEN 1 ELSE 0 END),
      COUNT(*)
    ) ;;
    value_format_name: percent_2
    description: "Returned order items / total order items."
  }

  measure: cancellation_rate {
    type: number
    sql: SAFE_DIVIDE(
      SUM(CASE WHEN ${TABLE}.is_cancelled_item THEN 1 ELSE 0 END),
      COUNT(*)
    ) ;;
    value_format_name: percent_2
  }
}
