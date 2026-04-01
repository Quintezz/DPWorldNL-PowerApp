/*
===============================================================================
  003_seed_sample.sql
  Arrival Rows — sample data
  Inserts 4 to 10 rows per sample header
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalRowsUnreleased does not exist. Run arrival_rows/001_table.sql first.', 16, 1)
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
    FROM dbo.ArrivalRowsUnreleased r
    INNER JOIN dbo.ArrivalHeadersUnreleased h
        ON h.ID = r.ParentHeaderDbID
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('Sample rows already exist for header range 950001-950500. Cleanup rows first.', 16, 1)
    RETURN
END

;WITH HeaderSet AS
(
    SELECT
        h.ID,
        h.HeaderID,
        h.SecurityReference,
        4 + (h.ID % 7) AS RowsPerHeader
    FROM dbo.ArrivalHeadersUnreleased h
    WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
),
RowNumbers AS
(
    SELECT 1 AS RowSequence
    UNION ALL SELECT 2
    UNION ALL SELECT 3
    UNION ALL SELECT 4
    UNION ALL SELECT 5
    UNION ALL SELECT 6
    UNION ALL SELECT 7
    UNION ALL SELECT 8
    UNION ALL SELECT 9
    UNION ALL SELECT 10
)
INSERT INTO dbo.ArrivalRowsUnreleased
(
    ParentHeaderDbID,
    HeaderRecordID,
    RowSequence,
    PartNumber,
    Vendor,
    Quantity,
    DellOwned,
    Bonded,
    Released,
    StatusID,
    Container
)
SELECT
    h.ID AS ParentHeaderDbID,
    h.HeaderID AS HeaderRecordID,
    n.RowSequence,
    CASE n.RowSequence
        WHEN 1 THEN N'FJPCW'
        WHEN 2 THEN N'736P9'
        WHEN 3 THEN N'KMW3T'
        WHEN 4 THEN N'9QX2L'
        WHEN 5 THEN N'H7MNP'
        WHEN 6 THEN N'T4Z8K'
        WHEN 7 THEN N'PL93V'
        WHEN 8 THEN N'WQ7XM'
        WHEN 9 THEN N'52NRT'
        WHEN 10 THEN N'BX8LD'
    END AS PartNumber,
    CASE n.RowSequence
        WHEN 1 THEN N'Vendor A'
        WHEN 2 THEN N'Vendor B'
        WHEN 3 THEN N'Vendor C'
        WHEN 4 THEN N'Vendor D'
        WHEN 5 THEN N'Vendor E'
        WHEN 6 THEN N'Vendor F'
        WHEN 7 THEN N'Vendor G'
        WHEN 8 THEN N'Vendor H'
        WHEN 9 THEN N'Vendor I'
        WHEN 10 THEN N'Vendor J'
    END AS Vendor,
    CASE n.RowSequence
        WHEN 1 THEN 10
        WHEN 2 THEN 25
        WHEN 3 THEN 40
        WHEN 4 THEN 15
        WHEN 5 THEN 60
        WHEN 6 THEN 30
        WHEN 7 THEN 12
        WHEN 8 THEN 80
        WHEN 9 THEN 22
        WHEN 10 THEN 50
    END AS Quantity,
    CASE WHEN n.RowSequence IN (1,3,5,8) THEN 1 ELSE 0 END AS DellOwned,
    CASE WHEN n.RowSequence IN (3,7,10) THEN 1 ELSE 0 END AS Bonded,
    0 AS Released,
    1 AS StatusID,
    CONCAT(N'CONT-', h.SecurityReference, N'-', RIGHT(N'00' + CAST(n.RowSequence AS nvarchar(2)), 2)) AS Container
FROM HeaderSet h
INNER JOIN RowNumbers n
    ON n.RowSequence <= h.RowsPerHeader
ORDER BY
    h.ID,
    n.RowSequence

SELECT
    COUNT(*) AS InsertedRows
FROM dbo.ArrivalRowsUnreleased r
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

SELECT TOP (25)
    r.ID,
    r.ParentHeaderDbID,
    r.HeaderRecordID,
    r.RowSequence,
    r.RowID,
    r.PartNumber,
    r.Vendor,
    r.Quantity,
    r.DellOwned,
    r.Bonded,
    r.Released,
    r.StatusID,
    r.Container
FROM dbo.ArrivalRowsUnreleased r
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
ORDER BY
    r.ParentHeaderDbID,
    r.RowSequence
