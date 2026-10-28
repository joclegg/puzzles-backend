-- Score and history sync shared by puzzles-web and puzzles-android.
-- Each client keeps saving locally and syncs these rows when signed in.
-- Conflicts resolve last-write-wins on updated_at.

create table public.saved_games (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  game text not null,
  id uuid not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  primary key (user_id, game, id)
);

create index saved_games_user_updated on public.saved_games (user_id, updated_at);

create table public.game_settings (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  game text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, game)
);

alter table public.saved_games enable row level security;
alter table public.game_settings enable row level security;

create policy "Own saved games" on public.saved_games
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Own settings" on public.game_settings
  for all to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

-- New tables are not exposed automatically, so grant the Data API access here.
grant select, insert, update, delete on public.saved_games to authenticated;
grant select, insert, update, delete on public.game_settings to authenticated;
