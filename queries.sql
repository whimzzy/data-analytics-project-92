select count(customer_id) as customers_count /*count считает количество покупателей*/
from customers

select concat(e.first_name, ' ', e.last_name) as name, /*соединение имени и фамилии*/ 
count(s.sales_id) as operations, /*подсчет количества продаж*/ 
round(sum(s.quantity*p.price), 0) as income /*подсчет и округление суммы продаж*/
from sales s
left join employees e 
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
order by income desc
limit 10;

WITH tab AS (select concat(e.first_name, ' ', e.last_name) as name, 
	sum(s.quantity*p.price) as income
from sales s
left join employees e 
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id
group by concat(e.first_name, ' ', e.last_name)
)
SELECT name, round(avg(income), 0) AS average_income /*подсчет и округление среднего дохода*/
FROM tab
GROUP BY name
HAVING round(avg(income), 0) < (SELECT avg(income) FROM tab) 
/*выбор тех, у кого средний доход меньше общего среднего дохода*/
ORDER BY average_income ASC;

WITH tab AS (select concat(e.first_name, ' ', e.last_name) as name, 
to_char(s.sale_date, 'fmday') as weekday, /*преобразуем дату в день недели*/ 
round(sum(s.quantity*p.price), 0) as income, EXTRACT(isodow from s.sale_date) AS extract
from sales s
left join employees e 
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id
group by to_char(s.sale_date, 'fmday'), 
concat(e.first_name, ' ', e.last_name), EXTRACT(isodow from s.sale_date)
)
SELECT name, weekday, income
FROM tab
ORDER BY extract ASC, name ASC;

WITH tab AS (select case
	when age >=16 and age <=25 then '16-25'
	when age >=26 and age <=40 then '26-40'
	when age >40 then '40+' 
end as age_category, /*распределяем по возрастным группам*/ customer_id
from customers
)
select age_category, count(customer_id)
from tab
group by age_category
order by age_category;


select to_char(s.sale_date, 'YYYY-MM') as date, /*переводим в год-месяц по условию*/ 
sum(distinct s.customer_id) as total_customers, /*сумма уникальных покупателей*/ 
round(sum(s.quantity*p.price), 0) as income
from sales s
left join customers c
on s.customer_id = c.customer_id 
left join products p
on s.product_id = p.product_id 
group by date
order by date asc; 
 

with tab as (select concat(c.first_name, ' ', c.last_name) as customer, s.sale_date, 
concat(e.first_name, ' ', e.last_name) as seller, p.price, c.customer_id
from sales s
left join customers c
on s.customer_id = c.customer_id 
left join products p
on s.product_id = p.product_id 
left join employees e 
on s.sales_person_id = e.employee_id
),
temp as (select customer, 
row_number() over (partition by customer order by sale_date) as rn, /*узнаем первую покупку каждого покупателя*/ 
sale_date, seller, customer_id
from tab
where price = 0 /*где по акции товар стоил ноль*/
)
select customer, sale_date, seller
from temp
where rn = 1
order by customer_id;
