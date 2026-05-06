WITH RECURSIVE ContractChains AS (
    --  самые первые договоры, у которых нет предка
    SELECT 
        ContractId AS RootId, -- Метка всей цепочки
        ContractId, 
        PropertyId, 
        TenantId, 
        MonthlyRent, 
        DurationMonths, 
        ContractDate
    FROM RentContract
    WHERE OriginalContractId IS NULL
    
    UNION ALL
    
    SELECT 
        cc.RootId, 
        rc.ContractId, 
        rc.PropertyId, 
        rc.TenantId, 
        rc.MonthlyRent, 
        rc.DurationMonths, 
        rc.ContractDate
    FROM RentContract rc
    JOIN ContractChains cc ON rc.OriginalContractId = cc.ContractId
),

-- данные самого нового договора в каждой цепочке
LastContractData AS (
    SELECT DISTINCT ON (RootId) 
        RootId, 
        MonthlyRent AS LastPrice, 
        ContractDate AS LastStartDate,
        -- дата окончания дата старта + количество месяцев
        (ContractDate + (DurationMonths || ' months')::interval)::date AS LastEndDate
    FROM ContractChains
    ORDER BY RootId, ContractDate DESC
)

SELECT 
    -- Описание жилья
    'Тип: ' || p.Type || ', Адрес: ' || p.Address || ', Площадь: ' || p.Area AS "Описание жилья",
    cl.FullName AS "Участник договора",
    MIN(cc.ContractDate) AS "Дата начала первого договора",
    COUNT(cc.ContractId) AS "Число договоров",
    lc.LastStartDate AS "Дата начала последнего",
    lc.LastEndDate AS "Дата окончания последнего",
    CASE 
        WHEN lc.LastEndDate >= CURRENT_DATE THEN 'Да' 
        ELSE 'Нет' 
    END AS "Актуальный договор",
    SUM(cc.MonthlyRent * cc.DurationMonths) AS "Общая сумма всех договоров",
    ROUND(AVG(cc.MonthlyRent), 2) AS "Средняя цена за месяц",
    lc.LastPrice AS "Цена последнего договора",
    
    -- считаем через подзапрос по ID всех контрактов в цепочке
    (SELECT COALESCE(SUM(pd.Amount), 0) 
     FROM PaymentDocument pd 
     WHERE pd.ContractId IN (SELECT cc2.ContractId FROM ContractChains cc2 WHERE cc2.RootId = cc.RootId)
       AND pd.ContractType = 'аренда' 
       AND pd.Status = 'оплачен' 
       AND pd.DocumentType = 'исходящий_риелтору'
    ) AS "Сумма выплат риелтору"

FROM ContractChains cc
JOIN LastContractData lc ON cc.RootId = lc.RootId
JOIN Property p ON cc.PropertyId = p.PropertyId
JOIN Client cl ON cc.TenantId = cl.ClientId
GROUP BY 
    cc.RootId, 
    p.Type, p.Address, p.Area, 
    cl.FullName, 
    lc.LastStartDate, lc.LastEndDate, lc.LastPrice
HAVING COUNT(cc.ContractId) > 3;
