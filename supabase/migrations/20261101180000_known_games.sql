-- game is free text, so a client sending the wrong id (or the wrong case) was
-- only found after it synced. Reject anything but the eight games' ids.
-- NOT VALID checks new and updated rows without scanning the existing ones.

alter table public.saved_games
  add constraint saved_games_known_game check (game in (
    'fiveLetters', 'kakuro', 'sightlines', 'slideOut',
    'solitaire', 'sudoku', 'twoTone', 'wordWheel'
  )) not valid;

alter table public.game_settings
  add constraint game_settings_known_game check (game in (
    'fiveLetters', 'kakuro', 'sightlines', 'slideOut',
    'solitaire', 'sudoku', 'twoTone', 'wordWheel'
  )) not valid;
