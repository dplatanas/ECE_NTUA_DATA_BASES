SELECT 
    a.artist_id,
    a.name AS artist_name,
    a.stage_name,
    ROUND(AVG(r.interpretation), 2) AS μέσος_όρος_ερμηνείας,
    ROUND(AVG(r.overall_impression), 2) AS μέσος_όρος_συνολικής_εντύπωσης
FROM 
    Artist a
JOIN 
    Performance_members pm ON a.artist_id = pm.artist_id
JOIN 
    Review r ON pm.performance_id = r.performance_id
WHERE 
    a.artist_id = 30  -- Αντικαταστήστε με το επιθυμητό artist_id
GROUP BY 
    a.artist_id, a.name, a.stage_name;