/*
===============================================================================
  003_seed_sample.sql
  Arrival Headers — sample data
  Inserts 10 realistic sample headers

  Assumptions:
    - dbo.ArrivalHeadersUnreleased already exists
    - required lookup/reference data already exists
===============================================================================
*/

SET NOCOUNT ON

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
VALUES
    (N'950001', 1, N'DHL Supply Chain', 2, N'TRUCK-VSL-001', '2026-04-02T08:00:00', 1, 1, '2026-04-02T09:00:00', 1, 0, 0),
    (N'950002', 1, N'Kuehne+Nagel',    1, N'TRUCK-VSL-002', '2026-04-02T10:30:00', 1, 1, '2026-04-02T11:00:00', 1, 0, 1),
    (N'950003', 3, N'Maersk',          2, N'MAERSK HAMBURG', '2026-04-03T06:00:00', 2, 2, '2026-04-03T14:00:00', 1, 0, 0),
    (N'950004', 3, N'MSC',             3, N'MSC ELOANE', '2026-04-04T07:30:00', 1, 2, '2026-04-04T15:00:00', 1, 0, 1),
    (N'950005', 2, N'DB Schenker',     1, N'AIR-VSL-001', '2026-04-02T05:45:00', 1, 1, '2026-04-02T07:00:00', 1, 0, 0),
    (N'950006', 1, N'DSV',             4, N'TRUCK-VSL-003', '2026-04-05T09:15:00', 2, 1, '2026-04-05T10:00:00', 1, 0, 0),
    (N'950007', 4, N'Expeditors',      1, N'COASTER-17', '2026-04-06T12:00:00', 1, 2, '2026-04-06T13:00:00', 1, 0, 1),
    (N'950008', 3, N'CMA CGM',         2, N'CMA CGM RIVOLI', '2026-04-01T23:00:00', 2, 2, '2026-04-02T08:00:00', 1, 0, 0),
    (N'950009', 1, N'GXO Logistics',   2, N'TRUCK-VSL-004', '2026-04-03T16:30:00', 1, 1, '2026-04-03T17:00:00', 1, 0, 1),
    (N'950010', 2, N'UPS Supply Chain',1, N'AIR-VSL-002', '2026-04-04T04:20:00', 1, 1, '2026-04-04T06:00:00', 1, 0, 0)

SELECT TOP (10)
    ID,
    HeaderBusinessNumber,
    HeaderID,
    SecurityReference,
    Carrier,
    Vessel,
    StatusID,
    Released,
    HasComment
FROM dbo.ArrivalHeadersUnreleased
ORDER BY ID DESC
