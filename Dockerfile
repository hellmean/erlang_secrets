# Build state 0
FROM openapitools/openapi-generator:cli-6.0.x

COPY swagger.yml swagger.yml
RUN java -jar openapi-generator-cli.jar generate -i swagger.yml -g html2 -o / 

# Build stage 1
FROM erlang:23-alpine

# Set working directory
RUN mkdir /buildroot
WORKDIR /buildroot

# Copy our Erlang test application
COPY . erlang_secrets

RUN apk add git
RUN apk add --update alpine-sdk
# And build the release
WORKDIR erlang_secrets
RUN rebar3 as prod release

# Build stage 2
FROM erlang:23-alpine

# Install some libs
RUN apk add --no-cache openssl && \
    apk add --no-cache ncurses-libs

RUN apk add --update alpine-sdk
# Install the released application
COPY --from=0 /index.html /erlang_secrets/index.html
COPY --from=1 /buildroot/erlang_secrets/_build/prod/rel/erlang_secrets /erlang_secrets

# Expose relevant ports
EXPOSE 8080
EXPOSE 8443

CMD ["/erlang_secrets/bin/erlang_secrets", "foreground"]
