CREATE OR REPLACE PROCEDURE generate_monthly_payouts(p_target_month DATE)
LANGUAGE plpgsql AS $$
DECLARE
    v_start_date DATE := DATE_TRUNC('month', p_target_month);
    v_end_date DATE := (v_start_date + INTERVAL '1 month') - INTERVAL '1 day';
    v_already_exists BOOLEAN;
BEGIN
    -- проверяем, не создавали ли мы уже выплаты за этот месяц
    SELECT EXISTS (
        SELECT 1 FROM PaymentDocument 
        WHERE DocumentType = 'исходящий_риелтору' 
          AND CreationDate >= v_start_date 
          AND CreationDate <= v_end_date
    ) INTO v_already_exists;

    IF v_already_exists THEN
        RAISE EXCEPTION 'Выплаты за период % уже были сформированы! Двойное начисление заблокировано.', v_start_date;
    END IF;

    -- Массовая вставка расчетов за месяц
    INSERT INTO PaymentDocument (
        ContractId, ContractType, DocumentType, Amount, CreationDate, Status, 
        RealtorId, ManagerId, AccountantId
    )
    SELECT 
        sc.ContractId, 
        'продажа', 
        'исходящий_риелтору', 
        sc.AgencyFee * (r.BasePercent / 100.0),
        CURRENT_TIMESTAMP, 
        'не оплачен', 
        sc.RealtorId, 
        1, 
        1  
    FROM SaleContract sc
    JOIN Realtor r ON sc.RealtorId = r.EmployeeId
    WHERE sc.ContractDate BETWEEN v_start_date AND v_end_date;
END;
$$;

