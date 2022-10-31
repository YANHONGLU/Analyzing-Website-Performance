use mavenfuzzyfactory;
select pageview_url,
       count(distinct website_session_id) as sessions
from website_pageviews
where created_at <'2012-06-09'
group by 1
order by 2 desc