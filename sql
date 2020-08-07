-- overall background: Mkt size of liquor in Iowa/
-- total revenue
select sum(s.total::money) as tot_sales
from sales s
-- ANS: $392,293,023.61
;
-- population, how many counties
select sum(c.population) as tot_population
,count(c.county) as num_of_county
from counties c
--tot_population: 3,046,352, num_of_county: 99
;
-- About our client
select count(distinct p.vendor_name) as num_of_vendor
, count(distinct p.item_description) as types_of_liquor
from products p
-- num_of_vendor: 271
-- types_of_liquor: 7276
;
-- how many products does each vendor provide, tot_sales
select p.vendor_name
, count(distinct p.item_description) as distinct_products
, count(*) as tot_products
, sum(s.total) as tot_sales
, round((sum(s.total)/392293023.61)*100,2) as pct_to_tot_sales
, round(sum((sum(s.total)/392293023.61)*100)over(order by sum(s.total) desc),2) as acc_tot
from products p
inner join sales s on p.item_no = s.item
group by p.vendor_name
having count(*) > 1
order by 4 desc
;
-- double check the previous query
select * from products as p
where p.vendor_name = 'Jim Beam Brands'
-- has 925 rows of item_no
;
-- Mkt size of each county, sum, pct_to_tot, acc_tot
select distinct s.county
, sum(s.total)
, round((sum(s.total)/392293023.61)*100,2) as pct_to_tot
, round(sum((sum(s.total)/392293023.61)*100)over(order by sum(s.total) desc),2) as acc_tot
from sales s
group by 1
order by 2 desc
--https://stackoverflow.com/questions/13862432/accumulate-a-summarized-column
--sum(wsum) over (order by wsum desc) as acc_wsum
;
--Top 5 highest sales by county and by date
select date(date_trunc('month',date))
, sum(total::money)
from sales
where county in ('Polk', 'Linn', 'Scott', 'Johnson', 'Black Hawk')
group by 1
order by 1 ;
-- What's the most popular liquor, from which vendor: tot_amt and pct_to_tot
select distinct s.category_name
, sum(s.total)
, round((sum(s.total)/392293023.61)*100,2) as pct_to_tot
, round(sum((sum(s.total)/392293023.61)*100)over(order by sum(s.total) desc),2) as acc_tot
, s.vendor
, rank() over (partition by s.vendor order by sum(total) desc)
, s.county
from sales s
group by 1, 5, 7
order by 2 desc
;
-- the profit estimation
select sum(s.btl_price::numeric)- sum(p.bottle_price::numeric) as tot_profit
from products p
inner join sales s on p.item_no=s.item
-- 14653048.14
;
select p.proof
, sum(s.total) as tot_sales
, count(s.total)
, round((sum(sP.total)/392293023.61)*100,2) as pct_to_tot_sales
, round(sum((sum(s.total)/392293023.61)*100)over(order by sum(s.total) desc),2) as acc_tot_sales
from sales as s
inner join products as p on p.item_no = s.item
group by p.proof
order by tot_sales desc
;
select distinct p.category_name
, (s.btl_price::numeric)
, (p.bottle_price::numeric)
, (s.btl_price::numeric)-(p.bottle_price::numeric) as profit
, round((sum(s.total)/392293023.61)*100,2) as pct_to_tot_sales
, p.proof
, p.vendor_name
from products p
inner join sales s on s.item = p.item_no
where cast(p.proof as int) = 80
group by 1, 2, 3, 4, 6, 7
order by 3 desc
;
select distinct p.category_name
, (s.btl_price::numeric)
, (p.bottle_price::numeric)
, (s.btl_price::numeric)-(p.bottle_price::numeric) as profit
, round((sum(s.total)/392293023.61)*100,2) as pct_to_tot_sales
, p.proof
, p.vendor_name
from products p
inner join sales s on s.item = p.item_no
where cast(p.proof as int) = 70
group by 1, 2, 3, 4, 6, 7
order by 3 desc
;
