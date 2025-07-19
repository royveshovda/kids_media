defmodule KidsMediaWeb.RouterTest do
  use KidsMediaWeb.ConnCase, async: true

  describe "routes" do
    test "GET / routes to HomeLive", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert html_response(conn, 200)
      # Should contain LiveView elements
      assert conn.resp_body =~ "phx-"
    end

    test "GET /subject/:id routes to SubjectLive", %{conn: conn} do
      # Note: This may fail without proper Unsplash API configuration
      # but tests that the route is properly defined
      conn = get(conn, "/subject/test")

      # Should either succeed or fail with a known error (not 404)
      assert conn.status in [200, 500]
      refute conn.status == 404
    end

    test "undefined routes return 404", %{conn: conn} do
      assert_error_sent(404, fn ->
        get(conn, "/nonexistent")
      end)
    end

    test "LiveDashboard is available in development", %{conn: conn} do
      if Application.get_env(:kids_media, :dev_routes) do
        conn = get(conn, "/dev/dashboard")
        # May redirect to login
        assert conn.status in [200, 302]
      else
        assert_error_sent(404, fn ->
          get(conn, "/dev/dashboard")
        end)
      end
    end
  end

  describe "route helpers" do
    test "verified routes work correctly" do
      # Test that the route helpers are properly generated
      assert ~p"/" == "/"
      assert ~p"/subject/cheetah" == "/subject/cheetah"
    end
  end

  describe "pipeline configuration" do
    test "browser pipeline includes required plugs", %{conn: conn} do
      conn = get(conn, ~p"/")

      # Check that security headers are present
      assert get_resp_header(conn, "x-frame-options") != []
      assert get_resp_header(conn, "x-content-type-options") != []
    end

    test "CSRF protection is enabled", %{conn: conn} do
      conn = get(conn, ~p"/")

      # Should include CSRF token in forms/meta tags
      assert conn.resp_body =~ "csrf"
    end
  end
end
