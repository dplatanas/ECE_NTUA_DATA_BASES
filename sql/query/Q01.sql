SELECT 
    f.year,
    t.payment_method,
    SUM(t.price) AS total_revenue
FROM 
    Ticket t
JOIN 
    Event e ON t.event_id = e.event_id
JOIN 
    Festival f ON e.festival_id = f.festival_id
GROUP BY 
    f.year, t.payment_method
ORDER BY 
    f.year, t.payment_method;
