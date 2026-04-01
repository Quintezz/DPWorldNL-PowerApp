/*
===============================================================================
  004_seed_sample.sql
  Comments — sample data for dbo.ArrivalRowComments
  Seeds a small deterministic set of comments against the first 5 sample rows
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalRowComments', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalRowComments does not exist. Run 002_table.sql first.', 16, 1)
    RETURN
END

IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalRowsUnreleased does not exist.', 16, 1)
    RETURN
END

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalHeadersUnreleased does not exist.', 16, 1)
    RETURN
END

IF NOT EXISTS
(
    SELECT 1
    FROM dbo.ArrivalRowsUnreleased r
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('No sample rows found. Seed rows first.', 16, 1)
    RETURN
END

IF EXISTS
(
    SELECT 1
    FROM dbo.ArrivalRowComments c
    INNER JOIN dbo.ArrivalRowsUnreleased r
        ON r.RowID = c.ParentRowID
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) = 950001
      AND r.RowSequence <= 5
)
BEGIN
    RAISERROR('Sample row comments already exist for header 950001 rows 1-5. Cleanup first.', 16, 1)
    RETURN
END

;WITH SampleRows AS
(
    SELECT TOP (5)
        r.RowID
    FROM dbo.ArrivalRowsUnreleased r
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) = 950001
    ORDER BY r.RowSequence
),
SampleComments AS
(
    SELECT 1 AS Seq, N'Quantity check'  AS CommentTitle, N'Quantity does not match packing list. Recount needed.' AS CommentText, N'planner.a@dpworld.nl' AS CreatedBy
    UNION ALL
    SELECT 2,        N'Part on hold',                    N'Part flagged for quality hold by receiving team.',              N'planner.b@dpworld.nl'
    UNION ALL
    SELECT 3,        NULL,                               N'Vendor confirmed shipment details are correct.',                N'planner.a@dpworld.nl'
)
INSERT INTO dbo.ArrivalRowComments
(
    ParentRowID,
    CommentTitle,
    CommentText,
    CreatedBy
)
SELECT
    r.RowID,
    c.CommentTitle,
    c.CommentText,
    c.CreatedBy
FROM SampleRows r
CROSS JOIN SampleComments c

SELECT COUNT(*) AS SeededRowComments
FROM dbo.ArrivalRowComments c
INNER JOIN dbo.ArrivalRowsUnreleased r
    ON r.RowID = c.ParentRowID
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) = 950001
  AND r.RowSequence <= 5
