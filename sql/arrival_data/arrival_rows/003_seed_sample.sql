/*
===============================================================================
  003_seed_sample.sql
  Arrival Rows — sample data
  Inserts 4 to 10 rows per sample header

  Rules:
  - PartNumber per header: approx. 80% from dbo.ProductTable.PartNo
  - PartNumber per header: approx. 20% fake
  - Real PartNo values are unique within the same header
  - PrimairySupplier is NOT sourced from dbo.ProductTable
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
    RAISERROR('dbo.ProductTable does not exist.', 16, 1)
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

IF OBJECT_ID('tempdb..#ProductPool') IS NOT NULL
    DROP TABLE #ProductPool

CREATE TABLE #ProductPool
(
    PartNo nvarchar(255) NOT NULL PRIMARY KEY
)

INSERT INTO #ProductPool
(
    PartNo
)
SELECT DISTINCT
    LTRIM(RTRIM(pt.PartNo))
FROM dbo.ProductTable pt
WHERE pt.PartNo IS NOT NULL
  AND LTRIM(RTRIM(pt.PartNo)) <> N''

IF NOT EXISTS (SELECT 1 FROM #ProductPool)
BEGIN
    RAISERROR('dbo.ProductTable contains no usable PartNo values.', 16, 1)
    RETURN
END

DECLARE @DistinctProductPartCount int
DECLARE @MaxRealRowsPerHeader int

SELECT
    @DistinctProductPartCount = COUNT(*)
FROM #ProductPool

SELECT
    @MaxRealRowsPerHeader = MAX(CONVERT(int, ROUND((4 + (h.ID % 7)) * 0.8, 0)))
FROM dbo.ArrivalHeadersUnreleased h
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500

IF @DistinctProductPartCount < ISNULL(@MaxRealRowsPerHeader, 0)
BEGIN
    RAISERROR(
        'dbo.ProductTable does not contain enough distinct PartNo values for per-header unique selection.',
        16,
        1
    )
    RETURN
END

;WITH HeaderSet AS
(
    SELECT
        h.ID,
        h.HeaderID,
        h.SecurityReference,
        4 + (h.ID % 7) AS RowsPerHeader,
        CONVERT(int, ROUND((4 + (h.ID % 7)) * 0.8, 0)) AS RealRowsPerHeader,
        (4 + (h.ID % 7)) - CONVERT(int, ROUND((4 + (h.ID % 7)) * 0.8, 0)) AS FakeRowsPerHeader
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
Tally AS
(
    SELECT TOP (500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
),
RealParts AS
(
    SELECT
        h.ID AS ParentHeaderDbID,
        rp.RealSequence AS RowSequence,
        rp.PartNo
    FROM HeaderSet h
    CROSS APPLY
    (
        SELECT
            x.PartNo,
            ROW_NUMBER() OVER (ORDER BY x.PartNo) AS RealSequence
        FROM
        (
            SELECT TOP (h.RealRowsPerHeader)
                p.PartNo
            FROM #ProductPool p
            ORDER BY NEWID()
        ) x
    ) rp
),
FakeParts AS
(
    SELECT
        h.ID AS ParentHeaderDbID,
        h.RealRowsPerHeader + fp.FakeSequence AS RowSequence,
        fp.PartNo
    FROM HeaderSet h
    CROSS APPLY
    (
        SELECT
            x.PartNo,
            ROW_NUMBER() OVER (ORDER BY x.CandidateNo) AS FakeSequence
        FROM
        (
            SELECT TOP (h.FakeRowsPerHeader)
                c.CandidateNo,
                c.PartNo
            FROM
            (
                SELECT DISTINCT
                    t.N AS CandidateNo,
                    UPPER(LEFT(CONVERT(varchar(40), HASHBYTES('SHA1', CONCAT(N'FAKE|', h.SecurityReference, N'|', t.N)), 2), 5)) AS PartNo
                FROM Tally t
            ) c
            WHERE NOT EXISTS
            (
                SELECT 1
                FROM #ProductPool p
                WHERE p.PartNo = c.PartNo
            )
            ORDER BY c.CandidateNo
        ) x
    ) fp
),
AssignedParts AS
(
    SELECT
        rp.ParentHeaderDbID,
        rp.RowSequence,
        rp.PartNo
    FROM RealParts rp

    UNION ALL

    SELECT
        fp.ParentHeaderDbID,
        fp.RowSequence,
        fp.PartNo
    FROM FakeParts fp
)
INSERT INTO dbo.ArrivalRowsUnreleased
(
    ParentHeaderDbID,
    HeaderRecordID,
    RowSequence,
    PartNumber,
    PrimairySupplier,
    Quantity,
    DellOwned,
    Bonded,
    Released,
    StatusID,
    Container,
    HasComment,
    Incoming,
    ASN,
    MRN
)
SELECT
    h.ID AS ParentHeaderDbID,
    h.HeaderID AS HeaderRecordID,
    n.RowSequence,
    ap.PartNo AS PartNumber,
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
    END AS PrimairySupplier,
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
    CASE n.RowSequence
        WHEN 1 THEN 4
        WHEN 2 THEN 5
        WHEN 3 THEN 6
        ELSE 2
    END AS StatusID,
    CONCAT(N'CONT-', h.SecurityReference, N'-', RIGHT(N'00' + CAST(n.RowSequence AS nvarchar(2)), 2)) AS Container,
    0 AS HasComment,
    0 AS Incoming,
    NULL AS ASN,
    NULL AS MRN
FROM HeaderSet h
INNER JOIN RowNumbers n
    ON n.RowSequence <= h.RowsPerHeader
INNER JOIN AssignedParts ap
    ON ap.ParentHeaderDbID = h.ID
   AND ap.RowSequence = n.RowSequence
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
    r.PrimairySupplier,
    r.Quantity,
    r.DellOwned,
    r.Bonded,
    r.Released,
    r.StatusID,
    r.Container,
    r.HasComment,
    r.Incoming,
    r.ASN,
    r.MRN
FROM dbo.ArrivalRowsUnreleased r
INNER JOIN dbo.ArrivalHeadersUnreleased h
    ON h.ID = r.ParentHeaderDbID
WHERE TRY_CONVERT(int, h.SecurityReference) BETWEEN 950001 AND 950500
ORDER BY
    r.ParentHeaderDbID,
    r.RowSequence

DROP TABLE #ProductPool
