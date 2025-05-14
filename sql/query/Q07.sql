SELECT
  f.festival_id,
  f.name AS festival_name,
  ROUND(AVG(
    CASE s.experience_level
      WHEN 'intern'      THEN 1
      WHEN 'junior'      THEN 2
      WHEN 'average'     THEN 3
      WHEN 'experienced' THEN 4
      WHEN 'senior'      THEN 5
    END
  ), 2) AS avg_experience
FROM Festival f
JOIN Event e
  ON f.festival_id = e.festival_id
JOIN Staff_Assignment sa
  ON e.event_id = sa.event_id
  AND sa.staff_role = 'technician' -- technician
JOIN Staff s
  ON sa.staff_id = s.staff_id
GROUP BY
  f.festival_id,
  f.name
ORDER BY
  avg_experience ASC
LIMIT 1;
