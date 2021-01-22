-module(erlang_secrets_config).

-export([counter_bound/0]).

-spec counter_bound() -> integer().
counter_bound() ->
    10000000.
