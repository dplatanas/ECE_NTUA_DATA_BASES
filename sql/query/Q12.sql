SELECT
    f.festival_id,
    f.name            AS festival_name,
    e.event_date      AS festival_date,
    sa.staff_role     AS category,
    COUNT(DISTINCT sa.staff_id) AS required_personnel
FROM Festival f
JOIN Event e
  ON f.festival_id = e.festival_id
JOIN Staff_Assignment sa
  ON e.event_id    = sa.event_id
     AND sa.staff_role IN ('technician','security','support')
GROUP BY
    f.festival_id,
    f.name,
    e.event_date,
    sa.staff_role
ORDER BY
    f.festival_id,
    e.event_date,
    sa.staff_role;
