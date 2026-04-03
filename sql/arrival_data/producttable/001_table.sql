/*
===============================================================================
  dbo.ProductTable
  Volledige importtabel voor ProductTable Excel dump
===============================================================================
*/

SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.ProductTable', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.ProductTable;
END
GO

CREATE TABLE dbo.ProductTable
(
    ProductTableID      BIGINT IDENTITY(1,1) NOT NULL,
    ItemInternalId          NVARCHAR(100)        NULL,
    PartNo                  NVARCHAR(100)        NULL,
    Description             NVARCHAR(500)        NULL,
    PutFamily               NVARCHAR(100)        NULL,
    Vendor                  NVARCHAR(50)         NULL,
    VendorPartNo            NVARCHAR(100)        NULL,

    UnitPrice               DECIMAL(18,2)        NULL,
    [Length]                DECIMAL(18,3)        NULL,
    [Width]                 DECIMAL(18,3)        NULL,
    [Height]                DECIMAL(18,3)        NULL,
    WeightNet               DECIMAL(18,3)        NULL,
    WeightGross             DECIMAL(18,3)        NULL,
    WeightVerification      NVARCHAR(20)         NULL,
    VolumeWeight            DECIMAL(18,3)        NULL,

    UnitsPerPallet          INT                  NULL,
    SerialsInAsn            INT                  NULL,
    UniqueSerials           INT                  NULL,

    Department              NVARCHAR(50)         NULL,
    CommodityCode           NVARCHAR(50)         NULL,
    Commodity               NVARCHAR(100)        NULL,
    PackoutScan             NVARCHAR(50)         NULL,
    PackType                NVARCHAR(50)         NULL,
    OverpackQty             INT                  NULL,

    LTOCompliant            NVARCHAR(10)         NULL,
    OptionsMultipack        NVARCHAR(10)         NULL,
    OptionsOverpack         NVARCHAR(10)         NULL,

    PalletAccess            NVARCHAR(50)         NULL,
    PalletSize              NVARCHAR(50)         NULL,
    PalletQty               INT                  NULL,

    FAI                     NVARCHAR(20)         NULL,
    FAIDet                  NVARCHAR(50)         NULL,
    TariffCode              NVARCHAR(50)         NULL,
    EANAssigned             NVARCHAR(10)         NULL,
    RecycleLabelAssigned    NVARCHAR(10)         NULL,
    RecycleLabel            NVARCHAR(100)        NULL,

    MCLength                DECIMAL(18,3)        NULL,
    MCWidth                 DECIMAL(18,3)        NULL,
    MCHeight                DECIMAL(18,3)        NULL,
    MCWeight                DECIMAL(18,3)        NULL,
    MCVolumeWeight          DECIMAL(18,3)        NULL,

    OTMBoxType              NVARCHAR(50)         NULL,
    MasterCartonQty         INT                  NULL,
    RescanQty               INT                  NULL,
    FPS                     NVARCHAR(10)         NULL,
    MCP                     NVARCHAR(10)         NULL,
    UnitsInWarehouse        INT                  NULL,
    OptionsPart             NVARCHAR(50)         NULL,

    CreatedAt               DATETIME2(0)         NOT NULL
        CONSTRAINT DF_ProductTable_CreatedAt DEFAULT (SYSDATETIME()),

    CONSTRAINT PK_ProductTable
        PRIMARY KEY CLUSTERED (ProductTableID)
);
GO

CREATE INDEX IX_ProductTable_PartNo
    ON dbo.ProductTable (PartNo);
GO

CREATE INDEX IX_ProductTable_Vendor
    ON dbo.ProductTable (Vendor);
GO

CREATE INDEX IX_ProductTable_ItemInternalId
    ON dbo.ProductTable (ItemInternalId);
GO
