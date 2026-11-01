-- Saved games and settings that each app syncs when signed in.
-- Conflicts resolve last-write-wins on updated_at; synced_at is set by the
-- server on every write so clients can pull rows stored since their last pull.

create table public.saved_games (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  game text not null,
  id uuid not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  deleted boolean not null default false,
  synced_at timestamptz not null default now(),
  primary key (user_id, game, id)
);

-- not valid: existing rows aren't checked, new and updated ones are.
alter table public.saved_games
  add constraint saved_games_known_game check (game in (
    'fiveLetters', 'kakuro', 'sightlines', 'slideOut',
    'solitaire', 'sudoku', 'twoTone', 'wordWheel'
  )) not valid;

create index saved_games_user_synced on public.saved_games (user_id, synced_at);

create table public.game_settings (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  game text not null,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  synced_at timestamptz not null default now(),
  primary key (user_id, game)
);

-- not valid: existing rows aren't checked, new and updated ones are.
alter table public.game_settings
  add constraint game_settings_known_game check (game in (
    'fiveLetters', 'kakuro', 'sightlines', 'slideOut',
    'solitaire', 'sudoku', 'twoTone', 'wordWheel'
  )) not valid;

create index game_settings_user_synced on public.game_settings (user_id, synced_at);

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

grant select, insert, update, delete on public.saved_games to authenticated;
grant select, insert, update, delete on public.game_settings to authenticated;

-- An upsert older than the stored row is dropped, so a device coming back
-- online can't overwrite newer data.
create function public.stamp_sync_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if tg_op = 'UPDATE' and new.updated_at < old.updated_at then
    return null;
  end if;
  new.synced_at := now();
  return new;
end;
$$;

create trigger saved_games_stamp_sync_write
  before insert or update on public.saved_games
  for each row execute function public.stamp_sync_write();

create trigger game_settings_stamp_sync_write
  before insert or update on public.game_settings
  for each row execute function public.stamp_sync_write();
