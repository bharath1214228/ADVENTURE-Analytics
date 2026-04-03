Create database Project2;
use project2;
show databases;
select * from fact_internet_sales_new;
select * from factinternetsales;
select * from dimproduct;
select * from factinternetsales;
select * from dimdate;

/* Q0 Union of Fact Internet sales and Fact internet sales new*/
create table sales as
select * from fact_internet_sales_new
union all 
select * from factinternetsales;

/* Q1.Lookup the productname from the Product sheet to Sales sheet.*/
select * from dimproduct;
select s.*, p.englishproductname as productname
from sales s
left join dimproduct p
on s.productkey = p.productkey;

/* Q2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet. */
select * from dimcustomer;
update dimcustomer set MiddleName = NULL where MiddleName = '';
select s.*,
c.Customer_FullName,
p.EnglishProductName as ProductName, 
p.Unit_Price as unitprice1
from sales s 
left join dimcustomer c
on s.CustomerKey = c.CustomerKey
left join dimproduct p
on s.ProductKey = p.ProductKey;

/* Q3.calcuate the following fields from the Orderdatekey field ( First Create a Date Field from Orderdatekey) */
select OrderDateKey,
str_to_date(OrderDateKey, '%Y%m%d') as OrderDate1,
# year
year(str_to_date(OrderDateKey, '%Y%m%d')) as `Year`,
# month
month(str_to_date(OrderDateKey, '%Y%m%d')) as MonthNo,
# monthname
monthname(str_to_date(OrderDateKey, '%Y%m%d')) as `MonthName`,
# Quarter
concat('Q', quarter(str_to_date(OrderDateKey, '%Y%m%d'))) as Quarter,
# yearmonth
date_format(str_to_date(OrderDateKey, '%Y%m%d'),'%Y-%b') as YearMonth,
# weekdayno
weekday(str_to_date(OrderDateKey, '%Y%m%d')) +1 as WeekDayNo,
# weekdayname
dayname(str_to_date(OrderDateKey, '%Y%m%d'))  as WeekDayName,
# Financial month
case when month(str_to_date(OrderDateKey, '%Y%m%d')) >= 4
then concat('FM',month(str_to_date(OrderDateKey, '%Y%m%d')) - 3)
else concat('FM',month(str_to_date(OrderDateKey, '%Y%m%d')) + 9)
end as FinancialMonth,
# financial Quarter
case when month(str_to_date(OrderDateKey, '%Y%m%d')) between 4 and 6 then 'FQ1'
when month(str_to_date(OrderDateKey, '%Y%m%d')) between 7 and 9 then 'FQ2'
when month(str_to_date(OrderDateKey, '%Y%m%d')) between 10 and 12 then 'FQ3'
else 'FQ4'
end as FinancialQuarter
from sales;

/* Q4.Calculate the Sales amount usning the columns(unit price,order quantity,unit discount) */
select s.salesordernumber, s.unitprice, s.orderquantity, s.unitpricediscountpct, 
s.unitprice * s.orderquantity * (1 - s.unitpricediscountpct) as salesamount_calc
from sales s;

/* Q5.Calculate the Productioncost usning the columns(unit cost ,order quantity) */
select s.productkey, p.standardcost, s.orderquantity , p.standardcost * s.orderquantity as productioncost
from sales s
left join dimproduct p
on s.productkey = p.productkey;

/* Q6.Calculate the profit. */
select s.productkey, s.unitprice, s.orderquantity, s.unitpricediscountpct, p.standardcost,
(s.unitprice * s.orderquantity * (1 - s.unitpricediscountpct)) - (p.standardcost * s.orderquantity) as profit
from sales s
left join dimproduct p
on s.productkey = p.productkey;

/* Q7.Create a Pivot table for month and sales (provide the Year as filter to select a particular Year) */
select year(orderdate) as year,
month(orderdate) as month,
monthname(orderdate) as Monthname,
sum(salesamount) as Totalsales
from sales
where year(orderdate) = 2011
group by 1,2,3
order by 2 asc;

/* Q8.Create a Bar chart to show yearwise Sales */
select year(orderdate) as `year`,
sum(salesamount) as Yearlysales
from sales
group by 1
order by `year`;

/* Q9.Create a Line Chart to show Monthwise sales */
select month(orderdate) as month,
monthname(orderdate) as monthname,
sum(salesamount) as monthlysales
from sales
group by 1,2
order by month;

/* Q10.Create a Pie chart to show Quarterwise sales */
select concat('Q', quarter(orderdate)) as `quarter`,
sum(salesamount) as quarter_sales
from sales group by `quarter` order by `quarter`;

/* Q11.Create a combinational chart (bar and Line) to show Salesamount and Productioncost together */
select year(s.orderdate) as `year`,
sum(s.salesamount) as total_sales,
sum(p.standardcost * s.orderquantity) as total_production_cost
from sales s
left join dimproduct p on s.productkey = p.productkey
group by `year`
order by `year`;

/* Q12.Build addtional KPI /Charts for Performance by Products, Customers, Region */
# Top 10 products by sales
select p.EnglishProductName, sum(s.SalesAmount) as TotalSales
from sales s join dimproduct p on s.Productkey = p.Productkey
group by p.EnglishProductName
order by TotalSales desc
limit 10; 

# Region Wise sales
select t.salesterritorycountry, sum(s.salesamount) as total_sales
from sales s join dimsalesterritory t on s.salesterritorykey=t.salesterritorykey
group by t.salesterritorycountry order by total_sales;

# Top 10 customers By Sales
select concat_ws(' ', c.FirstName, c.MiddleName, c.LastName) as CustomerName,
sum(s.salesamount) as total_sales 
from sales s join dimcustomer c on s.customerkey=c.customerkey
group by CustomerName order by total_sales desc limit 10;






