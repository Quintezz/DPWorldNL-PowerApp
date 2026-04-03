CREATE OR ALTER PROCEDURE dbo.usp_EBDOnHold_LoadJson
    @RowsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RowsJson IS NULL OR ISJSON(@RowsJson) <> 1
    BEGIN
        THROW 50001, 'Parameter @RowsJson bevat geen geldige JSON.', 1;
    END;

    INSERT INTO dbo.EBDOnHold
    (
        Site,
        OrderNumber,
        SortCode,
        ChannelID,
        Segment,
        Company,
        FSDate,
        FSTime,
        RecDate,
        RecTime,
        IsComplete,
        OrderQty,
        ActualBoxQty,
        OnHoldReason,
        OHH,
        StatusText,
        CountryCode,
        VolWeight,
        ActWeight,
        CarrierCode,
        DaysOnHold,
        BuildDate,
        CommentText,
        InstructionText,
        PreAlert5525Time,
        Confirmed5550Time
    )
    SELECT
        NULLIF(j.Site, ''),
        TRY_CONVERT(BIGINT, NULLIF(j.OrderNumber, '')),
        NULLIF(j.SortCode, ''),
        NULLIF(j.ChannelID, ''),
        NULLIF(j.Segment, ''),
        NULLIF(j.Company, ''),
        TRY_CONVERT(DATE, NULLIF(j.FSDate, ''), 103),
        TRY_CONVERT(TIME(0), NULLIF(j.FSTime, '')),
        TRY_CONVERT(DATE, NULLIF(j.RecDate, ''), 103),
        TRY_CONVERT(TIME(0), NULLIF(j.RecTime, '')),
        TRY_CONVERT(BIT, NULLIF(j.IsComplete, '')),
        TRY_CONVERT(INT, NULLIF(j.OrderQty, '')),
        TRY_CONVERT(INT, NULLIF(j.ActualBoxQty, '')),
        NULLIF(j.OnHoldReason, ''),
        TRY_CONVERT(INT, NULLIF(j.OHH, '')),
        NULLIF(j.StatusText, ''),
        NULLIF(j.CountryCode, ''),
        TRY_CONVERT(DECIMAL(18,2), NULLIF(j.VolWeight, '')),
        TRY_CONVERT(DECIMAL(18,2), NULLIF(j.ActWeight, '')),
        NULLIF(j.CarrierCode, ''),
        TRY_CONVERT(INT, NULLIF(j.DaysOnHold, '')),
        TRY_CONVERT(DATE, NULLIF(j.BuildDate, ''), 103),
        NULLIF(j.CommentText, ''),
        NULLIF(j.InstructionText, ''),
        TRY_CONVERT(DATETIME2(0), NULLIF(j.PreAlert5525Time, ''), 103),
        TRY_CONVERT(DATETIME2(0), NULLIF(j.Confirmed5550Time, ''), 103)
    FROM OPENJSON(@RowsJson)
    WITH
    (
        Site                NVARCHAR(10)   '$.Site',
        OrderNumber         NVARCHAR(50)   '$.OrderNumber',
        SortCode            NVARCHAR(50)   '$.SortCode',
        ChannelID           NVARCHAR(50)   '$.ChannelID',
        Segment             NVARCHAR(100)  '$.Segment',
        Company             NVARCHAR(255)  '$.Company',
        FSDate              NVARCHAR(20)   '$.FSDate',
        FSTime              NVARCHAR(20)   '$.FSTime',
        RecDate             NVARCHAR(20)   '$.RecDate',
        RecTime             NVARCHAR(20)   '$.RecTime',
        IsComplete          NVARCHAR(10)   '$.IsComplete',
        OrderQty            NVARCHAR(20)   '$.OrderQty',
        ActualBoxQty        NVARCHAR(20)   '$.ActualBoxQty',
        OnHoldReason        NVARCHAR(255)  '$.OnHoldReason',
        OHH                 NVARCHAR(20)   '$.OHH',
        StatusText          NVARCHAR(100)  '$.StatusText',
        CountryCode         NVARCHAR(10)   '$.CountryCode',
        VolWeight           NVARCHAR(30)   '$.VolWeight',
        ActWeight           NVARCHAR(30)   '$.ActWeight',
        CarrierCode         NVARCHAR(20)   '$.CarrierCode',
        DaysOnHold          NVARCHAR(20)   '$.DaysOnHold',
        BuildDate           NVARCHAR(20)   '$.BuildDate',
        CommentText         NVARCHAR(MAX)  '$.CommentText',
        InstructionText     NVARCHAR(MAX)  '$.InstructionText',
        PreAlert5525Time    NVARCHAR(30)   '$.PreAlert5525Time',
        Confirmed5550Time   NVARCHAR(30)   '$.Confirmed5550Time'
    ) AS j;
END;
GO
