SELECT * FROM steel_data.cars;

#What are the details of all cars purchased in the year 2022?
select distinct c.*
from cars c
left join sales s
on c.car_id = s.car_id
where year(purchase_date) = '2022'
order by car_id;

#What is the total number of cars sold by each salesperson?
select count(s.car_id) num_of_carsold, sp.salesman_id, sp.name
from sales s
left join salespersons sp
using (salesman_id)
group by salesman_id
order by sp.salesman_id;

# What is the total revenue generated by each salesperson?
select sum(c.cost_$) as revenue, salesman_id
from cars c
left join sales s
using (car_id)
group by salesman_id;

#What are the details of the cars sold by each salesperson?
select salespersons.name as salesperson, sales.purchase_date,  cars.*
from cars 
inner join sales 
using (car_id)
join salespersons
using (salesman_id)
order by salespersons.name;

#What is the total revenue generated by each car type?
select distinct sales.car_id, cars.type as car_type, sum(cars.cost_$) as revenue
from cars
inner join sales
using (car_id)
group by type
order by revenue desc;

#What are the details of the cars sold in the year 2021 by salesperson 'Emily Wong'?
select cars.*, salespersons.name
from cars
left join sales
using (car_id)
left join salespersons
using (salesman_id)
where salespersons.name = 'Emily Wong' and
 year(purchase_date) = 2021;
 
 #What is the total revenue generated by the sales of hatchback cars?
 select cars.style, sum(cost_$) as revenue
 from cars
 join sales
 using (car_id)
 where cars.style = 'Hatchback';

#What is the total revenue generated by the sales of SUV cars in the year 2022?
select sum(cost_$) as revenue, cars.style
from cars
left join sales
using (car_id)
where cars.style = 'SUV' and year(purchase_date) = 2022
group by cars.style;

#What is the name and city of the salesperson who sold the most number of cars in the year 2023?
select salespersons.name, salespersons.city, count(sales.salesman_id) as num_of_car_sales
from sales
left join salespersons
using (salesman_id)
where year(purchase_date) = 2023
group by salespersons.salesman_id
order by num_of_car_sales desc
limit 1;

#What is the name and age of the salesperson who generated the highest revenue in the year 2022?
select salespersons.name, salespersons.age, sum(cars.cost_$) as revenue
from cars
left join sales
using (car_id)
left join salespersons
using(salesman_id)
where year(purchase_date) = 2022
group by salespersons.salesman_id
order by revenue desc
limit 1;






