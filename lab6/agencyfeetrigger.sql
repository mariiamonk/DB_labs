-- DELETE FROM SaleContract WHERE PropertyId IN (SELECT PropertyId FROM Property WHERE Address = 'тест триггера комиссии');
-- DELETE FROM Property WHERE Address = 'тест триггера комиссии';


-- INSERT INTO Property (Type, Area, Address, RegionId, ManagerId)
-- VALUES ('офис', 100.0, 'тест триггера комиссии', 
--         (SELECT MAX(RegionId) FROM Region), 
--         (SELECT MAX(EmployeeId) FROM Manager));


-- SELECT * FROM Property 
-- WHERE Address = 'тест триггера комиссии' 
-- ORDER BY PropertyId DESC;


-- INSERT INTO SaleContract (PropertyId, BuyerId, SellerId, ManagerId, RealtorId, BankId, TotalPrice, AgencyFee, PaymentType, ContractDate)
-- VALUES (
--     (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера комиссии'), 
--     (SELECT MAX(ClientId) FROM Client),  
--     (SELECT MIN(ClientId) FROM Client),  
--     (SELECT MAX(EmployeeId) FROM Manager), 
--     (SELECT MAX(EmployeeId) FROM Realtor), 
--     (SELECT MAX(BankId) FROM Bank), 
--     10000000, 
--     1.00, 
--     'наличные', CURRENT_DATE
-- );


-- SELECT sc.ContractId, sc.TotalPrice, sc.AgencyFee, p.Address
-- FROM SaleContract sc
-- JOIN Property p ON sc.PropertyId = p.PropertyId
-- WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера комиссии');


UPDATE SaleContract
SET AgencyFee = 700000.00
WHERE PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера комиссии');


SELECT sc.ContractId, sc.TotalPrice, sc.AgencyFee, p.Address
FROM SaleContract sc
JOIN Property p ON sc.PropertyId = p.PropertyId
WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера комиссии');