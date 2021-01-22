-module(erlang_secrets_server).

-behaviour(gen_server).

%% API
-export([stop/0, start_link/0, store_secret/1, get_secret/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
         code_change/3]).

-record(state, {counter}).

store_secret(Secret) ->
    gen_server:call({global, erlang_secrets_server}, {store_secret, Secret}).

get_secret(Key) ->
    gen_server:call({global, erlang_secrets_server}, {get_secret, Key}).

% start() ->
%     erlang_secrets_sup:start_child(Name).

stop() ->
    gen_server:call({global, erlang_secrets_server}, stop).

start_link() ->
    gen_server:start_link({global, erlang_secrets_server}, erlang_secrets_server, [], []).

init(_Args) ->
    Bound = erlang_secrets_config:counter_bound(),
    erlang_secrets = ets:new(erlang_secrets, [set, named_table]),
    {ok, #state{counter = rand:uniform(Bound) rem Bound}}.

handle_call(stop, _From, State) ->
    {stop, normal, stopped, State};
handle_call({store_secret, Secret}, _From, State = #state{counter = Counter}) ->
    Key = erlang_secrets_keygen:key(Counter),
    Bound = erlang_secrets_config:counter_bound(),
    NewState = State#state{counter = (Counter + 1) rem Bound},
    case ets:insert_new(erlang_secrets, {Key, Secret}) of
        true ->
            {reply, {ok, Key}, NewState};
        false ->
            {reply, collision, NewState}
    end;
handle_call({get_secret, Key}, _From, State) ->
    case ets:lookup(erlang_secrets, Key) of
        [] ->
            {reply, not_found, State};
        [{_Key, Secret}] ->
            true = ets:delete(erlang_secrets, Key),
            {reply, {ok, Secret}, State}
    end.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
