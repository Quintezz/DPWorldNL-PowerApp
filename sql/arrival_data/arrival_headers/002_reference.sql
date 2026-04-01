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

  Seeding strategy:
    - MERGE is used for every lookup table so each seed dataset is defined
      exactly once; there are no duplicated UNION ALL queries between an
      UPDATE path and an INSERT path.
    - IDENTITY_INSERT is enabled around each MERGE so explicit IDs are
      honoured for new rows.
    - Every seeding block and the FK-addition block are each wrapped in their
      own TRY-CATCH so failures are reported clearly without silently
      swallowing errors.
    - A post-seed validation section at the end prints row counts and raises
      an error if any table falls below its expected minimum.
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
-- 6. Seed dbo.TransportTypes (MERGE upserts each row; no duplicated UNION ALL)
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
BEGIN
    BEGIN TRY
        SET IDENTITY_INSERT dbo.TransportTypes ON;

        MERGE dbo.TransportTypes AS tgt
        USING
        (
            SELECT 1 AS ID, N'Truck'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
            UNION ALL SELECT 2, N'Air',       CAST(1 AS bit), 2
            UNION ALL SELECT 3, N'Container', CAST(1 AS bit), 3
            UNION ALL SELECT 4, N'Other',     CAST(1 AS bit), 4
        ) AS src (ID, Name, IsActive, SortOrder)
            ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET tgt.Name      = src.Name,
                       tgt.IsActive  = src.IsActive,
                       tgt.SortOrder = src.SortOrder
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Name, IsActive, SortOrder)
            VALUES (src.ID, src.Name, src.IsActive, src.SortOrder);

        SET IDENTITY_INSERT dbo.TransportTypes OFF;
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT dbo.TransportTypes OFF;
        THROW;
    END CATCH;
END;

-------------------------------------------------------------------------------
-- 7. Seed dbo.LoadTypes
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.LoadTypes', 'U') IS NOT NULL
BEGIN
    BEGIN TRY
        SET IDENTITY_INSERT dbo.LoadTypes ON;

        MERGE dbo.LoadTypes AS tgt
        USING
        (
            SELECT 1 AS ID, N'LCL'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
            UNION ALL SELECT 2, N'FCL',     CAST(1 AS bit), 2
            UNION ALL SELECT 3, N'FCL ODM', CAST(1 AS bit), 3
            UNION ALL SELECT 4, N'FCL LSE', CAST(1 AS bit), 4
        ) AS src (ID, Name, IsActive, SortOrder)
            ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET tgt.Name      = src.Name,
                       tgt.IsActive  = src.IsActive,
                       tgt.SortOrder = src.SortOrder
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Name, IsActive, SortOrder)
            VALUES (src.ID, src.Name, src.IsActive, src.SortOrder);

        SET IDENTITY_INSERT dbo.LoadTypes OFF;
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT dbo.LoadTypes OFF;
        THROW;
    END CATCH;
END;

-------------------------------------------------------------------------------
-- 8. Seed dbo.Sites
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.Sites', 'U') IS NOT NULL
BEGIN
    BEGIN TRY
        SET IDENTITY_INSERT dbo.Sites ON;

        MERGE dbo.Sites AS tgt
        USING
        (
            SELECT 1 AS ID, N'TLB' AS Code, N'Tilburg' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
            UNION ALL SELECT 2, N'VNR', N'Venray', CAST(1 AS bit), 2
        ) AS src (ID, Code, Name, IsActive, SortOrder)
            ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET tgt.Code      = src.Code,
                       tgt.Name      = src.Name,
                       tgt.IsActive  = src.IsActive,
                       tgt.SortOrder = src.SortOrder
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Code, Name, IsActive, SortOrder)
            VALUES (src.ID, src.Code, src.Name, src.IsActive, src.SortOrder);

        SET IDENTITY_INSERT dbo.Sites OFF;
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT dbo.Sites OFF;
        THROW;
    END CATCH;
END;

-------------------------------------------------------------------------------
-- 9. Seed dbo.ReceivingDepartments
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NOT NULL
BEGIN
    BEGIN TRY
        SET IDENTITY_INSERT dbo.ReceivingDepartments ON;

        MERGE dbo.ReceivingDepartments AS tgt
        USING
        (
            SELECT 1 AS ID, N'Receiving' AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
            UNION ALL SELECT 2, N'Merge', CAST(1 AS bit), 2
        ) AS src (ID, Name, IsActive, SortOrder)
            ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET tgt.Name      = src.Name,
                       tgt.IsActive  = src.IsActive,
                       tgt.SortOrder = src.SortOrder
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Name, IsActive, SortOrder)
            VALUES (src.ID, src.Name, src.IsActive, src.SortOrder);

        SET IDENTITY_INSERT dbo.ReceivingDepartments OFF;
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT dbo.ReceivingDepartments OFF;
        THROW;
    END CATCH;
END;

-------------------------------------------------------------------------------
-- 10. Seed dbo.ArrivalHeaderStatuses
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NOT NULL
BEGIN
    BEGIN TRY
        SET IDENTITY_INSERT dbo.ArrivalHeaderStatuses ON;

        MERGE dbo.ArrivalHeaderStatuses AS tgt
        USING
        (
            SELECT 1 AS ID, N'DRAFT'     AS Code, N'Draft'     AS Name, CAST(1 AS bit) AS IsActive, 1 AS SortOrder
            UNION ALL SELECT 2, N'PLANNED',   N'Planned',   CAST(1 AS bit), 2
            UNION ALL SELECT 3, N'READY',     N'Ready',     CAST(1 AS bit), 3
            UNION ALL SELECT 4, N'RELEASED',  N'Released',  CAST(1 AS bit), 4
            UNION ALL SELECT 5, N'CANCELLED', N'Cancelled', CAST(1 AS bit), 5
        ) AS src (ID, Code, Name, IsActive, SortOrder)
            ON tgt.ID = src.ID
        WHEN MATCHED THEN
            UPDATE SET tgt.Code      = src.Code,
                       tgt.Name      = src.Name,
                       tgt.IsActive  = src.IsActive,
                       tgt.SortOrder = src.SortOrder
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (ID, Code, Name, IsActive, SortOrder)
            VALUES (src.ID, src.Code, src.Name, src.IsActive, src.SortOrder);

        SET IDENTITY_INSERT dbo.ArrivalHeaderStatuses OFF;
    END TRY
    BEGIN CATCH
        SET IDENTITY_INSERT dbo.ArrivalHeaderStatuses OFF;
        THROW;
    END CATCH;
END;

-------------------------------------------------------------------------------
-- 11. Add missing foreign keys to dbo.ArrivalHeadersUnreleased (batched TRY-CATCH)
-------------------------------------------------------------------------------
BEGIN TRY
    IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
    BEGIN
        IF OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ArrivalHeadersUnreleased_TransportTypes')
            ALTER TABLE dbo.ArrivalHeadersUnreleased
            ADD CONSTRAINT FK_ArrivalHeadersUnreleased_TransportTypes
                FOREIGN KEY (TransportTypeID) REFERENCES dbo.TransportTypes (ID);

        IF OBJECT_ID('dbo.LoadTypes', 'U') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ArrivalHeadersUnreleased_LoadTypes')
            ALTER TABLE dbo.ArrivalHeadersUnreleased
            ADD CONSTRAINT FK_ArrivalHeadersUnreleased_LoadTypes
                FOREIGN KEY (LoadTypeID) REFERENCES dbo.LoadTypes (ID);

        IF OBJECT_ID('dbo.Sites', 'U') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ArrivalHeadersUnreleased_Sites')
            ALTER TABLE dbo.ArrivalHeadersUnreleased
            ADD CONSTRAINT FK_ArrivalHeadersUnreleased_Sites
                FOREIGN KEY (SiteID) REFERENCES dbo.Sites (ID);

        IF OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ArrivalHeadersUnreleased_ReceivingDepartments')
            ALTER TABLE dbo.ArrivalHeadersUnreleased
            ADD CONSTRAINT FK_ArrivalHeadersUnreleased_ReceivingDepartments
                FOREIGN KEY (ReceivingDepartmentID) REFERENCES dbo.ReceivingDepartments (ID);

        IF OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ArrivalHeadersUnreleased_ArrivalHeaderStatuses')
            ALTER TABLE dbo.ArrivalHeadersUnreleased
            ADD CONSTRAINT FK_ArrivalHeadersUnreleased_ArrivalHeaderStatuses
                FOREIGN KEY (StatusID) REFERENCES dbo.ArrivalHeaderStatuses (ID);
    END;
END TRY
BEGIN CATCH
    THROW;
END CATCH;

-------------------------------------------------------------------------------
-- 12. Post-seed validation
--     Prints the actual row count for each lookup table and raises an error
--     if any table falls below its expected minimum seed count.
-------------------------------------------------------------------------------
DECLARE @Errors int = 0;
DECLARE @RowCount int;

IF OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
BEGIN
    SET @RowCount = (SELECT COUNT(*) FROM dbo.TransportTypes);
    IF @RowCount < 4
    BEGIN
        PRINT 'WARNING: dbo.TransportTypes has ' + CAST(@RowCount AS varchar(10)) + ' row(s); expected >= 4.';
        SET @Errors = @Errors + 1;
    END;
    ELSE PRINT 'OK: dbo.TransportTypes — ' + CAST(@RowCount AS varchar(10)) + ' row(s).';
END;

IF OBJECT_ID('dbo.LoadTypes', 'U') IS NOT NULL
BEGIN
    SET @RowCount = (SELECT COUNT(*) FROM dbo.LoadTypes);
    IF @RowCount < 4
    BEGIN
        PRINT 'WARNING: dbo.LoadTypes has ' + CAST(@RowCount AS varchar(10)) + ' row(s); expected >= 4.';
        SET @Errors = @Errors + 1;
    END;
    ELSE PRINT 'OK: dbo.LoadTypes — ' + CAST(@RowCount AS varchar(10)) + ' row(s).';
END;

IF OBJECT_ID('dbo.Sites', 'U') IS NOT NULL
BEGIN
    SET @RowCount = (SELECT COUNT(*) FROM dbo.Sites);
    IF @RowCount < 2
    BEGIN
        PRINT 'WARNING: dbo.Sites has ' + CAST(@RowCount AS varchar(10)) + ' row(s); expected >= 2.';
        SET @Errors = @Errors + 1;
    END;
    ELSE PRINT 'OK: dbo.Sites — ' + CAST(@RowCount AS varchar(10)) + ' row(s).';
END;

IF OBJECT_ID('dbo.ReceivingDepartments', 'U') IS NOT NULL
BEGIN
    SET @RowCount = (SELECT COUNT(*) FROM dbo.ReceivingDepartments);
    IF @RowCount < 2
    BEGIN
        PRINT 'WARNING: dbo.ReceivingDepartments has ' + CAST(@RowCount AS varchar(10)) + ' row(s); expected >= 2.';
        SET @Errors = @Errors + 1;
    END;
    ELSE PRINT 'OK: dbo.ReceivingDepartments — ' + CAST(@RowCount AS varchar(10)) + ' row(s).';
END;

IF OBJECT_ID('dbo.ArrivalHeaderStatuses', 'U') IS NOT NULL
BEGIN
    SET @RowCount = (SELECT COUNT(*) FROM dbo.ArrivalHeaderStatuses);
    IF @RowCount < 5
    BEGIN
        PRINT 'WARNING: dbo.ArrivalHeaderStatuses has ' + CAST(@RowCount AS varchar(10)) + ' row(s); expected >= 5.';
        SET @Errors = @Errors + 1;
    END;
    ELSE PRINT 'OK: dbo.ArrivalHeaderStatuses — ' + CAST(@RowCount AS varchar(10)) + ' row(s).';
END;

IF @Errors > 0
    RAISERROR('Post-seed validation found %d under-seeded table(s). Review WARNING messages above.', 16, 1, @Errors);
ELSE
    PRINT 'Seed validation passed — all reference tables meet expected row counts.';
