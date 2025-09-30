# SQL Query Analysis

A tidy, reproducible home for your ad‑hoc and reusable T‑SQL queries.

## What’s inside
- **/src** — your finalized SQL scripts (copied from the repo; paste the contents into the placeholders)
- **/workbench** — scratch/WIP queries
- **/ddl** — future table/UDF/proc definitions
- **/tests** — seed data + verification queries
- **/.github/workflows** — SQLFluff CI linting
- **/.devcontainer** — optional VS Code/Codespaces environment
- **.sqlfluff** — lint rules (T‑SQL)
- **.pre-commit-config.yaml** — local lint/format on commit
- **.editorconfig** — consistent indentation & EOLs
- **scripts** — helper commands

## How to use
```bash
# (optional) install pre-commit
pip install pre-commit && pre-commit install

# lint everything
sqlfluff lint .

# try fixing common issues
sqlfluff fix .
```

## Files catalog
| File | Purpose |
|---|---|
| Background Party Match.sql | Joins background data to party affiliation; latest match per person. |
| Confidential Filing Search.sql | Text pattern search across filings; intended for full‑text or LIKE scans. |
| County Data Pull.sql | Aggregations by county/FIPS with rollups. |
| Dumby variables on multiple categories.sql | One‑hot/dummy‑variable expansion for multi‑category fields. |

> Heads‑up: I couldn’t programmatically fetch file **contents** from GitHub in this environment, so the SQL files in `/src` are **placeholders** with headers. Paste your actual query text into each file (same filenames).

## Conventions
- Keywords UPPERCASE, identifiers `snake_case` or `CamelCase` (pick one).
- Prefer CTEs with descriptive names: `cte_party_matches`, `cte_county_rollup`.
- Parameterize filters via `DECLARE @param` for reproducibility.
- Guardrails: `SET NOCOUNT ON; SET XACT_ABORT ON;` around DML; use transactions for writes.

## CI & Dev Container
- Pushes/PRs run SQLFluff (see `.github/workflows/sqlfluff.yml`).
- Open in VS Code Dev Container / Codespaces for a ready‑to‑run environment with `sqlcmd` and `sqlfluff` installed.
