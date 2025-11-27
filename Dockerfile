# 1. Build stage
FROM hexpm/elixir:1.17.2-erlang-27.0-debian-bookworm-20240612 AS build

RUN apt-get update && apt-get install -y build-essential git nodejs npm

WORKDIR /app

# Install Hex + Rebar
RUN mix local.hex --force && mix local.rebar --force

# Copy project files
COPY . .

# Install deps
RUN mix deps.get
RUN npm install --prefix assets
RUN npm run build --prefix assets
RUN MIX_ENV=prod mix release

# 2. Run stage
FROM debian:bookworm-slim AS app
RUN apt-get update && apt-get install -y openssl libncurses5 locales && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8

WORKDIR /app

COPY --from=build /app/_build/prod/rel/* ./

ENV PHX_SERVER=true

CMD ["bin/invoice", "start"]
