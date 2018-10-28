/***********************************************
** DATA ENGINEERING PLATFORMS (MSCA 31012)
** File: classicmodels-DW-DML
** Desc: Operational verus Analytical queries
** Auth: Shreenidhi Bharadwaj
** Date: 10/08/2018
************************************************/

# Find the sum of quantityOrdered on a monthly basis based on per country & productLine
# Dimensional Query ( analytical database ) approach
use classicmodelsdw;
SELECT 
    dimc.country,
    dimp.productLine,
    dimt.month,
    SUM(fact.quantityOrdered)
FROM
    factOrderDetails AS fact
    INNER JOIN dimtime AS dimt
    INNER JOIN dimproducts AS dimp 
    INNER JOIN dimcustomers AS dimc 
WHERE
    fact.dateId = dimt.dateId
        AND fact.productCode = dimp.productCode
        AND fact.customerNumber = dimc.customerNumber
GROUP BY country , productLine , month
ORDER BY country , productLine , month;

# Non-Dimensional Query
use classicmodels;
SELECT 
    c.country,
    p.productLine,
    MONTH(o.orderdate),
    SUM(od.quantityOrdered)
FROM
    orders AS o
        INNER JOIN
    orderdetails AS od ON od.ordernumber = o.ordernumber
        INNER JOIN
    products p ON p.productcode = od.productcode
        INNER JOIN
    customers AS c ON o.customernumber = c.customernumber
GROUP BY country , productLine , MONTH(orderdate)
ORDER BY country , productLine , MONTH(orderdate);


# find all products brought by customers
# Data Warehouse ( analytical database ) approach
use classicmodelsdw;
SELECT 
    c.customerNumber, fact.productcode
FROM
    factOrderDetails AS fact
inner join dimcustomers AS c on c.customernumber = fact.customernumber;


# Operational ( relational ) database approach ( 3 table join ) 
use classicmodels;
SELECT 
    c.customerNumber, p.productcode
FROM
    customers AS c
    inner join orders AS o on o.customernumber = c.customernumber
    inner join orderdetails AS od on od.ordernumber = o.ordernumber
    inner join products p on p.productcode = od.productcode;


# list all customers that brought atleast 10 different products
# Data Warehouse ( analytical database ) approach
use classicmodelsdw;
SELECT 
    customerNumber
FROM
    factOrderDetails AS fact
GROUP BY customerNumber
HAVING COUNT(DISTINCT productcode) > 10;

# Operational ( relational ) database approach ( 3 table join ) 
use classicmodels;
SELECT 
    c.customerNumber
FROM
    customers AS c
    inner join orders AS o on o.customernumber = c.customernumber
    inner join orderdetails AS od on od.ordernumber = o.ordernumber
    inner join products p on p.productcode = od.productcode
GROUP BY c.customerNumber
HAVING COUNT(DISTINCT p.productcode) > 10;

--- End ---