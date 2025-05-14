SELECT 
    a.artist_id,
    a.name,
    a.stage_name,
    TIMESTAMPDIFF(YEAR, a.dob, CURDATE()) AS age,
    COUNT(*) AS συμμετοχές
FROM 
    Artist a
JOIN 
    Performance_members pm ON a.artist_id = pm.artist_id
JOIN
	performance p ON p.performance_id = pm.performance_id
JOIN 
    Event e       ON p.event_id    = e.event_id
JOIN 
    Festival f    ON e.festival_id = f.festival_id
WHERE 
    TIMESTAMPDIFF(YEAR, a.dob, CURDATE()) < 30
GROUP BY 
    a.artist_id, a.name, a.stage_name, age
ORDER BY 
    συμμετοχές DESC
LIMIT 10;
