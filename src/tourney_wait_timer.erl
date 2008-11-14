%%%% Copyright (C) 2005-2008 Wager Labs, SA

-module(tourney_wait_timer).

-export([start/3, game_start/3]).

-include("common.hrl").
-include("pp.hrl").
-include("tourney.hrl").

-define(?TIMEOUT, 300000).

start(T, Ctx, []) ->
		StartTime = (T#tourney.config)#tab_tourney_config.start_time,
		Future = datetime_to_now(StarTime),
		erlang:start_timer(?TIMEOUT, self(), none),
		{next, wait_for_players, T, Future}.

wait_for_players(T, Future, {timeout, _, _}) ->
		Now = now(),
		if
				Now > Future ->
						{stop, T, Future};
				true ->
						erlang:start_timer(?TIMEOUT, self(), none),
						{continue, T, Future}
		end.

wait_for_players(T, Ctx, _) ->
		{skip, T, Ctx}.

%%% calendar:datetime_to_gregorian_seconds({{1970,1,1}, {0,0,0}})

-define(GREGORIAN_SECONDS_1970, 62167219200).

datetime_to_now(DateTime) ->
   GSeconds = calendar:datetime_to_gregorian_seconds(DateTime),
   ESeconds = GSeconds - ?GREGORIAN_SECONDS_1970,
   {ESeconds div 1000000, ESeconds rem 1000000, 0}.