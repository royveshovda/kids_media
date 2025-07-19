defmodule KidsMediaWeb.LiveCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require LiveView testing functionality.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint KidsMediaWeb.Endpoint

      use KidsMediaWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
      import KidsMediaWeb.LiveCase
    end
  end

  setup _tags do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end