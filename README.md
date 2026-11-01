# puzzles-backend

The Supabase backend behind Puzzles. It syncs saved games and settings between devices for the [Android](https://github.com/joclegg/puzzles-android), [iOS](https://github.com/joclegg/puzzles-ios) and [web](https://github.com/joclegg/puzzles-web) apps. Signing in is optional: each app works offline on its own and syncs when signed in, with Google, Microsoft or an emailed link with a code.

The whole backend is a database schema. The apps talk to the tables directly through Supabase's Data API, and row level security keeps every row private to its owner.

## How sync works

- `saved_games`: one row per game played, keyed by user, game and a client-made UUID. `data` holds the client's save as JSON.
- `game_settings`: one row per user per game.
- `game` must be one of the eight games' ids.
- Conflicts resolve last-write-wins on `updated_at`. A trigger drops any update older than the stored row, so a device that was offline can't overwrite newer data, and sets `synced_at` to the server's time on every write.
- Clients pull rows whose `synced_at` is after their last pull, a page at a time.
- Deletes are soft (`deleted = true`), so they sync too.

## Functions

- `delete_account()`: deletes the caller's account, and their rows with it. The apps call it from settings and then sign out.
- `keep_alive()`: a no-op anyone may call. A daily Cloudflare Worker in [joclegg-infra](https://github.com/joclegg/joclegg-infra) calls it so the free plan never pauses the project.

## Working on it

With the Supabase CLI and Docker:

```sh
supabase db start                          # local database with every migration applied
supabase db lint --local --fail-on error   # lint, as CI does
supabase db schema declarative sync --name <name>  # generate a migration from supabase/schemas/
```

Every merge to `main` pushes new migrations to the live project through the `Deploy` workflow. The `SUPABASE_ACCESS_TOKEN` it uses is managed in joclegg-infra.
