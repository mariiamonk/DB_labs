WITH RECURSIVE ContractChains AS (
    SELECT 
        ContractId as RootId, 
        ContractId, PropertyId, TenantId, MonthlyRent, DurationMonths, ContractDate
    FROM RentContract
    WHERE OriginalContractId IS NULL
    
    UNION ALL
    
    SELECT 
        cc.RootId, 
        rc.ContractId, rc.PropertyId, rc.TenantId, rc.MonthlyRent, rc.DurationMonths, rc.ContractDate
    FROM RentContract rc
    JOIN ContractChains cc ON rc.OriginalContractId = cc.ContractId
)

-- группируем всё по RootId
SELECT 
    -- описание объекта
    'Адрес: ' || p.Address || ' (' || p.Type || ')' as "Объект",
    c.FullName as "Арендатор",
    
    COUNT(*) as "Кол-во договоров",
    MIN(cc.ContractDate) as "Начало",
    SUM(cc.MonthlyRent * cc.DurationMonths) as "Общая сумма",
    ROUND(AVG(cc.MonthlyRent), 2) as "Средняя цена",
    
    (SELECT ContractDate FROM RentContract 
     WHERE OriginalContractId IS NOT NULL AND PropertyId = cc.PropertyId 
     ORDER BY ContractDate DESC LIMIT 1) as "Дата последнего",
     
    -- Считаем выплаты риелтору по  цепочке
    (SELECT COALESCE(SUM(Amount), 0) FROM PaymentDocument 
     WHERE ContractId IN (SELECT ContractId FROM ContractChains WHERE RootId = cc.RootId)
     AND Status = 'оплачен' AND DocumentType = 'исходящий_риелтору') as "Выплаты риелтору"

FROM ContractChains cc
JOIN Property p ON cc.PropertyId = p.PropertyId
JOIN Client c ON cc.TenantId = c.ClientId

GROUP BY cc.RootId, p.Address, p.Type, c.FullName, cc.PropertyId
HAVING COUNT(*) > 3;
