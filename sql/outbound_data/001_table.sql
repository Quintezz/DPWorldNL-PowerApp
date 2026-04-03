/*
===============================================================================
  dbo.EBDOnHold
  Definitieve tabel voor directe import van EBD On Hold export
===============================================================================
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.EBDOnHold', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.EBDOnHold;
END
GO

CREATE TABLE dbo.EBDOnHold
(
    EBDOnHoldID          BIGINT IDENTITY(1,1) NOT NULL,
    Site                 NVARCHAR(10)         NOT NULL,
    OrderNumber          BIGINT               NOT NULL,
    SortCode             NVARCHAR(50)         NULL,
    ChannelID            NVARCHAR(50)         NOT NULL,
    Segment              NVARCHAR(100)        NULL,
    Company              NVARCHAR(255)        NULL,

    FSDate               DATE                 NULL,
    FSTime               TIME(0)              NULL,
    RecDate              DATE                 NULL,
    RecTime              TIME(0)              NULL,

    IsComplete           BIT                  NULL,

    OrderQty             INT                  NULL,
    ActualBoxQty         INT                  NULL,
    OnHoldReason         NVARCHAR(255)        NULL,
    OHH                  INT                  NULL,

    StatusText           NVARCHAR(100)        NULL,
    CountryCode          CHAR(2)              NULL,
    VolWeight            DECIMAL(18,2)        NULL,
    ActWeight            DECIMAL(18,2)        NULL,
    CarrierCode          NVARCHAR(20)         NULL,
    DaysOnHold           INT                  NULL,

    BuildDate            DATE                 NULL,
    CommentText          NVARCHAR(MAX)        NULL,
    InstructionText      NVARCHAR(MAX)        NULL,

    PreAlert5525Time     DATETIME2(0)         NULL,
    Confirmed5550Time    DATETIME2(0)         NULL,

    CreatedAt            DATETIME2(0)         NOT NULL
        CONSTRAINT DF_EBDOnHold_CreatedAt DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_EBDOnHold
        PRIMARY KEY CLUSTERED (EBDOnHoldID)
);
GO

CREATE INDEX IX_EBDOnHold_OrderNumber
    ON dbo.EBDOnHold (OrderNumber);
GO

CREATE INDEX IX_EBDOnHold_StatusText
    ON dbo.EBDOnHold (StatusText);
GO

CREATE INDEX IX_EBDOnHold_FSDate
    ON dbo.EBDOnHold (FSDate);
GO

CREATE INDEX IX_EBDOnHold_BuildDate
    ON dbo.EBDOnHold (BuildDate);
GO
