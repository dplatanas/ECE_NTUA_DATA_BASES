SELECT 
    v.visitor_id,
    v.first_name,
    v.last_name,
    COUNT(DISTINCT p.performance_id) AS παραστάσεις
FROM 
    Visitor v
JOIN 
    Ticket t 
  ON v.visitor_id = t.visitor_id
JOIN 
    Performance p 
  ON t.event_id = p.event_id
JOIN 
    Event e 
  ON p.event_id = e.event_id
WHERE 
    -- Φιλτράρουμε τις παραστάσεις στο διάστημα ενός έτους
    e.event_date BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY 
    v.visitor_id, v.first_name, v.last_name
HAVING 
    COUNT(DISTINCT p.performance_id) > 3;
