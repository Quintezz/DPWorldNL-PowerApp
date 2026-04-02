IF OBJECT_ID('dbo.ProductTable', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ProductTable
    (
        ProductTableID BIGINT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_ProductTabe PRIMARY KEY,
        ItemInternalId       NVARCHAR(100)  NULL,
        PartNo               NVARCHAR(255)  NULL,
        Vendor               NVARCHAR(100)  NULL,
        Description          NVARCHAR(1000) NULL,
        VendorPartNo         NVARCHAR(255)  NULL,
        ImportedAt           DATETIME2(0)   NOT NULL
            CONSTRAINT DF_ProductTableImport_ImportedAt DEFAULT SYSUTCDATETIME()
    );
END;
