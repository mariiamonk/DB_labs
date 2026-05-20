-- DELETE FROM RentContract WHERE PropertyId IN (SELECT PropertyId FROM Property WHERE Address = 'тест триггера аренды');
-- DELETE FROM Property WHERE Address = 'тест триггера аренды';

-- INSERT INTO Property (Type, Area, Address, RegionId, ManagerId)
-- VALUES ('квартира', 40.0, 'тест триггера аренды', 
--         (SELECT MAX(RegionId) FROM Region), 
--         (SELECT MAX(EmployeeId) FROM Manager));

-- SELECT * FROM Property 
-- WHERE Address = 'тест триггера аренды' 
-- ORDER BY PropertyId DESC;

-- SELECT rc.ContractId, rc.ContractDate, rc.DurationMonths, rc.MonthlyRent, p.Address
-- FROM RentContract rc
-- JOIN Property p ON rc.PropertyId = p.PropertyId
-- WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера аренды');


-- INSERT INTO RentContract (PropertyId, TenantId, LandlordId, ManagerId, RealtorId, BankId, ContractDate, DurationMonths, MonthlyRent)
-- VALUES (
--     (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера аренды'), 
--     (SELECT MAX(ClientId) FROM Client), 
--     (SELECT MIN(ClientId) FROM Client),  
--     (SELECT MAX(EmployeeId) FROM Manager), 
--     (SELECT MAX(EmployeeId) FROM Realtor), 
--     (SELECT MAX(BankId) FROM Bank), 
--     '2026-01-01', 6, 50000
-- );


-- SELECT rc.ContractId, rc.ContractDate, rc.DurationMonths, rc.MonthlyRent, p.Address
-- FROM RentContract rc
-- JOIN Property p ON rc.PropertyId = p.PropertyId
-- WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера аренды');


INSERT INTO RentContract (PropertyId, TenantId, LandlordId, ManagerId, RealtorId, BankId, ContractDate, DurationMonths, MonthlyRent)
VALUES (
    (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера аренды'), 
    (SELECT MAX(ClientId) FROM Client), 
    (SELECT MIN(ClientId) FROM Client),  
    (SELECT MAX(EmployeeId) FROM Manager), 
    (SELECT MAX(EmployeeId) FROM Realtor), 
    (SELECT MAX(BankId) FROM Bank), 
    '2026-03-01', 3, 60000
);