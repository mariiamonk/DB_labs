-- SELECT * FROM Property;

-- DELETE FROM SaleContract WHERE PropertyId IN (SELECT PropertyId FROM Property WHERE Address = 'тест триггера');
-- DELETE FROM Property WHERE Address = 'тест триггера';

-- SELECT * FROM Property;

-- INSERT INTO Property (Type, Area, Address, RegionId, ManagerId)
-- VALUES ('квартира', 55.5, 'тест триггера', 
--         (SELECT MAX(RegionId) FROM Region), 
--         (SELECT MAX(EmployeeId) FROM Manager));

-- SELECT * FROM Property 
-- WHERE Address = 'тест триггера' 
-- ORDER BY PropertyId DESC;


-- SELECT sc.ContractId, sc.TotalPrice, sc.ContractDate, p.Address
-- FROM SaleContract sc
-- JOIN Property p ON sc.PropertyId = p.PropertyId
-- WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера');

-- INSERT INTO SaleContract (PropertyId, BuyerId, SellerId, ManagerId, RealtorId, BankId, TotalPrice, AgencyFee, PaymentType, ContractDate)
-- VALUES (
--     (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера'), 
--     (SELECT MAX(ClientId) FROM Client),  
--     (SELECT MIN(ClientId) FROM Client),  
--     (SELECT MAX(EmployeeId) FROM Manager), 
--     (SELECT MAX(EmployeeId) FROM Realtor), 
--     (SELECT MAX(BankId) FROM Bank), 
--     10000000, 500000, 'наличные', CURRENT_DATE
-- );

-- SELECT sc.ContractId, sc.TotalPrice, sc.ContractDate, p.Address
-- FROM SaleContract sc
-- JOIN Property p ON sc.PropertyId = p.PropertyId
-- WHERE p.PropertyId = (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера');

INSERT INTO SaleContract (PropertyId, BuyerId, SellerId, ManagerId, RealtorId, BankId, TotalPrice, AgencyFee, PaymentType, ContractDate)
VALUES (
    (SELECT MAX(PropertyId) FROM Property WHERE Address = 'тест триггера'), 
    (SELECT MAX(ClientId) FROM Client), 
    (SELECT MIN(ClientId) FROM Client),  
    (SELECT MAX(EmployeeId) FROM Manager), 
    (SELECT MAX(EmployeeId) FROM Realtor), 
    (SELECT MAX(BankId) FROM Bank), 
    15000000, 750000, 'наличные', CURRENT_DATE
);