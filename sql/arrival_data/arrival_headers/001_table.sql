/*
===============================================================================
  001_table.sql
  Arrival Headers — first phase
  Creates:
    - dbo.Seq_HeaderBusinessNumber
    - dbo.ArrivalHeadersUnreleased

  Scope:
    - headers only
    - no rows
    - no comments
    - no mails
    - no attachments
    - no SharePoint publication tables
===============================================================================
*/

SET NOCOUNT ON;

-------------------------------------------------------------------------------
-- 1. Create sequence for HeaderBusinessNumber
-------------------------------------------------------------------------------
IF NOT EXISTS (
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_HeaderBusinessNumber'
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
BEGIN
    CREATE SEQUENCE dbo.Seq_HeaderBusinessNumber
        AS bigint
        START WITH 1
        INCREMENT BY 1
        MINVALUE 1
        NO MAXVALUE
        NO CYCLE
        NO CACHE;
END;

-------------------------------------------------------------------------------
-- 2. Create table dbo.ArrivalHeadersUnreleased
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalHeadersUnreleased
    (
        ID int IDENTITY(1,1) NOT NULL,
        HeaderBusinessNumber bigint NOT NULL
            CONSTRAINT DF_ArrivalHeadersUnreleased_HeaderBusinessNumber
                DEFAULT (NEXT VALUE FOR dbo.Seq_HeaderBusinessNumber),

        HeaderID AS
            CAST(
                CASE
                    WHEN LEN(CAST(HeaderBusinessNumber AS varchar(20))) < 10
                        THEN RIGHT('0000000000' + CAST(HeaderBusinessNumber AS varchar(20)), 10)
                    ELSE CAST(HeaderBusinessNumber AS varchar(20))
                END
            AS nvarchar(20)) PERSISTED,

        SecurityReference nvarchar(50) NULL,
        TransportTypeID int NULL,
        Carrier nvarchar(100) NULL,
        LoadTypeID int NULL,
        Vessel nvarchar(100) NULL,
        ETA datetime2(0) NULL,
        SiteID int NULL,
        Released bit NOT NULL
            CONSTRAINT DF_ArrivalHeadersUnreleased_Released DEFAULT ((0)),
        ReceivingDepartmentID int NULL,
        CreatedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalHeadersUnreleased_CreatedAt DEFAULT (sysdatetime()),
        ModifiedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalHeadersUnreleased_ModifiedAt DEFAULT (sysdatetime()),
        PlannedDateTime datetime2(0) NULL,
        StatusID int NULL,
        HasComment bit NOT NULL
            CONSTRAINT DF_ArrivalHeadersUnreleased_HasComment DEFAULT ((0)),

        CONSTRAINT PK_ArrivalHeadersUnreleased
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_ArrivalHeadersUnreleased_HeaderBusinessNumber
            UNIQUE (HeaderBusinessNumber),

        CONSTRAINT UQ_ArrivalHeadersUnreleased_HeaderID
            UNIQUE (HeaderID)
    );
END;

-------------------------------------------------------------------------------
-- 3. Add foreign keys only if lookup tables already exist
--    This keeps the script usable in early phases.
-------------------------------------------------------------------------------

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
   AND OBJECT_ID('dbo.TransportTypes', 'U') IS NOT NULL
   AND NOT EXISTS (
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
   AND NOT EXISTS (
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
   AND NOT EXISTS (
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
   AND NOT EXISTS (
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
   AND NOT EXISTS (
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
