#Create silver_views table
CREATE TABLE nawalhasan_homework.silver_views
    WITH (
          format = 'PARQUET',
          parquet_compression = 'SNAPPY',
          external_location = 's3://ceu-nawal-2021/datalake/views_silver'
    ) AS SELECT article, views, rank, date
         FROM nawalhasan_homework.bronze_views
         WHERE date IS NOT NULL;