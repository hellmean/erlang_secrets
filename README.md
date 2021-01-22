# erlang_secrets

A simple api to store secrets for one time retrieval. Implemented using erlang and cowboy http server.

A stored secret can be retrieved once using generated key.

This service is meant to be used with a https proxy.

Use `docker build .` to create a linux docker image that can be used for deployment.