connection: "bigquery_ecommerce"

include: "/views/*.view.lkml"

explore: fct_order_items {
  label: "Order Item Analysis"
  description: "Order-item grain explore for sales, returns, margin, product, and customer analysis."

  join: mart_user_lifetime_metrics {
    type: left_outer
    sql_on: ${fct_order_items.user_id} = ${mart_user_lifetime_metrics.user_id} ;;
    relationship: many_to_one
  }
}

explore: fct_sessions {
  label: "Session Funnel Analysis"
  description: "Session-level explore for traffic, funnel progression, conversion, and abandoned cart analysis."

  join: mart_user_lifetime_metrics {
    type: left_outer
    sql_on: ${fct_sessions.user_id} = ${mart_user_lifetime_metrics.user_id} ;;
    relationship: many_to_one
  }
}
