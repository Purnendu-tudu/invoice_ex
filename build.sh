#!/usr/bin/env bash
# Exit immediately if a command exits with a non-zero status.
set -o errexit

# Initial Setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile Assets
npm install --prefix ./assets
# Runs esbuild/tailwind and creates the digest manifest
MIX_ENV=prod mix assets.deploy

# Build the Release
MIX_ENV=prod mix release --overwrite