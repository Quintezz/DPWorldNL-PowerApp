/*
===============================================================================
  003_seed_sample.sql
  Comments — sample data for dbo.ArrivalHeaderComments

  Logic:
    - 70% of headers in range 950001-950500 get at least 1 comment
    - of those selected headers, 40% get a second comment
    - deterministic selection based on header ID order
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalHeaderComments', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalHeaderComments does not exist. Run 001_table.sql first.', 16, 1)
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
    FROM dbo.ArrivalHeadersUnreleased
    WHERE TRY_CONVERT(int, SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('No sample headers found in range 950001-950500. Seed headers first.', 16, 1)
    RETURN
END

IF EXISTS
(
    SELECT 1
    FROM dbo.ArrivalHeaderComments c
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.HeaderID = c.ParentHeaderID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('Sample header comments already exist for range 950001-950500. Cleanup first.', 16, 1)
    RETURN
END

;WITH HeaderPool AS
(
    SELECT
        h.ID,
        h.HeaderID,
        ROW_NUMBER() OVER (ORDER BY h.ID) AS RN
    FROM dbo.ArrivalHeadersUnreleased h
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
),
Counts AS
(
    SELECT
        COUNT(*) AS TotalHeaders,
        CAST(FLOOR(COUNT(*) * 0.70) AS int) AS HeadersWithAtLeastOneComment
    FROM HeaderPool
),
SelectedHeaders AS
(
    SELECT
        hp.ID,
        hp.HeaderID,
        hp.RN,
        c.HeadersWithAtLeastOneComment,
        CAST(FLOOR(c.HeadersWithAtLeastOneComment * 0.40) AS int) AS HeadersWithTwoComments
    FROM HeaderPool hp
    CROSS JOIN Counts c
    WHERE hp.RN <= c.HeadersWithAtLeastOneComment
),
CommentPlan AS
(
    SELECT
        sh.HeaderID,
        CASE
            WHEN sh.RN <= sh.HeadersWithTwoComments THEN 2
            ELSE 1
        END AS CommentCount
    FROM SelectedHeaders sh
),
CommentTemplates AS
(
    SELECT
        1 AS Seq,
        N'ETA change' AS CommentTitle,
        N'ETA moved forward by 2 hours due to traffic.' AS CommentText,
        N'planner.a@dpworld.nl' AS CreatedBy
    UNION ALL
    SELECT
        2,
        N'Carrier note',
        N'Carrier confirmed updated delivery timing.',
        N'planner.b@dpworld.nl'
)
INSERT INTO dbo.ArrivalHeaderComments
(
    ParentHeaderID,
    CommentTitle,
    CommentText,
    CreatedBy
)
SELECT
    cp.HeaderID,
    ct.CommentTitle,
    ct.CommentText,
    ct.CreatedBy
FROM CommentPlan cp
INNER JOIN CommentTemplates ct
    ON ct.Seq <= cp.CommentCount

SELECT
    COUNT(*) AS SeededHeaderComments
FROM dbo.ArrivalHeaderComments c
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.HeaderID = c.ParentHeaderID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

SELECT
    COUNT(DISTINCT c.ParentHeaderID) AS HeadersWithComments
FROM dbo.ArrivalHeaderComments c
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.HeaderID = c.ParentHeaderID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

SELECT
    COUNT(*) AS HeadersWithTwoComments
FROM
(
    SELECT
        c.ParentHeaderID
    FROM dbo.ArrivalHeaderComments c
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.HeaderID = c.ParentHeaderID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
    GROUP BY c.ParentHeaderID
    HAVING COUNT(*) = 2
) x
