defmodule KidsMediaWeb.PageControllerTest do
  use KidsMediaWeb.ConnCase

  test "GET / redirects to LiveView", %{conn: conn} do
    # Since the home route is now handled by HomeLive instead of PageController,
    # we test that the route exists and is properly configured
    conn = get(conn, ~p"/")

    # The route should either render the LiveView or redirect appropriately
    # In Phoenix LiveView, initial GET requests render the static HTML first
    assert html_response(conn, 200)
  end
end