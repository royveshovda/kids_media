defmodule KidsMediaWeb.SubjectLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(%{"id" => topic}, _session, socket) do
    images = KidsMedia.Unsplash.search!("#{topic} animal")
    # video_id = KidsMedia.YouTube.first_video_id!("#{topic} for kids")
    {:ok,
     socket
     |> assign(topic: topic, images: images, page_title: topic)
     |> assign(:root_layout, {KidsMediaWeb.Layouts, :fullscreen})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="root"
      phx-hook="Fullscreen"
      class="w-full h-full min-h-screen overflow-auto bg-black text-white flex flex-col items-center"
    >
      <h1 class="text-4xl font-extrabold mt-4 mb-2 capitalize">{@topic}</h1>
      
    <!-- images -->
      <div class="flex flex-wrap justify-center gap-4 px-4 pb-4">
        <%= for img <- @images do %>
          <img src={img} class="h-52 rounded-lg shadow-md" loading="lazy" />
        <% end %>
      </div>
    </div>
    """
  end
end
