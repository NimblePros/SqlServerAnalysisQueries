--Total Stored Procedures
SELECT COUNT(*) AS TotalUserStoredProcedures
FROM sys.procedures
WHERE is_ms_shipped = 0
AND name NOT IN ('sp_upgraddiagrams', 'sp_helpdiagrams', 'sp_helpdiagramdefinition',
                 'sp_creatediagram', 'sp_renamediagram', 'sp_alterdiagram', 'sp_dropdiagram');

--Total and Average Length of Stored Procedures
SELECT 
    COUNT(*) AS TotalStoredProcedures,
    SUM(LEN(sm.definition)) AS TotalLengthOfStoredProcedures,
    AVG(LEN(sm.definition)) AS AverageLengthOfStoredProcedures
FROM 
    sys.procedures AS sp
JOIN 
    sys.sql_modules AS sm ON sp.object_id = sm.object_id
WHERE 
    sp.is_ms_shipped = 0
	AND name NOT IN ('sp_upgraddiagrams', 'sp_helpdiagrams', 'sp_helpdiagramdefinition',
                 'sp_creatediagram', 'sp_renamediagram', 'sp_alterdiagram', 'sp_dropdiagram')

--Top 10 Longest Stored Procedures
SELECT TOP 10
    OBJECT_NAME(sm.object_id) AS StoredProcedureName,
    LEN(sm.definition) AS LengthInCharacters
FROM 
    sys.sql_modules AS sm
JOIN 
    sys.procedures AS sp ON sm.object_id = sp.object_id
WHERE 
    sp.is_ms_shipped = 0
	AND name NOT IN ('sp_upgraddiagrams', 'sp_helpdiagrams', 'sp_helpdiagramdefinition',
                 'sp_creatediagram', 'sp_renamediagram', 'sp_alterdiagram', 'sp_dropdiagram')
ORDER BY 
    LEN(sm.definition) DESC;

--Stored Procedures Ordered by Parameter Count Descending
SELECT 
    OBJECT_NAME(sm.object_id) AS StoredProcedureName,
    COUNT(p.parameter_id) AS NumberOfParameters
FROM 
    sys.sql_modules AS sm
JOIN 
    sys.procedures AS sp ON sm.object_id = sp.object_id
LEFT JOIN 
    sys.parameters AS p ON sm.object_id = p.object_id
WHERE 
    sp.is_ms_shipped = 0
	AND sp.name NOT IN ('sp_upgraddiagrams', 'sp_helpdiagrams', 'sp_helpdiagramdefinition',
                 'sp_creatediagram', 'sp_renamediagram', 'sp_alterdiagram', 'sp_dropdiagram')

GROUP BY 
    sm.object_id
ORDER BY 
    COUNT(p.parameter_id) DESC;

--Top 10 Tables With Most Columns
SELECT TOP 10
    t.name AS TableName,
    COUNT(c.column_id) AS NumberOfColumns
FROM 
    sys.tables AS t
JOIN 
    sys.columns AS c ON t.object_id = c.object_id
GROUP BY 
    t.name
ORDER BY 
    COUNT(c.column_id) DESC;

--Foreign Key and Table Counts and Ratio
WITH FKCounts AS (
    SELECT 
        COUNT(f.object_id) AS ForeignKeyCount
    FROM 
        sys.foreign_keys AS f
),
TableCounts AS (
    SELECT 
        COUNT(t.object_id) AS TableCount
    FROM 
        sys.tables AS t
)
SELECT 
    (SELECT ForeignKeyCount FROM FKCounts) AS TotalForeignKeys,
    (SELECT TableCount FROM TableCounts) AS TotalTables,
    CAST((SELECT ForeignKeyCount FROM FKCounts) AS FLOAT) / 
    CAST((SELECT TableCount FROM TableCounts) AS FLOAT) AS ForeignKeyToTableRatio

--Total Views
SELECT COUNT(*) AS TotalUserViews
FROM sys.views
WHERE is_ms_shipped = 0;

--Total Indexes (not PK or Unique)
SELECT COUNT(*) AS TotalIndexes
FROM sys.indexes
WHERE is_primary_key = 0 AND is_unique_constraint = 0;

--Total User-Defined Triggers
SELECT COUNT(*) AS TotalTriggers
FROM sys.triggers
WHERE is_ms_shipped = 0;

--Total Users and Roles
SELECT 
    'Database Users' AS SecurityElement, COUNT(*) AS Total
FROM sys.database_principals
WHERE type_desc IN ('SQL_USER', 'WINDOWS_USER', 'EXTERNAL_USER')
UNION ALL
SELECT 
    'Database Roles' AS SecurityElement, COUNT(*) AS Total
FROM sys.database_principals
WHERE type_desc = 'DATABASE_ROLE';

--Total Functions, Schemas, Types
SELECT 'Scalar-valued Functions' AS ItemType, COUNT(*) AS TotalCount
FROM sys.objects
WHERE type = 'FN'
UNION ALL
SELECT 'Table-valued Functions' AS ItemType, COUNT(*) AS TotalCount
FROM sys.objects
WHERE type IN ('TF', 'IF', 'TVF')
UNION ALL
SELECT 'Schemas' AS ItemType, COUNT(*) AS TotalCount
FROM sys.schemas
UNION ALL
SELECT 'Partition Functions' AS ItemType, COUNT(*) AS TotalCount
FROM sys.partition_functions
UNION ALL
SELECT 'User-defined Types' AS ItemType, COUNT(*) AS TotalCount
FROM sys.types
WHERE is_user_defined = 1
