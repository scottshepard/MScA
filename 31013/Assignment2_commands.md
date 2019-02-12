## Question 1

Create an external Hive table from this data set called chicago_crimes in a database named as <your userid>. (Try to match the column names from the metadata link above. Ensure that column names have no spaces or special characters)

```
hdfs dfs -put /home/$USER/data/crimes.csv /user/$USER/data/crimes.csv 
```

Open up hive, get environment ready
```
hive
use sshepard;
show tables;
drop table if exists crimes;
```

Create the external table

```
> create external table CRIMES (
    id string,
    case_number string,
    occurred_at string,
    block string,
    iucr string,
    primary_type string,
    description string,
    location_description string,
    arrest string,
    domestic string,
    beat string,
    district string,
    ward string,
    community_area string,
    fbi_code string,
    x_coordinate string,
    y_coordinate string,
    year string,
    updated_on string,
    latitude string,
    longitude string,
    location string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
   "separatorChar" = ",",
   "quoteChar"     = '\"',
   "escapeChar"    = '\\') 
STORED AS TEXTFILE
LOCATION '/user/sshepard/data/'
tblproperties("skip.header.line.count"="1"); 

OK
Time taken: 0.173 seconds
```

## Question 2

Load all the chicago crimes data (~ 1.5 GB) from 2001 to present from the Chicago city data portal into chicago_crimes.

```
hive> LOAD DATA INPATH '/user/sshepard/data/crimes.csv' INTO TABLE crimes;
Loading data to table sshepard.crimes
OK
Time taken: 0.703 seconds
```

Unfortunately the data in occurred_at is stored as a string. Hive only supports
a certain format type so it has to be uploaded first and then cast. My solution
to this is to create another external table called `chicago_crimes` that will have the 
right casting.

```
create external table CHICAGO_CRIMES (
    id int,
    case_number string,
    occurred_at date,
    block string,
    iucr string,
    primary_type string,
    description string,
    location_description string,
    arrest boolean,
    domestic boolean,
    beat string,
    district string,
    ward int,
    community_area int,
    fbi_code string,
    x_coordinate decimal,
    y_coordinate decimal,
    year int,
    updated_on string,
    latitude decimal,
    longitude decimal,
    location string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' ESCAPED BY '\\'
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE
LOCATION '/user/sshepard/data/'
tblproperties("skip.header.line.count"="1"); 
```

Now I insert data into `chicago_crimes` from `crimes` using `insert overwrite`.

```
INSERT OVERWRITE TABLE CHICAGO_CRIMES 
SELECT 
    cast(id as int) as id,
    cast(case_number as int) as case_number,
    cast(from_unixtime(unix_timestamp(occurred_at,'MM/dd/yyyy HH:mm:ss aa')) as date) as occurred_at,
    block,
    iucr,
    primary_type,
    description,
    location_description,
    cast(arrest as boolean) as arrest,
    cast(domestic as boolean) as domestic,
    beat,
    district,
    cast(ward as int) as ward,
    cast(community_area as int) as community_area,
    fbi_code,
    cast(x_coordinate as decimal) as x_coordinate,
    cast(y_coordinate as decimal) as y_coordinate,
    cast(year as int) as year,
    updated_on,
    latitude,
    longitude,
    location
FROM crimes;

Query ID = sshepard_20190212001349_ad582f44-a0bd-4163-baf3-8a6e871fa103
Total jobs = 3
Launching Job 1 out of 3
Number of reduce tasks is set to 0 since there's no reduce operator
19/02/12 00:13:49 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3042, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3042/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3042
Hadoop job information for Stage-1: number of mappers: 10; number of reducers: 0
2019-02-12 00:13:59,037 Stage-1 map = 0%,  reduce = 0%
2019-02-12 00:14:16,584 Stage-1 map = 4%,  reduce = 0%, Cumulative CPU 217.76 sec
2019-02-12 00:14:24,845 Stage-1 map = 14%,  reduce = 0%, Cumulative CPU 292.99 sec
2019-02-12 00:14:28,970 Stage-1 map = 47%,  reduce = 0%, Cumulative CPU 357.84 sec
2019-02-12 00:14:35,158 Stage-1 map = 59%,  reduce = 0%, Cumulative CPU 424.31 sec
2019-02-12 00:14:40,308 Stage-1 map = 61%,  reduce = 0%, Cumulative CPU 430.25 sec
2019-02-12 00:14:41,340 Stage-1 map = 64%,  reduce = 0%, Cumulative CPU 491.76 sec
2019-02-12 00:14:45,461 Stage-1 map = 79%,  reduce = 0%, Cumulative CPU 507.22 sec
2019-02-12 00:14:46,491 Stage-1 map = 84%,  reduce = 0%, Cumulative CPU 519.92 sec
2019-02-12 00:14:47,522 Stage-1 map = 93%,  reduce = 0%, Cumulative CPU 541.18 sec
2019-02-12 00:14:53,698 Stage-1 map = 96%,  reduce = 0%, Cumulative CPU 556.05 sec
2019-02-12 00:14:54,726 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 558.13 sec
MapReduce Total cumulative CPU time: 9 minutes 18 seconds 130 msec
Ended Job = job_1547750003855_3042
Stage-4 is selected by condition resolver.
Stage-3 is filtered out by condition resolver.
Stage-5 is filtered out by condition resolver.
Moving data to directory hdfs://nameservice1/user/sshepard/data/.hive-staging_hive_2019-02-12_00-13-49_265_4663904795520879897-1/-ext-10000
Loading data to table default.chicago_crimes
MapReduce Jobs Launched:
Stage-Stage-1: Map: 10   Cumulative CPU: 558.13 sec   HDFS Read: 2828222664 HDFS Write: 2458770205 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 9 minutes 18 seconds 130 msec
OK
Time taken: 68.405 seconds
```

## Question 3

What are earliest and most recent dates of the crimes recorded in the dataset and what are the types of those crimes. (Dates might vary based on when you download the dataset)

### 3.1 Earliest time

The earliest time in this dataset is 1/1/2001

```
hive> select min(occurred_at) from crimes2;
Query ID = sshepard_20190211222658_17c2914a-2eb5-46d6-88e8-e7a25f90f838
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/11 22:26:58 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_2997, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_2997/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_2997
Hadoop job information for Stage-1: number of mappers: 4; number of reducers: 1
2019-02-11 22:27:08,299 Stage-1 map = 0%,  reduce = 0%
2019-02-11 22:27:18,622 Stage-1 map = 50%,  reduce = 0%, Cumulative CPU 23.51 sec
2019-02-11 22:27:19,656 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 48.53 sec
2019-02-11 22:27:27,901 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 52.36 sec
MapReduce Total cumulative CPU time: 52 seconds 360 msec
Ended Job = job_1547750003855_2997
MapReduce Jobs Launched:
Stage-Stage-1: Map: 4  Reduce: 1   Cumulative CPU: 52.36 sec   HDFS Read: 1224260999 HDFS Write: 110 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 52 seconds 360 msec
OK
2001-01-01
Time taken: 31.734 seconds, Fetched: 1 row(s)
```

### 3.2 Most Recent

The most recent date in this dataset is 1/29/2019

```
hive> select max(occurred_at) from crimes2;
Query ID = sshepard_20190211223242_00dbc754-29a3-424f-b9d8-9be4e57894f3
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/11 22:32:42 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_2998, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_2998/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_2998
Hadoop job information for Stage-1: number of mappers: 4; number of reducers: 1
2019-02-11 22:32:52,717 Stage-1 map = 0%,  reduce = 0%
2019-02-11 22:33:02,020 Stage-1 map = 25%,  reduce = 0%, Cumulative CPU 11.21 sec
2019-02-11 22:33:03,053 Stage-1 map = 75%,  reduce = 0%, Cumulative CPU 33.82 sec
2019-02-11 22:33:05,116 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 46.65 sec
2019-02-11 22:33:11,311 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 50.3 sec
MapReduce Total cumulative CPU time: 50 seconds 300 msec
Ended Job = job_1547750003855_2998
MapReduce Jobs Launched:
Stage-Stage-1: Map: 4  Reduce: 1   Cumulative CPU: 50.3 sec   HDFS Read: 1224261543 HDFS Write: 110 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 50 seconds 300 msec
OK
2019-01-29
Time taken: 31.36 seconds, Fetched: 1 row(s)
```

## Question 4

List the top 5 and bottom 5 primary crime types based on total count of occurences

### Top 5

```
hive> select * from (select primary_type, count(*) as cnt from chicago_crimes group by primary_type) t order by cnt desc limit 5;
Query ID = sshepard_20190211225302_f9dd011a-622d-4c95-b645-137860f3b290
Total jobs = 2
Launching Job 1 out of 2
Number of reduce tasks not specified. Estimated from input data size: 19
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/11 22:53:03 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3009, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3009/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3009
Hadoop job information for Stage-1: number of mappers: 4; number of reducers: 19
2019-02-11 22:53:12,532 Stage-1 map = 0%,  reduce = 0%
2019-02-11 22:53:21,809 Stage-1 map = 50%,  reduce = 0%, Cumulative CPU 13.71 sec
2019-02-11 22:53:22,843 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 28.79 sec
2019-02-11 22:53:32,121 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 86.14 sec
MapReduce Total cumulative CPU time: 1 minutes 26 seconds 140 msec
Ended Job = job_1547750003855_3009
Launching Job 2 out of 2
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/11 22:53:34 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3010, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3010/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3010
Hadoop job information for Stage-2: number of mappers: 2; number of reducers: 1
2019-02-11 22:53:43,829 Stage-2 map = 0%,  reduce = 0%
2019-02-11 22:53:51,049 Stage-2 map = 100%,  reduce = 0%, Cumulative CPU 5.59 sec
2019-02-11 22:53:59,302 Stage-2 map = 100%,  reduce = 100%, Cumulative CPU 8.97 sec
MapReduce Total cumulative CPU time: 8 seconds 970 msec
Ended Job = job_1547750003855_3010
MapReduce Jobs Launched:
Stage-Stage-1: Map: 4  Reduce: 19   Cumulative CPU: 86.14 sec   HDFS Read: 1224347189 HDFS Write: 42664 HDFS EC Read: 0 SUCCESS
Stage-Stage-2: Map: 2  Reduce: 1   Cumulative CPU: 8.97 sec   HDFS Read: 55172 HDFS Write: 232 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 1 minutes 35 seconds 110 msec
OK
THEFT   1431292
BATTERY 1241692
CRIMINAL DAMAGE 776656
NARCOTICS   713778
ASSAULT 422392
Time taken: 57.902 seconds, Fetched: 5 row(s)
```

### Bottom 5

```
hive> select * from (select primary_type, count(*) as cnt from chicago_crimes group by primary_type) t order by cnt limit 5;
Query ID = sshepard_20190212001612_9be87d78-6cad-4b55-8340-9f9e5645dde9
Total jobs = 2
Launching Job 1 out of 2
Number of reduce tasks not specified. Estimated from input data size: 37
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/12 00:16:13 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3043, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3043/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3043
Hadoop job information for Stage-1: number of mappers: 8; number of reducers: 37
2019-02-12 00:16:22,504 Stage-1 map = 0%,  reduce = 0%
2019-02-12 00:16:30,775 Stage-1 map = 13%,  reduce = 0%, Cumulative CPU 5.47 sec
2019-02-12 00:16:31,808 Stage-1 map = 63%,  reduce = 0%, Cumulative CPU 32.91 sec
2019-02-12 00:16:32,841 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 63.43 sec
2019-02-12 00:16:41,096 Stage-1 map = 100%,  reduce = 59%, Cumulative CPU 136.06 sec
2019-02-12 00:16:42,124 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 175.86 sec
MapReduce Total cumulative CPU time: 2 minutes 55 seconds 860 msec
Ended Job = job_1547750003855_3043
Launching Job 2 out of 2
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/12 00:16:43 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3044, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3044/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3044
Hadoop job information for Stage-2: number of mappers: 2; number of reducers: 1
2019-02-12 00:16:52,754 Stage-2 map = 0%,  reduce = 0%
2019-02-12 00:16:59,989 Stage-2 map = 100%,  reduce = 0%, Cumulative CPU 6.47 sec
2019-02-12 00:17:08,244 Stage-2 map = 100%,  reduce = 100%, Cumulative CPU 9.67 sec
MapReduce Total cumulative CPU time: 9 seconds 670 msec
Ended Job = job_1547750003855_3044
MapReduce Jobs Launched:
Stage-Stage-1: Map: 8  Reduce: 37   Cumulative CPU: 175.86 sec   HDFS Read: 2459789065 HDFS Write: 340282 HDFS EC Read: 0 SUCCESS
Stage-Stage-2: Map: 2  Reduce: 1   Cumulative CPU: 9.67 sec   HDFS Read: 357434 HDFS Write: 676 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 3 minutes 5 seconds 530 msec
OK
 ALL EMPLOYEES MUST WASH HANDS PRIOR TO FOOD HANDLING. NO BARE HAND CONTACT WITH READY TO EAT FOODS (USE GLOVES 1
 5 MICE DROPPINGS ON FLOOR IN NORTHWEST CORNER NEAR BIKE AND WATER METER CLOSET     1
 AND MAINTAINED - Comments: Must re-attached rear exposed hand sink in rear prep area with hot  1
UNDER SHELVES ALONG BASEBOARD WALLS AND CORNERS.OVER 100 DROPPINGS AT ACTIVITY ROOM INSIDE THE STORAGE AREA 1
 1/4 INCH OPENING TO OUTSIDE AT BOTTOM OF DOOR. MUST RODENT PROOF DOOR.   | 24. DISH WASHING FACILITIES: PROPERLY DESIGNED  1
Time taken: 56.613 seconds, Fetched: 5 row(s)
```

These seem like parsing errors in the input rather than true primary_types, but 
after spending a while trying different inputs and escape chars, this is the 
best I can come up with.

## Question 5

Which location descripton has the highest number of homicides associated with it 

```
hive> select * from (select location_description, count(*) as cnt from chicago_crimes where primary_type = 'HOMICIDE' group by location_description) t order by cnt desc limit 5;
Query ID = sshepard_20190212002431_ce4141dd-5808-4924-be3b-2235a594a17a
Total jobs = 2
Launching Job 1 out of 2
Number of reduce tasks not specified. Estimated from input data size: 37
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/12 00:24:32 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3047, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3047/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3047
Hadoop job information for Stage-1: number of mappers: 8; number of reducers: 37
2019-02-12 00:24:41,740 Stage-1 map = 0%,  reduce = 0%
2019-02-12 00:24:51,016 Stage-1 map = 13%,  reduce = 0%, Cumulative CPU 8.77 sec
2019-02-12 00:24:52,050 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 79.87 sec
2019-02-12 00:25:00,302 Stage-1 map = 100%,  reduce = 32%, Cumulative CPU 115.87 sec
2019-02-12 00:25:02,367 Stage-1 map = 100%,  reduce = 46%, Cumulative CPU 134.75 sec
2019-02-12 00:25:03,397 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 212.07 sec
MapReduce Total cumulative CPU time: 3 minutes 32 seconds 70 msec
Ended Job = job_1547750003855_3047
Launching Job 2 out of 2
Number of reduce tasks determined at compile time: 1
In order to change the average load for a reducer (in bytes):
  set hive.exec.reducers.bytes.per.reducer=<number>
In order to limit the maximum number of reducers:
  set hive.exec.reducers.max=<number>
In order to set a constant number of reducers:
  set mapreduce.job.reduces=<number>
19/02/12 00:25:05 INFO client.ConfiguredRMFailoverProxyProvider: Failing over to rm94
Starting Job = job_1547750003855_3048, Tracking URL = http://md02.rcc.local:8088/proxy/application_1547750003855_3048/
Kill Command = /opt/cloudera/parcels/CDH-6.1.0-1.cdh6.1.0.p0.770702/lib/hadoop/bin/hadoop job  -kill job_1547750003855_3048
Hadoop job information for Stage-2: number of mappers: 2; number of reducers: 1
2019-02-12 00:25:14,991 Stage-2 map = 0%,  reduce = 0%
2019-02-12 00:25:22,227 Stage-2 map = 100%,  reduce = 0%, Cumulative CPU 5.99 sec
2019-02-12 00:25:30,475 Stage-2 map = 100%,  reduce = 100%, Cumulative CPU 9.14 sec
MapReduce Total cumulative CPU time: 9 seconds 140 msec
Ended Job = job_1547750003855_3048
MapReduce Jobs Launched:
Stage-Stage-1: Map: 8  Reduce: 37   Cumulative CPU: 212.07 sec   HDFS Read: 2459814761 HDFS Write: 6233 HDFS EC Read: 0 SUCCESS
Stage-Stage-2: Map: 2  Reduce: 1   Cumulative CPU: 9.14 sec   HDFS Read: 23434 HDFS Write: 206 HDFS EC Read: 0 SUCCESS
Total MapReduce CPU Time Spent: 3 minutes 41 seconds 210 msec
OK
STREET  9238
AUTO    2254
APARTMENT   1640
ALLEY   1210
HOUSE   1048
Time taken: 60.801 seconds, Fetched: 5 row(s)
```

The most common location for homicides in Chicago is the street. 

## Question 6

Which are the most dangerous and least dangerous police districts in the Chicago area?



