/*
===============================================================================
  002_reference.sql
  Arrival Rows — first phase reference data

  Creates and seeds only the minimum lookup/reference objects needed for:
    - dbo.ArrivalRowsUnreleased

  In scope:
    - dbo.ArrivalRowStatuses

  Also:
    - adds missing foreign key on dbo.ArrivalRowsUnreleased.StatusID
===============================================================================
*/

SET NOCOUNT ON

-------------------------------------------------------------------------------
-- 1. Create dbo.ArrivalRowStatuses
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalRowStatuses', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalRowStatuses
    (
        ID int IDENTITY(1,1) NOT NULL,
        Code nvarchar(50) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_ArrivalRowStatuses_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_ArrivalRowStatuses
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_ArrivalRowStatuses_Code
            UNIQUE (Code),

        CONSTRAINT UQ_ArrivalRowStatuses_Name
            UNIQUE (Name)
    )
END

-------------------------------------------------------------------------------
-- 2. Seed dbo.ArrivalRowStatuses
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalRowStatuses', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.ArrivalRowStatuses
    SET Code      = src.Code,
        Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.ArrivalRowStatuses tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'DRAFT'     AS Code, N'Draft'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'OPEN',           N'Open',             CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'READY',          N'Ready',            CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'RELEASED',       N'Released',         CAST(1 AS bit), 4
        UNION ALL
        SELECT 5, N'CANCELLED',      N'Cancelled',        CAST(1 AS bit), 5
    ) src
        ON tgt.ID = src.ID

    SET IDENTITY_INSERT dbo.ArrivalRowStatuses ON

    INSERT INTO dbo.ArrivalRowStatuses
    (
        ID,
        Code,
        Name,
        IsActive,
        SortOrder
    )
    SELECT
        src.ID,
        src.Code,
        src.Name,
        src.IsActive,
        src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'DRAFT'     AS Code, N'Draft'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'OPEN',           N'Open',             CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'READY',          N'Ready',            CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'RELEASED',       N'Released',         CAST(1 AS bit), 4
        UNION ALL
        SELECT 5, N'CANCELLED',      N'Cancelled',        CAST(1 AS bit), 5
    ) src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.ArrivalRowStatuses tgt
        WHERE tgt.ID = src.ID
    )

    SET IDENTITY_INSERT dbo.ArrivalRowStatuses OFF
END

-------------------------------------------------------------------------------
-- 3. Add missing foreign key to dbo.ArrivalRowsUnreleased
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.ArrivalRowStatuses', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalRowsUnreleased_ArrivalRowStatuses'
   )
BEGIN
    ALTER TABLE dbo.ArrivalRowsUnreleased
    ADD CONSTRAINT FK_ArrivalRowsUnreleased_ArrivalRowStatuses
        FOREIGN KEY (StatusID)
        REFERENCES dbo.ArrivalRowStatuses (ID)
END
