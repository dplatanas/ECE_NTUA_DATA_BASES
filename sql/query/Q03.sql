SELECT 
    a.artist_id,
    a.name,
    a.stage_name,
    f.festival_id,
    f.year,
    COUNT(*) AS warm_up_appearances
FROM 
    Performance_members pm
JOIN
	performance p ON pm.performance_id = p.performance_id	
JOIN 
    Artist a ON pm.artist_id = a.artist_id
JOIN 
    Event e ON p.event_id = e.event_id
JOIN 
    Festival f ON e.festival_id = f.festival_id
WHERE 
    p.type = 'warm up'
GROUP BY 
    a.artist_id, a.name, a.stage_name, f.festival_id, f.year
HAVING 
    COUNT(*) > 2
ORDER BY 
    warm_up_appearances DESC;