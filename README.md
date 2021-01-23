# erlang_secrets

A simple api to exchange secrets using one time links. Implemented using erlang and cowboy http server.

A stored secret can be retrieved once using a generated key.

This service is meant to be used with a https reverse proxy.

You don't need to know erlang or install any dependencies to use this service. All you need is docker.

Use `docker build -t erlang_secrets:latest .` to create a docker image that can be used for deployment.

The server listens on 8080 tcp port by default. The same port is exposed in the Dockerfile.

After the build you can run the service locally with `docker run -p 127.0.0.1:8081:8080/tcp erlang_secrets:latest`. That way the service will be available on port 8081 of your local host. And you can access the OpenAPI documentation via http://localhost:8081/