# KidsMedia

A Phoenix LiveView application that provides an immersive, kid-friendly interface for exploring educational content about animals. The app fetches images from Unsplash API and is designed for fullscreen, distraction-free experiences.

## Features

- **Kid-Friendly Interface**: Large buttons, bright colors, and simple navigation
- **Animal Image Galleries**: High-quality images from Unsplash API
- **Interactive Carousel**: Automatic slideshow with customizable timing
- **Fullscreen Experience**: Distraction-free viewing mode
- **Apple TV Support**: TV-optimized interface for big screen viewing

## Apple TV Support

KidsMedia includes full Apple TV support through a TV-optimized web interface. Simply add `?tv=1` to any URL to activate TV mode:

- `/?tv=1` - TV-optimized home page with multiple animal options
- `/subject/cheetah?tv=1` - TV-optimized animal gallery

### Apple TV Remote Controls
- **Arrow Keys**: Navigate between options and images
- **Enter/Select**: Select animals or view images
- **Menu**: Return to previous screen or close modals

For detailed Apple TV setup and usage instructions, see [APPLE_TV.md](APPLE_TV.md).

## Getting Started

To start your Phoenix server:

* Copy `.env.example` to `.env` and add your Unsplash API key
* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

## Environment Variables

This application requires the following environment variables:

* `UNSPLASH_ACCESS_KEY`: Get your API key from [Unsplash Developers](https://unsplash.com/developers)

For development, you can source the `.env` file:

```bash
source .env && mix phx.server
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser, or [`localhost:4000/?tv=1`](http://localhost:4000/?tv=1) for the TV-optimized interface.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
