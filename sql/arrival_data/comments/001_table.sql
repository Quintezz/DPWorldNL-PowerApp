/*
===============================================================================
  001_table.sql
  Comments — dbo.ArrivalHeaderComments

  Scope:
    - header comments only
    - requires dbo.ArrivalHeadersUnreleased to already exist
    - no procedures
    - no triggers
    - no mail, attachments, or SharePoint logic
===============================================================================
*/

SET NOCOUNT ON

IF OBJECT_ID('dbo.ArrivalHeadersUnreleased', 'U') IS NULL
BEGIN
    RAISERROR('dbo.ArrivalHeadersUnreleased does not exist. Create headers first.', 16, 1)
    RETURN
END

IF OBJECT_ID('dbo.ArrivalHeaderComments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ArrivalHeaderComments
    (
        ID int IDENTITY(1,1) NOT NULL,

        ParentHeaderID nvarchar(20) NOT NULL,

        CommentTitle nvarchar(200) NULL,

        CommentText nvarchar(max) NOT NULL,

        CreatedAt datetime2(0) NOT NULL
            CONSTRAINT DF_ArrivalHeaderComments_CreatedAt DEFAULT (sysdatetime()),

        CreatedBy nvarchar(255) NULL,

        CONSTRAINT PK_ArrivalHeaderComments
            PRIMARY KEY CLUSTERED (ID),

        CONSTRAINT FK_ArrivalHeaderComments_ParentHeaderID
            FOREIGN KEY (ParentHeaderID)
            REFERENCES dbo.ArrivalHeadersUnreleased (HeaderID)
    )
END
