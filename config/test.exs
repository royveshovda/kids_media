import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :kids_media, KidsMediaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "xH/+I67UZ8rKc8BLfqhkGLHzMP43zEsF78hjo8wpoihFXPxFxDvBzHMv15Nu3MN8",
  server: false

# In test we don't send emails
config :kids_media, KidsMedia.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Configure test API key for Unsplash (can be fake for testing)
config :kids_media, KidsMedia.Unsplash, access_key: "test_key"

# Use mock for Unsplash in tests to avoid real API calls
config :kids_media, :unsplash_module, KidsMedia.UnsplashMock

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
