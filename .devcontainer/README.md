# KidsMedia Development Environment

This directory contains the devcontainer configuration for the KidsMedia Phoenix LiveView application, optimized for GitHub Codespaces.

## Quick Start

1. Open this repository in GitHub Codespaces or VS Code with Dev Containers extension
2. Wait for the container to build and setup (first time only, ~2-3 minutes)
3. Run `mix phx.server`
5. Open the forwarded port 4000 to view your application

## Performance Optimizations

This devcontainer is optimized for fast startup times:

- **Pre-built base image**: Uses official Elixir image with Erlang pre-installed
- **Volume caching**: Mix, Hex, deps, and build artifacts are cached across sessions
- **Pre-compiled dependencies**: Common Phoenix dependencies are pre-compiled during setup
- **Minimal extensions**: Only essential VS Code extensions for Elixir development

## VS Code Extensions Included

- **ElixirLS**: Language server for Elixir with IntelliSense and debugging
- **Phoenix Framework**: Phoenix-specific tooling
- **Tailwind CSS IntelliSense**: Autocomplete for Tailwind classes
- **Prettier**: Code formatting
- **JSON**: Enhanced JSON support

## Port Forwarding

- Port 4000: Phoenix development server (automatically forwarded)

## Troubleshooting

If you encounter any issues:

1. Rebuild the container: Command Palette → "Dev Containers: Rebuild Container"
2. Clear dependency cache: `mix deps.clean --all && mix deps.get`
3. Check the setup logs in the terminal during container creation
