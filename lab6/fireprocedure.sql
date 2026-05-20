
CREATE OR REPLACE PROCEDURE fire_and_reassign_employee(
    p_fired_id INTEGER, 
    p_successor_id INTEGER
)
LANGUAGE plpgsql AS $$
DECLARE
    v_is_successor_active BOOLEAN;
BEGIN
    -- Проверяем, существует ли преемник и работает ли он
    SELECT (FireDate IS NULL) INTO v_is_successor_active
    FROM Employee 
    WHERE EmployeeId = p_successor_id;
    IF NOT FOUND OR v_is_successor_active = FALSE THEN
        RAISE EXCEPTION 'Негативный сценарий: Преемник (ID %) не найден или уже уволен!', p_successor_id;
    END IF;
    -- передаем дела преемнику (обновляем связи)
    UPDATE Property SET ManagerId = p_successor_id WHERE ManagerId = 
p_fired_id;
    UPDATE SaleContract SET RealtorId = p_successor_id WHERE RealtorId = 
p_fired_id;
    UPDATE RentContract SET RealtorId = p_successor_id WHERE RealtorId = 
p_fired_id;

    UPDATE Employee SET FireDate = CURRENT_DATE WHERE EmployeeId = 
p_fired_id; 
END;
$$;
