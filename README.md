# KidsMedia

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

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
