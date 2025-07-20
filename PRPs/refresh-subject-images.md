# PRP: Refresh Subject Images Feature

## Overview

Add the ability to refresh/reload the images displayed for a subject without navigating away from the page or reloading the entire page. This will provide users with fresh image results for the same animal topic.

## Context Analysis

### Current Implementation

The KidsMedia application currently:

- Fetches images on mount via `KidsMedia.Unsplash.search!/1` in `SubjectLive.mount/3`
- Displays images in a responsive grid layout with modal viewing and carousel functionality
- Uses Phoenix LiveView for real-time UI updates
- The Unsplash module already has built-in randomness strategies for varied results

### Key Files Referenced

- **Primary**: `lib/kids_media_web/live/subject.ex` - Main subject view with image handling
- **API Layer**: `lib/kids_media/unsplash.ex` - Image fetching with randomness features
- **Tests**: `test/kids_media_web/live/subject_live_test.exs` - Test patterns to follow
- **Mock**: `lib/kids_media/unsplash_mock.ex` - For testing scenarios

### Existing Patterns

The codebase follows these established patterns:

- Handle events with `handle_event/3` callbacks
- Use `assign/3` to update socket state
- Large, kid-friendly buttons with emoji and descriptive text
- Error handling via try-catch or graceful fallbacks
- Consistent button styling: `bg-color-500 hover:bg-color-600 text-white font-bold py-3 px-6 rounded-lg text-lg`

## Requirements

### Functional Requirements

1. **Refresh Button**: Add a prominent "🔄 Get New Images" button to the subject view
2. **Image Reload**: Clicking the button should fetch fresh images from Unsplash API
3. **State Management**: Preserve carousel settings and modal state during refresh
4. **Loading State**: Show loading indicator while fetching new images
5. **Error Handling**: Gracefully handle API failures with user feedback
6. **Accessibility**: Button should be keyboard accessible and screen reader friendly

### Non-Functional Requirements

1. **Performance**: Refresh should complete within 3 seconds under normal conditions
2. **User Experience**: Loading state should be clear and non-disruptive
3. **Reliability**: Fallback to existing images if API call fails
4. **Consistency**: Follow existing UI patterns and styling

## Technical Implementation

### API Integration

The `KidsMedia.Unsplash.search!/1` function already provides built-in randomness through:

- 70%/30% split between search and random endpoints
- Random query enhancement with descriptive terms
- Result shuffling for variety
- Multiple ordering strategies

**Reference Code** (`lib/kids_media/unsplash.ex:37-42`):

```elixir
def search!(query) do
  # Randomly choose between search strategies for more variety
  if :rand.uniform() > 0.3 do
    search_with_randomness(query)
  else
    random_photos(query)
  end
end
```

### LiveView Implementation Pattern

Follow the existing event handling pattern in `SubjectLive`:

**Reference Pattern** (`lib/kids_media_web/live/subject.ex:23-26`):

```elixir
def handle_event("open_modal", %{"index" => index}, socket) do
  index = String.to_integer(index)
  {:noreply, assign(socket, show_modal: true, current_image_index: index)}
end
```

### UI Integration

Position the refresh button near the carousel controls for logical grouping:

**Reference Location** (`lib/kids_media_web/live/subject.ex:87-95`):

```heex
<!-- Carousel controls -->
<div class="mb-4 flex flex-col items-center gap-4">
  <button phx-click="start_carousel" type="button" class="...">
    🎠 Start Carousel
  </button>
  <!-- ADD REFRESH BUTTON HERE -->
</div>
```

## Implementation Tasks

### Task 1: Add refresh_images handle_event

- **File**: `lib/kids_media_web/live/subject.ex`
- **Location**: After existing handle_event functions (line ~75)
- **Purpose**: Handle refresh button clicks with loading state and error handling

```elixir
def handle_event("refresh_images", _params, socket) do
  topic = socket.assigns.topic
  
  socket = 
    socket
    |> assign(loading_images: true, error_message: nil)
  
  try do
    unsplash_module = Application.get_env(:kids_media, :unsplash_module, KidsMedia.Unsplash)
    new_images = unsplash_module.search!("#{topic} animal")
    
    {:noreply, 
     socket
     |> assign(images: new_images, loading_images: false, current_image_index: 0)
     |> put_flash(:info, "Images refreshed!")}
  rescue
    error ->
      {:noreply, 
       socket
       |> assign(loading_images: false, error_message: "Failed to load new images")
       |> put_flash(:error, "Unable to refresh images. Please try again.")}
  end
end
```

### Task 2: Update mount to initialize loading state

- **File**: `lib/kids_media_web/live/subject.ex`
- **Location**: In mount function assigns (line ~17)
- **Purpose**: Initialize loading_images and error_message state

```elixir
|> assign(
  show_modal: false,
  current_image_index: 0,
  carousel_active: false,
  carousel_interval: 3,
  loading_images: false,  # ADD THIS
  error_message: nil      # ADD THIS
)}
```

### Task 3: Add refresh button to UI

- **File**: `lib/kids_media_web/live/subject.ex`
- **Location**: In carousel controls section (line ~87)
- **Purpose**: Provide user interface for refresh functionality

```heex
<button
  phx-click="refresh_images"
  type="button"
  disabled={@loading_images}
  class={[
    "font-bold py-3 px-6 rounded-lg text-lg",
    if(@loading_images,
      do: "bg-blue-300 text-gray-600 cursor-not-allowed",
      else: "bg-blue-500 hover:bg-blue-600 text-white"
    )
  ]}
>
  <%= if @loading_images do %>
    ⏳ Loading...
  <% else %>
    🔄 Get New Images
  <% end %>
</button>
```

### Task 4: Add error message display

- **File**: `lib/kids_media_web/live/subject.ex`
- **Location**: After the header (line ~85)
- **Purpose**: Show error messages when refresh fails

```heex
<%= if @error_message do %>
  <div class="mb-4 bg-red-500 text-white px-4 py-2 rounded-lg">
    {@error_message}
  </div>
<% end %>
```

### Task 5: Add comprehensive tests

- **File**: `test/kids_media_web/live/subject_live_test.exs`
- **Location**: New describe block after existing tests
- **Purpose**: Ensure refresh functionality works correctly

```elixir
describe "Image refresh functionality" do
  test "refresh_images event fetches new images", %{conn: conn} do
    # Test successful refresh
  end
  
  test "refresh_images shows loading state", %{conn: conn} do
    # Test loading UI state
  end
  
  test "refresh_images handles errors gracefully", %{conn: conn} do
    # Test error handling
  end
  
  test "refresh button is disabled during loading", %{conn: conn} do
    # Test button state during loading
  end
end
```

### Task 6: Update unsplash mock for testing

- **File**: `lib/kids_media/unsplash_mock.ex`
- **Location**: Add test helper functions
- **Purpose**: Support testing different scenarios

## Error Handling Strategy

### API Failure Scenarios

1. **Network timeout**: Maintain existing images, show flash message
2. **API rate limit**: Fallback to existing images, inform user to try later
3. **Invalid response**: Keep current images, log error, show user-friendly message
4. **No results**: Keep existing images, inform user no new images available

### Implementation Pattern

```elixir
try do
  # API call
rescue
  HTTPoison.Error ->
    # Network error handling
  Jason.DecodeError ->
    # JSON parsing error handling
  _ ->
    # Generic error fallback
end
```

## Validation Gates

### Pre-Implementation Checks

```bash
# Verify current system works
mix test test/kids_media_web/live/subject_live_test.exs
mix compile --warnings-as-errors
```

### Post-Implementation Validation

```bash
# Full validation suite
mix ci

# Specific checks
mix test test/kids_media_web/live/subject_live_test.exs
mix credo --strict
mix format --check-formatted
```

### Manual Testing Checklist

- [ ] Refresh button appears and is styled correctly
- [ ] Button shows loading state when clicked
- [ ] New images load successfully
- [ ] Error handling works with network disconnected
- [ ] Modal and carousel state preserved during refresh
- [ ] Flash messages appear appropriately
- [ ] Button is keyboard accessible
- [ ] Works with both real API and mock

## Documentation References

- **Phoenix LiveView Documentation**: <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html>
- **LiveView Event Handling**: <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#handle_event/3>
- **Phoenix Flash Messages**: <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#put_flash/3>
- **LiveView Testing**: <https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html>

## Success Criteria

### Definition of Done

1. ✅ Refresh button added to subject view with proper styling
2. ✅ Button triggers image reload without page refresh
3. ✅ Loading state displayed during API call
4. ✅ Error handling with user feedback implemented
5. ✅ Modal and carousel state preserved during refresh
6. ✅ Comprehensive tests added and passing
7. ✅ All CI checks pass (mix ci)
8. ✅ Manual testing checklist completed
9. ✅ No existing functionality broken

### Performance Targets

- Refresh completes within 3 seconds (normal conditions)
- No memory leaks or state corruption
- Graceful degradation on API failures

## Risk Assessment & Mitigation

### High Risk

- **API Rate Limiting**: Mitigated by preserving existing images on failure
- **State Corruption**: Mitigated by careful socket assign management

### Medium Risk

- **Loading State Confusion**: Mitigated by clear UI indicators
- **Double-Click Issues**: Mitigated by disabling button during loading

### Low Risk

- **Styling Inconsistency**: Mitigated by following existing button patterns
- **Test Coverage**: Mitigated by comprehensive test suite

## Implementation Confidence Score: 9/10

**Rationale**: High confidence due to:

- Well-established LiveView patterns in codebase
- Existing Unsplash integration with randomness built-in
- Clear error handling patterns to follow
- Comprehensive test structure already in place
- Straightforward UI integration point identified

**Potential Issues**:

- API rate limiting (low probability, mitigated)
- State management during refresh (medium probability, well-documented solution)

The implementation follows established patterns in the codebase and leverages existing infrastructure, making it a low-risk, high-value feature addition.
