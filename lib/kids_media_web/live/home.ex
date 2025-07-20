defmodule KidsMediaWeb.HomeLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :root_layout, {KidsMediaWeb.Layouts, :fullscreen})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full h-full min-h-screen bg-blue-500 text-white relative">
      <!-- Integrated Navigation -->
      <nav class="absolute top-4 left-0 right-0 flex justify-between px-8 z-10">
        <a href="/" class="text-white hover:text-blue-200 text-lg font-semibold transition-colors">
          <img src={~p"/images/logo.svg"} width="36" />
        </a>
        <a
          href="https://github.com/royveshovda/kids_media"
          target="_blank"
          class="text-white hover:text-blue-200 text-lg font-semibold transition-colors"
        >
          📚 GitHub
        </a>
      </nav>
      
    <!-- Main Content Area -->
      <div class="flex items-center justify-center h-full pt-16">
        <button
          phx-click="goto"
          value="cheetah"
          class="text-5xl font-bold bg-yellow-400 text-blue-900 px-20 py-12 rounded-xl shadow-2xl hover:bg-yellow-300 transition-all transform hover:scale-105"
        >
          🐆  Cheetahs
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("goto", %{"value" => topic}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/subject/#{topic}")}
  end
end
