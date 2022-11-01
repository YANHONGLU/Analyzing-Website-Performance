#1finding the 1 website_pageview_id
create temporary table first_pageviews 
select website_session_id,min(website_pageview_id) as min_pageview_id
from website_pageviews
where created_at<'2012-06-14'
group by 1;

#2identify the landing page of each session
create temporary table sessions_w_home_landing_page
select first_pageviews.website_session_id,
       website_pageviews.pageview_url as landing_page
from first_pageviews
left join website_pageviews
on website_pageviews.website_pageview_id=first_pageviews.min_pageview_id
where website_pageviews.pageview_url='/home';

#3 identify bounces: count pageviews
create temporary table bounced_sessions
select sessions_w_home_landing_page.website_session_id,
       sessions_w_home_landing_page.landing_page,
       count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from sessions_w_home_landing_page
left join website_pageviews
on website_pageviews.website_session_id=sessions_w_home_landing_page.website_session_id
group by 1,2
having count(website_pageviews.website_pageview_id)=1;

#identify bounces:bounces
select sessions_w_home_landing_page.website_session_id,
       bounced_sessions.website_session_id as bounced_website_session_id
from sessions_w_home_landing_page
left join bounced_sessions
on sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id
order by 1;

#identify bounces:bounce rate
select count(distinct sessions_w_home_landing_page.website_session_id) as sessions,
       count(distinct bounced_sessions.website_session_id) as bounced_sessions
from  sessions_w_home_landing_page
left join bounced_sessions
on sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id;

#summary
select count(distinct sessions_w_home_landing_page.website_session_id) as sessions,
       count(distinct bounced_sessions.website_session_id) as bounced_sessions,
       count(distinct bounced_sessions.website_session_id)
       / count(distinct sessions_w_home_landing_page.website_session_id) as bounce_rate
from  sessions_w_home_landing_page
left join bounced_sessions
on sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id;