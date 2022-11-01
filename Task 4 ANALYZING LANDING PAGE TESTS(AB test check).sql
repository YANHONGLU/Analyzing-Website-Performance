#1 find out when the new lander/page launched
select min(created_at) as first_created_at,
       min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url='/lander-1' and created_at is not null;

#2 find the 1 website_pageview_id
create temporary table first_test_pageviews
select website_pageviews.website_session_id,
       min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
inner join website_sessions
on  website_pageviews.website_session_id=website_sessions.website_session_id
    and website_sessions.created_at<'2012-07-28'
    and website_pageviews.website_pageview_id>23504
    and utm_source='gsearch'
    and utm_campaign='nonbrand'
group by 1;

#3 identify the  landing page
create temporary table nonbrand_test_sessions_w_landing_page
select first_test_pageviews.website_session_id,
       website_pageviews.pageview_url as landing_page
from first_test_pageviews
left join website_pageviews
on website_pageviews.website_pageview_id=first_test_pageviews.min_pageview_id
where website_pageviews.pageview_url in ('/home','/lander-1');


#4 count pageviews
create temporary table nonbrand_test_bounced_sessions
select  nonbrand_test_sessions_w_landing_page.website_session_id,
        nonbrand_test_sessions_w_landing_page.landing_page,
        count(website_pageviews.website_pageview_id) as count_of_pages_viewed
from  nonbrand_test_sessions_w_landing_page
left join website_pageviews
on website_pageviews.website_pageview_id=nonbrand_test_sessions_w_landing_page.website_session_id
group by 1,2
having  count(website_pageviews.website_pageview_id)=1;

#5 identify bounce:bounce
select  nonbrand_test_sessions_w_landing_page.landing_page,
        nonbrand_test_sessions_w_landing_page.website_session_id,
        nonbrand_test_bounced_sessions.website_session_id as bounced_website_session_id
from  nonbrand_test_sessions_w_landing_page
left join nonbrand_test_bounced_sessions
on nonbrand_test_bounced_sessions.website_session_id=nonbrand_test_sessions_w_landing_page.website_session_id
order by 2;


#6summarize
select  nonbrand_test_sessions_w_landing_page.landing_page,
        count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as sessions,
        count(distinct nonbrand_test_bounced_sessions.website_session_id) as bounced_sessions,
        count(distinct nonbrand_test_bounced_sessions.website_session_id) 
        /count(distinct nonbrand_test_sessions_w_landing_page.website_session_id) as bounce_rate
from  nonbrand_test_sessions_w_landing_page
left join nonbrand_test_bounced_sessions
on nonbrand_test_bounced_sessions.website_session_id=nonbrand_test_sessions_w_landing_page.website_session_id
group by 1;
