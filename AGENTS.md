# AGENTS.md

## Structure

The Supabase backend that syncs saved games and settings for the Android, iOS and web apps. It is a database schema and nothing else.

| Path | Purpose |
| --- | --- |
| `supabase/schemas/` | The desired schema: edit these files to change the database. |
| `supabase/migrations/` | Generated from `supabase/schemas/`, one `<timestamp>_<name>.sql` file per change, applied in order. |
| `supabase/config.toml` | Local Supabase settings for `supabase db start`. |
| `.github/workflows/build-and-test.yml` | Starts a local database with every migration, lints it, and fails if the migrations differ from `supabase/schemas/`. |
| `.github/workflows/deploy.yml` | Pushes new migrations to the live project after each merge to `main`. |
| `README.md` | The tables, the functions, and how sync works. |

## Conventions

### Checks and deploying
- MUST keep `supabase db start` and `supabase db lint --local --fail-on error` passing.
- MUST change the schema only by editing `supabase/schemas/`, then generating the migration with `supabase db schema declarative sync --name <name>`.
- MUST NOT write or edit migration files by hand. If a change can't be expressed in `supabase/schemas/` (such as updating existing rows), stop and ask.
- MUST keep the generated migration and the `supabase/schemas/` change in the same commit; CI fails if they differ.
- MUST review every generated migration for drops: a rename comes out as drop plus add, which loses data and breaks released apps.
- MUST NOT edit a migration that has merged: it has already run on the live project.
- MUST NOT run `supabase db push` by hand unless the `Deploy` workflow can't.

### SQL
- MUST write SQL keywords in lower case and names in snake_case, schema-qualified (`public.saved_games`).
- MUST put a comment saying why above each object in `supabase/schemas/`.
- MUST give every function `set search_path = ''`, and use `security definer` only when the caller's rights aren't enough.
- MUST grant execute on every new function only to the roles that need it, and revoke it from `public` when it is `security definer`.
- MUST grant the Data API access to new tables and functions explicitly: nothing is exposed by default.
- MUST add constraints and checks with a separate `alter table ... add constraint ... not valid` when existing rows might break them (inside `create table` it is ignored), and validate later.

### Data and sync
- MUST turn on row level security for every table, limiting each row to its owner with `(select auth.uid())`.
- MUST NOT delete synced rows: set `deleted = true`, so the delete syncs to other devices.
- MUST move `updated_at` forward when a migration changes existing rows, or clients ignore the change.
- MUST keep conflicts last-write-wins on `updated_at`, with `synced_at` set by the server on every write.
- MUST keep every change compatible with the released apps, which read and write these tables directly.
- MUST add a new game's id to the `known_game` checks before any app syncs it.
- MUST NOT remove `keep_alive()`: a daily job calls it so the free plan doesn't pause the project.
- MUST NOT commit secrets.
