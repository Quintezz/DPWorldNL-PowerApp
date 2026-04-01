/*
===============================================================================
  000_cleanup_rows.sql
  Arrival Rows — cleanup

  Scope:
    - rows only
    - does not touch headers
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NOT NULL
BEGIN
    DELETE FROM dbo.ArrivalRowsUnreleased

    DBCC CHECKIDENT ('dbo.ArrivalRowsUnreleased', RESEED, 0)
END
