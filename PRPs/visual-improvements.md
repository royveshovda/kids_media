# Visual Improvements PRP - KidsMedia UI Enhancement

name: "Visual Improvements PRP - Unified Fullscreen Experience"
description: |
  Transform KidsMedia's visual design for a more immersive, kid-friendly experience by:
  1. Making the home page a single unified color instead of white background with blue box
  2. Adding home and GitHub links to the same fullscreen area  
  3. Making the carousel view completely fullscreen with minimal UI distractions

## Purpose
Enhance the visual appeal and immersive experience of KidsMedia by creating a cohesive fullscreen design that eliminates visual distractions and provides a seamless kid-friendly interface.

## Core Principles
- **Immersive Experience**: Remove visual boundaries and distractions
- **Kid-Friendly Design**: Large, bold, accessible interface elements
- **Consistent Visual Language**: Unified color scheme and layout approach
- **Minimal UI in Focus Mode**: Hide unnecessary controls during carousel viewing

## Goal
Create a visually cohesive, fullscreen experience where:
1. Home page uses a single background color with integrated navigation
2. Carousel mode maximizes image viewing with only essential controls visible
3. All interactions feel seamless and kid-appropriate

## Why
The current design has visual inconsistencies:
- White background with blue box creates visual boundaries
- Navigation elements feel disconnected from the main content
- Carousel mode shows too many controls, reducing focus on content
- The design doesn't fully utilize the fullscreen potential

## What
**Home Page Improvements:**
- Replace `bg-sky-100` background with a unified fullscreen blue design
- Integrate home and GitHub links into the same blue container
- Maintain large, kid-friendly button design
- Ensure navigation feels part of the main interface

**Carousel Improvements:**
- Hide navigation buttons (prev/next/close) during carousel viewing
- Keep only play/pause button and interval slider visible
- Maximize image size to fill entire screen
- Minimize UI chrome for distraction-free viewing

## All Needed Context

### Documentation & References

```yaml
- file: lib/kids_media_web/live/home.ex
  why: Current home page implementation with bg-sky-100 and button styling
  
- file: lib/kids_media_web/live/subject.ex  
  why: Carousel modal implementation with current control layout
  
- file: lib/kids_media_web/components/layouts/fullscreen.html.heex
  why: Base fullscreen layout already configured for black background
  
- file: lib/kids_media_web/components/layouts/app.html.heex
  why: Shows current header/navigation structure with home and GitHub links
  
- doc: https://tailwindcss.com/docs/background-color
  section: Background color utilities for unified design
  
- doc: https://tailwindcss.com/docs/display#hidden
  section: Show/hide utilities for conditional UI elements
```

### Current Codebase Context

**Home Page Structure:**
```elixir
# Current: White background with blue box effect
<div class="w-full h-full min-h-screen flex items-center justify-center bg-sky-100">
  <button class="text-5xl font-bold bg-yellow-400 px-20 py-12 rounded shadow-lg">
    🐆  Cheetahs
  </button>
</div>
```

**Carousel Modal Structure:**
```elixir
# Current: Full controls visible
<div class="fixed top-0 left-0 w-screen h-screen">
  <button class="absolute top-4 right-4">✕</button>  <!-- Close -->
  <button class="absolute left-4">⬅️</button>        <!-- Previous -->
  <button class="absolute right-4">➡️</button>       <!-- Next -->
  <div class="absolute bottom-6">                    <!-- Controls -->
    <button>⏸️ Pause</button>
    <input type="range" />
  </div>
</div>
```

**Navigation Context:**
```heex
<!-- From app.html.heex - current header structure -->
<header class="px-4 sm:px-6 lg:px-8">
  <div class="flex items-center justify-between border-b border-zinc-100 py-3">
    <a href="/">Home</a>
    <a href="https://github.com/royveshovda/kids_media">GitHub</a>
  </div>
</header>
```

### Known Gotchas & Considerations

```elixir
# Layout System: Both pages use fullscreen layout
assign(:root_layout, {KidsMediaWeb.Layouts, :fullscreen})

# Existing Fullscreen Hook: Already configured in assets/js/app.js
Hooks.Fullscreen = { mounted() { /* fullscreen logic */ } }

# Carousel State Management: Need to preserve existing functionality
@assigns: show_modal, carousel_active, current_image_index

# CSS Considerations: Tailwind classes already configured
# - bg-black (fullscreen layout body)
# - Various positioning classes (absolute, fixed)
# - Responsive utilities (sm:, lg:)
```

## Implementation Blueprint

### Data Models and Structure
No new data models needed. Working with existing assigns in LiveView components:
- `@show_modal`, `@carousel_active` for UI state
- `@images`, `@current_image_index` for content
- Layout assignments remain unchanged

### List of Tasks

```yaml
Task 1: Update Home Page Design
MODIFY lib/kids_media_web/live/home.ex:
  - FIND: 'class="w-full h-full min-h-screen flex items-center justify-center bg-sky-100"'
  - REPLACE: Create unified blue fullscreen design with integrated navigation
  - ADD: Home and GitHub navigation links within the same container
  - PRESERVE: Existing button styling and functionality

Task 2: Hide Carousel Navigation Controls  
MODIFY lib/kids_media_web/live/subject.ex:
  - FIND: Close button, prev/next buttons in modal
  - ADD: Conditional rendering based on @carousel_active state
  - PRESERVE: Play/pause button and interval slider
  - MAINTAIN: All existing event handlers and functionality

Task 3: Maximize Image Display
MODIFY lib/kids_media_web/live/subject.ex:
  - FIND: 'class="max-w-[90vw] max-h-[90vh]"' on carousel image
  - REPLACE: Use larger viewport dimensions for carousel mode
  - CONDITIONAL: Different sizing based on @carousel_active
  - PRESERVE: Non-carousel modal behavior
```

### Task 1 Pseudocode

```elixir
# Home page visual redesign
def render(assigns) do
  ~H"""
  <div class="w-full h-full min-h-screen bg-blue-500 text-white">
    <!-- Integrated Navigation -->
    <nav class="absolute top-4 left-0 right-0 flex justify-between px-8">
      <a href="/" class="text-white hover:text-blue-200">🏠 Home</a>
      <a href="https://github.com/..." class="text-white hover:text-blue-200">📚 GitHub</a>
    </nav>
    
    <!-- Main Content Area -->
    <div class="flex items-center justify-center h-full pt-16">
      <button class="text-5xl font-bold bg-yellow-400 text-blue-900 px-20 py-12 rounded-xl shadow-2xl hover:bg-yellow-300 transition-all">
        🐆 Cheetahs
      </button>
    </div>
  </div>
  """
end
```

### Task 2 & 3 Pseudocode

```elixir
# Conditional UI rendering for carousel
<%= if @show_modal do %>
  <div class="fixed top-0 left-0 w-screen h-screen ...">
    
    <!-- Hide these during active carousel -->
    <%= unless @carousel_active do %>
      <button class="absolute top-4 right-4">✕</button>
      <button class="absolute left-4">⬅️</button>
      <button class="absolute right-4">➡️</button>
    <% end %>
    
    <!-- Dynamic image sizing -->
    <img 
      src={...}
      class={if @carousel_active, 
              do: "max-w-[95vw] max-h-[95vh] object-contain", 
              else: "max-w-[90vw] max-h-[90vh] object-contain"}
    />
    
    <!-- Always show: play/pause and slider -->
    <div class="absolute bottom-6 left-1/2 transform -translate-x-1/2">
      <!-- Existing controls -->
    </div>
  </div>
<% end %>
```

### Integration Points

```yaml
LAYOUTS:
  - file: lib/kids_media_web/components/layouts/fullscreen.html.heex
  - action: No changes needed (already configured)
  
STYLES:
  - file: assets/css/app.css  
  - action: Potential custom styles if needed (unlikely with Tailwind)
  
JAVASCRIPT:
  - file: assets/js/app.js
  - action: No changes needed to existing hooks
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Format and lint check
mix format --check-formatted
mix credo --strict

# Expected: No errors, clean formatting
# If errors: Fix syntax issues, follow existing patterns
```

### Level 2: Unit Tests

```bash
# Run existing tests to ensure no regressions
mix test

# Test specific LiveView rendering
mix test test/kids_media_web/live/home_test.exs
mix test test/kids_media_web/live/subject_test.exs

# Expected: All tests pass, new elements render correctly
```

### Level 3: Integration Test

```bash
# Start the application
source .env && mix phx.server

# Manual verification:
# 1. Visit http://localhost:4000 - should see unified blue design
# 2. Click Cheetahs button - should navigate properly  
# 3. Click image to open modal - controls should be visible
# 4. Start carousel - nav buttons should hide, only play/pause visible
# 5. Stop carousel - all controls should return

# Expected: Smooth transitions, no JavaScript errors, responsive design
```

## Final Validation Checklist

- [ ] Home page has unified blue background without white container
- [ ] Navigation links are integrated into the main design
- [ ] Cheetah button maintains prominence and functionality
- [ ] Carousel mode hides prev/next/close buttons
- [ ] Play/pause and interval slider remain visible in carousel
- [ ] Images display larger in carousel mode
- [ ] Non-carousel modal behavior is preserved
- [ ] All existing functionality works unchanged
- [ ] Design is responsive and kid-friendly
- [ ] No console errors in browser

## Anti-Patterns to Avoid

- **Don't break existing functionality**: Preserve all event handlers and state management
- **Don't remove accessibility**: Maintain keyboard navigation and screen reader compatibility  
- **Don't hardcode colors**: Use Tailwind utilities for maintainability
- **Don't over-engineer**: Simple conditional rendering, no complex state changes
- **Don't forget mobile**: Ensure design works on touch devices
- **Don't ignore performance**: Conditional rendering shouldn't impact performance

## Confidence Score: 9/10

High confidence due to:
- Clear visual requirements and existing codebase understanding
- Well-defined conditional rendering patterns already in use
- Simple CSS/styling changes using established Tailwind utilities
- Existing fullscreen layout foundation already working
- No complex state management or external API changes required

The main risk is ensuring mobile responsiveness and maintaining accessibility, but these are addressable through testing and following existing patterns in the codebase.
