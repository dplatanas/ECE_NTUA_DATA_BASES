SELECT
  v.visitor_id,
  v.first_name,
  v.last_name,
  p.performance_id,
  e.event_date,
  ROUND(AVG(r.interpretation), 2)       AS avg_interpretation,
  ROUND(AVG(r.overall_impression), 2)    AS avg_overall
FROM Visitor v
JOIN Review r 
  ON v.visitor_id = r.visitor_id
JOIN Performance p 
  ON r.performance_id = p.performance_id
JOIN Event e 
  ON p.event_id = e.event_id
WHERE v.visitor_id = 101   -- ή όποιο άλλο ID θες
GROUP BY
  v.visitor_id,
  v.first_name,
  v.last_name,
  p.performance_id,
  e.event_date;
