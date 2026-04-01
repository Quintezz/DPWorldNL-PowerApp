/*
===============================================================================
  000_cleanup_headers.sql
  Cleanup for dbo.ArrivalHeadersUnreleased
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NOT NULL
BEGIN
    DELETE FROM dbo.ArrivalHeadersUnreleased

    DBCC CHECKIDENT ('dbo.ArrivalHeadersUnreleased', RESEED, 0)
END

IF EXISTS
(
    SELECT 1
    FROM sys.sequences
    WHERE name = 'Seq_HeaderBusinessNumber'
      AND SCHEMA_NAME(schema_id) = 'dbo'
)
BEGIN
    ALTER SEQUENCE dbo.Seq_HeaderBusinessNumber
        RESTART WITH 1
END
