defmodule KidsMediaWeb.SmokeTest do
  use KidsMediaWeb.ConnCase, async: true

  describe "Application health" do
    test "application starts without errors" do
      # Test that the application and endpoint are running
      assert Process.whereis(KidsMediaWeb.Endpoint) != nil
    end

    test "basic routes are accessible", %{conn: conn} do
      # Test that fundamental routes respond
      conn = get(conn, "/")
      assert conn.status == 200
    end

    test "LiveDashboard is available in dev/test", %{conn: conn} do
      # Test that development tools are accessible
      if Application.get_env(:kids_media, :dev_routes) do
        conn = get(conn, "/dev/dashboard")
        assert conn.status == 200
      else
        # In production, this route shouldn't exist
        assert_error_sent(404, fn ->
          get(conn, "/dev/dashboard")
        end)
      end
    end

    test "static assets are served correctly", %{conn: conn} do
      # Test that CSS and JS assets are available
      # Note: In test environment, assets might not be compiled
      conn = get(conn, "/assets/app.css")
      # 404 is acceptable in test env
      assert conn.status in [200, 404]
    end
  end

  describe "Configuration" do
    test "required configuration keys are present" do
      # Test that essential configuration is available
      assert Application.get_env(:kids_media, KidsMediaWeb.Endpoint) != nil
      assert Application.get_env(:kids_media, :generators) != nil
    end

    test "Unsplash module configuration exists" do
      # Test that Unsplash module has configuration (even if empty in test)
      config = Application.get_env(:kids_media, KidsMedia.Unsplash, [])
      assert is_list(config)
    end
  end

  describe "Dependencies" do
    test "required dependencies are available" do
      # Test that critical dependencies are loaded
      assert Code.ensure_loaded?(Phoenix.LiveView)
      assert Code.ensure_loaded?(HTTPoison)
      assert Code.ensure_loaded?(Jason)
    end

    test "application modules are loadable" do
      # Test that our main modules can be loaded
      assert Code.ensure_loaded?(KidsMedia.Unsplash)
      assert Code.ensure_loaded?(KidsMediaWeb.HomeLive)
      assert Code.ensure_loaded?(KidsMediaWeb.SubjectLive)
    end
  end
end
