-module(erlang_secrets_keygen).

-export([key/1]).

key(Counter) ->
    TimestampMicro = erlang:system_time(microsecond),
    crypto:hash(md5,
                [integer_to_binary(Counter),
                 atom_to_list(node()),
                 integer_to_binary(TimestampMicro)]).
