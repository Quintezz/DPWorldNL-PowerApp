/*
===============================================================================
  001_table.sql
  Arrival Headers — first phase
===============================================================================
*/

SET NOCOUNT ON

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
        NO CACHE
END

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
    )
END
