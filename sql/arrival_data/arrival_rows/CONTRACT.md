# Contract – dbo.ArrivalRowsUnreleased (Phase 1)

This file defines the first-phase contract for `dbo.ArrivalRowsUnreleased`.

Only arrival rows are in scope in this file.  
Rows must always belong to an existing header in `dbo.ArrivalHeadersUnreleased`.

---

## Purpose

`dbo.ArrivalRowsUnreleased` stores the line-level records that belong to unreleased arrival headers.

This table exists to:
- store row-level planning data
- keep each row linked to a real parent header
- support later expansion with row comments, mail links, and other row-related logic

Rows are not standalone records.  
A row may only exist if a valid parent header already exists.

---

## Key strategy

| Key | Column | How it is assigned |
|---|---|---|
| Technical primary key | `ID` | `IDENTITY(1,1)` – assigned by SQL Server |
| Parent technical link | `ParentHeaderDbID` | References `dbo.ArrivalHeadersUnreleased.ID` |
| Parent business-key copy | `HeaderRecordID` | Copy of `dbo.ArrivalHeadersUnreleased.HeaderID` |
| Row sequence within header | `RowSequence` | Starts at `1` per header |
| Row business/display key | `RowID` | Persisted computed column derived from `HeaderRecordID` + `RowSequence` |

### Rules
- `ParentHeaderDbID` must always reference an existing header.
- `HeaderRecordID` must always match the parent header business key.
- `RowSequence` is unique within each header.
- `RowID` must be unique across the table.
- Applications must not invent `RowID` independently if SQL Server builds it.

---

## Required columns

| Column | Type | Notes |
|---|---|---|
| `ID` | `int IDENTITY(1,1)` | Technical primary key, database-generated |
| `ParentHeaderDbID` | `int NOT NULL` | FK to `dbo.ArrivalHeadersUnreleased.ID` |
| `HeaderRecordID` | `nvarchar(20) NOT NULL` | Copy of parent `HeaderID` |
| `RowSequence` | `int NOT NULL` | Starts at 1 per header |
| `RowID` | `nvarchar(30) NOT NULL UNIQUE` | Persisted computed row identifier |
| `PartNumber` | `nvarchar(100)` | Part number |
| `PrimairySupplier` | `nvarchar(100)` | Primary supplier name |
| `Quantity` | `int` | Quantity for the row |
| `Incoming` | `bit` | Indicates incoming shipment flag |
| `ASN` | `nvarchar(100)` | Advance Shipping Notice reference |
| `MRN` | `nvarchar(100)` | Movement Reference Number |
| `DellOwned` | `bit` | Indicates Dell-owned inventory |
| `Bonded` | `bit` | Indicates bonded stock |
| `Released` | `bit` | Release flag |
| `CreatedAt` | `datetime2` | Set by SQL Server on insert |
| `ModifiedAt` | `datetime2` | Set by SQL Server on insert in this phase |
| `StatusID` | `int` | FK-based status column for row status |
| `Container` | `nvarchar(100)` | Container or grouping reference |
| `HasComment` | `bit` | Helper flag indicating whether a comment is linked to this row |

---

## RowID rule

`RowID` is the business/display identifier for the row.

Expected format:

- `HeaderRecordID-0001`
- `HeaderRecordID-0002`
- `HeaderRecordID-0003`

So if `HeaderRecordID = 0000000123`, then example row IDs are:

- `0000000123-0001`
- `0000000123-0002`

---

## Rules in scope for this phase

- `ID` is database-generated (`IDENTITY`).
- `ParentHeaderDbID` must reference an existing header.
- `HeaderRecordID` must match the related parent header.
- `RowSequence` must start at `1` within a header.
- `RowSequence` must be unique per header.
- `RowID` must be unique across all rows.
- `Released` is stored on the row.
- `StatusID` is stored as an integer lookup-based status field.
- `HasComment` is a helper flag, same concept as the header model. In this phase it defaults to `0` and automatic maintenance is not yet implemented.
- `CreatedAt` is set by SQL Server on insert.
- `ModifiedAt` is set by SQL Server on insert in this phase; automatic update maintenance is not yet implemented in this phase.

---

## Constraints expected in this phase

The row table should support at least these constraints:

- primary key on `ID`
- foreign key on `ParentHeaderDbID`
- unique constraint on `(ParentHeaderDbID, RowSequence)`
- unique constraint on `RowID`

If `RowID` is implemented as a computed persisted column, SQL Server remains the owner of that value.

---

## Sample data rule for later seed phase

When sample rows are seeded later:

- rows must only be created for existing sample headers
- rows must always link to the real header IDs
- each sample header should receive between **4 and 10 rows**
- rows must be derived from the header sample set, never created as orphan records

This seed logic is not part of this contract file, but it is a required rule for later sample generation.

---

## Out of scope for this phase

- Row comments
- Mail attachments
- SharePoint publication
- Stored procedures
- Deployment / bootstrap logic
- Automatic update handling for `ModifiedAt`
- Full sample seed implementation
- Header table definition details outside the required parent relationship
