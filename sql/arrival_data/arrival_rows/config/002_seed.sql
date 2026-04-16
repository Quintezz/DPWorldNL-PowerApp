/*
===============================================================================
  002_seed_GridRowConfig_cmpGridRows.sql
  Doel:
  Seed voor dbo.GridRowConfig voor grid/component: cmpGridRows

  Opmerking:
  - Tabel dbo.GridRowConfig moet al bestaan
  - Seed wordt volledig opnieuw gezet voor GridName = 'cmpGridRows'
===============================================================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.GridRowConfig', 'U') IS NULL
BEGIN
    RAISERROR('dbo.GridRowConfig does not exist. Run the table script first.', 16, 1)
    RETURN
END
GO

BEGIN TRY
    BEGIN TRANSACTION

    DELETE FROM dbo.GridRowConfig
    WHERE GridName = N'cmpGridRows'

    INSERT INTO dbo.GridRowConfig
    (
        GridName,
        ColumnKey,
        ColumnLabel,
        DataField,
        SortOrder,
        WidthPx,
        MinWidthPx,
        MaxWidthPx,
        IsVisible,
        IsFilterable,
        IsSortable,
        IsResizable,
        IsFrozen,
        IsRequired,
        IsSystemColumn,
        FilterType,
        FilterPlaceholder,
        HeaderAlign,
        CellAlign,
        HeaderTooltip,
        Description,
        IsActive
    )
    VALUES
    (
        N'cmpGridRows',
        N'PartNo',
        N'PartNo',
        N'PartNo',
        1,
        130,
        100,
        220,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search PartNo',
        N'Left',
        N'Left',
        N'Filter on PartNo',
        N'Part number column',
        1
    ),
    (
        N'cmpGridRows',
        N'PrimairySupplier',
        N'Supplier',
        N'PrimairySupplier',
        2,
        130,
        110,
        220,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search supplier',
        N'Left',
        N'Left',
        N'Filter on supplier',
        N'Supplier column. DataField intentionally kept as PrimairySupplier.',
        1
    ),
    (
        N'cmpGridRows',
        N'Quantity',
        N'Quantity',
        N'Quantity',
        3,
        125,
        100,
        180,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search quantity',
        N'Left',
        N'Left',
        N'Filter on quantity',
        N'Quantity column',
        1
    ),
    (
        N'cmpGridRows',
        N'DellOwned',
        N'Dell',
        N'DellOwned',
        4,
        95,
        80,
        140,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'SingleSelect',
        N'Select Dell value',
        N'Left',
        N'Left',
        N'Filter on Dell ownership',
        N'Dell yes/no column',
        1
    ),
    (
        N'cmpGridRows',
        N'Container',
        N'Container',
        N'Container',
        5,
        180,
        140,
        260,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search container',
        N'Left',
        N'Left',
        N'Filter on container',
        N'Container reference column',
        1
    ),
    (
        N'cmpGridRows',
        N'Incoming',
        N'Incoming',
        N'Incoming',
        6,
        125,
        100,
        180,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search incoming',
        N'Left',
        N'Left',
        N'Filter on incoming',
        N'Incoming column',
        1
    ),
    (
        N'cmpGridRows',
        N'ASN',
        N'ASN',
        N'ASN',
        7,
        105,
        90,
        180,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search ASN',
        N'Left',
        N'Left',
        N'Filter on ASN',
        N'ASN column',
        1
    ),
    (
        N'cmpGridRows',
        N'MRN',
        N'MRN',
        N'MRN',
        8,
        100,
        90,
        180,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search MRN',
        N'Left',
        N'Left',
        N'Filter on MRN',
        N'MRN column',
        1
    ),
    (
        N'cmpGridRows',
        N'Status',
        N'Status',
        N'Status',
        9,
        130,
        110,
        200,
        1,
        1,
        1,
        1,
        0,
        0,
        0,
        N'MultiSelect',
        N'Search status',
        N'Left',
        N'Left',
        N'Filter on status',
        N'Status column with dropdown filter',
        1
    ),
    (
        N'cmpGridRows',
        N'Actions',
        N'Actions',
        NULL,
        10,
        110,
        90,
        160,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        N'None',
        NULL,
        N'Center',
        N'Center',
        N'Action buttons',
        N'System column for edit/delete actions',
        1
    ),
    (
        N'cmpGridRows',
        N'Comment',
        N'Comment',
        N'HasComment',
        11,
        140,
        110,
        220,
        1,
        0,
        0,
        1,
        0,
        0,
        0,
        N'None',
        NULL,
        N'Left',
        N'Left',
        N'Comment indicator',
        N'Comment column / indicator column',
        1
    )

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000)
    DECLARE @ErrorSeverity int
    DECLARE @ErrorState int

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE()

    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION
    END

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
    RETURN
END CATCH
GO
