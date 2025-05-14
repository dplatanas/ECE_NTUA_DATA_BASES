SELECT
    g1.name AS genre1,
    g2.name AS genre2,
    COUNT(DISTINCT f.festival_id) AS ζεύγη_εμφανίσεων
FROM Artist a

  -- πρώτο genre
  JOIN Artist_Genres ag1
    ON a.artist_id = ag1.artist_id
  JOIN Genre g1
    ON ag1.genre_id = g1.genre_id

  -- δεύτερο genre, αποφεύγουμε διπλομετρήσεις με genre_id σύγκριση
  JOIN Artist_Genres ag2
    ON a.artist_id = ag2.artist_id
  JOIN Genre g2
    ON ag2.genre_id = g2.genre_id
    AND g1.genre_id < g2.genre_id

  -- συμμετοχές σε φεστιβάλ
  JOIN Performance_members pm
    ON a.artist_id = pm.artist_id
  JOIN 	performance p
	ON pm.performance_id = p.performance_id
  JOIN Event e
    ON p.event_id = e.event_id
  JOIN Festival f
    ON e.festival_id = f.festival_id

GROUP BY
    g1.name, g2.name

ORDER BY
    ζεύγη_εμφανίσεων DESC

LIMIT 3;
