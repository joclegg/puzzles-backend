# puzzles-backend

Supabase backend that syncs scores and history for [puzzles-web](https://github.com/joclegg/puzzles-web) and [puzzles-android](https://github.com/joclegg/puzzles-android).

- `supabase/migrations/`: the database schema. Push it with `supabase db push --linked`.
- `saved_games`: one row per game played, keyed by user, game and a client-made UUID. `data` holds the client's save as JSON.
- `game_settings`: one row per user per game.
- Row level security limits every row to its owner. Sign-in is Google only.
- Conflicts resolve last-write-wins on `updated_at`. Deletes are soft (`deleted = true`) so they sync too.
