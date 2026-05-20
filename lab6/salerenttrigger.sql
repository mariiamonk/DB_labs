CREATE OR REPLACE FUNCTION check_double_sale() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM SaleContract 
        WHERE PropertyId = NEW.PropertyId 
          AND ContractId != COALESCE(NEW.ContractId, -1)
    ) THEN
        RAISE EXCEPTION 'Ошибка: Объект недвижимости с ID % уже продан!', NEW.PropertyId;
    END IF; 
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trg_prevent_double_sale
BEFORE INSERT OR UPDATE ON SaleContract
FOR EACH ROW
EXECUTE PROCEDURE check_double_sale();
CREATE OR REPLACE FUNCTION check_rent_overlap() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM RentContract 
        WHERE PropertyId = NEW.PropertyId 
          AND ContractId != COALESCE(NEW.ContractId, -1)
          AND (NEW.ContractDate, (NEW.DurationMonths || ' months')::interval) 
              OVERLAPS 
              (ContractDate, (DurationMonths || ' months')::interval)
    ) THEN
        RAISE EXCEPTION 'Ошибка: Объект недвижимости с ID % уже сдан в аренду на выбранные даты!', NEW.PropertyId;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_double_rent
BEFORE INSERT OR UPDATE ON RentContract
FOR EACH ROW
EXECUTE PROCEDURE check_rent_overlap();
