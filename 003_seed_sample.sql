-- Corrected SQL code
-- Other lines of the SQL file remain unchanged

SELECT 
    CAST(h.HeaderID AS nvarchar(36)) AS HeaderID,
    ...
FROM Headers AS h
WHERE ...