/*
===============================================================================
  000_cleanup_comments.sql
  Comments — cleanup

  Scope:
    - comment tables only
    - does not touch dbo.ArrivalHeadersUnreleased
    - does not touch dbo.ArrivalRowsUnreleased
===============================================================================
*/

SET NOCOUNT ON

-- Row comments must be deleted before header comments (no FK dependency between
-- the two comment tables, but this order is safest and mirrors table creation order)
IF OBJECT_ID('dbo.ArrivalRowComments', 'U') IS NOT NULL
BEGIN
    DELETE FROM dbo.ArrivalRowComments

    DBCC CHECKIDENT ('dbo.ArrivalRowComments', RESEED, 0)
END

IF OBJECT_ID('dbo.ArrivalHeaderComments', 'U') IS NOT NULL
BEGIN
    DELETE FROM dbo.ArrivalHeaderComments

    DBCC CHECKIDENT ('dbo.ArrivalHeaderComments', RESEED, 0)
END
