SELECT 
    a.artist_id,
    a.name,
    a.stage_name,
    g.name AS genre_name,
    CASE 
        WHEN pm.artist_id IS NOT NULL THEN 'Ναι'  -- Αλλαγή εδώ
        ELSE 'Όχι'
    END AS συμμετοχή_φέτος
FROM 
    Artist a
JOIN 
    Artist_Genres ag ON a.artist_id = ag.artist_id
JOIN 
    Genre g ON ag.genre_id = g.genre_id
LEFT JOIN (
    SELECT 
        DISTINCT artist_id  -- Εδώ επιστρέφουμε μόνο artist_id
    FROM 
        Performance_members pm
    JOIN 
		performance p ON p.performance_id = pm.performance_id    
    JOIN 
        Event e ON p.event_id = e.event_id
    JOIN 
        Festival f ON e.festival_id = f.festival_id
    WHERE 
        f.year = 2023
) pm ON a.artist_id = pm.artist_id
WHERE 
    g.name = 'Rock';