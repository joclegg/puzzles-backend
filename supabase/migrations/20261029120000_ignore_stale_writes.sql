-- Last write wins on the server too: an upsert older than the stored row is
-- dropped, so a device that comes back online can't overwrite newer data.
-- Clients pull after pushing, so the device with the stale copy then picks
-- up the newer row.

create function public.ignore_stale_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.updated_at < old.updated_at then
    return null;
  end if;
  return new;
end;
$$;

create trigger saved_games_ignore_stale_write
  before update on public.saved_games
  for each row execute function public.ignore_stale_write();

create trigger game_settings_ignore_stale_write
  before update on public.game_settings
  for each row execute function public.ignore_stale_write();
