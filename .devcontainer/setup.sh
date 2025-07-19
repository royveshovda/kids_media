#!/bin/bash

# Codespaces-specific setup for KidsMedia
set -e

echo "🚀 Setting up KidsMedia for GitHub Codespaces..."

# Install hex and rebar
mix local.hex --force
mix local.rebar --force

# Install Phoenix
mix archive.install hex phx_new --force

# Navigate to workspace and setup project
cd /workspaces/kids_media

# Install dependencies
mix deps.get

# Compile project
mix compile

# Install and setup assets
mix assets.setup

echo "✅ KidsMedia setup complete!"
echo "🔥 Ready to develop! Run 'source .env && mix phx.server' to start."
