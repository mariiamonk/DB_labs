-- DELETE FROM SaleContract WHERE RealtorId IN (SELECT EmployeeId FROM Employee WHERE FullName LIKE 'ТЕСТ %');
-- DELETE FROM RentContract WHERE RealtorId IN (SELECT EmployeeId FROM Employee WHERE FullName LIKE 'ТЕСТ %');
-- DELETE FROM Property WHERE ManagerId IN (SELECT EmployeeId FROM Employee WHERE FullName LIKE 'ТЕСТ %');

-- DELETE FROM Manager WHERE EmployeeId IN (SELECT EmployeeId FROM Employee WHERE FullName LIKE 'ТЕСТ %');
-- DELETE FROM Employee WHERE FullName LIKE 'ТЕСТ %';


-- INSERT INTO Employee (FullName, Phone, BirthDate, TaxId, PassportNumber, HireDate)
-- VALUES ('ТЕСТ Увольняемый', '+7(999)111-11-11', '1990-01-01', '111111111111', '1111 111111', '2020-01-01');

-- INSERT INTO Employee (FullName, Phone, BirthDate, TaxId, PassportNumber, HireDate)
-- VALUES ('ТЕСТ Преемник', '+7(999)222-22-22', '1990-01-01', '222222222222', '2222 222222', '2020-01-01');

-- INSERT INTO Manager (EmployeeId) SELECT EmployeeId FROM Employee WHERE FullName = 'ТЕСТ Увольняемый';
-- INSERT INTO Manager (EmployeeId) SELECT EmployeeId FROM Employee WHERE FullName = 'ТЕСТ Преемник';


-- INSERT INTO Property (Type, Area, Address, RegionId, ManagerId)
-- VALUES ('дом', 150.0, 'тест увольнения менеджера', 
--         (SELECT MAX(RegionId) FROM Region), 
--         (SELECT EmployeeId FROM Employee WHERE FullName = 'ТЕСТ Увольняемый'));


-- SELECT EmployeeId, FullName, HireDate, FireDate 
-- FROM Employee 
-- WHERE FullName LIKE 'ТЕСТ %';


-- SELECT PropertyId, Address, ManagerId 
-- FROM Property 
-- WHERE Address = 'тест увольнения менеджера';


-- CALL fire_and_reassign_employee(49, 50);


-- SELECT EmployeeId, FullName, HireDate, FireDate 
-- FROM Employee 
-- WHERE FullName LIKE 'ТЕСТ %';


SELECT PropertyId, Address, ManagerId 
FROM Property 
WHERE Address = 'тест увольнения менеджера';