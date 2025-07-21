# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KidsMedia is a Phoenix LiveView application that provides an immersive, kid-friendly interface for exploring educational content about animals. The app fetches images from Unsplash API and is designed for fullscreen, distraction-free experiences.

## Core Architecture

### Key Modules

- **`lib/kids_media/unsplash.ex`**: External API integration for fetching animal images
- **`lib/kids_media_web/live/home.ex`**: Subject selection page with large, kid-friendly buttons  
- **`lib/kids_media_web/live/subject.ex`**: Fullscreen subject display with image galleries
- **`lib/kids_media_web/components/layouts/fullscreen.html.heex`**: Custom layout for immersive experiences

### Architectural Patterns

**Fullscreen Layout System**: Both home and subject pages use a custom fullscreen layout (`{KidsMediaWeb.Layouts, :fullscreen}`) set via `assign(:root_layout, ...)` in mount/3. This bypasses the default app header/footer for immersive viewing.

**External API Integration**: The `KidsMedia.Unsplash` module follows this pattern:

```elixir
def search!(query) do
  # Fetch from API, decode JSON, extract URLs
  # Always returns list of image URLs or raises
end
```

**LiveView Hooks**: Uses `phx-hook="Fullscreen"` with JavaScript hook in `assets/js/app.js` that automatically triggers fullscreen mode after DOM patching.

## Development Commands

### Setup and Development

```bash
# Initial setup - installs deps, sets up assets
mix setup

# Start development server (with environment variables)
source .env && mix phx.server

# Start with IEx console access
source .env && iex -S mix phx.server
```

### Environment Variables

- **Local Development**: If `UNSPLASH_ACCESS_KEY` is not set, prefix commands with `source .env &&`
- **GitHub Codespaces**: Environment variables are pre-configured, `source .env &&` usually not needed
- **When in doubt**: Try without prefix first; if you get "environment variable missing" error, then use `source .env &&`

### Testing

```bash
# Run all tests
mix test

# Run tests with coverage (minimum 80% required)
mix test --cover

# Generate detailed coverage report
mix coveralls.html

# Watch mode for development
mix test.watch

# Run specific test file
mix test test/kids_media_web/live/home_live_test.exs
```

### Code Quality and CI Validation

**CRITICAL**: Always run these commands before completing changes to ensure PR compliance:

```bash
# Quick comprehensive validation
mix ci

# Individual validation steps:
mix compile --warnings-as-errors
mix format --check-formatted  # or mix format to auto-fix
mix test --color
mix credo --strict
mix sobelow --skip
mix assets.setup && mix assets.build
```

### Asset Management

```bash
# Setup assets (installs Tailwind/esbuild if missing)
mix assets.setup

# Build assets for development
mix assets.build

# Build minified assets for production
mix assets.deploy
```

## Configuration

### Content Security Policy

Custom CSP in `endpoint.ex` allows Unsplash images and YouTube embeds:

```elixir
"default-src 'self'; img-src 'self' https://images.unsplash.com; frame-src https://www.youtube-nocookie.com; script-src 'self' 'unsafe-inline'"
```

### Environment Variables for configuration

- `UNSPLASH_ACCESS_KEY`: Required for image fetching. See `.env.example` for setup.

## LiveView Conventions

- Use `assign(:root_layout, {KidsMediaWeb.Layouts, :fullscreen})` for immersive pages
- Subject LiveViews should set `page_title` assign for proper browser titles
- Images are lazy-loaded with `loading="lazy"`
- Navigation uses `push_navigate(socket, to: ~p"/subject/#{topic}")` pattern

## Test Structure

### Test Types

1. **Unit Tests** (`test/kids_media/`) - Individual modules in isolation
2. **LiveView Tests** (`test/kids_media_web/live/`) - Phoenix LiveView components
3. **Integration Tests** (`test/kids_media_web/integration_test.exs`) - End-to-end functionality
4. **Smoke Tests** (`test/kids_media_web/smoke_test.exs`) - Basic health checks

### Mocking Strategy

External API calls (Unsplash) are mocked using configurable modules to avoid network dependencies and ensure fast, reliable tests.

## Styling Approach

Tailwind CSS with kid-friendly aesthetics:

- Large buttons with emoji (`text-5xl font-bold bg-yellow-400 px-20 py-12`)
- Black backgrounds for fullscreen content (`bg-black text-white`)
- Responsive image grids (`flex flex-wrap justify-center gap-4`)

## PRP Workflow (Product Requirements Document)

**CRITICAL**: Always follow the structured PRP approach: **Plan → Create PRP → Execute PRP**

This project uses a rigorous PRP workflow to ensure high-quality, well-documented feature development with one-pass implementation success.

### Creating PRPs

Use the comprehensive research and documentation process to create detailed PRPs:

#### Research Process

1. **Codebase Analysis**
   - Search for similar features/patterns in the codebase
   - Identify files to reference in PRP (`lib/kids_media/`, `lib/kids_media_web/`)
   - Note existing conventions to follow (LiveView patterns, API integration, testing approaches)
   - Check test patterns in `test/` directory for validation approach

2. **External Research**
   - Search for similar features/patterns online
   - Library documentation (include specific URLs for Phoenix LiveView, HTTPoison, etc.)
   - Implementation examples (GitHub/StackOverflow/blogs)
   - Best practices and common pitfalls

3. **Context Gathering** (CRITICAL for AI success)
   - Include ALL necessary documentation, code examples, and gotchas
   - Reference existing patterns from `lib/kids_media/unsplash.ex`, LiveView components
   - Document library quirks (HTTPoison supervision, rate limiting, timeouts)
   - Include validation commands and expected outcomes

#### PRP Template Usage

- Use `PRPs/templates/prp_base.md` as foundation for all PRPs
- Include executable validation gates (`mix ci`, `mix test`, specific test commands)
- Reference existing codebase patterns and conventions
- Provide pseudocode with critical implementation details
- Document error handling strategies and integration points

#### PRP Storage and Quality

- Save PRPs as `PRPs/{feature-name}.md`
- Score PRPs 1-10 for implementation confidence
- Ensure all necessary context is included for one-pass success
- Include specific file modifications and creation tasks
- Provide clear implementation path with validation loops

### Executing PRPs

Follow the structured execution process for reliable implementation:

#### 1. Load PRP

- Read the specified PRP file completely
- Understand all context and requirements
- Follow all instructions in the PRP
- Extend research if needed using web searches and codebase exploration
- Ensure all needed context is available

#### 2. Plan (ULTRATHINK)

- Think comprehensively before executing
- Use TodoWrite tool to create and track implementation plan
- Break down complex tasks into smaller, manageable steps
- Identify implementation patterns from existing code to follow
- Plan validation approach using existing CI commands

#### 3. Execute

- Implement all code following PRP specifications
- Follow existing patterns (LiveView conventions, API integration, testing structure)
- Use established patterns from `lib/kids_media/unsplash.ex` for external API calls
- Maintain kid-friendly design principles and accessibility considerations

#### 4. Validate

- Run each validation command specified in PRP
- Use existing CI pipeline: `mix ci` for comprehensive checks
- Fix any failures iteratively
- Re-run until all validation gates pass
- Ensure minimum 80% test coverage maintained

#### 5. Complete

- Ensure all checklist items are completed
- Run final validation suite
- Reference the PRP again to ensure everything is implemented
- Report completion status with validation results

### PRP Best Practices

#### Quality Standards

- Include executable validation commands (`mix ci`, `mix test --cover`)
- Reference existing codebase patterns consistently
- Document error handling strategies and gotchas
- Provide clear implementation path with pseudocode
- Score implementation confidence 1-10

#### Integration with Existing Workflow

- Connect PRP validation gates to existing CI commands section
- Use established test patterns and coverage requirements
- Follow LiveView conventions and architectural patterns
- Maintain consistency with styling approach and accessibility requirements

## Important Notes

- YouTube integration is planned but not yet implemented (see commented code in subject.ex)
- Assets are processed via esbuild/tailwind, not Node.js package manager
- Application is designed for touch interfaces and accessibility
- All compilation must complete without warnings for PR approval
- Code must be properly formatted using `mix format`
- Minimum 80% test coverage required
