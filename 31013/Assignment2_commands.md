# 1. Create an external Hive table from this data set called chicago_crimes in a database named as <your userid>. (Try to match the column names from the metadata link above. Ensure that column names have no spaces or special characters)

Open up hive, get environment ready
```
hive
hive> use sshepard;
hive> show tables;
hive> drop table if exists crimes;
```

Create the external table

```
> create external table CRIMES (
    id int,
    case_number string,
    occurred_at string,
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
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','  ESCAPED BY '\\'
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE
LOCATION '/user/sshepard/data/'
tblproperties("skip.header.line.count"="1"); 
OK
Time taken: 0.173 seconds
```

# 2. Load all the chicago crimes data (~ 1.5 GB) from 2001 to present from the Chicago city data portal into chicago_crimes.

```
hive> LOAD DATA INPATH '/user/sshepard/data/crimes.csv' INTO TABLE crimes;
Loading data to table sshepard.crimes
OK
Time taken: 0.703 seconds
```

hdfs dfs -put /home/$USER/data/crimes.csv /user/$USER/data/crimes.csv 
hive
use sshepard;
show tables;
drop table if exists crimes;

create external table CRIMES (
    id int,
    case_number string,
    occurred_at string,
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
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','  ESCAPED BY '\\'
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE
LOCATION '/user/sshepard/data/'
tblproperties("skip.header.line.count"="1"); 


LOAD DATA INPATH '/user/sshepard/data/crimes.csv' INTO TABLE crimes;

create external table CRIMES2 (
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
    longitude decimal
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','  ESCAPED BY '\\'
LINES TERMINATED BY '\n' 
STORED AS TEXTFILE
LOCATION '/user/sshepard/data/'
tblproperties("skip.header.line.count"="1"); 

INSERT OVERWRITE TABLE CRIMES2 
SELECT id,
    case_number,
    cast(from_unixtime(unix_timestamp(occurred_at,'MM/dd/yyyy HH:mm:ss aa')) as date) as occurred_at,
    block,
    iucr,
    primary_type,
    description,
    location_description,
    arrest,
    domestic,
    beat,
    district,
    ward,
    community_area,
    fbi_code,
    x_coordinate,
    y_coordinate,
    year,
    updated_on,
    latitude,
    longitude
FROM crimes;



# 3. What are earliest and most recent dates of the crimes recorded in the dataset and what are the types of those crimes. (Dates might vary based on when you download the dataset)

## 3.1 Earliest time

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

## 3.2 Most Recent




