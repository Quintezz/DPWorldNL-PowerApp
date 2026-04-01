/*
===============================================================================
  004_seed_sample.sql
  Comments — sample data for dbo.ArrivalRowComments

  Logic:
    - 70% of sample rows get at least 1 comment
    - of those selected rows, 40% get a second comment
    - deterministic selection based on row ID order
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
    RAISERROR('No sample rows found in header range 950001-950500. Seed rows first.', 16, 1)
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
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('Sample row comments already exist for header range 950001-950500. Cleanup first.', 16, 1)
    RETURN
END

;WITH RowPool AS
(
    SELECT
        r.ID,
        r.RowID,
        ROW_NUMBER() OVER (ORDER BY r.ID) AS RN
    FROM dbo.ArrivalRowsUnreleased r
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
),
Counts AS
(
    SELECT
        COUNT(*) AS TotalRows,
        CAST(FLOOR(COUNT(*) * 0.70) AS int) AS RowsWithAtLeastOneComment
    FROM RowPool
),
SelectedRows AS
(
    SELECT
        rp.ID,
        rp.RowID,
        rp.RN,
        c.RowsWithAtLeastOneComment,
        CAST(FLOOR(c.RowsWithAtLeastOneComment * 0.40) AS int) AS RowsWithTwoComments
    FROM RowPool rp
    CROSS JOIN Counts c
    WHERE rp.RN <= c.RowsWithAtLeastOneComment
),
CommentPlan AS
(
    SELECT
        sr.RowID,
        CASE
            WHEN sr.RN <= sr.RowsWithTwoComments THEN 2
            ELSE 1
        END AS CommentCount
    FROM SelectedRows sr
),
CommentTemplates AS
(
    SELECT
        1 AS Seq,
        N'Quantity check' AS CommentTitle,
        N'Quantity does not match packing list. Recount needed.' AS CommentText,
        N'planner.a@dpworld.nl' AS CreatedBy
    UNION ALL
    SELECT
        2,
        N'Part on hold',
        N'Part flagged for quality hold by receiving team.',
        N'planner.b@dpworld.nl'
)
INSERT INTO dbo.ArrivalRowComments
(
    ParentRowID,
    CommentTitle,
    CommentText,
    CreatedBy
)
SELECT
    cp.RowID,
    ct.CommentTitle,
    ct.CommentText,
    ct.CreatedBy
FROM CommentPlan cp
INNER JOIN CommentTemplates ct
    ON ct.Seq <= cp.CommentCount

SELECT
    COUNT(*) AS SeededRowComments
FROM dbo.ArrivalRowComments c
INNER JOIN dbo.ArrivalRowsUnreleased r
    ON r.RowID = c.ParentRowID
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

SELECT
    COUNT(DISTINCT c.ParentRowID) AS RowsWithComments
FROM dbo.ArrivalRowComments c
INNER JOIN dbo.ArrivalRowsUnreleased r
    ON r.RowID = c.ParentRowID
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

SELECT
    COUNT(*) AS RowsWithTwoComments
FROM
(
    SELECT
        c.ParentRowID
    FROM dbo.ArrivalRowComments c
    INNER JOIN dbo.ArrivalRowsUnreleased r
        ON r.RowID = c.ParentRowID
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
    GROUP BY c.ParentRowID
    HAVING COUNT(*) = 2
) x
