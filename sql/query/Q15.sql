SELECT 
    v.first_name         AS visitor_first_name,
    v.last_name          AS visitor_last_name,
    a.name               AS artist_name,
    SUM(
      r.interpretation + 
      r.lights_sound + 
      r.stage_presence + 
      r.organization + 
      r.overall_impression
    )                     AS total_score
FROM Visitor v
JOIN Review r 
  ON v.visitor_id = r.visitor_id
JOIN performance_members pm
  ON r.performance_id = pm.performance_id
JOIN Artist a 
  ON pm.artist_id = a.artist_id
GROUP BY 
    v.visitor_id,
    a.artist_id
ORDER BY 
    total_score DESC
LIMIT 5;