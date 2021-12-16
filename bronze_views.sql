#Create bronze_views table
CREATE EXTERNAL TABLE
nawalhasan_homework.bronze_views (
    article STRING,
    views INT,
    rank INT,
    date DATE,
    retrieved_at TIMESTAMP) 
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://ceu-nawal-2021/datalake/views/';
 