/*
===============================================================================
  002_table.sql
  Comments — dbo.ArrivalRowComments

  Scope:
    - row comments only
    - requires dbo.ArrivalRowsUnreleased to already exist
    - no procedures
    - no triggers
    - no mail, attachments, or SharePoint logic
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalRowsUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalRowsUnreleased does not exist. Create rows first.', 16, 1)
    RETURN
END

IF OBJECT_ID('dbo.ArrivalRowComments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalRowComments
    (
        ID int IDENTITY(1,1) NOT NULL,

        ParentRowID nvarchar(30) NOT NULL,

        CommentTitle nvarchar(200) NULL,

        CommentText nvarchar(max) NOT NULL,

        CreatedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalRowComments_CreatedAt DEFAULT (sysdatetime()),

        CreatedBy nvarchar(255) NULL,

        CONSTRAINT PK_ArrivalRowComments
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT FK_ArrivalRowComments_ParentRowID
            FOREIGN KEY (ParentRowID)
            REFERENCES dbo.ArrivalRowsUnreleased (RowID)
    )
END
