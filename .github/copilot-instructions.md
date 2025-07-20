# KidsMedia - AI Coding Agent Instructions

## Project Overview
KidsMedia is a Phoenix LiveView application that provides an immersive, kid-friendly interface for exploring educational content about animals. The app fetches images from Unsplash API and is designed for fullscreen, distraction-free experiences.

## Architecture

### Core Components
- **`lib/kids_media/unsplash.ex`**: External API integration for fetching animal images
- **`lib/kids_media_web/live/home.ex`**: Subject selection page with large, kid-friendly buttons  
- **`lib/kids_media_web/live/subject.ex`**: Fullscreen subject display with image galleries
- **`lib/kids_media_web/components/layouts/fullscreen.html.heex`**: Custom layout for immersive experiences

### Key Patterns

**Fullscreen Layout System**: Both home and subject pages use a custom fullscreen layout (`{KidsMediaWeb.Layouts, :fullscreen}`) set via `assign(:root_layout, ...)` in mount/3. This bypasses the default app header/footer for immersive viewing.

**External API Integration**: The `KidsMedia.Unsplash` module follows a simple pattern:
```elixir
def search!(query) do
  # Fetch from API, decode JSON, extract URLs
  # Always returns list of image URLs or raises
end
```

**LiveView Hooks**: Uses `phx-hook="Fullscreen"` with JavaScript hook in `assets/js/app.js` that automatically triggers fullscreen mode after DOM patching.

## Development Workflow

**Setup**: Run `mix setup` (installs deps, sets up assets)
**Environment**: Copy `.env.example` to `.env` and configure API keys
**Start**: `source .env && mix phx.server` or `source .env && iex -S mix phx.server` for console access
**Assets**: Tailwind + esbuild configured, auto-rebuild in dev

### Environment Variable Considerations
- **Local Development**: If `UNSPLASH_ACCESS_KEY` is not set in your shell environment, prefix mix commands with `source .env &&` 
- **GitHub Codespaces**: Environment variables are typically pre-configured, so `source .env &&` is usually not needed
- **Coding Agent/CI**: Environment variables are set via secrets, so `source .env &&` is not needed
- **When in doubt**: Try the command without the prefix first; if you get an "environment variable UNSPLASH_ACCESS_KEY is missing" error, then use `source .env &&`

## PR Validation & CI Checks

**IMPORTANT**: Before completing any changes, ALWAYS verify that all PR checks pass locally to ensure code quality and prevent CI failures.

### Required Validation Steps
Run these commands in order to validate changes match PR requirements (prefix with `source .env &&` if needed):

1. **Compilation**: `mix compile --warnings-as-errors`
2. **Code Formatting**: `mix format --check-formatted` (or `mix format` to auto-fix)
3. **Tests**: `mix test --color`
4. **Static Analysis**: `mix credo --strict`
5. **Security Check**: `mix sobelow --skip`
6. **Assets Build**: `mix assets.setup && mix assets.build`

### Quick Validation Command
Use the CI alias for comprehensive checks: `mix ci`

### PR Workflow Compliance
- All compilation must complete without warnings
- Code must be properly formatted (use `mix format` if needed)
- All tests must pass
- Credo and Sobelow checks should complete (warnings acceptable but not errors)
- Assets must build successfully

### Best Practices
- Run `mix test --cover` for test coverage validation (minimum 80% required)
- Check `mix coveralls.html` for detailed coverage reports
- Use `mix test.watch` during development for continuous testing
- Validate assets with `mix assets.build --minify` for production readiness

## Configuration Specifics

**Content Security Policy**: Custom CSP in `endpoint.ex` allows Unsplash images and YouTube embeds:
```elixir
"default-src 'self'; img-src 'self' https://images.unsplash.com; frame-src https://www.youtube-nocookie.com; script-src 'self' 'unsafe-inline'"
```

**API Keys**: Unsplash access key configured via environment variable `UNSPLASH_ACCESS_KEY`. See `.env.example` for setup.

## LiveView Conventions

- Use `assigns(:root_layout, {KidsMediaWeb.Layouts, :fullscreen})` for immersive pages
- Subject LiveViews should set `page_title` assign for proper browser titles
- Images are lazy-loaded with `loading="lazy"`
- Navigation uses `push_navigate(socket, to: ~p"/subject/#{topic}")` pattern

## Styling Approach
Tailwind CSS with kid-friendly aesthetics:
- Large buttons with emoji (`text-5xl font-bold bg-yellow-400 px-20 py-12`)
- Black backgrounds for fullscreen content (`bg-black text-white`)
- Responsive image grids (`flex flex-wrap justify-center gap-4`)

## PRP (Product Requirements Document) Workflow

The project uses a structured PRP approach for feature implementation to ensure high-quality, well-documented development.

### Creating PRPs
Use `.github/chatmodes/create-prp.chatmode.md` to generate comprehensive PRPs:

1. **Research Phase**: Analyze codebase patterns, external documentation, and implementation examples
2. **Context Gathering**: Include all necessary documentation, code examples, and gotchas
3. **Implementation Blueprint**: Provide pseudocode, task lists, and validation gates
4. **Quality Validation**: Ensure PRPs include executable validation commands

**PRP Template**: Use `PRPs/templates/prp_base.md` as the foundation for all PRPs
**Storage**: Save PRPs as `PRPs/{feature-name}.md`

### Executing PRPs
Use `.github/chatmodes/execute-prp.chatmode.md` to implement features from PRPs:

1. **Load PRP**: Read and understand all context and requirements
2. **Plan**: Break down complex tasks using comprehensive planning
3. **Execute**: Implement following the PRP guidance
4. **Validate**: Run all validation commands and fix failures iteratively
5. **Complete**: Ensure all checklist items are done

### PRP Best Practices
- Include all necessary context for one-pass implementation success
- Reference existing codebase patterns and conventions
- Provide executable validation gates (mix ci, mix test, etc.)
- Document error handling strategies and gotchas
- Score PRPs 1-10 for implementation confidence

## Notes
- YouTube integration is planned but not yet implemented (see commented code in subject.ex)
- Assets are processed via esbuild/tailwind, not Node.js package manager
- Application is designed for touch interfaces and accessibility
