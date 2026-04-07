/*
===============================================================================
  003_seed_sample.sql
  Arrival Rows — sample data met 80% echte PartNumbers uit ProductTable
  Inserts 4 tot 10 rows per sample header
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

IF OBJECT_ID('dbo.ProductTable', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ProductTable does not exist. Run producttable/001_table.sql first.', 16, 1)
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

;WITH RealPartNumbers AS
(
    SELECT 
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS RN,
        PartNo
    FROM dbo.ProductTable
    WHERE PartNo IS NOT NULL AND RTRIM(PartNo) <> ''
),
RealPartCount AS
(
    SELECT COUNT(*) AS TotalReal FROM RealPartNumbers
),
FakePartNumbers AS
(
    SELECT 1 AS FakeNum, N'FJPCW' AS PartNo
    UNION ALL SELECT 2, N'736P9'
    UNION ALL SELECT 3, N'KMW3T'
    UNION ALL SELECT 4, N'9QX2L'
    UNION ALL SELECT 5, N'H7MNP'
    UNION ALL SELECT 6, N'T4Z8K'
    UNION ALL SELECT 7, N'PL93V'
    UNION ALL SELECT 8, N'WQ7XM'
    UNION ALL SELECT 9, N'52NRT'
    UNION ALL SELECT 10, N'BX8LD'
),
HeaderSet AS
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
),
PartNumberSelection AS
(
    SELECT
        h.ID,
        h.HeaderID,
        n.RowSequence,
        CASE 
            WHEN (ABS(CHECKSUM(NEWID() + CAST(h.ID AS nvarchar(20)) + CAST(n.RowSequence AS nvarchar(20)))) % 100) < 80
            THEN (
                SELECT TOP 1 PartNo 
                FROM RealPartNumbers rp
                WHERE rp.RN = (ABS(CHECKSUM(NEWID() + h.HeaderID + CAST(n.RowSequence AS nvarchar(20)))) % (SELECT TotalReal FROM RealPartCount)) + 1
            )
            ELSE (
                SELECT TOP 1 PartNo 
                FROM FakePartNumbers fp
                WHERE fp.FakeNum = ((ABS(CHECKSUM(NEWID())) % 10) + 1)
            )
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
        END AS Quantity
    FROM HeaderSet h
    CROSS JOIN RowNumbers n
    WHERE n.RowSequence <= h.RowsPerHeader
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
    Container,
    HasComment
)
SELECT
    h.ID AS ParentHeaderDbID,
    ps.HeaderID AS HeaderRecordID,
    ps.RowSequence,
    ps.PartNumber,
    ps.Vendor,
    ps.Quantity,
    CASE WHEN ps.RowSequence IN (1,3,5,8) THEN 1 ELSE 0 END AS DellOwned,
    CASE WHEN ps.RowSequence IN (3,7,10) THEN 1 ELSE 0 END AS Bonded,
    0 AS Released,
    1 AS StatusID,
    CONCAT(N'CONT-', h.SecurityReference, N'-', RIGHT(N'00' + CAST(ps.RowSequence AS nvarchar(2)), 2)) AS Container,
    0 AS HasComment
FROM HeaderSet h
INNER JOIN PartNumberSelection ps
    ON ps.ID = h.ID
ORDER BY
    h.ID,
    ps.RowSequence

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
    r.Container,
    r.HasComment
FROM dbo.ArrivalRowsUnreleased r
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
ORDER BY
    r.ParentHeaderDbID,
    r.RowSequence