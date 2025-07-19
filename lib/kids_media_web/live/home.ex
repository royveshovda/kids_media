defmodule KidsMediaWeb.HomeLive do
  use KidsMediaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="h-screen w-screen flex items-center justify-center bg-sky-100">
      <button
        phx-click="goto"
        value="cheetah"
        class="text-5xl font-bold bg-yellow-400 px-20 py-12 rounded shadow-lg"
      >
        🐆  Cheetahs
      </button>
    </div>
    """
  end

  def handle_event("goto", %{"value" => topic}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/subject/#{topic}")}
  end
end
