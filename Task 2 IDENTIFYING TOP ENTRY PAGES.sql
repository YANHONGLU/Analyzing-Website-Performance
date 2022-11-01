create temporary table  first_pv_per_session
select website_session_id,
       min(website_pageview_id) as first_pv
from website_pageviews
where created_at<'2012-06-12'
group by 1 ;

select website_pageviews.pageview_url as landing_page_url,
       count(distinct first_pv_per_session.website_session_id) as sessions_hitting_page
from first_pv_per_session
left join website_pageviews
on first_pv_per_session.first_pv=website_pageviews.website_pageview_id
group by 1;
