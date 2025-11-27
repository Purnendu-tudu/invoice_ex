# ========================
# 1. Build Stage
# ========================
FROM hexpm/elixir:1.17.3-erlang-27.1-debian-bookworm-20240812 AS build

# Install build tools
RUN apt-get update && apt-get install -y build-essential git nodejs npm

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# Copy mix files first (cache deps)
COPY mix.exs mix.lock ./
COPY config config/

RUN mix deps.get --only prod
RUN mix deps.compile

# Copy assets
COPY assets assets
RUN npm --prefix ./assets install
RUN npm --prefix ./assets run build

# Copy the whole project
COPY . .

RUN MIX_ENV=prod mix compile

# Build Phoenix release
RUN MIX_ENV=prod mix release

# ========================
# 2. Runtime Stage
# ========================
FROM debian:bookworm-20240812-slim AS runtime

RUN apt-get update && apt-get install -y openssl libstdc++6

WORKDIR /app

COPY --from=build /app/_build/prod/rel/* ./

# Runtime ENV
ENV HOME=/app
ENV MIX_ENV=prod
ENV PHX_SERVER=true

CMD ["bin/invoice", "start"]
