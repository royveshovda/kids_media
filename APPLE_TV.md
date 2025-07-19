# Apple TV Support for KidsMedia

KidsMedia now includes full support for Apple TV viewing through a TV-optimized web interface. This allows you to browse and view animal images on your Apple TV using the Apple TV remote.

## How to Use on Apple TV

### Method 1: Safari on Apple TV
1. Open Safari on your Apple TV
2. Navigate to your KidsMedia website
3. Add `?tv=1` to the URL (e.g., `https://yourdomain.com/?tv=1`)
4. Use your Apple TV remote to navigate

### Method 2: AirPlay from Device
1. Open the website on your iPhone/iPad/Mac
2. Add `?tv=1` to the URL for the TV-optimized interface
3. Use AirPlay to mirror to your Apple TV

## Apple TV Remote Controls

### Home Page Navigation
- **Up/Down Arrows**: Navigate between animal options
- **Enter/Select**: Choose an animal to explore
- **Menu**: Return to home (from subject pages)

### Subject Page Navigation
- **Up/Down Arrows**: Navigate between carousel button and images
- **Enter/Select**: Start carousel or view image in fullscreen
- **Menu**: Return to home page

### Image Modal Navigation
- **Left/Right Arrows**: Navigate between images
- **Up/Down Arrows**: Navigate modal controls (close, play/pause)
- **Enter/Select**: Activate focused control
- **Menu/Escape**: Close modal

## TV-Optimized Features

### Visual Enhancements
- **Large Fonts**: Optimized for 10-foot viewing distance
- **High Contrast**: Clear visibility on TV screens
- **Focus Indicators**: Bright cyan outlines show current selection
- **Larger Buttons**: Easy target acquisition with remote

### Navigation Features
- **Directional Navigation**: Full support for d-pad navigation
- **Automatic Focus Management**: Logical tab order for remote navigation
- **Visual Feedback**: Clear indication of focused elements
- **Carousel Mode**: Automatic slideshow with configurable timing

### Apple TV Specific Optimizations
- **Disabled Text Selection**: Prevents unwanted selections
- **Hidden Cursor**: Clean TV viewing experience
- **Fullscreen Layout**: Edge-to-edge content display
- **Touch-Free Operation**: Complete remote-only navigation

## Technical Implementation

### URL Parameter
Add `?tv=1` to any URL to activate TV mode:
- `/?tv=1` - TV-optimized home page
- `/subject/cheetah?tv=1` - TV-optimized subject page

### Layout System
- **TV Layout**: Uses `tv.html.heex` with TV-specific styles
- **JavaScript Hooks**: `TVNavigation` and `TVImageModal` for remote support
- **CSS Classes**: `.tv-focusable`, `.tv-button`, `.tv-image` for styling

### Browser Compatibility
- **Safari on Apple TV**: Fully supported
- **Other TV Browsers**: May work with similar remote interfaces
- **Desktop Browsers**: Can be tested with keyboard navigation

## Development Notes

### Testing TV Mode
You can test TV mode on desktop by:
1. Adding `?tv=1` to the URL
2. Using arrow keys and Enter to simulate Apple TV remote
3. Observing focus indicators and navigation flow

### Customization
TV-specific styles are defined in the `tv.html.heex` layout file and can be customized for different TV interfaces or remote control schemes.

### Future Enhancements
- Native tvOS app wrapper for App Store distribution
- Voice control integration
- Enhanced gesture support
- Multi-device sync for shared viewing experiences