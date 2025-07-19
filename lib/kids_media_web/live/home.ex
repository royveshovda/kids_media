defmodule KidsMediaWeb.HomeLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    tv_mode = Map.get(params, "tv") == "1"
    layout = if tv_mode, do: {KidsMediaWeb.Layouts, :tv}, else: {KidsMediaWeb.Layouts, :fullscreen}
    
    {:ok, assign(socket, root_layout: layout, tv_mode: tv_mode)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div 
      id="home-container"
      phx-hook={if @tv_mode, do: "TVNavigation", else: "Fullscreen"}
      class={[
        "w-full h-full min-h-screen flex items-center justify-center",
        if(@tv_mode, do: "bg-black", else: "bg-sky-100")
      ]}
    >
      <div class="flex flex-col items-center gap-8">
        <h1 class={[
          "text-center font-bold mb-8",
          if(@tv_mode, do: "text-6xl text-white", else: "text-4xl text-gray-800")
        ]}>
          🐾 Kids Animal Explorer
        </h1>
        
        <div class="grid gap-6">
          <button
            id="cheetah-btn"
            phx-click="goto"
            value="cheetah"
            class={[
              "tv-focusable transition-all duration-200",
              if(@tv_mode, 
                do: "tv-button bg-yellow-400 hover:bg-yellow-500 text-black",
                else: "text-5xl font-bold bg-yellow-400 px-20 py-12 rounded shadow-lg hover:bg-yellow-500 transition-colors text-black"
              )
            ]}
            tabindex="0"
          >
            🐆  Cheetahs
          </button>
          
          <%= if @tv_mode do %>
            <button
              id="lion-btn"
              phx-click="goto"
              value="lion"
              class="tv-focusable tv-button bg-orange-400 hover:bg-orange-500 text-black transition-all duration-200"
              tabindex="0"
            >
              🦁  Lions
            </button>
            
            <button
              id="elephant-btn"
              phx-click="goto"
              value="elephant"
              class="tv-focusable tv-button bg-gray-400 hover:bg-gray-500 text-black transition-all duration-200"
              tabindex="0"
            >
              🐘  Elephants
            </button>
            
            <button
              id="giraffe-btn"
              phx-click="goto"
              value="giraffe"
              class="tv-focusable tv-button bg-yellow-300 hover:bg-yellow-400 text-black transition-all duration-200"
              tabindex="0"
            >
              🦒  Giraffes
            </button>
          <% end %>
        </div>
        
        <%= if @tv_mode do %>
          <div class="text-center text-gray-400 text-lg mt-8">
            Use your Apple TV remote to navigate • Press Enter to select
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("goto", %{"value" => topic}, socket) do
    tv_param = if socket.assigns.tv_mode, do: "?tv=1", else: ""
    {:noreply, push_navigate(socket, to: ~p"/subject/#{topic}#{tv_param}")}
  end
end
