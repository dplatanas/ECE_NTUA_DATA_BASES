SELECT 
  s.staff_id,
  s.name,
  s.staff_role
FROM Staff s
LEFT JOIN Staff_Assignment sa
  ON s.staff_id = sa.staff_id
  AND sa.assignment_date = '2025-06-15'   -- επιλεγμένη ημερομηνία
  AND sa.staff_role = 'support'
WHERE 
  s.staff_role = 'support'
  AND sa.assignment_id IS NULL;
