#Create gold_allviews table
CREATE TABLE nawalhasan_homework.gold_allviews
    WITH (
          format = 'PARQUET',
          parquet_compression = 'SNAPPY',
          external_location = 's3://ceu-nawal-2021/datalake/gold_allviews'
    ) AS SELECT DISTINCT(article),
                SUM(views) AS total_top_view,
                MIN(rank) AS top_rank,
                COUNT(article) AS ranked_days 
                FROM nawalhasan_homework.silver_views
                GROUP BY article
                ORDER BY total_top_view DESC;