# Comments Layer — Contract

## Purpose

Stores free-text comments written by planners against an arrival header or an arrival row.
Comments are append-only records; they are never edited in place.

---

## Tables

### dbo.ArrivalHeaderComments

Holds comments linked to a specific arrival header.

| Column          | Type              | Nullable | Notes                          |
|-----------------|-------------------|----------|--------------------------------|
| ID              | int IDENTITY(1,1) | NOT NULL | Primary key                    |
| ParentHeaderID  | nvarchar(20)      | NOT NULL | FK → dbo.ArrivalHeadersUnreleased.HeaderID |
| CommentTitle    | nvarchar(200)     | NULL     | Optional short subject line    |
| CommentText     | nvarchar(max)     | NOT NULL | Main comment body              |
| CreatedAt       | datetime2(0)      | NOT NULL | Default sysdatetime()          |
| CreatedBy       | nvarchar(255)     | NULL     | User identity (UPN or display name) |

### dbo.ArrivalRowComments

Holds comments linked to a specific arrival row.

| Column        | Type              | Nullable | Notes                        |
|---------------|-------------------|----------|------------------------------|
| ID            | int IDENTITY(1,1) | NOT NULL | Primary key                  |
| ParentRowID   | nvarchar(30)      | NOT NULL | FK → dbo.ArrivalRowsUnreleased.RowID |
| CommentTitle  | nvarchar(200)     | NULL     | Optional short subject line  |
| CommentText   | nvarchar(max)     | NOT NULL | Main comment body            |
| CreatedAt     | datetime2(0)      | NOT NULL | Default sysdatetime()        |
| CreatedBy     | nvarchar(255)     | NULL     | User identity (UPN or display name) |

---

## Relationship Strategy

- `ArrivalHeaderComments.ParentHeaderID` references `dbo.ArrivalHeadersUnreleased.HeaderID` (the computed, persisted business key).
- `ArrivalRowComments.ParentRowID` references `dbo.ArrivalRowsUnreleased.RowID` (the computed, persisted business key).
- No cascades are defined; comment cleanup must be handled explicitly before parent removal.

---

## Out of Scope (this phase)

- Automatic `HasComment` flag maintenance on parent header/row is **not implemented** in this phase.
  The `HasComment` column exists on both parent tables and will be addressed in a future phase.
- No stored procedures, triggers, mail, attachments, or SharePoint logic.
