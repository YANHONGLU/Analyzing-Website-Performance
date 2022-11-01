#`1 find first_pageview_id

select min(website_pageviews.created_at) as first_created_at,
       min(website_pageviews.website_pageview_id) as first_pv_id
from website_pageviews
where pageview_url='/billing-2';

#2 summarize
select billing_version_seen,
       count(distinct website_session_id) as sessions,
       count(distinct order_id) as orders,
       count(distinct order_id) /count(distinct website_session_id) as billing_to_orders
from(
      select website_pageviews.website_session_id,
             website_pageviews.pageview_url as billing_version_seen,
             orders.order_id
	  from website_pageviews
      left join orders
      on orders.website_session_id=website_pageviews.website_session_id
      where website_pageviews.website_pageview_id>=53550
            and website_pageviews.created_at<'2012-11-10'
            and website_pageviews.pageview_url in ('/billing','/billing-2')) as billing_sessions_w_order
group by 1;