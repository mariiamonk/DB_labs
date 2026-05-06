-- создаем список всех сделок
WITH AllContracts AS (
    SELECT RealtorId, ContractDate, 'Аренда' AS ContractType FROM RentContract
    UNION ALL
    SELECT RealtorId, ContractDate, 'Продажа' AS ContractType FROM SaleContract
),

-- Находим дату самой последней сделки для каждого р
LastDates AS (
    SELECT RealtorId, MAX(ContractDate) AS MaxDate
    FROM AllContracts
    GROUP BY RealtorId
)

SELECT 
    e.FullName AS "ФИО риелтора",
    
    -- Считаем количество и суммы аренды
    (SELECT COUNT(*) FROM RentContract WHERE RealtorId = r.EmployeeId) AS "Аренды",
    (SELECT SUM(MonthlyRent * DurationMonths) FROM RentContract WHERE RealtorId = r.EmployeeId) AS "Сумма ар.",
    
    -- Считаем количество и суммы продажи
    (SELECT COUNT(*) FROM SaleContract WHERE RealtorId = r.EmployeeId) AS "Продажи",
    (SELECT SUM(TotalPrice) FROM SaleContract WHERE RealtorId = r.EmployeeId) AS "Сумма пр.",
    
    -- Получаем дату и тип последней сделки
    ld.MaxDate AS "Дата последней сделки",
    (SELECT ContractType FROM AllContracts 
     WHERE RealtorId = r.EmployeeId AND ContractDate = ld.MaxDate 
     LIMIT 1) AS "Тип последней сделки",
    
    COALESCE(SUM(pd.Amount), 0) AS "Всего выплачено"

FROM Realtor r
JOIN Employee e ON r.EmployeeId = e.EmployeeId
LEFT JOIN LastDates ld ON r.EmployeeId = ld.RealtorId
LEFT JOIN PaymentDocument pd ON r.EmployeeId = pd.RealtorId 
    AND pd.Status = 'оплачен' 
    AND pd.DocumentType = 'исходящий_риелтору'

GROUP BY e.FullName, r.EmployeeId, ld.MaxDate;
