defmodule KidsMediaWeb.SubjectLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(%{"id" => topic}, _session, socket) do
    images = KidsMedia.Unsplash.search!("#{topic} animal")
    # video_id = KidsMedia.YouTube.first_video_id!("#{topic} for kids")
    {:ok,
     socket
     |> assign(topic: topic, images: images, page_title: topic)
     |> assign(:root_layout, {KidsMediaWeb.Layouts, :fullscreen})
     |> assign(
       show_modal: false,
       current_image_index: 0,
       carousel_active: false,
       carousel_interval: 3
     )}
  end

  @impl true
  def handle_event("open_modal", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, assign(socket, show_modal: true, current_image_index: index)}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_modal: false, carousel_active: false)}
  end

  def handle_event("next_image", _params, socket) do
    current_index = socket.assigns.current_image_index
    max_index = length(socket.assigns.images) - 1
    new_index = if current_index >= max_index, do: 0, else: current_index + 1
    {:noreply, assign(socket, current_image_index: new_index)}
  end

  def handle_event("prev_image", _params, socket) do
    current_index = socket.assigns.current_image_index
    max_index = length(socket.assigns.images) - 1
    new_index = if current_index <= 0, do: max_index, else: current_index - 1
    {:noreply, assign(socket, current_image_index: new_index)}
  end

  def handle_event("start_carousel", _params, socket) do
    IO.puts("🎠 START CAROUSEL EVENT - Images: #{length(socket.assigns.images)}")

    if length(socket.assigns.images) > 1 do
      IO.puts("✅ Setting carousel_active: true, show_modal: true")
      {:noreply, assign(socket, carousel_active: true, show_modal: true)}
    else
      IO.puts("❌ Not enough images for carousel")
      {:noreply, socket}
    end
  end

  def handle_event("stop_carousel", _params, socket) do
    IO.puts("⏸️ STOP CAROUSEL EVENT")
    IO.puts("✅ Setting carousel_active: false")
    {:noreply, assign(socket, carousel_active: false)}
  end

  def handle_event("stop_modal_close", _params, socket) do
    # This event prevents the modal from closing when clicking on control areas
    # It's a no-op event that just prevents event bubbling
    {:noreply, socket}
  end

  def handle_event("update_carousel_interval", %{"value" => value}, socket) do
    interval = String.to_integer(value)
    socket = assign(socket, carousel_interval: interval)

    # If carousel is active, push an event to restart the timer
    if socket.assigns.carousel_active and socket.assigns.show_modal do
      {:noreply, push_event(socket, "restart_carousel", %{interval: interval * 1000})}
    else
      {:noreply, socket}
    end
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
      
    <!-- Carousel controls -->
      <div class="mb-4 flex flex-col items-center gap-4">
        <button
          phx-click="start_carousel"
          type="button"
          disabled={length(@images) < 2}
          class={[
            "font-bold py-3 px-6 rounded-lg text-lg",
            if(length(@images) >= 2,
              do: "bg-green-500 hover:bg-green-600 text-white",
              else: "bg-gray-500 text-gray-300 cursor-not-allowed"
            )
          ]}
        >
          🎠 Start Carousel
        </button>

        <form phx-change="update_carousel_interval" class="flex items-center gap-4">
          <label class="text-sm">Slide interval:</label>
          <input
            type="range"
            name="value"
            min="1"
            max="7"
            value={@carousel_interval}
            class="w-32"
            disabled={length(@images) < 2}
          />
          <span class="text-sm">{@carousel_interval}s</span>
        </form>
      </div>
      
    <!-- Images -->
      <div class="flex flex-wrap justify-center gap-4 px-4 pb-4">
        <%= for {img, index} <- Enum.with_index(@images) do %>
          <img
            src={img}
            class="h-52 rounded-lg shadow-md cursor-pointer hover:opacity-80 transition-opacity"
            loading="lazy"
            phx-click="open_modal"
            phx-value-index={index}
          />
        <% end %>
      </div>
      
    <!-- Modal for fullscreen image viewing -->
      <%= if @show_modal do %>
        <div
          id="image-modal"
          phx-hook="ImageModal"
          class="fixed top-0 left-0 w-screen h-screen flex items-center justify-center"
          style="background-color: rgba(0, 0, 0, 0.95); z-index: 999999;"
          phx-click="close_modal"
          data-carousel-active={to_string(@carousel_active)}
          data-carousel-interval={@carousel_interval * 1000}
        >
          <!-- Close button -->
          <button
            phx-click="close_modal"
            type="button"
            class="absolute top-4 right-4 text-white text-3xl hover:text-red-300 bg-red-600 bg-opacity-80 rounded-full w-14 h-14 flex items-center justify-center"
          >
            ✕
          </button>
          
    <!-- Previous button -->
          <%= if length(@images) > 1 do %>
            <button
              phx-click="prev_image"
              type="button"
              class="absolute left-4 top-1/2 transform -translate-y-1/2 text-white text-3xl hover:text-gray-300 bg-gray-800 bg-opacity-70 rounded-full w-14 h-14 flex items-center justify-center z-10"
            >
              ⬅️
            </button>
          <% end %>
          
    <!-- Next button -->
          <%= if length(@images) > 1 do %>
            <button
              phx-click="next_image"
              type="button"
              class="absolute right-4 top-1/2 transform -translate-y-1/2 text-white text-3xl hover:text-gray-300 bg-gray-800 bg-opacity-70 rounded-full w-14 h-14 flex items-center justify-center z-10"
            >
              ➡️
            </button>
          <% end %>
          
    <!-- Current image -->
          <img
            src={Enum.at(@images, @current_image_index)}
            class="max-w-[90vw] max-h-[90vh] object-contain pointer-events-none"
            alt="Fullscreen image"
          />
          
    <!-- Carousel controls -->
          <%= if length(@images) > 1 do %>
            <div
              class="absolute bottom-6 left-1/2 transform -translate-x-1/2 flex flex-col items-center gap-4 z-10"
              phx-click="stop_modal_close"
            >
              <!-- Play/Pause button -->
              <div class="flex gap-4">
                <%= if @carousel_active do %>
                  <button
                    phx-click="stop_carousel"
                    phx-capture-click="stop_modal_close"
                    type="button"
                    class="bg-red-500 hover:bg-red-600 text-white font-bold py-3 px-6 rounded-lg text-lg"
                  >
                    ⏸️ Pause
                  </button>
                <% else %>
                  <button
                    phx-click="start_carousel"
                    phx-capture-click="stop_modal_close"
                    type="button"
                    class="bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-6 rounded-lg text-lg"
                  >
                    ▶️ Play
                  </button>
                <% end %>
              </div>
              
    <!-- Interval slider -->
              <form
                phx-change="update_carousel_interval"
                class="flex items-center gap-4 bg-black bg-opacity-50 px-4 py-2 rounded"
                onmousedown="event.stopPropagation()"
                onmouseup="event.stopPropagation()"
              >
                <label class="text-white text-sm">Slide interval:</label>
                <input
                  type="range"
                  name="value"
                  min="1"
                  max="7"
                  value={@carousel_interval}
                  class="w-32"
                />
                <span class="text-white text-sm">{@carousel_interval}s</span>
              </form>
            </div>
          <% end %>
          
    <!-- Image counter -->
          <div class="absolute top-4 left-1/2 transform -translate-x-1/2 text-white bg-black bg-opacity-50 px-4 py-2 rounded z-10">
            {@current_image_index + 1} / {length(@images)}
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
