CREATE OR ALTER PROCEDURE dbo.usp_ProductTableImport_Reset
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.ProductTable;
END;
GO
