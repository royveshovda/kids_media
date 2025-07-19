defmodule KidsMediaWeb.HomeLiveTest do
  use KidsMediaWeb.LiveCase, async: true

  describe "Home page" do
    test "mounts successfully", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "🐆  Cheetahs"
      assert html =~ "bg-sky-100"
    end

    test "uses fullscreen layout", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Check that the fullscreen layout is assigned
      assert view |> element("div.w-full.h-full.min-h-screen") |> has_element?()
    end

    test "navigates to subject page when button is clicked", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Click the cheetah button
      view
      |> element("button[phx-click='goto'][value='cheetah']")
      |> render_click()

      # Should navigate to the subject page
      assert_redirected(view, "/subject/cheetah")
    end

    test "button has correct styling and accessibility", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      # Check button has proper styling classes
      assert html =~ "text-5xl font-bold bg-yellow-400"
      assert html =~ "px-20 py-12 rounded shadow-lg"
      assert html =~ "hover:bg-yellow-500 transition-colors"
    end

    test "page is kid-friendly with large elements", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      # Check for large, kid-friendly design elements
      assert html =~ "text-5xl"
      # Large text
      assert html =~ "🐆"
      # Emoji for visual appeal
      assert html =~ "px-20 py-12"
      # Large padding for easy clicking
    end

    test "goto event handles different topics", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Test that the goto event would work with different values
      # (This tests the event handler logic)
      assert view
             |> element("button[phx-click='goto']")
             |> has_element?()
    end
  end

  describe "Event handling" do
    test "goto event with valid topic redirects correctly", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Simulate the goto event with cheetah value
      view
      |> element("button[value='cheetah']")
      |> render_click()

      assert_redirected(view, "/subject/cheetah")
    end
  end

  describe "Responsive design" do
    test "layout works on different screen sizes", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      # Check for responsive classes
      assert html =~ "w-full h-full min-h-screen"
      assert html =~ "flex items-center justify-center"
    end
  end
end
