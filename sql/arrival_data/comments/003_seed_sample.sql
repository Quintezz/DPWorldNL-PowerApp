/*
===============================================================================
  003_seed_sample.sql
  Comments — sample data for dbo.ArrivalHeaderComments
  Seeds a small deterministic set of comments against the first 5 sample headers
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
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950005
)
BEGIN
    RAISERROR('Sample header comments already exist for range 950001-950005. Cleanup first.', 16, 1)
    RETURN
END

;WITH SampleHeaders AS
(
    SELECT TOP (5)
        h.HeaderID
    FROM dbo.ArrivalHeadersUnreleased h
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
    ORDER BY h.ID
),
SampleComments AS
(
    SELECT 1 AS Seq, N'ETA change'           AS CommentTitle, N'ETA moved forward by 2 hours due to traffic.'    AS CommentText, N'planner.a@dpworld.nl' AS CreatedBy
    UNION ALL
    SELECT 2,        N'Carrier note',                         N'Carrier confirmed late departure from origin.',              N'planner.b@dpworld.nl'
    UNION ALL
    SELECT 3,        NULL,                                    N'Awaiting customs clearance confirmation.',                   N'planner.a@dpworld.nl'
)
INSERT INTO dbo.ArrivalHeaderComments
(
    ParentHeaderID,
    CommentTitle,
    CommentText,
    CreatedBy
)
SELECT
    h.HeaderID,
    c.CommentTitle,
    c.CommentText,
    c.CreatedBy
FROM SampleHeaders h
CROSS JOIN SampleComments c

SELECT COUNT(*) AS SeededHeaderComments
FROM dbo.ArrivalHeaderComments c
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.HeaderID = c.ParentHeaderID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950005
