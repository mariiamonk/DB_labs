INSERT INTO Region (Name, Description, ParentRegionId, SaleBonusCoef, RentBonusCoef) VALUES
('Москва', 'Столичный регион', NULL, 15.0, 12.0),
('Санкт-Петербург', 'Северная столица', NULL, 14.0, 11.0);

INSERT INTO Region (Name, Description, ParentRegionId, SaleBonusCoef, RentBonusCoef) VALUES
('Центральный округ', 'Центр Москвы', 1, 18.0, 14.0),
('Приморский район', 'Район у залива', 2, 12.5, 10.0),
('Московская область', 'Область вокруг Москвы', 1, 10.0, 8.5);

INSERT INTO Employee (FullName, Phone, BirthDate, TaxId, PassportNumber, HireDate, FireDate, DirectorId) VALUES
('Директоров Дмитрий Дмитриевич', '+7(495)111-22-33', '1980-01-15', '123456789012', '4500 111111', '2020-01-10', NULL, NULL),
('Менеджеров Михаил Михайлович', '+7(495)222-33-44', '1985-05-20', '234567890123', '4500 222222', '2021-03-15', NULL, NULL),
('Риелторов Роман Романович', '+7(495)333-44-55', '1990-07-10', '345678901234', '4500 333333', '2022-01-20', NULL, NULL),
('Бухгалтеров Борис Борисович', '+7(495)444-55-66', '1988-11-05', '456789012345', '4500 444444', '2021-06-01', NULL, NULL),
('Второй_Менеджер Анна Сергеевна', '+7(495)555-66-77', '1992-03-25', '567890123456', '4500 555555', '2023-02-01', NULL, NULL);

INSERT INTO Director (EmployeeId) VALUES (1);
UPDATE Employee SET DirectorId = NULL WHERE EmployeeId = 1;

INSERT INTO Manager (EmployeeId) VALUES (2), (5);
INSERT INTO Realtor (EmployeeId) VALUES (3);
INSERT INTO Accountant (EmployeeId) VALUES (4);

INSERT INTO Client (FullName, Address, PassportData) VALUES
('Иванов Иван Иванович', 'г. Москва, ул. Тверская, д. 10, кв. 5', '4510 123456'),
('Петрова Мария Сергеевна', 'г. Москва, ул. Арбат, д. 15', '4510 654321'),
('Сидоров Алексей Петрович', 'г. Санкт-Петербург, Невский пр., д. 25', '4510 789012'),
('Кузнецова Елена Владимировна', 'г. Москва, Ленинский пр., д. 50', '4510 345678'),
('Смирнов Дмитрий Алексеевич', 'Московская обл., г. Химки, ул. Речная, д. 5', '4510 901234');

INSERT INTO Bank (Name, LicenseNumber, Bik, AccountNumber, CorrespondentNumber) VALUES
('Сбербанк', '1234567890', '044525225', '40702810123456789012', '30101810400000000225'),
('ВТБ', '0987654321', '044525745', '40702810234567890123', '30101810100000000745'),
('Альфа-Банк', '1122334455', '044525593', '40702810345678901234', '30101810200000000593');

INSERT INTO Property (Type, Area, Address, Floor, CeilingHeight, RegionId, ManagerId) VALUES
('квартира', 45.5, 'г. Москва, ул. Тверская, д. 10, кв. 5', 3, 2.7, 3, 2),
('квартира', 78.0, 'г. Москва, ул. Арбат, д. 15, кв. 8', 5, 2.8, 3, 2),
('дом', 150.0, 'Московская обл., дер. Примерная, ул. Центральная, д. 1', NULL, 3.2, 5, 2),
('офис', 120.5, 'г. Москва, БЦ "Москва-Сити", башня "Федерация"', 45, 3.5, 1, 2),
('квартира', 55.0, 'г. Санкт-Петербург, Невский пр., д. 25, кв. 12', 2, 2.6, 4, 5);

INSERT INTO SaleContract (PropertyId, BuyerId, SellerId, ManagerId, RealtorId, BankId, ContractDate, TotalPrice, AgencyFee, PaymentType, MortgagePercent, MortgageTermMonths) VALUES
(1, 1, 2, 2, 3, 1, '2025-03-15', 12500000.00, 250000.00, 'ипотека', 12.5, 240),
(2, 3, 4, 2, 3, NULL, '2025-03-20', 18000000.00, 360000.00, 'наличные', NULL, NULL),
(5, 5, 1, 5, 3, 2, '2025-03-25', 8500000.00, 170000.00, 'ипотека', 10.5, 180);

INSERT INTO RentContract (PropertyId, TenantId, LandlordId, ManagerId, RealtorId, BankId, ContractDate, MonthlyRent, DurationMonths, OriginalContractId) VALUES
(3, 2, 5, 2, 3, 1, '2025-03-10', 45000.00, 12, NULL),
(4, 1, 3, 5, 3, 2, '2025-03-18', 120000.00, 24, NULL);

INSERT INTO AgencyContract (ClientId, ManagerId, ContractDate, FeeAmount, ContractType, PropertyPrice, MonthlyRent) VALUES
(1, 2, '2025-03-01', 50000.00, 'продажа', 12500000.00, NULL),
(2, 5, '2025-03-05', 35000.00, 'аренда', NULL, 45000.00),
(3, 2, '2025-03-08', 60000.00, 'продажа', 18000000.00, NULL);

INSERT INTO PaymentDocument (ContractType, ContractId, DocumentType, Amount, CreationDate, PaymentDate, Status, RealtorId, ManagerId, AccountantId) VALUES
('продажа', 1, 'входящий_менеджеру', 250000.00, '2025-03-15 10:30:00', '2025-03-16 14:00:00', 'оплачен', 3, 2, 4),
('продажа', 2, 'входящий_менеджеру', 360000.00, '2025-03-20 11:00:00', NULL, 'не оплачен', 3, 2, 4),
('аренда', 1, 'входящий_риелтору', 22500.00, '2025-03-10 09:00:00', '2025-03-11 10:00:00', 'оплачен', 3, 2, 4);
