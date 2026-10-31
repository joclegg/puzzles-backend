# AGENTS.md

The Supabase backend that syncs scores and history for puzzles-web and puzzles-android. It is a database schema and nothing else: see `README.md` for the tables and how sync works.

## Stack

- Supabase: Postgres, row level security and auth
- SQL migrations, run with the Supabase CLI

## Commands

- `supabase db start`: start the local database, applying every migration
- `supabase db lint --local --fail-on error`: lint the schema, as CI does
- `supabase migration new <name>`: add a migration

## Rules

- MUST keep `supabase db lint --local --fail-on error` passing.
- MUST change the schema only through a new file in `supabase/migrations/`, named `<timestamp>_<name>.sql`.
- MUST NOT edit a migration that has merged: the `Deploy` workflow has already pushed it to the live project.
- MUST NOT run `supabase db push` by hand unless the `Deploy` workflow can't, as every merge to `main` pushes migrations.
- MUST turn on row level security for every table, limiting each row to its owner.
- MUST NOT delete synced rows: set `deleted = true`, so the delete syncs to other devices.
- MUST move `updated_at` forward when a migration changes existing rows, or clients ignore the change.
- MUST keep conflicts last-write-wins on `updated_at`, with `synced_at` set by the server on every write.
- MUST keep changes compatible with the released apps, which read and write these tables directly.
- MUST NOT remove `keep_alive()`: a daily job calls it so the free plan doesn't pause the project.
- MUST NOT commit secrets. `SUPABASE_ACCESS_TOKEN` is managed in joclegg-infra.
