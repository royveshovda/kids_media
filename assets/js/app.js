// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")


let Hooks = {};
Hooks.Fullscreen = {
  mounted() {
    setTimeout(() => {
      if (document.documentElement.requestFullscreen) {
        document.documentElement.requestFullscreen().catch(() => { });
      }
    }, 300); // give LiveView time to patch the DOM
  }
};

Hooks.ImageModal = {
  carouselTimer: null,

  mounted() {
    console.log("🔧 ImageModal hook mounted");
    console.log("📊 Initial data attributes:", {
      carouselActive: this.el.dataset.carouselActive,
      carouselInterval: this.el.dataset.carouselInterval
    });
    this.handleKeydown = this.handleKeydown.bind(this);
    this.handleRestartCarousel = this.handleRestartCarousel.bind(this);
    document.addEventListener('keydown', this.handleKeydown);
    window.addEventListener('phx:restart_carousel', this.handleRestartCarousel);
    this.startCarouselIfActive();
  },

  updated() {
    console.log("🔄 ImageModal hook updated");
    console.log("📊 Updated data attributes:", {
      carouselActive: this.el.dataset.carouselActive,
      carouselInterval: this.el.dataset.carouselInterval
    });
    this.startCarouselIfActive();
  },

  destroyed() {
    document.removeEventListener('keydown', this.handleKeydown);
    window.removeEventListener('phx:restart_carousel', this.handleRestartCarousel);
    this.stopCarousel();
  },

  handleRestartCarousel(event) {
    console.log("🔄 Received restart_carousel event:", event.detail);
    this.stopCarousel();
    if (this.el.dataset.carouselActive === 'true') {
      console.log("✅ Starting new carousel with interval:", event.detail.interval);
      this.carouselTimer = setInterval(() => {
        console.log("⏰ Carousel auto-advance");
        this.pushEvent("next_image", {});
      }, event.detail.interval);
    } else {
      console.log("❌ Not starting carousel - element says not active");
    }
  },

  handleKeydown(event) {
    switch (event.key) {
      case 'Escape':
        this.pushEvent("close_modal", {});
        break;
      case 'ArrowLeft':
        event.preventDefault();
        this.pushEvent("prev_image", {});
        break;
      case 'ArrowRight':
        event.preventDefault();
        this.pushEvent("next_image", {});
        break;
    }
  },

  startCarouselIfActive() {
    const isActive = this.el.dataset.carouselActive === 'true';
    const interval = parseInt(this.el.dataset.carouselInterval) || 3000;

    console.log("🎠 startCarouselIfActive - isActive:", isActive, "interval:", interval);

    this.stopCarousel(); // Clear any existing timer

    if (isActive) {
      console.log("▶️ Starting carousel timer");
      this.carouselTimer = setInterval(() => {
        console.log("⏰ Carousel auto-advance (from startCarouselIfActive)");
        this.pushEvent("next_image", {});
      }, interval);
    }
  },

  stopCarousel() {
    if (this.carouselTimer) {
      clearInterval(this.carouselTimer);
      this.carouselTimer = null;
    }
  }
};

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

