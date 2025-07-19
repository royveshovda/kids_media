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

// TV Navigation Hook for Apple TV remote support
Hooks.TVNavigation = {
  mounted() {
    this.handleKeydown = this.handleKeydown.bind(this);
    this.focusableElements = [];
    this.currentFocusIndex = 0;
    
    document.addEventListener('keydown', this.handleKeydown);
    this.updateFocusableElements();
    this.focusCurrentElement();
  },

  updated() {
    this.updateFocusableElements();
  },

  destroyed() {
    document.removeEventListener('keydown', this.handleKeydown);
  },

  updateFocusableElements() {
    this.focusableElements = Array.from(
      this.el.querySelectorAll('.tv-focusable, button[tabindex="0"], [tabindex="0"]')
    ).filter(el => !el.disabled && getComputedStyle(el).display !== 'none');
    
    // If we have elements and current index is out of bounds, reset to 0
    if (this.focusableElements.length > 0 && this.currentFocusIndex >= this.focusableElements.length) {
      this.currentFocusIndex = 0;
    }
  },

  focusCurrentElement() {
    if (this.focusableElements.length > 0) {
      // Remove focus from all elements
      this.focusableElements.forEach(el => {
        el.classList.remove('tv-focused');
        el.blur();
      });
      
      // Focus current element
      const currentElement = this.focusableElements[this.currentFocusIndex];
      if (currentElement) {
        currentElement.classList.add('tv-focused');
        currentElement.focus();
      }
    }
  },

  handleKeydown(event) {
    if (this.focusableElements.length === 0) return;

    switch (event.key) {
      case 'ArrowUp':
        event.preventDefault();
        this.navigateUp();
        break;
      case 'ArrowDown':
        event.preventDefault();
        this.navigateDown();
        break;
      case 'ArrowLeft':
        event.preventDefault();
        this.navigateLeft();
        break;
      case 'ArrowRight':
        event.preventDefault();
        this.navigateRight();
        break;
      case 'Enter':
        event.preventDefault();
        this.selectCurrent();
        break;
      case 'Escape':
        // Let the app handle escape
        break;
    }
  },

  navigateUp() {
    if (this.currentFocusIndex > 0) {
      this.currentFocusIndex--;
    } else {
      this.currentFocusIndex = this.focusableElements.length - 1;
    }
    this.focusCurrentElement();
  },

  navigateDown() {
    if (this.currentFocusIndex < this.focusableElements.length - 1) {
      this.currentFocusIndex++;
    } else {
      this.currentFocusIndex = 0;
    }
    this.focusCurrentElement();
  },

  navigateLeft() {
    // For grid layouts, try to move left in the same row
    this.navigateUp();
  },

  navigateRight() {
    // For grid layouts, try to move right in the same row
    this.navigateDown();
  },

  selectCurrent() {
    const currentElement = this.focusableElements[this.currentFocusIndex];
    if (currentElement) {
      currentElement.click();
    }
  }
};

// TV Image Modal Hook - specialized for modal navigation
Hooks.TVImageModal = {
  carouselTimer: null,

  mounted() {
    console.log("🔧 TVImageModal hook mounted");
    this.handleKeydown = this.handleKeydown.bind(this);
    this.handleRestartCarousel = this.handleRestartCarousel.bind(this);
    this.focusableElements = [];
    this.currentFocusIndex = 0;
    
    document.addEventListener('keydown', this.handleKeydown);
    window.addEventListener('phx:restart_carousel', this.handleRestartCarousel);
    
    this.updateFocusableElements();
    this.focusCurrentElement();
    this.startCarouselIfActive();
  },

  updated() {
    console.log("🔄 TVImageModal hook updated");
    this.updateFocusableElements();
    this.startCarouselIfActive();
  },

  destroyed() {
    document.removeEventListener('keydown', this.handleKeydown);
    window.removeEventListener('phx:restart_carousel', this.handleRestartCarousel);
    this.stopCarousel();
  },

  updateFocusableElements() {
    this.focusableElements = Array.from(
      this.el.querySelectorAll('.tv-focusable, button[tabindex="0"]')
    ).filter(el => !el.disabled && getComputedStyle(el).display !== 'none');
    
    if (this.focusableElements.length > 0 && this.currentFocusIndex >= this.focusableElements.length) {
      this.currentFocusIndex = 0;
    }
  },

  focusCurrentElement() {
    if (this.focusableElements.length > 0) {
      this.focusableElements.forEach(el => {
        el.classList.remove('tv-focused');
        el.blur();
      });
      
      const currentElement = this.focusableElements[this.currentFocusIndex];
      if (currentElement) {
        currentElement.classList.add('tv-focused');
        currentElement.focus();
      }
    }
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
    }
  },

  handleKeydown(event) {
    switch (event.key) {
      case 'Escape':
      case 'Menu':
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
      case 'ArrowUp':
        event.preventDefault();
        this.navigateUp();
        break;
      case 'ArrowDown':
        event.preventDefault();
        this.navigateDown();
        break;
      case 'Enter':
        event.preventDefault();
        this.selectCurrent();
        break;
    }
  },

  navigateUp() {
    if (this.currentFocusIndex > 0) {
      this.currentFocusIndex--;
    } else {
      this.currentFocusIndex = this.focusableElements.length - 1;
    }
    this.focusCurrentElement();
  },

  navigateDown() {
    if (this.currentFocusIndex < this.focusableElements.length - 1) {
      this.currentFocusIndex++;
    } else {
      this.currentFocusIndex = 0;
    }
    this.focusCurrentElement();
  },

  selectCurrent() {
    const currentElement = this.focusableElements[this.currentFocusIndex];
    if (currentElement) {
      currentElement.click();
    }
  },

  startCarouselIfActive() {
    const isActive = this.el.dataset.carouselActive === 'true';
    const interval = parseInt(this.el.dataset.carouselInterval) || 3000;

    console.log("🎠 startCarouselIfActive - isActive:", isActive, "interval:", interval);

    this.stopCarousel();

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

