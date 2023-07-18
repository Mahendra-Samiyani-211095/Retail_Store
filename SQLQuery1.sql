Create database Retail_Data
USE Retail_Data
SELECT * FROM DBO.Customer
SELECT * FROM DBO.Product
SELECT * FROM DBO.Transactions

--DATA PREPARATION AND UNDERSTANDING

-- ANSWER TO QUESTION 1.

;with CTERD AS
(
  SELECT COUNT(*) AS ROW_COUNT FROM DBO.Customer
  UNION ALL
  SELECT COUNT(*) FROM DBO.Product                       -- THIS SQL QUERY RETRIVES THE TOTAL NO. OF ROWS FROM ALL THE THE THREE TABLES(WITH CTE CONCEPT)
  UNION ALL                                             
  SELECT COUNT(*) FROM DBO.Transactions
)
SELECT SUM(ROW_COUNT) AS TotalRows
FROM CTERD

--ALTERNATE OPTION

SELECT COUNT(*) AS ROW_COUNT FROM DBO.Customer
  UNION ALL
  SELECT COUNT(*) FROM DBO.Product                       
  UNION ALL                                              --IF WE EXECUTE THE QUERY WITHOUT THE CTE CONCEPT WE WILL GET THE COUNT OF ROWS FROM EACH TABLES SAPERATELY
  SELECT COUNT(*) FROM DBO.Transactions

--ANSWER TO QUESTION 2

SELECT COUNT(QTY) AS RETURN_ORDERS FROM DBO.Transactions
WHERE QTY < 0

--ANSWER TO QUESTION 3

--THE DATES ARE ALREADY CONVERTED IN A PROPER FORMAT WHILE WE IMPORTED THE TABLE RECORDS
--WE CAN VERIFY THE SAME BY COPYING THE DATES OF CUSTOMER TABLE AND TRANSACTIONS TABLE IN AN SEPERATE EXCEL FILE AND SEE IT'S FORMAT
SELECT DOB FROM DBO.Customer
SELECT TRAN_DATE FROM DBO.Transactions

--ANSWER TO QUESTION 4

SELECT DATEDIFF(DAY,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS DATE_DIFF_DAYS,
DATEDIFF(MONTH,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS DATE_DIFF_MONTHS,
DATEDIFF(YEAR,MIN(TRAN_DATE),MAX(TRAN_DATE)) AS DATE_DIFF_YEARS FROM DBO.Transactions

--ANSWER TO QUESTION 5

SELECT prod_cat from dbo.Product
where prod_subcat = 'DIY'


--DATA ANALYSIS

--ANSWER TO QUESTION 1

select top 1 Store_type as Frequent_Used_Channel , count(transaction_id) as Channel_Count 
from dbo.Transactions
group by Store_type
order by Channel_Count desc

--ANSWER TO QUESTION 2

Select GENDER , COUNT(customer_Id) as Total_Count from dbo.Customer
group by Gender                                                         -- HERE "NULL" SHOWS THAT THERE ARE 2 RECORDS WHERE THE GENDER IS NOT MENTIONED 
ORDER BY Gender

--ANSWER TO QUESTION 3

select top 1 city_code , count(customer_Id) as MAX_COUNT_OF_CUSTOMER
from dbo.Customer
group by city_code
order by MAX_COUNT_OF_CUSTOMER desc

--ANSWER TO QUESTION 4

select count(prod_subcat) from dbo.Product
where prod_cat = 'Books'                                          --THIS GIVES COUNT OF PRODUCT SUB CATEGORY WHERE PRODUCT CATEGORY IS BOOKS

--ALTERNATE OPTION

select prod_subcat from dbo.Product
where prod_cat = 'Books'                                          --THIS GIVES THE NAME OF PRODUCT SUB CATEGORY WHICH BELONG TO BOOKS CATEGORY

--ANSWER TO QUESTION 5

select max(Qty) from dbo.Transactions

--ANSWER TO QUESTION 6

select sum(total_amt) as Total_Amount from dbo.Transactions          
inner join dbo.Product on dbo.Transactions.prod_cat_code = dbo.Product.prod_cat_code
and                                                           --IF YOU TALLY THE RESULT OF TOTAL_AMT COLUMN OF A SQL QUERY TO EXCEL THE RESULT DIFFERS
dbo.Transactions.prod_subcat_code = dbo.Product.prod_sub_cat_code
where prod_cat in( 'Electronics' , 'Books')

--ALTERNATE OPTION

select sum(total_amt) from dbo.Transactions                   --IF YOU TALLY THE RESULT OF TOTAL_AMT COLUMN OF A SQL QUERY TO EXCEL THE RESULT DIFFERS
where prod_cat_code in ('3','5')

--ANSWER TO QUESTION 7

select cust_id as Customer_Count_More_Than_10 , count(transaction_id) as No_of_Transactions from dbo.Transactions
where Qty > 0
group by cust_id
having count(transaction_id) >10
order by cust_id

--ANSWER TO QUESTION 8

select sum(total_amt) as Total_Revenue from dbo.Transactions                         
inner join dbo.Product on dbo.Transactions.prod_cat_code = dbo.Product.prod_cat_code 
and                                                                                    --IF YOU TALLY THE RESULT OF TOTAL_AMT COLUMN OF A SQL QUERY TO EXCEL THE RESULT DIFFERS 
dbo.Transactions.prod_subcat_code = dbo.Product.prod_sub_cat_code                      --IF YOU TALLY THE RESULT OF TAX COLUMN OF A SQL QUERY TO EXCEL THE RESULT MATCHES      
where prod_cat in('Clothing' , 'Electronics') and Store_type = 'Flagship store'

--ANSWER TO QUESTION 9

select T2.prod_subcat as Product_SubCategory , sum(total_amt) as Total_Amount from dbo.Transactions as T1
inner join dbo.Product as T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
inner join dbo.Customer as T3 on T1.cust_id = T3.customer_Id
where T3.Gender = 'M' and T2.prod_cat = 'Electronics'
group by T2.prod_subcat

--ANSWER TO QUESTION 10
  
Select Top 5 P.prod_subcat as SubCategory,
Sum(Case When T.Qty > 0 Then T.Qty Else 0 end ) as Sales,
Sum(Case When T.Qty < 0 Then T.Qty Else 0 end) as [Return],
Sum(Case When T.Qty < 0 Then T.Qty Else 0 end )* 100/Sum(Case When T.Qty > 0 Then T.Qty Else 0 end) as [asReturn%],
100 + Sum(Case When T.Qty < 0 Then T.Qty Else 0 end)* 100/Sum(Case When T.Qty > 0 Then T.Qty Else 0 end) as [Sales %]
from dbo.Transactions as T
inner join dbo.Product as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
group by prod_subcat
Order By [Sales] desc   

--ANSWER TO QUESTION 11

select sum(T.total_amt) as Total_Revenue
from (select T.*,
             max(T.tran_date) over () as max_tran_date
      from dbo.Transactions as T
     ) 
	  T inner join
     dbo.Customer as C
     on T.cust_id = C.customer_Id
where (datediff(yy , C.DOB , getdate()) + (case when datepart(month , getdate()) - datepart(month , C.DOB) < 0 then -1 else 0 end)) between 25 and 35
and datediff(dd , T.tran_date , T.max_tran_date) <= 30

--ANSWER TO QUESTION 12

select top 1 P.prod_cat as Product_Category , count((case when T.Qty < 0 then T.Qty else 0 end)) as Return_Count  from
(
  select T.* , max(T.tran_date) over() as max_tran_date
  from dbo.Transactions as T
)
 T inner join dbo.Product as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
where datediff(mm , T.tran_date , T.max_tran_date) <= 3
group by P.prod_cat
order by  Return_Count desc

--ANSWER TO QUESTION 13

select top 1  Store_type , sum(total_amt) as Sales_Amount , sum(Qty) as Quantity_Sold
from dbo.Transactions
group by Store_type
order by Sales_Amount desc , Quantity_Sold desc

--ANSWER TO QUESTION 14

select P.prod_cat , avg(T.total_amt) as Category_Average from
(
select T.* , avg(T.total_amt) over() as Overall_Average from dbo.Transactions as T
)
T inner join dbo.Product as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = p.prod_sub_cat_code
group by P.prod_cat , Overall_Average
having avg(T.total_amt) > Overall_Average


--ANSWER TO QUESTION 15

select top 5 P.prod_subcat as Product_SubCategory, avg(total_amt) as Average_Revenue, sum(total_amt) as Total_Revenue from dbo.Transactions as T 
inner join dbo.product as P on T.prod_cat_code = P.prod_cat_code and T.prod_subcat_code = P.prod_sub_cat_code
Where  P.prod_cat in 
( 
  select top 5 P.prod_cat from dbo.product as P inner join dbo.Transactions as T on P.prod_cat_code = T.prod_cat_code 
   and P.prod_sub_cat_code = T.prod_subcat_code 
   group by P.prod_cat 
   order by sum(Qty) desc 
) 
group by P.prod_subcat


