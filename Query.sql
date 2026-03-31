SELECT 'Region:' as table_name, COUNT(*) as count FROM Region
UNION ALL SELECT 'Employee:', COUNT(*) FROM Employee
UNION ALL SELECT 'Manager:', COUNT(*) FROM Manager
UNION ALL SELECT 'Realtor:', COUNT(*) FROM Realtor
UNION ALL SELECT 'Client:', COUNT(*) FROM Client
UNION ALL SELECT 'Property:', COUNT(*) FROM Property;
