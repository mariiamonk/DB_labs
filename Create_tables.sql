DROP TABLE IF EXISTS PaymentDocument CASCADE;
DROP TABLE IF EXISTS AgencyContract CASCADE;
DROP TABLE IF EXISTS SaleContract CASCADE;
DROP TABLE IF EXISTS RentContract CASCADE;
DROP TABLE IF EXISTS Property CASCADE;
DROP TABLE IF EXISTS Client CASCADE;
DROP TABLE IF EXISTS Bank CASCADE;
DROP TABLE IF EXISTS Realtor CASCADE;
DROP TABLE IF EXISTS Manager CASCADE;
DROP TABLE IF EXISTS Accountant CASCADE;
DROP TABLE IF EXISTS Director CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS Region CASCADE;
DROP DOMAIN IF EXISTS property_type_domain CASCADE;
DROP DOMAIN IF EXISTS payment_type_domain CASCADE;
DROP DOMAIN IF EXISTS contract_type_domain CASCADE;
DROP DOMAIN IF EXISTS document_type_domain CASCADE;
DROP DOMAIN IF EXISTS payment_status_domain CASCADE;

CREATE TABLE IF NOT EXISTS Employee (
    EmployeeId SERIAL PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL,
    Phone VARCHAR(255) NOT NULL CHECK (Phone ~ '^\+?[0-9\-\s\(\)]{10,20}$'),
    BirthDate DATE NOT NULL CHECK (BirthDate <= CURRENT_DATE - INTERVAL '18 years'),
    TaxId VARCHAR(255) NOT NULL UNIQUE,
    PassportNumber VARCHAR(255) NOT NULL UNIQUE,
    HireDate DATE NOT NULL,
    FireDate DATE NULL CHECK ((FireDate IS NULL OR FireDate >= HireDate) AND FireDate <= CURRENT_DATE),
    DirectorId INTEGER
);

CREATE TABLE IF NOT EXISTS Director (
    EmployeeId INTEGER PRIMARY KEY,
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

ALTER TABLE Employee 
ADD FOREIGN KEY (DirectorId) REFERENCES Director(EmployeeId);

CREATE TABLE IF NOT EXISTS Realtor (
    EmployeeId INTEGER PRIMARY KEY,
    BasePercent DECIMAL(5,2) NOT NULL DEFAULT 5 CHECK (BasePercent BETWEEN 0 AND 100),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

CREATE TABLE IF NOT EXISTS Manager (
    EmployeeId INTEGER PRIMARY KEY,
    SalePercent DECIMAL(5,2) NOT NULL DEFAULT 10 CHECK (SalePercent BETWEEN 0 AND 100),
    RentPercent DECIMAL(5,2) NOT NULL DEFAULT 15 CHECK (RentPercent BETWEEN 0 AND 100),
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

CREATE TABLE IF NOT EXISTS Accountant (
    EmployeeId INTEGER PRIMARY KEY,
    FOREIGN KEY (EmployeeId) REFERENCES Employee(EmployeeId)
);

CREATE TABLE  IF NOT EXISTS Region (
	RegionId SERIAL PRIMARY KEY,
	Name VARCHAR(255) NOT NULL UNIQUE,
	Description VARCHAR(1024) DEFAULT 'Описание отсутствует',
	ParentRegionId INTEGER CHECK (ParentRegionId IS NULL OR ParentRegionId != RegionId),
	SaleBonusCoef DECIMAL(5, 2) DEFAULT 0 NOT NULL CHECK (SaleBonusCoef BETWEEN 0 AND 100),
	RentBonusCoef DECIMAL(5, 2) DEFAULT 0 NOT NULL CHECK (RentBonusCoef BETWEEN 0 AND 100),

	FOREIGN KEY (ParentRegionId) REFERENCES Region(RegionId)
);

CREATE DOMAIN property_type_domain AS VARCHAR(50)
CHECK (VALUE IN ('квартира', 'дом', 'офис', 'участок', 'коммерческое помещение'));

CREATE TABLE IF NOT EXISTS Property (
	PropertyId SERIAL PRIMARY KEY,
	Type property_type_domain NOT NULL,
	Area DECIMAL(10,2) NOT NULL CHECK (Area > 0),
    Address VARCHAR(255) NOT NULL,
    Floor INTEGER DEFAULT 1,
    CeilingHeight DECIMAL(10,2) DEFAULT 3,
    RegionId INTEGER NOT NULL,
    ManagerId INTEGER NOT NULL,
	
    FOREIGN KEY (RegionId) REFERENCES Region(RegionId),
    FOREIGN KEY (ManagerId) REFERENCES Manager(EmployeeId)
);

CREATE TABLE IF NOT EXISTS Client (
    ClientId SERIAL PRIMARY KEY,
    FullName VARCHAR(255) NOT NULL CHECK (LENGTH(FullName) > 0),
    Address VARCHAR(255) NOT NULL,
    PassportData VARCHAR(255) NOT NULL UNIQUE CHECK (PassportData ~ '^[0-9]{4}\s[0-9]{6}$')
);

CREATE TABLE Bank (
    BankId SERIAL PRIMARY KEY,
    Name VARCHAR(255) NOT NULL UNIQUE,
    LicenseNumber VARCHAR(255) NOT NULL UNIQUE,
    Bik VARCHAR(9) NOT NULL UNIQUE CHECK (Bik ~ '^[0-9]{9}$'),
    AccountNumber VARCHAR(20) NOT NULL UNIQUE CHECK (AccountNumber ~ '^[0-9]{20}$'),
    CorrespondentNumber VARCHAR(20) NOT NULL UNIQUE CHECK (CorrespondentNumber ~ '^[0-9]{20}$')
);

CREATE DOMAIN payment_type_domain AS VARCHAR(50)
CHECK (VALUE IN ('наличные', 'ипотека', 'безналичный расчет', 'материнский капитал'));

CREATE TABLE IF NOT EXISTS SaleContract (
    ContractId SERIAL PRIMARY KEY,
    PropertyId INTEGER NOT NULL,
    BuyerId INTEGER NOT NULL,
    SellerId INTEGER NOT NULL,
    ManagerId INTEGER NOT NULL,
    RealtorId INTEGER NOT NULL,
    BankId INTEGER NULL,
    ContractDate DATE NOT NULL DEFAULT CURRENT_DATE CHECK (ContractDate <= CURRENT_DATE),
    TotalPrice DECIMAL(15,2) NOT NULL,
    AgencyFee DECIMAL(15,2) NOT NULL CHECK(AgencyFee > 0),
    PaymentType payment_type_domain NOT NULL DEFAULT 'наличные',
    MortgagePercent DECIMAL(5,2) NULL CHECK (MortgagePercent IS NULL OR MortgagePercent BETWEEN 0 AND 100),
    MortgageTermMonths INTEGER NULL CHECK (MortgageTermMonths IS NULL OR MortgageTermMonths > 0) CHECK ((PaymentType = 'ипотека' AND MortgagePercent IS NOT NULL AND MortgageTermMonths IS NOT NULL) OR (PaymentType != 'ипотека' AND MortgagePercent IS NULL AND MortgageTermMonths IS NULL)),
	
    FOREIGN KEY (PropertyId) REFERENCES Property(PropertyId),
    FOREIGN KEY (BuyerId) REFERENCES Client(ClientId),
    FOREIGN KEY (SellerId) REFERENCES Client(ClientId),
    FOREIGN KEY (ManagerId) REFERENCES Manager(EmployeeId),
    FOREIGN KEY (RealtorId) REFERENCES Realtor(EmployeeId),
    FOREIGN KEY (BankId) REFERENCES Bank(BankId)
);

CREATE TABLE IF NOT EXISTS RentContract (
    ContractId SERIAL PRIMARY KEY,
    PropertyId INTEGER NOT NULL,
    TenantId INTEGER NOT NULL,
    LandlordId INTEGER NOT NULL,
    ManagerId INTEGER NOT NULL,
    RealtorId INTEGER NOT NULL,
    BankId INTEGER NOT NULL,
    ContractDate DATE NOT NULL DEFAULT CURRENT_DATE,
    MonthlyRent DECIMAL(15,2) NOT NULL CHECK (MonthlyRent > 0),
    DurationMonths INTEGER NOT NULL CHECK (DurationMonths > 0),
    OriginalContractId INTEGER NULL CHECK (OriginalContractId IS NULL OR OriginalContractId != ContractId),
	
    FOREIGN KEY (PropertyId) REFERENCES Property(PropertyId),
    FOREIGN KEY (TenantId) REFERENCES Client(ClientId),
    FOREIGN KEY (LandlordId) REFERENCES Client(ClientId),
    FOREIGN KEY (ManagerId) REFERENCES Manager(EmployeeId),
    FOREIGN KEY (RealtorId) REFERENCES Realtor(EmployeeId),
    FOREIGN KEY (BankId) REFERENCES Bank(BankId),
    FOREIGN KEY (OriginalContractId) REFERENCES RentContract(ContractId)
);

CREATE DOMAIN contract_type_domain AS VARCHAR(50)
CHECK (VALUE IN ('продажа', 'аренда'));

CREATE DOMAIN document_type_domain AS VARCHAR(50)
CHECK (VALUE IN ('входящий_риелтору', 'входящий_менеджеру', 'исходящий_риелтору', 'исходящий_менеджеру'));

CREATE DOMAIN payment_status_domain AS VARCHAR(50)
CHECK (VALUE IN ('оплачен', 'не оплачен', 'частично оплачен', 'просрочен'));

CREATE TABLE IF NOT EXISTS PaymentDocument (
    PaymentId SERIAL PRIMARY KEY,
    ContractType contract_type_domain NOT NULL,
    ContractId INTEGER NOT NULL,
    DocumentType document_type_domain NOT NULL,
    Amount DECIMAL(15,2) NOT NULL CHECK (Amount > 0),
    CreationDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PaymentDate TIMESTAMP NULL CHECK (PaymentDate IS NULL OR PaymentDate >= CreationDate),
    Status payment_status_domain NOT NULL DEFAULT 'не оплачен',
    RealtorId INTEGER NOT NULL,
    ManagerId INTEGER NOT NULL,
    AccountantId INTEGER NOT NULL,
	
    FOREIGN KEY (RealtorId) REFERENCES Realtor(EmployeeId),
    FOREIGN KEY (ManagerId) REFERENCES Manager(EmployeeId),
    FOREIGN KEY (AccountantId) REFERENCES Accountant(EmployeeId)
);

CREATE TABLE IF NOT EXISTS AgencyContract (
    ContractId SERIAL PRIMARY KEY,
    ClientId INTEGER NOT NULL,
    ManagerId INTEGER NOT NULL,
    ContractDate DATE NOT NULL DEFAULT CURRENT_DATE CHECK (ContractDate <= CURRENT_DATE),
    FeeAmount DECIMAL(15,2) NOT NULL CHECK (FeeAmount > 0),
    ContractType contract_type_domain NOT NULL CHECK ((ContractType = 'продажа' AND PropertyPrice IS NOT NULL AND MonthlyRent IS NULL) OR (ContractType = 'аренда' AND PropertyPrice IS NULL AND MonthlyRent IS NOT NULL)),
    PropertyPrice DECIMAL(15,2) NULL CHECK (PropertyPrice IS NULL OR PropertyPrice > 0),
    MonthlyRent DECIMAL(15,2) NULL CHECK (MonthlyRent IS NULL OR MonthlyRent > 0),
	
    FOREIGN KEY (ClientId) REFERENCES Client(ClientId),
    FOREIGN KEY (ManagerId) REFERENCES Manager(EmployeeId)
);

