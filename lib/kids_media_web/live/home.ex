defmodule KidsMediaWeb.HomeLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :root_layout, {KidsMediaWeb.Layouts, :fullscreen})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full min-h-screen flex items-center justify-center bg-sky-100">
      <button
        phx-click="goto"
        value="cheetah"
        class="text-5xl font-bold bg-yellow-400 px-20 py-12 rounded shadow-lg hover:bg-yellow-500 transition-colors"
      >
        🐆  Cheetahs
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("goto", %{"value" => topic}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/subject/#{topic}")}
  end
end
