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

## Notes
- YouTube integration is planned but not yet implemented (see commented code in subject.ex)
- Assets are processed via esbuild/tailwind, not Node.js package manager
- Application is designed for touch interfaces and accessibility
