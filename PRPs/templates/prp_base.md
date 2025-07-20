name: "Base PRP Template v1 - Context-Rich with Validation Loops"
description: |

## Purpose

Template optimized for AI agents to implement features with sufficient context and self-validation capabilities to achieve working code through iterative refinement.

## Core Principles

1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance
5. **Global rules**: Be sure to follow all rules in .github/copilot-instructions.md

---

## Goal

[What needs to be built - be specific about the end state and desires]

## Why

- [Business value and user impact]
- [Integration with existing features]
- [Problems this solves and for whom]

## What

[User-visible behavior and technical requirements]

### Success Criteria

- [ ] [Specific measurable outcomes]

## All Needed Context

### Documentation & References (list all context needed to implement the feature)

```yaml
# MUST READ - Include these in your context window
- url: [Official API docs URL]
  why: [Specific sections/methods you'll need]
  
- file: [path/to/example.ex]
  why: [Pattern to follow, gotchas to avoid]
  
- doc: [Library documentation URL] 
  section: [Specific section about common pitfalls]
  critical: [Key insight that prevents common errors]

- docfile: [PRPs/ai_docs/file.md]
  why: [docs that the user has pasted in to the project]

```

### Current Codebase tree (run `tree` in the root of the project) to get an overview of the codebase

```bash

```

### Desired Codebase tree with files to be added and responsibility of file

```bash

```

### Known Gotchas of our codebase & Library Quirks

```elixir

```

## Implementation Blueprint

### Data models and structure

Create the core data models, we ensure type safety and consistency.

```elixir

```

### list of tasks to be completed to fullfill the PRP in the order they should be completed

```yaml
Task 1:
MODIFY lib/existing_module.ex:
  - FIND pattern: "class OldImplementation"
  - INJECT after line containing "def __init__"
  - PRESERVE existing method signatures

CREATE lib/new_feature.ex:
  - MIRROR pattern from: lib/similar_feature.ex
  - MODIFY class name and core logic
  - KEEP error handling pattern identical

...(...)

Task N:
...

```

### Per task pseudocode as needed added to each task

```elixir
# Task 1
# Pseudocode with CRITICAL details dont write entire code
defp new_feature(param) when is_binary(param) do
  # PATTERN: Always validate input first (see lib/kids_media/validators.ex)
  {:ok, validated} = validate_input(param)  # returns {:error, reason} on failure
  
  # GOTCHA: HTTPoison requires proper supervision (see application.ex)
  case HTTPoison.get(url, headers(), [timeout: 30_000, recv_timeout: 30_000]) do
    # PATTERN: Use existing retry with exponential backoff
    {:error, %HTTPoison.Error{reason: :timeout}} ->
      # CRITICAL: Unsplash API rate limit is 50 req/hour for demo
      :timer.sleep(1000)  # Rate limiting between requests
      retry_request(validated, attempts - 1)
    
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
      # PATTERN: Standardized response format (see lib/kids_media/unsplash.ex)
      Jason.decode!(body) |> format_response()
    
    {:ok, %HTTPoison.Response{status_code: 429}} ->
      {:error, :rate_limited}
  end
end

# PATTERN: GenServer for connection pooling (if needed)
# CRITICAL: Use Task.async_stream/3 for concurrent requests, limit to 5
```

### Integration Points

```yaml
CONFIG:
  - add to: config/config.exs
  - pattern: "FEATURE_TIMEOUT = int(os.getenv('FEATURE_TIMEOUT', '30'))"
  
ROUTES:
  ```yaml
  ROUTES:
    - add to: lib/kids_media_web/router.ex
    - pattern: 'scope "/feature", KidsMediaWeb do pipe_through :browser live "/", FeatureLive, :index end'
  ```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
mix format
mix credo

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns

```elixir
# CREATE test/kids_media/new_feature_test.exs with these test cases:
defmodule KidsMedia.NewFeatureTest do
  use ExUnit.Case, async: true
  
  alias KidsMedia.NewFeature

  describe "new_feature/1" do
    test "happy path - basic functionality works" do
      # Basic functionality works
      assert {:ok, result} = NewFeature.new_feature("valid_input")
      assert result.status == "success"
    end

    test "validation error - invalid input returns error tuple" do
      # Invalid input returns error tuple (Elixir pattern)
      assert {:error, :validation_error} = NewFeature.new_feature("")
      assert {:error, :validation_error} = NewFeature.new_feature(nil)
    end

    test "external api timeout - handles timeouts gracefully" do
      # Mock external API call to simulate timeout
      with_mock HTTPoison, [:passthrough], [
        get: fn _url, _headers, _opts -> {:error, %HTTPoison.Error{reason: :timeout}} end
      ] do
        assert {:error, :timeout} = NewFeature.new_feature("valid_input")
      end
    end

    test "rate limiting - handles 429 responses" do
      # Test rate limiting scenario
      with_mock HTTPoison, [:passthrough], [
        get: fn _url, _headers, _opts -> 
          {:ok, %HTTPoison.Response{status_code: 429, body: "{}"}}
        end
      ] do
        assert {:error, :rate_limited} = NewFeature.new_feature("valid_input")
      end
    end
  end
end
```

```bash
# Run and iterate until passing:
mix test
# If failing: Read error, understand root cause, fix code, re-run (never mock to pass)
```

### Level 3: Integration Test

```bash
# Start the service
source .env && mix phx.server

# Test the endpoint
curl -X POST http://localhost:4000/ \
  -H "Content-Type: application/json"

# Expected: {"status": "success", "data": {...}}
# If error: Check logs at logs/app.log for stack trace
```

## Final validation Checklist

- [ ] All tests pass: `mix test`
- [ ] No linting errors: `mix ci`
- [ ] No type errors: `mix dialyzer`
- [ ] Manual test successful: [specific curl/command]
- [ ] Error cases handled gracefully
- [ ] Logs are informative but not verbose
- [ ] Documentation updated if needed

---

## Anti-Patterns to Avoid

- ❌ Don't create new patterns when existing ones work
- ❌ Don't skip validation because "it should work"  
- ❌ Don't ignore failing tests - fix them
- ❌ Don't use sync functions in async context
- ❌ Don't hardcode values that should be config
- ❌ Don't catch all exceptions - be specific
