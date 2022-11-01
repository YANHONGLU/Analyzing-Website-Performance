#1 select all pageviews
create temporary table pageview_level
select website_sessions.website_session_id,website_pageviews.pageview_url,
       case when pageview_url='/products' then 1 else 0 end as products_page,
       case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_page,
       case when pageview_url='/cart' then 1 else 0 end as cart_page,
       case when pageview_url='/shipping' then 1 else 0 end as shipping_page,
       case when pageview_url='/billing' then 1 else 0 end as billing_page,
       case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.utm_source='gsearch'
      and website_sessions.utm_campaign='nonbrand'
      and website_sessions.created_at>'2012-08-05'
      and website_sessions.created_at<'2012-09-05'
order by 1,website_pageviews.created_at;

#2identify each pageview as the specific funnel step
create temporary table session_level_made_it_flags
select website_session_id,
       max(products_page) as product_made_it,
       max(mrfuzzy_page) as mrfuzzy_made_it,
       max(cart_page) as cart_made_it,#
       max(shipping_page) as shipping_made_it,
       max(billing_page) as billing_made_it,
       max(thankyou_page) as thankyou_made_it
from pageview_level
group by 1;


#3 create session-level conversion funnel view
select  count(distinct website_session_id) as sessions,
        count(distinct case when product_made_it=1 then website_session_id  else null end) as to_products,
        count(distinct case when mrfuzzy_made_it=1 then website_session_id  else null end) as to_mrfuzzy,
        count(distinct case when cart_made_it=1 then website_session_id  else null end) as to_cart,
        count(distinct case when shipping_made_it=1 then website_session_id  else null end) as to_shipping,
        count(distinct case when billing_made_it=1 then website_session_id  else null end) as to_billing,
        count(distinct case when thankyou_made_it=1 then website_session_id  else null end) as to_thankyou
from session_level_made_it_flags;

#4 summary

select  count(distinct case when product_made_it=1 then website_session_id  else null end)/count(distinct website_session_id) as lander_click_rt,
        count(distinct case when mrfuzzy_made_it=1 then website_session_id  else null end)/count(distinct case when product_made_it=1 then website_session_id  else null end) as products_click_rt,
        count(distinct case when cart_made_it=1 then website_session_id  else null end)/ count(distinct case when mrfuzzy_made_it=1 then website_session_id  else null end) as mrfuzzy_click_rt,
        count(distinct case when shipping_made_it=1 then website_session_id  else null end)/count(distinct case when cart_made_it=1 then website_session_id  else null end) as cart_click_rt,
        count(distinct case when billing_made_it=1 then website_session_id  else null end)/count(distinct case when shipping_made_it=1 then website_session_id  else null end) as tshipping_click_rt,
        count(distinct case when thankyou_made_it=1 then website_session_id  else null end)/count(distinct case when billing_made_it=1 then website_session_id  else null end) as billing_click_rt
from session_level_made_it_flags;