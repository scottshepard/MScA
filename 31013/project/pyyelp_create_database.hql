set BUCKET=pyyelp-2;
create database if not exists pyyelp;
use pyyelp;

-- add serde.jar file into hive, otherwise will throw validation error when creating table
add jar json-serde-1.3.8-jar-with-dependencies-cdh5.jar;

-- create table
-- attribute is not included because different restaurant has very different sets of attribute 
DROP TABLE IF EXISTS businesses;
CREATE EXTERNAL TABLE businesses (business_id STRING, name STRING, address STRING, city STRING, state STRING, postal_code STRING, latitude FLOAT, longitude FLOAT, stars FLOAT, review_count INT, is_open INT, categories STRING, hours struct <Monday : STRING, Tuesday : STRING, Wednesday : STRING, Thursday : STRING, Friday : STRING, Saturday : STRING, Sunday : STRING>)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'; 
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/business.json' OVERWRITE INTO TABLE businesses;

-- the checkin table
DROP TABLE IF EXISTS checkins;
CREATE EXTERNAL TABLE checkins (business_id STRING, `date` STRING) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'; 
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/checkin.json' OVERWRITE INTO TABLE checkins;

-- tip table
DROP TABLE IF EXISTS tips;
CREATE EXTERNAL TABLE tips (
    user_id STRING, business_id STRING, 
    text STRING, `date` STRING, compliment_count INT)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'; 

-- user table
DROP TABLE IF EXISTS users;
CREATE EXTERNAL TABLE users (user_id STRING, name STRING, review_count INT, yelping_since STRING, useful INT, funny INT, cool INT, elite STRING, friends STRING, fans INT, average_stars FLOAT, compliment_hot INT, compliment_more INT, compliment_profile INT, compliment_cute INT, compliment_list INT, compliment_note INT, compliment_plain INT, compliment_cool INT, compliment_funny INT, compliment_writer INT, compliment_photos INT)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'; 

-- the review table
DROP TABLE IF EXISTS reviews;
CREATE EXTERNAL TABLE reviews (review_id STRING, user_id STRING, business_id STRING, stars FLOAT, useful INT, funny INT, cool INT, text STRING, `date` STRING)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'; 

-- load data
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/checkin.json' OVERWRITE INTO TABLE checkins;
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/tip.json' OVERWRITE INTO TABLE tips;
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/user.json' OVERWRITE INTO TABLE users;
LOAD DATA INPATH 'gs://${hiveconf:BUCKET}/yelp_dataset/review.json' OVERWRITE INTO TABLE reviews;
