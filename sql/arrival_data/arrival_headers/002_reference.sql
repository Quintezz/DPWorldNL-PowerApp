/*
===============================================================================
  002_reference.sql
  Arrival Headers — first phase reference data

  Creates and seeds only the minimum lookup/reference objects needed for:
    - dbo.ArrivalHeadersUnreleased

  In scope:
    - dbo.TransportTypes
    - dbo.LoadTypes
    - dbo.Sites
    - dbo.ReceivingDepartments
    - dbo.ArrivalHeaderStatuses

  Also:
    - adds missing foreign keys on dbo.ArrivalHeadersUnreleased if that table
      already exists and the lookup tables now exist
===============================================================================
*/

SET NOCOUNT ON;

-------------------------------------------------------------------------------
-- 1. Create dbo.TransportTypes
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.TransportTypes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TransportTypes
    (
        ID int IDENTITY(1,1) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_TransportTypes_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_TransportTypes
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_TransportTypes_Name
            UNIQUE (Name)
    );
END;

-------------------------------------------------------------------------------
-- 2. Create dbo.LoadTypes
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.LoadTypes', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.LoadTypes
    (
        ID int IDENTITY(1,1) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_LoadTypes_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_LoadTypes
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_LoadTypes_Name
            UNIQUE (Name)
    );
END;

-------------------------------------------------------------------------------
-- 3. Create dbo.Sites
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Sites', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sites
    (
        ID int IDENTITY(1,1) NOT NULL,
        Code nvarchar(50) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_Sites_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_Sites
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_Sites_Code
            UNIQUE (Code),

        CONSTRAINT UQ_Sites_Name
            UNIQUE (Name)
    );
END;

-------------------------------------------------------------------------------
-- 4. Create dbo.ReceivingDepartments
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ReceivingDepartments
    (
        ID int IDENTITY(1,1) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_ReceivingDepartments_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_ReceivingDepartments
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_ReceivingDepartments_Name
            UNIQUE (Name)
    );
END;

-------------------------------------------------------------------------------
-- 5. Create dbo.ArrivalHeaderStatuses
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalHeaderStatuses
    (
        ID int IDENTITY(1,1) NOT NULL,
        Code nvarchar(50) NOT NULL,
        Name nvarchar(100) NOT NULL,
        IsActive bit NOT NULL
            CONSTRAINT DF_ArrivalHeaderStatuses_IsActive DEFAULT ((1)),
        SortOrder int NULL,

        CONSTRAINT PK_ArrivalHeaderStatuses
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_ArrivalHeaderStatuses_Code
            UNIQUE (Code),

        CONSTRAINT UQ_ArrivalHeaderStatuses_Name
            UNIQUE (Name)
    );
END;

-------------------------------------------------------------------------------
-- 6. Seed dbo.TransportTypes
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.TransportTypes
    SET Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.TransportTypes tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'Truck'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'Air',            CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'Container',      CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'Other',          CAST(1 AS bit), 4
    ) src
        ON tgt.ID = src.ID;

    SET IDENTITY_INSERT dbo.TransportTypes ON;

    INSERT INTO dbo.TransportTypes (ID, Name, IsActive, SortOrder)
    SELECT src.ID, src.Name, src.IsActive, src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'Truck'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'Air',            CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'Container',      CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'Other',          CAST(1 AS bit), 4
    ) src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.TransportTypes tgt
        WHERE tgt.ID = src.ID
    );

    SET IDENTITY_INSERT dbo.TransportTypes OFF;
END;

-------------------------------------------------------------------------------
-- 7. Seed dbo.LoadTypes
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.LoadTypes', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.LoadTypes
    SET Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.LoadTypes tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'LCL'       AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'FCL',            CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'FCL ODM',        CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'FCL LSE',        CAST(1 AS bit), 4
    ) src
        ON tgt.ID = src.ID;

    SET IDENTITY_INSERT dbo.LoadTypes ON;

    INSERT INTO dbo.LoadTypes (ID, Name, IsActive, SortOrder)
    SELECT src.ID, src.Name, src.IsActive, src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'LCL'       AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'FCL',            CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'FCL ODM',        CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'FCL LSE',        CAST(1 AS bit), 4
    ) src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.LoadTypes tgt
        WHERE tgt.ID = src.ID
    );

    SET IDENTITY_INSERT dbo.LoadTypes OFF;
END;

-------------------------------------------------------------------------------
-- 8. Seed dbo.Sites
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Sites', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.Sites
    SET Code      = src.Code,
        Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.Sites tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'TLB' AS Code, N'Tilburg' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'VNR', N'Venray', CAST(1 AS bit), 2
    ) src
        ON tgt.ID = src.ID;

    SET IDENTITY_INSERT dbo.Sites ON;

    INSERT INTO dbo.Sites (ID, Code, Name, IsActive, SortOrder)
    SELECT src.ID, src.Code, src.Name, src.IsActive, src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'TLB' AS Code, N'Tilburg' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'VNR', N'Venray', CAST(1 AS bit), 2
    ) src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Sites tgt
        WHERE tgt.ID = src.ID
    );

    SET IDENTITY_INSERT dbo.Sites OFF;
END;

-------------------------------------------------------------------------------
-- 9. Seed dbo.ReceivingDepartments
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.ReceivingDepartments
    SET Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.ReceivingDepartments tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'Receiving' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'Merge',          CAST(1 AS bit), 2
    ) src
        ON tgt.ID = src.ID;

    SET IDENTITY_INSERT dbo.ReceivingDepartments ON;

    INSERT INTO dbo.ReceivingDepartments (ID, Name, IsActive, SortOrder)
    SELECT src.ID, src.Name, src.IsActive, src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'Receiving' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'Merge',          CAST(1 AS bit), 2
    ) src
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.ReceivingDepartments tgt
        WHERE tgt.ID = src.ID
    );

    SET IDENTITY_INSERT dbo.ReceivingDepartments OFF;
END;

-------------------------------------------------------------------------------
-- 10. Seed dbo.ArrivalHeaderStatuses
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NOT NULL
BEGIN
    UPDATE dbo.ArrivalHeaderStatuses
    SET Code      = src.Code,
        Name      = src.Name,
        IsActive  = src.IsActive,
        SortOrder = src.SortOrder
    FROM dbo.ArrivalHeaderStatuses tgt
    INNER JOIN
    (
        SELECT 1 AS ID, N'DRAFT'     AS Code, N'Draft'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'PLANNED',        N'Planned',          CAST(1 AS bit), 2
        UNION ALL
        SELECT 3, N'READY',          N'Ready',            CAST(1 AS bit), 3
        UNION ALL
        SELECT 4, N'RELEASED',       N'Released',         CAST(1 AS bit), 4
        UNION ALL
        SELECT 5, N'CANCELLED',      N'Cancelled',        CAST(1 AS bit), 5
    ) src
        ON tgt.ID = src.ID;

    SET IDENTITY_INSERT dbo.ArrivalHeaderStatuses ON;

    INSERT INTO dbo.ArrivalHeaderStatuses (ID, Code, Name, IsActive, SortOrder)
    SELECT src.ID, src.Code, src.Name, src.IsActive, src.SortOrder
    FROM
    (
        SELECT 1 AS ID, N'DRAFT'     AS Code, N'Draft'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
        UNION ALL
        SELECT 2, N'PLANNED',        N'Planned',          CAST(1 AS bit), 2
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
        FROM dbo.ArrivalHeaderStatuses tgt
        WHERE tgt.ID = src.ID
    );

    SET IDENTITY_INSERT dbo.ArrivalHeaderStatuses OFF;
END;

-------------------------------------------------------------------------------
-- 11. Add missing foreign keys to dbo.ArrivalHeadersUnreleased
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalHeadersUnreleased_TransportTypes'
   )
BEGIN
    ALTER TABLE dbo.ArrivalHeadersUnreleased
    ADD CONSTRAINT FK_ArrivalHeadersUnreleased_TransportTypes
        FOREIGN KEY (TransportTypeID)
        REFERENCES dbo.TransportTypes (ID);
END;

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.LoadTypes', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalHeadersUnreleased_LoadTypes'
   )
BEGIN
    ALTER TABLE dbo.ArrivalHeadersUnreleased
    ADD CONSTRAINT FK_ArrivalHeadersUnreleased_LoadTypes
        FOREIGN KEY (LoadTypeID)
        REFERENCES dbo.LoadTypes (ID);
END;

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.Sites', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalHeadersUnreleased_Sites'
   )
BEGIN
    ALTER TABLE dbo.ArrivalHeadersUnreleased
    ADD CONSTRAINT FK_ArrivalHeadersUnreleased_Sites
        FOREIGN KEY (SiteID)
        REFERENCES dbo.Sites (ID);
END;

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalHeadersUnreleased_ReceivingDepartments'
   )
BEGIN
    ALTER TABLE dbo.ArrivalHeadersUnreleased
    ADD CONSTRAINT FK_ArrivalHeadersUnreleased_ReceivingDepartments
        FOREIGN KEY (ReceivingDepartmentID)
        REFERENCES dbo.ReceivingDepartments (ID);
END;

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NOT NULL
   AND NOT EXISTS
   (
       SELECT 1
       FROM sys.foreign_keys
       WHERE name = 'FK_ArrivalHeadersUnreleased_ArrivalHeaderStatuses'
   )
BEGIN
    ALTER TABLE dbo.ArrivalHeadersUnreleased
    ADD CONSTRAINT FK_ArrivalHeadersUnreleased_ArrivalHeaderStatuses
        FOREIGN KEY (StatusID)
        REFERENCES dbo.ArrivalHeaderStatuses (ID);
END;
