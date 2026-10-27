# SQL Email Metrics Analysis

## Task
Build a dataset for a dashboard that shows how email campaigns perform across countries: how many accounts (subscribers) are created, and how many emails are sent, opened and clicked.

## What the query does
- Counts created accounts by date, country, send interval, verification and unsubscribe status
- Counts sent, opened emails and link visits for the same dimensions
- Combines both result sets with `UNION ALL` and collapses them into one row per combination
- Calculates total accounts and total sent emails per country
- Ranks countries by both metrics and keeps the top 10 by either one

## SQL techniques used
CTEs, multiple `JOIN`s (including `LEFT JOIN`), `UNION ALL`, aggregation, window functions, `DENSE_RANK`, `QUALIFY`

## Tools
Google BigQuery, Looker Studio

## Result
[Dashboard link](https://datastudio.google.com/reporting/ee51abde-7d24-409b-ba20-c8ee8bc404a2)
