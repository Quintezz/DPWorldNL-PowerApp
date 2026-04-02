CREATE OR ALTER PROCEDURE dbo.usp_ProductTableImport_LoadJson
    @RowsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RowsJson IS NULL OR ISJSON(@RowsJson) <> 1
    BEGIN
        THROW 50001, 'Parameter @RowsJson bevat geen geldige JSON.', 1;
    END;

    INSERT INTO dbo.ProductTableImport
    (
        ItemInternalId,
        PartNo,
        Vendor,
        Description,
        VendorPartNo
    )
    SELECT
        j.ItemInternalId,
        j.PartNo,
        j.Vendor,
        j.Description,
        j.VendorPartNo
    FROM OPENJSON(@RowsJson)
    WITH
    (
        ItemInternalId NVARCHAR(100)  '$.ItemInternalId',
        PartNo         NVARCHAR(255)  '$.PartNo',
        Vendor         NVARCHAR(100)  '$.Vendor',
        Description    NVARCHAR(1000) '$.Description',
        VendorPartNo   NVARCHAR(255)  '$.VendorPartNo'
    ) AS j;
END;
