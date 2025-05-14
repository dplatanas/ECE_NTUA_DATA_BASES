WITH genre_counts AS (
  SELECT 
    g.genre_id,
    g.name          AS genre_name,
    f.year,
    COUNT(*)        AS cnt
  FROM Genre g
  JOIN Artist_Genres ag ON g.genre_id = ag.genre_id
  JOIN Performance_members pm   ON ag.artist_id = pm.artist_id
  JOIN performance p ON p.performance_id = pm.performance_id
  JOIN Event e         ON p.event_id = e.event_id
  JOIN Festival f      ON e.festival_id = f.festival_id
  GROUP BY 
    g.genre_id, g.name, f.year
  HAVING COUNT(*) >= 3
)
SELECT 
  gc1.genre_name,
  gc1.year    AS year1,
  gc2.year    AS year2,
  gc1.cnt     AS performances
FROM genre_counts gc1
JOIN genre_counts gc2 
  ON gc1.genre_id = gc2.genre_id
  AND gc2.year = gc1.year + 1
  AND gc2.cnt  = gc1.cnt;
