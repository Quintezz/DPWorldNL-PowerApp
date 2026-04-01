# Contract – dbo.ArrivalHeadersUnreleased (Phase 1)

This file defines the first-phase contract for `dbo.ArrivalHeadersUnreleased`.  
Only arrival headers are in scope. Rows, comments, mail attachments, and SharePoint publication are explicitly out of scope for this phase.

---

## Key strategy

| Key | Column | How it is assigned |
|-----|--------|--------------------|
| Technical primary key | `ID` | `IDENTITY(1,1)` – assigned by SQL Server |
| Business key (numeric) | `HeaderBusinessNumber` | Sequence `dbo.Seq_HeaderBusinessNumber` – assigned by SQL Server |
| Business key (display) | `HeaderID` | Persisted computed column derived from `HeaderBusinessNumber`, zero-padded to minimum width 10 |

**Rules:**
- Applications must never supply `HeaderBusinessNumber` or `HeaderID` manually.
- `SecurityReference` is operational input only. It is not a business key and must not be used as a uniqueness source.
- Uniqueness for `HeaderBusinessNumber` and `HeaderID` is enforced in SQL Server.

---

## Required columns

| Column | Type | Notes |
|--------|------|-------|
| `ID` | `int IDENTITY(1,1)` | Technical primary key, database-generated |
| `HeaderBusinessNumber` | `bigint NOT NULL UNIQUE` | Database-generated from sequence `dbo.Seq_HeaderBusinessNumber` |
| `HeaderID` | `nvarchar(20) NOT NULL UNIQUE` | Persisted computed column, zero-padded to min width 10, database-generated |
| `SecurityReference` | `nvarchar` | Operational input, not a key |
| `TransportTypeID` | `int` | References transport type lookup |
| `Carrier` | `nvarchar` | Carrier name |
| `LoadTypeID` | `int` | References load type lookup |
| `Vessel` | `nvarchar` | Vessel name |
| `ETA` | `datetime2` | Estimated time of arrival |
| `SiteID` | `int` | References site lookup |
| `Released` | `bit` | Indicates whether the header has been released |
| `ReceivingDepartmentID` | `int` | References receiving department lookup |
| `CreatedAt` | `datetime2` | Set by SQL Server on insert |
| `ModifiedAt` | `datetime2` | Updated by SQL Server on every update |
| `PlannedDateTime` | `datetime2` | Planned arrival date/time |
| `StatusID` | `int` | FK-based status column referencing a header status lookup table (lookup table implementation is out of scope for this phase) |
| `HasComment` | `bit` | Indicates whether a comment is linked to this header |

---

## Rules in scope for this phase

- `ID` is database-generated (`IDENTITY`). Applications must not supply it.
- `HeaderBusinessNumber` is database-generated from sequence `dbo.Seq_HeaderBusinessNumber`. Applications must not supply it.
- `HeaderID` is database-generated as a persisted computed column. Applications must not supply it.
- Uniqueness of `HeaderBusinessNumber` and `HeaderID` is enforced by SQL Server constraints.
- Status is represented by `StatusID` (integer FK), not by free text or a loose integer without meaning.

---

## Out of scope for this phase

- `arrival_rows`
- Comments
- Mail attachments
- SharePoint publication
- Stored procedures
- Deployment / bootstrap logic
- Full status lookup table implementation
- Foreign key implementation details outside the header contract
