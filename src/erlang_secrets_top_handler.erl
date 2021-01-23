-module(erlang_secrets_top_handler).

%% Standard callbacks.
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_provided/2]).
-export([content_types_accepted/2]).
-export([resource_exists/2]).
%% Custom callbacks.
-export([create_entry/2]).
-export([fetch_entry/2]).

init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[{<<"application/json">>, create_entry}], Req, State}.

content_types_provided(Req, State) ->
    {[{<<"application/json">>, fetch_entry}], Req, State}.

create_entry(Req0, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req0),
    {[{<<"secret">>, Secret}]} = jiffy:decode(Body),
    {ok, SecretKey} = erlang_secrets_server:store_secret(Secret),
    SecretKeyBase64 = base64url:encode(SecretKey),
    ResponseJson = jiffy:encode({[{key, SecretKeyBase64}]}),
    Req2 = cowboy_req:set_resp_body(ResponseJson, Req1),
    {true, Req2, State}.

resource_exists(Req, State) ->
    case cowboy_req:binding(key, Req) of
        undefined ->
            {false, Req, State};
        Key ->
            DecodedKey = base64url:decode(Key),
            case erlang_secrets_server:get_secret(DecodedKey) of
                {ok, Secret} ->
                    {true, Req, Secret};
                not_found ->
                    {false, Req, State}
            end
    end.

fetch_entry(Req, State) ->
    ResponseJson = jiffy:encode({[{secret, State}]}),
    {ResponseJson, Req, index}.
