alter table "public"."game_settings"
  drop constraint "game_settings_known_game";

alter table "public"."saved_games"
  drop constraint "saved_games_known_game";
