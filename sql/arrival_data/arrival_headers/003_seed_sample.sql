/*
===============================================================================
  003_seed_sample.sql
  Arrival Headers — sample data
  Inserts 500 deterministic sample headers
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalHeadersUnreleased does not exist. Run 001_table.sql first.', 16, 1)
    RETURN
END

IF EXISTS
(
    SELECT 1
    FROM dbo.ArrivalHeadersUnreleased
    WHERE TRY_CONVERT(int, SecurityReference) BETWEEN 950001 AND 950500
)
BEGIN
    RAISERROR('Sample range 950001-950500 already exists. Cleanup first.', 16, 1)
    RETURN
END

;WITH Numbers AS
(
    SELECT TOP (500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.ArrivalHeadersUnreleased
(
    SecurityReference,
    TransportTypeID,
    Carrier,
    LoadTypeID,
    Vessel,
    ETA,
    SiteID,
    ReceivingDepartmentID,
    PlannedDateTime,
    StatusID,
    Released,
    HasComment
)
SELECT
    CAST(950000 + N AS nvarchar(50)) AS SecurityReference,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN 1
        WHEN 2 THEN 1
        WHEN 3 THEN 3
        WHEN 4 THEN 3
        WHEN 5 THEN 2
        WHEN 6 THEN 1
        WHEN 7 THEN 4
        WHEN 8 THEN 3
        WHEN 9 THEN 1
        WHEN 10 THEN 2
    END AS TransportTypeID,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN N'DHL Supply Chain'
        WHEN 2 THEN N'Kuehne+Nagel'
        WHEN 3 THEN N'Maersk'
        WHEN 4 THEN N'MSC'
        WHEN 5 THEN N'DB Schenker'
        WHEN 6 THEN N'DSV'
        WHEN 7 THEN N'Expeditors'
        WHEN 8 THEN N'CMA CGM'
        WHEN 9 THEN N'GXO Logistics'
        WHEN 10 THEN N'UPS Supply Chain'
    END AS Carrier,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN 2
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 3
        WHEN 5 THEN 1
        WHEN 6 THEN 4
        WHEN 7 THEN 1
        WHEN 8 THEN 2
        WHEN 9 THEN 2
        WHEN 10 THEN 1
    END AS LoadTypeID,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN N'TRUCK-VSL-'   + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 2 THEN N'TRUCK-VSL-'   + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 3 THEN N'MAERSK-VSL-'  + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 4 THEN N'MSC-VSL-'     + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 5 THEN N'AIR-VSL-'     + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 6 THEN N'TRUCK-VSL-'   + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 7 THEN N'OTHER-VSL-'   + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 8 THEN N'CMA-CGM-VSL-' + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 9 THEN N'TRUCK-VSL-'   + RIGHT('000' + CAST(N AS varchar(3)), 3)
        WHEN 10 THEN N'AIR-VSL-'    + RIGHT('000' + CAST(N AS varchar(3)), 3)
    END AS Vessel,

    DATEADD
    (
        hour,
        CASE ((N - 1) % 10) + 1
            WHEN 1 THEN 8
            WHEN 2 THEN 10
            WHEN 3 THEN 6
            WHEN 4 THEN 7
            WHEN 5 THEN 5
            WHEN 6 THEN 9
            WHEN 7 THEN 12
            WHEN 8 THEN 23
            WHEN 9 THEN 16
            WHEN 10 THEN 4
        END,
        DATEADD(day, (N - 1) / 10, CAST('2026-04-01T00:00:00' AS datetime2(0)))
    ) AS ETA,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN 1
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 1
        WHEN 5 THEN 1
        WHEN 6 THEN 2
        WHEN 7 THEN 1
        WHEN 8 THEN 2
        WHEN 9 THEN 1
        WHEN 10 THEN 1
    END AS SiteID,

    CASE ((N - 1) % 10) + 1
        WHEN 1 THEN 1
        WHEN 2 THEN 1
        WHEN 3 THEN 2
        WHEN 4 THEN 2
        WHEN 5 THEN 1
        WHEN 6 THEN 1
        WHEN 7 THEN 2
        WHEN 8 THEN 2
        WHEN 9 THEN 1
        WHEN 10 THEN 1
    END AS ReceivingDepartmentID,

    DATEADD
    (
        hour,
        CASE ((N - 1) % 10) + 1
            WHEN 1 THEN 9
            WHEN 2 THEN 11
            WHEN 3 THEN 14
            WHEN 4 THEN 15
            WHEN 5 THEN 7
            WHEN 6 THEN 10
            WHEN 7 THEN 13
            WHEN 8 THEN 32
            WHEN 9 THEN 17
            WHEN 10 THEN 6
        END,
        DATEADD(day, (N - 1) / 10, CAST('2026-04-01T00:00:00' AS datetime2(0)))
    ) AS PlannedDateTime,

    1 AS StatusID,
    0 AS Released,
    0 AS HasComment
FROM Numbers

SELECT COUNT(*) AS SeededHeaders
FROM dbo.ArrivalHeadersUnreleased
WHERE TRY_CONVERT(int, SecurityReference) BETWEEN 950001 AND 950500
