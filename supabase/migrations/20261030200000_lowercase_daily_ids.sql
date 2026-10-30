-- Android saved Slide Out and Word Wheel dailies as daily_<date>_EASY and the
-- web as daily_<date>_easy, so neither recognised the other's result.
-- Everything now uses lower case. Where a daily was played on both, keep one
-- row: a solved game first, then the earliest finished, then the latest
-- updated. The others are soft-deleted so the delete syncs too.
-- updated_at moves forward so that clients accept the changed rows.

with dailies as (
  select
    user_id, game, id,
    row_number() over (
      partition by user_id, game, lower(data->>'puzzleId')
      order by
        data->>'status' = 'solved' desc,
        (data->>'finishedAt')::bigint asc nulls last,
        updated_at desc
    ) as position
  from public.saved_games
  where game in ('slideOut', 'wordWheel')
    and not deleted
    and data->>'puzzleId' like 'daily\_%'
)
update public.saved_games as saved
set deleted = true, updated_at = now()
from dailies
where dailies.position > 1
  and saved.user_id = dailies.user_id
  and saved.game = dailies.game
  and saved.id = dailies.id;

update public.saved_games
set data = jsonb_set(data, '{puzzleId}', to_jsonb(lower(data->>'puzzleId'))),
    updated_at = now()
where game in ('slideOut', 'wordWheel')
  and not deleted
  and data->>'puzzleId' like 'daily\_%'
  and data->>'puzzleId' <> lower(data->>'puzzleId');
