-- The Keep alive workflow calls this so the free project doesn't pause.
create function public.keep_alive()
returns void
language sql
security invoker
set search_path = ''
as $$
  select 1;
$$;

-- New functions are not exposed automatically, so grant the Data API access here.
grant execute on function public.keep_alive() to anon;
