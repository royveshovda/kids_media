defmodule KidsMediaWeb.SubjectLive do
  use KidsMediaWeb, :live_view

  @impl true
  def mount(%{"id" => topic} = params, _session, socket) do
    images = KidsMedia.Unsplash.search!("#{topic} animal")
    tv_mode = Map.get(params, "tv") == "1"
    layout = if tv_mode, do: {KidsMediaWeb.Layouts, :tv}, else: {KidsMediaWeb.Layouts, :fullscreen}
    
    # video_id = KidsMedia.YouTube.first_video_id!("#{topic} for kids")
    {:ok,
     socket
     |> assign(topic: topic, images: images, page_title: topic, tv_mode: tv_mode)
     |> assign(:root_layout, layout)
     |> assign(
       show_modal: false,
       current_image_index: 0,
       carousel_active: false,
       carousel_interval: 3,
       focused_element: "carousel-btn"
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

  def handle_event("tv_navigate", %{"direction" => direction}, socket) do
    if socket.assigns.tv_mode and socket.assigns.show_modal do
      case direction do
        "left" -> handle_event("prev_image", %{}, socket)
        "right" -> handle_event("next_image", %{}, socket)
        "up" -> {:noreply, socket}
        "down" -> {:noreply, socket}
        "select" -> {:noreply, socket}
        "menu" -> handle_event("close_modal", %{}, socket)
        _ -> {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("tv_focus", %{"element" => element}, socket) do
    {:noreply, assign(socket, focused_element: element)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div
      id="root"
      phx-hook={if @tv_mode, do: "TVNavigation", else: "Fullscreen"}
      class="w-full h-full min-h-screen overflow-auto bg-black text-white flex flex-col items-center"
    >
      <!-- Back button for TV mode -->
      <%= if @tv_mode do %>
        <div class="w-full flex justify-start p-4">
          <.link 
            navigate="/?tv=1"
            class="tv-focusable tv-modal-control bg-red-600 hover:bg-red-700 text-white flex items-center justify-center"
            tabindex="0"
          >
            ←
          </.link>
        </div>
      <% end %>
      
      <h1 class={[
        "font-extrabold mt-4 mb-2 capitalize",
        if(@tv_mode, do: "text-6xl", else: "text-4xl")
      ]}>{@topic}</h1>
      
      <!-- Carousel controls -->
      <div class="mb-4 flex flex-col items-center gap-4">
        <button
          id="carousel-btn"
          phx-click="start_carousel"
          type="button"
          disabled={length(@images) < 2}
          class={[
            "tv-focusable font-bold py-3 px-6 rounded-lg transition-all duration-200",
            if(@tv_mode, do: "text-2xl py-4 px-8", else: "text-lg"),
            if(length(@images) >= 2,
              do: "bg-green-500 hover:bg-green-600 text-white",
              else: "bg-gray-500 text-gray-300 cursor-not-allowed"
            )
          ]}
          tabindex="0"
        >
          🎠 Start Carousel
        </button>

        <form phx-change="update_carousel_interval" class="flex items-center gap-4">
          <label class={if(@tv_mode, do: "text-lg", else: "text-sm")}>Slide interval:</label>
          <input
            type="range"
            name="value"
            min="1"
            max="7"
            value={@carousel_interval}
            class={if(@tv_mode, do: "w-48", else: "w-32")}
            disabled={length(@images) < 2}
          />
          <span class={if(@tv_mode, do: "text-lg", else: "text-sm")}>{@carousel_interval}s</span>
        </form>
      </div>
      
      <!-- Images -->
      <div class={[
        "flex flex-wrap justify-center gap-4 px-4 pb-4",
        if(@tv_mode, do: "gap-6", else: "gap-4")
      ]}>
        <%= for {img, index} <- Enum.with_index(@images) do %>
          <img
            id={"image-#{index}"}
            src={img}
            class={[
              "rounded-lg shadow-md cursor-pointer hover:opacity-80 transition-all duration-200",
              if(@tv_mode, 
                do: "tv-focusable tv-image h-64 w-64 object-cover", 
                else: "h-52"
              )
            ]}
            loading="lazy"
            phx-click="open_modal"
            phx-value-index={index}
            tabindex={if @tv_mode, do: "0", else: "-1"}
          />
        <% end %>
      </div>
      
      <!-- TV Navigation Help -->
      <%= if @tv_mode and not @show_modal do %>
        <div class="text-center text-gray-400 text-lg mt-4 mb-8">
          Use your Apple TV remote • Up/Down: Navigate • Enter: View image • Menu: Back
        </div>
      <% end %>
      
      <!-- Modal for fullscreen image viewing -->
      <%= if @show_modal do %>
        <div
          id="image-modal"
          phx-hook={if @tv_mode, do: "TVImageModal", else: "ImageModal"}
          class="fixed top-0 left-0 w-screen h-screen flex items-center justify-center"
          style="background-color: rgba(0, 0, 0, 0.95); z-index: 999999;"
          phx-click={if not @tv_mode, do: "close_modal"}
          data-carousel-active={to_string(@carousel_active)}
          data-carousel-interval={@carousel_interval * 1000}
        >
          <!-- Close button -->
          <button
            id="close-btn"
            phx-click="close_modal"
            type="button"
            class={[
              "absolute top-4 right-4 text-white hover:text-red-300 bg-red-600 bg-opacity-80 rounded-full flex items-center justify-center",
              if(@tv_mode, 
                do: "tv-focusable tv-modal-control text-4xl w-20 h-20", 
                else: "text-3xl w-14 h-14"
              )
            ]}
            tabindex="0"
          >
            ✕
          </button>
          
          <!-- Previous button -->
          <%= if length(@images) > 1 do %>
            <button
              id="prev-btn"
              phx-click="prev_image"
              type="button"
              class={[
                "absolute left-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300 bg-gray-800 bg-opacity-70 rounded-full flex items-center justify-center z-10",
                if(@tv_mode, 
                  do: "tv-focusable tv-modal-control text-4xl w-20 h-20", 
                  else: "text-3xl w-14 h-14"
                )
              ]}
              tabindex="0"
            >
              ⬅️
            </button>
          <% end %>
          
          <!-- Next button -->
          <%= if length(@images) > 1 do %>
            <button
              id="next-btn"
              phx-click="next_image"
              type="button"
              class={[
                "absolute right-4 top-1/2 transform -translate-y-1/2 text-white hover:text-gray-300 bg-gray-800 bg-opacity-70 rounded-full flex items-center justify-center z-10",
                if(@tv_mode, 
                  do: "tv-focusable tv-modal-control text-4xl w-20 h-20", 
                  else: "text-3xl w-14 h-14"
                )
              ]}
              tabindex="0"
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
              class={[
                "absolute bottom-6 left-1/2 transform -translate-x-1/2 flex flex-col items-center gap-4 z-10",
                if(@tv_mode, do: "gap-6", else: "gap-4")
              ]}
              phx-click="stop_modal_close"
            >
              <!-- Play/Pause button -->
              <div class="flex gap-4">
                <%= if @carousel_active do %>
                  <button
                    id="pause-btn"
                    phx-click="stop_carousel"
                    phx-capture-click="stop_modal_close"
                    type="button"
                    class={[
                      "bg-red-500 hover:bg-red-600 text-white font-bold rounded-lg",
                      if(@tv_mode, 
                        do: "tv-focusable text-2xl py-4 px-8", 
                        else: "text-lg py-3 px-6"
                      )
                    ]}
                    tabindex="0"
                  >
                    ⏸️ Pause
                  </button>
                <% else %>
                  <button
                    id="play-btn"
                    phx-click="start_carousel"
                    phx-capture-click="stop_modal_close"
                    type="button"
                    class={[
                      "bg-green-500 hover:bg-green-600 text-white font-bold rounded-lg",
                      if(@tv_mode, 
                        do: "tv-focusable text-2xl py-4 px-8", 
                        else: "text-lg py-3 px-6"
                      )
                    ]}
                    tabindex="0"
                  >
                    ▶️ Play
                  </button>
                <% end %>
              </div>
              
              <!-- Interval slider -->
              <form
                phx-change="update_carousel_interval"
                class={[
                  "flex items-center gap-4 bg-black bg-opacity-50 px-4 py-2 rounded",
                  if(@tv_mode, do: "px-6 py-3", else: "px-4 py-2")
                ]}
                onmousedown="event.stopPropagation()"
                onmouseup="event.stopPropagation()"
              >
                <label class={[
                  "text-white",
                  if(@tv_mode, do: "text-lg", else: "text-sm")
                ]}>Slide interval:</label>
                <input
                  type="range"
                  name="value"
                  min="1"
                  max="7"
                  value={@carousel_interval}
                  class={if(@tv_mode, do: "w-48", else: "w-32")}
                />
                <span class={[
                  "text-white",
                  if(@tv_mode, do: "text-lg", else: "text-sm")
                ]}>{@carousel_interval}s</span>
              </form>
            </div>
          <% end %>
          
          <!-- Image counter -->
          <div class={[
            "absolute top-4 left-1/2 transform -translate-x-1/2 text-white bg-black bg-opacity-50 px-4 py-2 rounded z-10",
            if(@tv_mode, do: "text-xl px-6 py-3", else: "text-base px-4 py-2")
          ]}>
            {@current_image_index + 1} / {length(@images)}
          </div>
          
          <!-- TV Navigation Help -->
          <%= if @tv_mode do %>
            <div class="absolute bottom-4 right-4 text-center text-gray-300 text-sm bg-black bg-opacity-50 px-4 py-2 rounded">
              Left/Right: Navigate images<br/>
              Menu: Close
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
