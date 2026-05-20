EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT p.Address, p.Area, e.FullName, rc.MonthlyRent
FROM RentContract rc
JOIN Property p ON rc.PropertyId = p.PropertyId
JOIN Employee e ON rc.RealtorId = e.EmployeeId
WHERE p.Type = 'квартира' AND p.Area >= 40.0
  AND rc.DurationMonths >= 12;

-- Composite Index
-- поиск недвижимости по типу и площади одновременно
CREATE INDEX idx_prop_type_area ON Property(Type, Area);

-- Partial Index
-- Индексирует только долгосрочные договоры
CREATE INDEX idx_rent_longterm ON RentContract(PropertyId, RealtorId) 
WHERE DurationMonths >= 12;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT sc.RealtorId, e.FullName, SUM(sc.TotalPrice) as TotalRevenue
FROM SaleContract sc
JOIN Employee e ON sc.RealtorId = e.EmployeeId
WHERE sc.PaymentType = 'наличные'
GROUP BY sc.RealtorId, e.FullName
ORDER BY TotalRevenue DESC;

-- Покрывающий индекс
CREATE INDEX idx_sale_payment_cover ON SaleContract(PaymentType, RealtorId) INCLUDE (TotalPrice);
