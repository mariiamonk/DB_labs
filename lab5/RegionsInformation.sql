WITH RECURSIVE RegionHierarchy AS (
-- Выбираем самые верхние регионы, у которых нет родительских 
    SELECT 
        RegionId,
        Name,
        Description,
        ParentRegionId,
        Name AS TopParentName,
        1 AS Level
    FROM Region
    WHERE ParentRegionId IS NULL
    
    UNION ALL
    
    SELECT 
        r.RegionId,
        r.Name,
        r.Description,
        r.ParentRegionId,
        rh.TopParentName,
        rh.Level + 1
    FROM Region r
    JOIN RegionHierarchy rh ON r.ParentRegionId = rh.RegionId
)
SELECT 
    rh.Name AS "Название региона",
    COALESCE(rh.Description, 'Описание отсутствует') AS "Описание",
    COALESCE(pr.Name, '-') AS "Родительский регион",
    rh.TopParentName AS "Самый верхний родительский регион"
FROM RegionHierarchy rh
LEFT JOIN Region pr ON rh.ParentRegionId = pr.RegionId
ORDER BY rh.TopParentName, rh.Level, rh.Name;
