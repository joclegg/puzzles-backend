-- Lets a signed-in user delete their own account. Deleting the auth.users row
-- cascades to saved_games and game_settings. Runs as the owner because
-- clients can't touch auth.users themselves; it only ever deletes the caller.
create function public.delete_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not signed in';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke execute on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
