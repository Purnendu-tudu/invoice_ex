# ========================
# 1. Build Stage
# ========================
FROM hexpm/elixir:1.17.3-erlang-27.1.2-debian-bullseye-20241111-slim AS build

# Install build tools (note: git and curl are often not needed unless you pull private repos)
RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install hex and rebar
RUN mix local.hex --force && mix local.rebar --force

WORKDIR /app

# Copy mix files first (cache deps)
COPY mix.exs mix.lock ./
COPY config config/

# Get and Compile Dependencies
RUN mix deps.get --only prod
RUN mix deps.compile

# Build and Deploy Assets (CRITICAL CHANGE HERE)
COPY assets assets
RUN npm --prefix ./assets install
# Use the official Phoenix deploy task which runs esbuild and creates the digest
RUN MIX_ENV=prod mix assets.deploy

# Copy the rest of the application
COPY . .

# Compile the application code
RUN MIX_ENV=prod mix compile

# Build Phoenix release
RUN MIX_ENV=prod mix release

# ========================
# 2. Runtime Stage
# ========================
# Using bookworm-slim is good practice for a small final image
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies needed for Erlang/Elixir and your release
RUN apt-get update && apt-get install -y \
    openssl \
    libncurses6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy release
COPY --from=build /app/_build/prod/rel/invoice ./

# Runtime ENV
ENV HOME=/app
ENV MIX_ENV=prod
# PHX_SERVER=true is handled by the 'server' script created by mix phx.gen.release
ENV PORT=4000 

# The CMD should just be the start command, or a script that runs migrations then starts.
# For Render, you will typically use a separate Start Command in the UI.
CMD ["/app/bin/invoice", "start"] 

# If you need migrations in the CMD (which is less flexible for Render):
# CMD ["/app/bin/invoice", "migrate"] && ["/app/bin/invoice", "start"]