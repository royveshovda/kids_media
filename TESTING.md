# Testing Guide

## Overview

This project includes a comprehensive test suite designed to ensure the KidsMedia application works correctly and provides a reliable, kid-friendly experience.

## Test Structure

### Test Types

1. **Unit Tests** (`test/kids_media/`)
   - Test individual modules in isolation
   - Mock external dependencies (like Unsplash API)
   - Focus on business logic and error handling

2. **LiveView Tests** (`test/kids_media_web/live/`)
   - Test Phoenix LiveView components
   - Verify rendering, event handling, and state management
   - Ensure proper navigation and user interactions

3. **Integration Tests** (`test/kids_media_web/integration_test.exs`)
   - Test complete user journeys
   - Verify end-to-end functionality
   - Check performance and UX considerations

4. **Smoke Tests** (`test/kids_media_web/smoke_test.exs`)
   - Basic application health checks
   - Configuration validation
   - Dependency availability

## Running Tests

```bash
# Run all tests
mix test

# Run tests with coverage
mix test --cover

# Run specific test file
mix test test/kids_media_web/live/home_live_test.exs

# Run tests in watch mode for development
mix test.watch

# Run full CI suite locally
mix ci
```

## Test Configuration

- **Test Coverage**: Configured with ExCoveralls, minimum 80% coverage
- **Async Tests**: Most tests run async for better performance
- **Mocking**: External API calls are mocked to avoid dependencies

## GitHub Actions

### PR Workflow (`.github/workflows/pr.yml`)
- Fast validation for pull requests
- Runs essential checks: compilation, formatting, tests
- Quick feedback for developers

### Full CI Pipeline (`.github/workflows/ci.yml`)
- Matrix testing across Elixir/OTP versions
- Comprehensive quality checks (Credo, Sobelow, Dialyxir)
- Asset building and validation
- Test coverage reporting

## Writing New Tests

### For New Modules
1. Create unit tests in `test/kids_media/`
2. Mock external dependencies
3. Test both success and error cases
4. Ensure async: true when possible

### For New LiveViews
1. Create tests in `test/kids_media_web/live/`
2. Use `KidsMediaWeb.LiveCase`
3. Test mounting, rendering, and event handling
4. Consider accessibility and UX aspects

### Best Practices
- Write descriptive test names
- Test edge cases and error conditions
- Keep tests focused and isolated
- Mock external dependencies consistently
- Consider the kid-friendly nature of the app in integration tests

## Mocking Strategy

Since the app depends on external APIs (Unsplash), tests use mocking to:
- Avoid network calls during testing
- Test error conditions reliably
- Ensure fast test execution
- Prevent API rate limiting issues

## Coverage Goals

- **Overall**: 80% minimum coverage
- **Core modules**: 90%+ coverage preferred
- **External integrations**: Focus on error handling
- **LiveViews**: Cover all event handlers and state changes