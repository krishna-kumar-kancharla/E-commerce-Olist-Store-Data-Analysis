use excelr;
select * from ecommerce;

-- 1) Weekday vs Weekend Payment Statistics
select 
    case 
        when dayofweek(str_to_date(order_purchase_timestamp, '%d-%m-%Y %H:%i:%s')) in (1, 7) then 'Weekend'
        else 'Weekday'
    end as day_type,
    payment_type,
    count(distinct order_id) as total_orders,
    round(avg(payment_value), 2) as avg_payment_value,
    round(sum(payment_value), 2) as total_payment_value
from ecommerce
where order_purchase_timestamp is not null
    and payment_type is not null
group by day_type, payment_type
order by day_type desc, total_payment_value desc; 

SELECT 
    CASE 
        WHEN DAYOFWEEK(order_purchase_timestamp) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    Round(SUM(payment_value)) AS total_payment_value,
    Round(AVG(payment_value) )AS avg_payment_value
    from ecommerce data
GROUP BY day_type
order by day_type;

-- 2) Number of Orders with review score 5 and payment type as credit card
select 
    count(distinct order_id) as orders_with_5star_creditcard,
    count(*) as total_records,
    round(sum(payment_value), 2) as total_payment_value,
    round(avg(payment_value), 2) as avg_payment_value,
    round(avg(payment_installments), 2) as avg_installments
from ecommerce
where review_score = 5
    and payment_type = 'credit_card';
    
-- 3) Average number of days taken for order_delivered_customer_date for pet_shop
select 
    product_category_name_english,
    count(distinct order_id) as total_orders,
    round(avg(datediff(str_to_date(order_delivered_customer_date, '%d-%m-%Y'), 
                       str_to_date(order_purchase_timestamp, '%d-%m-%Y'))), 2) as avg_delivery_days
from ecommerce
where product_category_name_english = 'pet_shop'
    and order_delivered_customer_date is not null
    and order_purchase_timestamp is not null
group by product_category_name_english;

-- 4) Average price and payment values from customers of sao paulo city
select 
    customer_city,
    customer_state,
    count(distinct order_id) as total_orders,
    count(distinct customer_id) as unique_customers,
    round(avg(price), 2) as avg_product_price,
    round(avg(payment_value), 2) as avg_payment_value,
    round(sum(price), 2) as total_product_price,
    round(sum(payment_value), 2) as total_payment_value,
    round(avg(freight_value), 2) as avg_freight_value
from ecommerce
where lower(customer_city) = 'sao paulo'
group by customer_city, customer_state;

-- 5) Relationship between shipping days and review scores
select 
    review_score,
    count(distinct order_id) as order_count,
    round(avg(datediff(
        str_to_date(order_delivered_customer_date, '%d-%m-%Y %H:%i:%s'),
        str_to_date(order_purchase_timestamp, '%d-%m-%Y %H:%i:%s')
    )), 2) as avg_shipping_days
from ecommerce
where order_delivered_customer_date is not null
    and order_purchase_timestamp is not null
    and review_score is not null
group by review_score
order by review_score desc;

-- ADDITIONAL ANALYTICAL QUERIES

-- 6) Top 20 Product Categories by Revenue
select 
    product_category_name_english,
    count(distinct order_id) as total_orders,
    count(distinct product_id) as unique_products,
    round(sum(price), 2) as total_revenue,
    round(avg(price), 2) as avg_price,
    round(sum(freight_value), 2) as total_freight,
    round(avg(freight_value), 2) as avg_freight
from ecommerce
where product_category_name_english is not null
group by product_category_name_english
order by total_revenue desc
limit 20;

-- 7) Monthly Sales Trend
select 
    date_format(str_to_date(order_purchase_timestamp, '%d-%m-%Y'), '%b-%Y') as month,
    count(distinct order_id) as total_orders,
    round(sum(payment_value), 2) as total_revenue,
    round(avg(payment_value), 2) as avg_order_value,
    count(distinct customer_id) as unique_customers
from ecommerce
where order_purchase_timestamp is not null
group by month
order by str_to_date(CONCAT('01-', month), '%d-%b-%Y');

-- 8) Seller Performance Analysis (Top 20)
select 
    seller_id,
    seller_city,
    seller_state,
    count(distinct order_id) as total_orders,
    count(distinct product_id) as products_sold,
    round(sum(price), 2) as total_revenue,
    round(avg(price), 2) as avg_product_price,
    round(avg(review_score), 2) as avg_review_score,
    round(sum(freight_value), 2) as total_freight
from ecommerce
where seller_id is not null
group by seller_id, seller_city, seller_state
order by total_revenue desc
limit 20;

-- 9) Freight Value vs Product Price Ratio by Category
select 
    product_category_name_english,
    count(distinct order_id) as order_count,
    round(avg(price), 2) as avg_price,
    round(avg(freight_value), 2) as avg_freight,
    round(sum(price), 2) as total_revenue,
    round(avg(freight_value / nullif(price, 0) * 100), 2) as freight_price_ratio_pct
from ecommerce
where price > 0 
    and product_category_name_english is not null
group by product_category_name_english
having order_count >= 10
order by freight_price_ratio_pct desc
limit 20;

-- 10) Order Status Distribution
select 
    order_status,
    count(distinct order_id) as order_count,
    round(count(distinct order_id) * 100.0 / (select COUNT(distinct order_id) from ecommerce), 2) as percentage,
    round(sum(payment_value), 2) as total_value
from ecommerce
where order_status is not null
group by order_status
order by  order_count desc;