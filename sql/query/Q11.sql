WITH max_participations AS (
  SELECT
    pm.artist_id,
    COUNT(DISTINCT e.festival_id) AS participations
  FROM Performance_members pm
  JOIN performance p ON p.performance_id = pm.performance_id
  JOIN Event e 
    ON p.event_id = e.event_id
  GROUP BY pm.artist_id
  ORDER BY participations DESC
  LIMIT 1
)
SELECT
  a.artist_id,
  a.name             AS artist_name,
  COUNT(DISTINCT e.festival_id) AS participations
FROM Artist a
JOIN Performance_members pm 
  ON a.artist_id = pm.artist_id
JOIN performance p 
  ON p.performance_id = pm.performance_id  
JOIN Event e 
  ON p.event_id = e.event_id
GROUP BY
  a.artist_id,
  a.name
HAVING
  COUNT(DISTINCT e.festival_id) <= (
    SELECT participations 
    FROM max_participations
  ) - 5;
