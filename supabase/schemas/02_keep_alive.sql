-- A daily job calls this so the free project doesn't pause. Never remove it.
create function public.keep_alive()
returns void
language sql
security invoker
set search_path = ''
as $$
  select 1;
$$;

grant execute on function public.keep_alive() to anon;
