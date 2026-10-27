-- Count the number of created accounts

with account_metrics as (
SELECT
    s.date as date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    count(a.id) as account_cnt
FROM `data-analytics-mate.DA.account` a
join `data-analytics-mate.DA.account_session` acs
on a.id = acs.account_id
join `data-analytics-mate.DA.session` s
on s.ga_session_id = acs.ga_session_id
join `data-analytics-mate.DA.session_params` sp
on sp.ga_session_id = s.ga_session_id
group by date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed),


-- Count the number of sent emails, opened emails and email link visits
email_metrics as (SELECT
    date_add(s.date, interval es.sent_date day) as date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    count(distinct es.id_message) as sent_msg,
    count(distinct eo.id_message) as open_msg,
    count(distinct ev.id_message) as visit_msg
FROM `data-analytics-mate.DA.account` a
join `data-analytics-mate.DA.account_session` acs
on a.id = acs.account_id
join `data-analytics-mate.DA.session` s
on s.ga_session_id = acs.ga_session_id
join `data-analytics-mate.DA.session_params` sp
on sp.ga_session_id = s.ga_session_id
join `data-analytics-mate.DA.email_sent` es
on a.id = es.id_account
left join `data-analytics-mate.DA.email_open` eo
on eo.id_message = es.id_message
left join `data-analytics-mate.DA.email_visit` ev
on ev.id_message = es.id_message
group by date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed),


-- Combine the two datasets with the metrics above using UNION ALL
unioned as (
select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    0 as sent_msg,
    0 as open_msg,
    0 as visit_msg
from account_metrics
union all
select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0 as account_cnt,
    sent_msg,
    open_msg,
    visit_msg
from email_metrics
),


-- Collapse the placeholder zeros left after the union into one row per dimension combination
final_1 as (
 select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    sum(account_cnt) as account_cnt,
    sum(sent_msg) as sent_msg,
    sum(open_msg) as open_msg,
    sum(visit_msg) as visit_msg,
from unioned
group by date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed),


-- Calculate the total number of created accounts (subscribers) and the total number of sent emails per country, excluding unsubscribed accounts
final_2 as (select
    *,
    sum(case when is_unsubscribed = 0 then account_cnt end) over(partition by country) as total_country_account_cnt,
    sum(sent_msg) over(partition by country) as total_country_sent_cnt
from final_1)


-- Rank countries by total accounts created and by total emails sent, then keep only the top 10 by either metric
   select *,
     dense_rank() over(order by total_country_account_cnt desc) as rank_total_country_account_cnt,
     dense_rank() over(order by total_country_sent_cnt desc) as rank_total_country_sent_cnt
from final_2
qualify (dense_rank() over(order by total_country_account_cnt desc) <= 10) or (dense_rank() over(order by total_country_sent_cnt desc) <= 10);
