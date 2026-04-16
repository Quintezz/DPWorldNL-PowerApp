/*
===============================================================================
  dbo.GridRowConfig
  Doel:
  Configtabel voor de kolomdefinitie van grid-componenten zoals cmpGridRows.

  Opzet:
  - 1 record per kolom per grid/component
  - seed komt apart
===============================================================================
*/

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('dbo.GridRowConfig', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.GridRowConfig
END
GO

CREATE TABLE dbo.GridRowConfig
(
    ID                 int IDENTITY(1,1) NOT NULL,
    GridName           nvarchar(100) NOT NULL,
    ColumnKey          nvarchar(100) NOT NULL,
    ColumnLabel        nvarchar(100) NOT NULL,
    DataField          nvarchar(128) NULL,

    SortOrder          int NOT NULL,
    WidthPx            int NOT NULL,
    MinWidthPx         int NULL,
    MaxWidthPx         int NULL,

    IsVisible          bit NOT NULL CONSTRAINT DF_GridRowConfig_IsVisible DEFAULT (1),
    IsFilterable       bit NOT NULL CONSTRAINT DF_GridRowConfig_IsFilterable DEFAULT (1),
    IsSortable         bit NOT NULL CONSTRAINT DF_GridRowConfig_IsSortable DEFAULT (1),
    IsResizable        bit NOT NULL CONSTRAINT DF_GridRowConfig_IsResizable DEFAULT (1),
    IsFrozen           bit NOT NULL CONSTRAINT DF_GridRowConfig_IsFrozen DEFAULT (0),
    IsRequired         bit NOT NULL CONSTRAINT DF_GridRowConfig_IsRequired DEFAULT (0),
    IsSystemColumn     bit NOT NULL CONSTRAINT DF_GridRowConfig_IsSystemColumn DEFAULT (0),

    FilterType         nvarchar(30) NOT NULL CONSTRAINT DF_GridRowConfig_FilterType DEFAULT ('None'),
    FilterPlaceholder  nvarchar(150) NULL,

    HeaderAlign        nvarchar(10) NOT NULL CONSTRAINT DF_GridRowConfig_HeaderAlign DEFAULT ('Left'),
    CellAlign          nvarchar(10) NOT NULL CONSTRAINT DF_GridRowConfig_CellAlign DEFAULT ('Left'),

    HeaderTooltip      nvarchar(250) NULL,
    Description        nvarchar(500) NULL,

    IsActive           bit NOT NULL CONSTRAINT DF_GridRowConfig_IsActive DEFAULT (1),

    CreatedAt          datetime2(0) NOT NULL CONSTRAINT DF_GridRowConfig_CreatedAt DEFAULT (sysutcdatetime()),
    ModifiedAt         datetime2(0) NOT NULL CONSTRAINT DF_GridRowConfig_ModifiedAt DEFAULT (sysutcdatetime()),

    CONSTRAINT PK_GridRowConfig
        PRIMARY KEY CLUSTERED (ID),

    CONSTRAINT UQ_GridRowConfig_GridName_ColumnKey
        UNIQUE (GridName, ColumnKey),

    CONSTRAINT UQ_GridRowConfig_GridName_SortOrder
        UNIQUE (GridName, SortOrder),

    CONSTRAINT CK_GridRowConfig_SortOrder
        CHECK (SortOrder > 0),

    CONSTRAINT CK_GridRowConfig_WidthPx
        CHECK (WidthPx > 0),

    CONSTRAINT CK_GridRowConfig_MinWidthPx
        CHECK (MinWidthPx IS NULL OR MinWidthPx > 0),

    CONSTRAINT CK_GridRowConfig_MaxWidthPx
        CHECK (MaxWidthPx IS NULL OR MaxWidthPx > 0),

    CONSTRAINT CK_GridRowConfig_MinMaxWidthPx
        CHECK
        (
            MinWidthPx IS NULL
            OR MaxWidthPx IS NULL
            OR MinWidthPx <= MaxWidthPx
        ),

    CONSTRAINT CK_GridRowConfig_FilterType
        CHECK (FilterType IN ('None', 'SingleSelect', 'MultiSelect', 'Text', 'Number', 'Date')),

    CONSTRAINT CK_GridRowConfig_HeaderAlign
        CHECK (HeaderAlign IN ('Left', 'Center', 'Right')),

    CONSTRAINT CK_GridRowConfig_CellAlign
        CHECK (CellAlign IN ('Left', 'Center', 'Right'))
)
GO

CREATE TRIGGER dbo.trg_GridRowConfig_ModifiedAt
ON dbo.GridRowConfig
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON

    UPDATE c
    SET c.ModifiedAt = sysutcdatetime()
    FROM dbo.GridRowConfig c
    INNER JOIN inserted i
        ON i.ID = c.ID
END
GO
