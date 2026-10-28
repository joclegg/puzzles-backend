# puzzles-backend

Supabase backend that syncs scores and history for [puzzles-web](https://github.com/joclegg/puzzles-web) and [puzzles-android](https://github.com/joclegg/puzzles-android).

- `supabase/migrations/`: the database schema. Push it with `supabase db push --linked`.
- `saved_games`: one row per game played, keyed by user, game and a client-made UUID. `data` holds the client's save as JSON.
- `game_settings`: one row per user per game.
- Row level security limits every row to its owner. Sign-in is Google only.
- Conflicts resolve last-write-wins on `updated_at`. Deletes are soft (`deleted = true`) so they sync too.
- `keep_alive()`: a no-op function anyone may call. The `Keep alive` workflow calls it every three days, because the free plan pauses a project after a week without activity. GitHub turns scheduled workflows off after 60 days without commits, so re-enable it in the Actions tab if that happens.
