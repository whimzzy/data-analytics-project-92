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

select concat(e.first_name, ' ', e.last_name) as name, 
to_char(s.sale_date, 'fmday') as weekday, /*преобразуем дату в день недели*/ 
round(sum(s.quantity*p.price), 0) as income
from sales s
left join employees e 
on s.sales_person_id = e.employee_id 
left join products p 
on s.product_id = p.product_id
group by to_char(s.sale_date, 'fmday'), concat(e.first_name, ' ', e.last_name)
order by case 
	when to_char(s.sale_date, 'fmday') = 'monday' then 1
	when to_char(s.sale_date, 'fmday') = 'tuesday' then 2
	when to_char(s.sale_date, 'fmday') = 'wednesday' then 3
	when to_char(s.sale_date, 'fmday') = 'thursday' then 4
	when to_char(s.sale_date, 'fmday') = 'friday' then 5
	when to_char(s.sale_date, 'fmday') = 'saturday' then 6
	when to_char(s.sale_date, 'fmday') = 'sunday' then 7
end
asc, /*выставление условия для нумерации дней недели*/ name asc;
