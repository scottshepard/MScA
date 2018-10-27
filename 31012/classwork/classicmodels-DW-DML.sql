/***********************************************
** DATA ENGINEERING PLATFORMS (MSCA 31012)
** File: classicmodels-DW-DML
** Desc: Populating data in the dimensional Model
** Auth: Shreenidhi Bharadwaj
** Date: 10/08/2018
************************************************/

-- -----------------------------------------------------
-- Populate Time dimension
-- -----------------------------------------------------

INSERT INTO numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

INSERT INTO numbers
SELECT 
    thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
FROM
    numbers_small thousands,
    numbers_small hundreds,
    numbers_small tens,
    numbers_small ones
LIMIT 1000000;

INSERT INTO dimTime (dateId, date)
SELECT 
    number,
    DATE_ADD('2014-01-01',
        INTERVAL number DAY)
FROM
    numbers
WHERE
    DATE_ADD('2014-01-01',
        INTERVAL number DAY) BETWEEN '2014-01-01' AND '2017-01-01'
ORDER BY number;

UPDATE dimTime 
SET 
    timestamp = UNIX_TIMESTAMP(date),
    day_of_week = DATE_FORMAT(date, '%W'),
    weekend = IF(DATE_FORMAT(date, '%W') IN ('Saturday' , 'Sunday'),
        'Weekend',
        'Weekday'),
    month = DATE_FORMAT(date, '%M'),
    year = DATE_FORMAT(date, '%Y'),
    month_day = DATE_FORMAT(date, '%d');

UPDATE dimTime 
SET 
    week_starting_monday = DATE_FORMAT(date, '%v');

-- -----------------------------------------------------
-- Copy Data from ClassicModels 
-- -----------------------------------------------------
# dimcustomers table 
# insert data into the dimcustomers table from classic models customers table 
INSERT INTO classicmodelsdw.dimcustomers
(SELECT 
    *
FROM
    classicmodels.customers);

# dimproducts table
# insert data into dimproducts table from classic models products table
INSERT INTO classicmodelsdw.dimproducts
(SELECT 
    *
FROM
    classicmodels.products);

# dimemployees table
# insert data into dimproducts table from classic models products table
INSERT INTO classicmodelsdw.dimemployees
(employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
SELECT 
    *
FROM
    classicmodels.employees;



# FactOrderDetails table
INSERT INTO classicmodelsdw.factorderdetails
(orderNumber, productCode, customerNumber, dateId, quantityOrdered, priceEach, status,orderDate,requiredDate,shippedDate,employeeNumber)
SELECT 
    orders.orderNumber,
    productCode,
    orders.customerNumber,
    dateId,
    quantityOrdered,
    priceEach,
    status,
    orderDate,
    requiredDate,
    shippedDate,
    salesRepEmployeeNumber
FROM
    classicmodels.orders,
    classicmodels.orderdetails,
    classicmodels.customers,
    dimTime
WHERE
    orders.orderNumber = orderdetails.orderNumber
        AND orders.customerNumber = customers.customerNumber
        AND orders.orderDate = dimTime.date;

-- END--
