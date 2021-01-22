%%%-------------------------------------------------------------------
%% @doc erlang_secrets public API
%% @end
%%%-------------------------------------------------------------------

-module(erlang_secrets_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
           {"/", cowboy_static, {file, "index.html"}},
           {"/[:key]", erlang_secrets_top_handler, []}
    ]}]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    erlang_secrets_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).

%% internal functions
