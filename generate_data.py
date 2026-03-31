#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import pg8000 as psycopg2
import random
from datetime import datetime, timedelta


def generate_string(length):
    letters = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'
    return ''.join(random.choice(letters) for _ in range(length))

def generate_digits(length):
    return ''.join(str(random.randint(0, 9)) for _ in range(length))

def generate_phone():
    return f"+7({random.randint(900, 999)}){random.randint(100, 999)}-{random.randint(10, 99)}-{random.randint(10, 99)}"

def generate_name():
    first_names = ['Иван', 'Петр', 'Сергей', 'Алексей', 'Дмитрий', 'Александр', 'Владимир', 'Михаил']
    last_names = ['Иванов', 'Петров', 'Сидоров', 'Смирнов', 'Кузнецов', 'Васильев', 'Попов', 'Соколов']
    patronymics = ['Иванович', 'Петрович', 'Сергеевич', 'Алексеевич', 'Дмитриевич', 'Александрович']
    return f"{random.choice(last_names)} {random.choice(first_names)} {random.choice(patronymics)}"

def generate_address():
    streets = ['Ленина', 'Советская', 'Мира', 'Центральная', 'Молодежная', 'Школьная', 'Садовая', 'Лесная']
    cities = ['Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань', 'Нижний Новгород']
    return f"г. {random.choice(cities)}, ул. {random.choice(streets)}, д. {random.randint(1, 100)}"

def generate_passport():
    return f"{random.randint(1000, 9999)} {random.randint(100000, 999999)}"

def generate_date(start_year=1950, end_year=2000):
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    return start + timedelta(days=random.randint(0, (end - start).days))

def insert_region(cursor, count):
    """Заполняет таблицу Region"""
    print(f"  Заполнение Region ({count} записей)...")
    
    root_names = ['Центральный', 'Северный', 'Южный', 'Западный', 'Восточный']
    root_ids = []
    
    for name in root_names[:min(3, count)]:
        cursor.execute("""
            INSERT INTO Region (Name, Description, ParentRegionId, SaleBonusCoef, RentBonusCoef)
            VALUES (%s, %s, NULL, %s, %s) RETURNING RegionId
        """, (name, f"Описание региона {name}", random.uniform(5, 15), random.uniform(3, 12)))
        root_ids.append(cursor.fetchone()[0])
        count -= 1
    
    for i in range(count):
        parent_id = random.choice(root_ids) if root_ids else None
        name = f"{random.choice(['Северный', 'Южный', 'Восточный', 'Западный', 'Центральный'])} район"
        cursor.execute("""
            INSERT INTO Region (Name, Description, ParentRegionId, SaleBonusCoef, RentBonusCoef)
            VALUES (%s, %s, %s, %s, %s)
        """, (f"{name} {i+1}", f"Описание региона {name}", parent_id, 
              random.uniform(5, 20), random.uniform(3, 15)))
    
    print(f"     Добавлено {count + len(root_ids)} регионов")

def insert_employee(cursor, count):
    print(f"  Заполнение Employee ({count} записей)...")
    
    employee_ids = []
    
    for i in range(count):
        hire_date = generate_date(2015, 2023)
        cursor.execute("""
            INSERT INTO Employee (FullName, Phone, BirthDate, TaxId, PassportNumber, HireDate, FireDate, DirectorId)
            VALUES (%s, %s, %s, %s, %s, %s, %s, NULL) RETURNING EmployeeId
        """, (
            generate_name(),
            generate_phone(),
            generate_date(1960, 1995),
            generate_digits(12),
            generate_passport(),
            hire_date,
            None if random.random() > 0.2 else hire_date + timedelta(days=random.randint(100, 1000)),
        ))
        employee_ids.append(cursor.fetchone()[0])
    
    director_id = employee_ids[0]
    cursor.execute("INSERT INTO Director (EmployeeId) VALUES (%s)", (director_id,))
    
    for emp_id in employee_ids[1:]:
        cursor.execute("UPDATE Employee SET DirectorId = %s WHERE EmployeeId = %s", (director_id, emp_id))
    
    manager_count = max(1, count // 10)
    realtor_count = max(1, count // 5)
    accountant_count = max(1, count // 20)
    
    for emp_id in employee_ids[1:1+manager_count]:
        cursor.execute("""
            INSERT INTO Manager (EmployeeId, SalePercent, RentPercent)
            VALUES (%s, %s, %s)
        """, (emp_id, random.uniform(2, 10), random.uniform(1, 8)))
    
    for emp_id in employee_ids[1+manager_count:1+manager_count+realtor_count]:
        cursor.execute("""
            INSERT INTO Realtor (EmployeeId, BasePercent)
            VALUES (%s, %s)
        """, (emp_id, random.uniform(1, 5)))
    
    for emp_id in employee_ids[1+manager_count+realtor_count:1+manager_count+realtor_count+accountant_count]:
        cursor.execute("INSERT INTO Accountant (EmployeeId) VALUES (%s)", (emp_id,))
    
    print(f"     Добавлено {count} сотрудников (1 директор, {manager_count} менеджеров, {realtor_count} риелторов, {accountant_count} бухгалтеров)")
    
    return employee_ids

def insert_client(cursor, count):
    print(f"  Заполнение Client ({count} записей)...")
    
    for _ in range(count):
        cursor.execute("""
            INSERT INTO Client (FullName, Address, PassportData)
            VALUES (%s, %s, %s)
        """, (generate_name(), generate_address(), generate_passport()))
    
    print(f"     Добавлено {count} клиентов")

def insert_bank(cursor, count):
    print(f"  Заполнение Bank ({count} записей)...")
    
    bank_names = ['Сбербанк', 'ВТБ', 'Альфа-Банк', 'Газпромбанк', 'Тинькофф', 'Райффайзенбанк']
    
    for i in range(min(count, len(bank_names))):
        cursor.execute("""
            INSERT INTO Bank (Name, LicenseNumber, Bik, AccountNumber, CorrespondentNumber)
            VALUES (%s, %s, %s, %s, %s)
        """, (bank_names[i], generate_digits(10), generate_digits(9), generate_digits(20), generate_digits(20)))
    
    for i in range(count - len(bank_names)):
        cursor.execute("""
            INSERT INTO Bank (Name, LicenseNumber, Bik, AccountNumber, CorrespondentNumber)
            VALUES (%s, %s, %s, %s, %s)
        """, (f"Банк_{i+1}", generate_digits(10), generate_digits(9), generate_digits(20), generate_digits(20)))
    
    print(f"     Добавлено {count} банков")

def insert_property(cursor, count, region_ids, manager_ids):
    print(f"  Заполнение Property ({count} записей)...")
    
    types = ['квартира', 'дом', 'офис', 'участок', 'коммерческое помещение']
    
    for _ in range(count):
        prop_type = random.choice(types)
        floor = random.randint(1, 20) if prop_type in ['квартира', 'офис'] else None
        ceiling = random.uniform(2.5, 3.5) if prop_type != 'участок' else None
        
        cursor.execute("""
            INSERT INTO Property (Type, Area, Address, Floor, CeilingHeight, RegionId, ManagerId)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            prop_type,
            round(random.uniform(20, 200), 1),
            generate_address(),
            floor,
            ceiling,
            random.choice(region_ids),
            random.choice(manager_ids)
        ))
    
    print(f"    Добавлено {count} объектов недвижимости")

def insert_sale_contract(cursor, count, property_ids, client_ids, manager_ids, realtor_ids, bank_ids):
    print(f"  Заполнение SaleContract ({count} записей)...")
    
    payment_types = ['наличные', 'ипотека', 'безналичный расчет']
    
    for _ in range(count):
        payment_type = random.choice(payment_types)
        is_mortgage = payment_type == 'ипотека'
        
        cursor.execute("""
            INSERT INTO SaleContract (PropertyId, BuyerId, SellerId, ManagerId, RealtorId, BankId,
                                       ContractDate, TotalPrice, AgencyFee, PaymentType, 
                                       MortgagePercent, MortgageTermMonths)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            random.choice(property_ids),
            random.choice(client_ids),
            random.choice(client_ids),
            random.choice(manager_ids),
            random.choice(realtor_ids),
            random.choice(bank_ids) if random.random() > 0.5 else None,
            generate_date(2023, 2025),
            round(random.uniform(1000000, 50000000), 2),
            round(random.uniform(10000, 500000), 2),
            payment_type,
            round(random.uniform(5, 20), 1) if is_mortgage else None,
            random.choice([120, 180, 240, 360]) if is_mortgage else None
        ))
    
    print(f"     Добавлено {count} договоров продажи")

def insert_rent_contract(cursor, count, property_ids, client_ids, manager_ids, realtor_ids, bank_ids):
    print(f"  Заполнение RentContract ({count} записей)...")
    
    for _ in range(count):
        cursor.execute("""
            INSERT INTO RentContract (PropertyId, TenantId, LandlordId, ManagerId, RealtorId, BankId,
                                       ContractDate, MonthlyRent, DurationMonths, OriginalContractId)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            random.choice(property_ids),
            random.choice(client_ids),
            random.choice(client_ids),
            random.choice(manager_ids),
            random.choice(realtor_ids),
            random.choice(bank_ids),
            generate_date(2023, 2025),
            round(random.uniform(10000, 200000), 2),
            random.choice([6, 12, 24, 36]),
            None
        ))
    
    print(f"     Добавлено {count} договоров аренды")

def insert_agency_contract(cursor, count, client_ids, manager_ids):
    print(f"  Заполнение AgencyContract ({count} записей)...")
    
    contract_types = ['продажа', 'аренда']
    
    for _ in range(count):
        contract_type = random.choice(contract_types)
        
        cursor.execute("""
            INSERT INTO AgencyContract (ClientId, ManagerId, ContractDate, FeeAmount, 
                                         ContractType, PropertyPrice, MonthlyRent)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            random.choice(client_ids),
            random.choice(manager_ids),
            generate_date(2023, 2025),
            round(random.uniform(10000, 100000), 2),
            contract_type,
            round(random.uniform(1000000, 30000000), 2) if contract_type == 'продажа' else None,
            round(random.uniform(10000, 150000), 2) if contract_type == 'аренда' else None
        ))
    
    print(f"     Добавлено {count} агентских договоров")

def insert_payment_document(cursor, count, sale_ids, rent_ids, realtor_ids, manager_ids, accountant_ids):
    print(f"  Заполнение PaymentDocument ({count} записей)...")
    
    doc_types = ['входящий_менеджеру', 'входящий_риелтору', 'исходящий_менеджеру', 'исходящий_риелтору']
    statuses = ['оплачен', 'не оплачен', 'частично оплачен']
    
    for _ in range(count):
        contract_type = random.choice(['продажа', 'аренда'])
        contract_id = random.choice(sale_ids) if contract_type == 'продажа' else random.choice(rent_ids)
        
        creation_date = generate_date(2023, 2025)
        
        if random.random() > 0.3:
            payment_date = creation_date + timedelta(days=random.randint(0, 60))
        else:
            payment_date = None
        
        cursor.execute("""
            INSERT INTO PaymentDocument (ContractType, ContractId, DocumentType, Amount,
                                         CreationDate, PaymentDate, Status, 
                                         RealtorId, ManagerId, AccountantId)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            contract_type,
            contract_id,
            random.choice(doc_types),
            round(random.uniform(5000, 200000), 2),
            creation_date,
            payment_date,
            random.choice(statuses),
            random.choice(realtor_ids),
            random.choice(manager_ids),
            random.choice(accountant_ids)
        ))
    
    print(f"     Добавлено {count} платежных документов")


def main():
    print("ГЕНЕРАТОР ТЕСТОВЫХ ДАННЫХ")
    print("Агентство недвижимости Find Your Place")
    print()
    
    try:
        db_password = input("Введите пароль от базы данных (postgres): ").strip()
        if not db_password:
            db_password = "postgres"
        
        print("\nВведите количество записей для каждой таблицы:")
        region_count = int(input("  Region: ") or "10")
        employee_count = int(input("  Employee: ") or "30")
        client_count = int(input("  Client: ") or "50")
        bank_count = int(input("  Bank: ") or "5")
        property_count = int(input("  Property: ") or "40")
        sale_count = int(input("  SaleContract: ") or "20")
        rent_count = int(input("  RentContract: ") or "20")
        agency_count = int(input("  AgencyContract: ") or "25")
        payment_count = int(input("  PaymentDocument: ") or "60")
        
        print("\nНАЧАЛО ГЕНЕРАЦИИ ДАННЫХ")
        
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            database='findPlace',
            user='postgres',
            password=db_password
        )
        cursor = conn.cursor()
        print(" Подключение к базе данных установлено")
        
        print("\nОчистка старых данных...")
        tables = ['paymentdocument', 'agencycontract', 'salecontract', 'rentcontract', 
                  'property', 'client', 'bank', 'realtor', 'manager', 'accountant', 
                  'director', 'employee', 'region']
        for table in tables:
            cursor.execute(f"TRUNCATE TABLE {table} CASCADE")
        print(" Таблицы очищены")
        
        print("\nСброс счетчиков...")
        sequences = ['region_regionid_seq', 'employee_employeeid_seq', 'client_clientid_seq',
                     'bank_bankid_seq', 'property_propertyid_seq', 'salecontract_contractid_seq',
                     'rentcontract_contractid_seq', 'agencycontract_contractid_seq',
                     'paymentdocument_paymentid_seq']
        for seq in sequences:
            cursor.execute(f"ALTER SEQUENCE {seq} RESTART WITH 1")
        print(" Счетчики сброшены")
        
        conn.commit()
        
        print("\nЗАПОЛНЕНИЕ ТАБЛИЦ")
        
        insert_region(cursor, region_count)
        conn.commit()
        cursor.execute("SELECT RegionId FROM Region")
        region_ids = [row[0] for row in cursor.fetchall()]
        
        employee_ids = insert_employee(cursor, employee_count)
        conn.commit()
        
        cursor.execute("SELECT EmployeeId FROM Manager")
        manager_ids = [row[0] for row in cursor.fetchall()]
        cursor.execute("SELECT EmployeeId FROM Realtor")
        realtor_ids = [row[0] for row in cursor.fetchall()]
        cursor.execute("SELECT EmployeeId FROM Accountant")
        accountant_ids = [row[0] for row in cursor.fetchall()]
        
        insert_client(cursor, client_count)
        conn.commit()
        cursor.execute("SELECT ClientId FROM Client")
        client_ids = [row[0] for row in cursor.fetchall()]
        
        insert_bank(cursor, bank_count)
        conn.commit()
        cursor.execute("SELECT BankId FROM Bank")
        bank_ids = [row[0] for row in cursor.fetchall()]
        
        insert_property(cursor, property_count, region_ids, manager_ids)
        conn.commit()
        cursor.execute("SELECT PropertyId FROM Property")
        property_ids = [row[0] for row in cursor.fetchall()]
        
        insert_sale_contract(cursor, sale_count, property_ids, client_ids, manager_ids, realtor_ids, bank_ids)
        conn.commit()
        cursor.execute("SELECT ContractId FROM SaleContract")
        sale_ids = [row[0] for row in cursor.fetchall()]
        
        insert_rent_contract(cursor, rent_count, property_ids, client_ids, manager_ids, realtor_ids, bank_ids)
        conn.commit()
        cursor.execute("SELECT ContractId FROM RentContract")
        rent_ids = [row[0] for row in cursor.fetchall()]
        
        insert_agency_contract(cursor, agency_count, client_ids, manager_ids)
        conn.commit()
        
        if sale_ids and rent_ids:
            insert_payment_document(cursor, payment_count, sale_ids, rent_ids, realtor_ids, manager_ids, accountant_ids)
            conn.commit()
        
        print("\nГЕНЕРАЦИЯ ЗАВЕРШЕНА")
        
        cursor.execute("""
            SELECT 'Region' as table_name, COUNT(*) FROM Region
            UNION ALL SELECT 'Employee', COUNT(*) FROM Employee
            UNION ALL SELECT 'Manager', COUNT(*) FROM Manager
            UNION ALL SELECT 'Realtor', COUNT(*) FROM Realtor
            UNION ALL SELECT 'Accountant', COUNT(*) FROM Accountant
            UNION ALL SELECT 'Client', COUNT(*) FROM Client
            UNION ALL SELECT 'Bank', COUNT(*) FROM Bank
            UNION ALL SELECT 'Property', COUNT(*) FROM Property
            UNION ALL SELECT 'SaleContract', COUNT(*) FROM SaleContract
            UNION ALL SELECT 'RentContract', COUNT(*) FROM RentContract
            UNION ALL SELECT 'AgencyContract', COUNT(*) FROM AgencyContract
            UNION ALL SELECT 'PaymentDocument', COUNT(*) FROM PaymentDocument
        """)
        
        print("\nИтоговое количество записей:")
        for row in cursor.fetchall():
            print(f"  {row[0]}: {row[1]}")
        
        cursor.close()
        conn.close()
        
    except psycopg2.OperationalError as e:
        print(f"\nОшибка подключения: {e}")
        print("   Проверьте пароль и название базы данных")
    except ValueError as e:
        print(f"\nОшибка ввода: {e}")
    except Exception as e:
        print(f"\nОшибка: {e}")
        conn.rollback()

if __name__ == "__main__":
    main()