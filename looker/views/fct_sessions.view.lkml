view: fct_sessions {
  sql_table_name: `my-project-20260419-493813.dbt_bigflagger233_marts.fct_sessions` ;;

  dimension: session_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.session_id ;;
  }

  dimension: user_id { type: string sql: ${TABLE}.user_id ;; }
  dimension: browser { type: string sql: ${TABLE}.browser ;; }
  dimension: traffic_source { type: string sql: ${TABLE}.traffic_source ;; }
  dimension: city { type: string sql: ${TABLE}.city ;; }
  dimension: state { type: string sql: ${TABLE}.state ;; }

  dimension_group: session_start {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.session_start_at_utc ;;
  }

  dimension: has_viewed_product {
    type: yesno
    sql: ${TABLE}.has_viewed_product = 1 ;;
  }

  dimension: has_added_to_cart {
    type: yesno
    sql: ${TABLE}.has_added_to_cart = 1 ;;
  }

  dimension: has_purchased {
    type: yesno
    sql: ${TABLE}.has_purchased = 1 ;;
  }

  dimension: is_abandoned_cart {
    type: yesno
    sql: ${TABLE}.is_abandoned_cart ;;
  }

  measure: sessions {
    type: count
  }

  measure: purchasers_sessions {
    type: count
    filters: [has_purchased: "yes"]
  }

  measure: abandoned_cart_sessions {
    type: count
    filters: [is_abandoned_cart: "yes"]
  }

  measure: conversion_rate {
    type: number
    sql: SAFE_DIVIDE(${purchasers_sessions}, ${sessions}) ;;
    value_format_name: percent_2
    description: "Conversion rate = purchased sessions / total sessions."
  }

  measure: avg_session_duration_seconds {
    type: average
    sql: ${TABLE}.session_duration_seconds ;;
    value_format_name: decimal_1
  }
}
