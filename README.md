# puzzles-backend

Supabase backend that syncs scores and history for [puzzles-web](https://github.com/joclegg/puzzles-web) and [puzzles-android](https://github.com/joclegg/puzzles-android).

- `supabase/migrations/`: the database schema. The `Deploy` workflow pushes it after each merge to main, using the `SUPABASE_ACCESS_TOKEN` secret. To push by hand, run `supabase db push --linked`.
- `saved_games`: one row per game played, keyed by user, game and a client-made UUID. `data` holds the client's save as JSON.
- `game_settings`: one row per user per game.
- Row level security limits every row to its owner. Sign-in is Google only.
- Conflicts resolve last-write-wins on `updated_at`. A trigger drops any update older than the stored row, so a device that was offline can't overwrite newer data, and sets `synced_at` to the server's time on every write. Clients pull rows with `synced_at` after their last pull, a page at a time. Deletes are soft (`deleted = true`) so they sync too.
- `keep_alive()`: a no-op function anyone may call. The `puzzles-keep-alive` Cloudflare Worker in [joclegg-infra](https://github.com/joclegg/joclegg-infra) (`cloudflare/keep_alive.tf`) calls it every day, because the free plan pauses a project after a week without activity.
