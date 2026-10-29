-- Last write wins on the server too: an upsert older than the stored row is
-- dropped, so a device that comes back online can't overwrite newer data.
-- synced_at is when the server last stored a row. Clients pull rows whose
-- synced_at is newer than the last pull, so a late upload with an old
-- updated_at is still picked up.

alter table public.saved_games add column synced_at timestamptz not null default now();
alter table public.game_settings add column synced_at timestamptz not null default now();

create index saved_games_user_synced on public.saved_games (user_id, synced_at);
create index game_settings_user_synced on public.game_settings (user_id, synced_at);
drop index public.saved_games_user_updated;

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
