SELECT 
    a.artist_id,
    a.name,
    COUNT(DISTINCT loc.continent) AS continents_count
FROM Artist a
JOIN Performance_members pm 
    ON a.artist_id = pm.artist_id
JOIN performance p
	ON p.performance_id = pm.performance_id
JOIN Event e 
    ON p.event_id = e.event_id
JOIN Stage s 
    ON e.stage_id = s.stage_id
JOIN Location loc 
    ON s.location_id = loc.location_id
GROUP BY 
    a.artist_id, 
    a.name
HAVING 
    COUNT(DISTINCT loc.continent) >= 3;
