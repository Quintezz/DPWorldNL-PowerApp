/*
===============================================================================
  001_table.sql
  Arrival Rows — first phase

  Scope:
    - rows only
    - requires dbo.ArrivalHeadersUnreleased to already exist
    - no row comments
    - no mails
    - no attachments
    - no SharePoint
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalHeadersUnreleased does not exist. Create headers first.', 16, 1)
    RETURN
END

IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalRowsUnreleased
    (
        ID int IDENTITY(1,1) NOT NULL,

        ParentHeaderDbID int NOT NULL,
        HeaderRecordID nvarchar(20) NOT NULL,
        RowSequence int NOT NULL,

        RowID AS
            CAST(
                HeaderRecordID + N'-' +
                RIGHT(N'0000' + CAST(RowSequence AS nvarchar(10)), 4)
            AS nvarchar(30)) PERSISTED,

        PartNumber nvarchar(100) NULL,
        Vendor nvarchar(100) NULL,
        Quantity int NULL,

        DellOwned bit NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_DellOwned DEFAULT ((0)),

        Bonded bit NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_Bonded DEFAULT ((0)),

        Released bit NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_Released DEFAULT ((0)),

        CreatedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_CreatedAt DEFAULT (sysdatetime()),

        ModifiedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_ModifiedAt DEFAULT (sysdatetime()),

        StatusID int NULL,
        Container nvarchar(100) NULL,

        HasComment bit NOT NULL
            CONSTRAINT DF_ArrivalRowsUnreleased_HasComment DEFAULT ((0)),

        CONSTRAINT PK_ArrivalRowsUnreleased
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT UQ_ArrivalRowsUnreleased_ParentHeaderDbID_RowSequence
            UNIQUE (ParentHeaderDbID, RowSequence),

        CONSTRAINT UQ_ArrivalRowsUnreleased_RowID
            UNIQUE (RowID),

        CONSTRAINT FK_ArrivalRowsUnreleased_ParentHeader
            FOREIGN KEY (ParentHeaderDbID)
            REFERENCES dbo.ArrivalHeadersUnreleased (ID),

        CONSTRAINT CK_ArrivalRowsUnreleased_RowSequence
            CHECK (RowSequence >= 1),

        CONSTRAINT CK_ArrivalRowsUnreleased_Quantity
            CHECK (Quantity IS NULL OR Quantity > 0)
    )
END
