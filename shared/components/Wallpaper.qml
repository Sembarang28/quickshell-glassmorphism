import Quickshell
import Quickshell.Wayland
import QtQuick

// Wallpaper on the background layer, one per screen (image from niri/assets/wallpaper.jpg)
PanelWindow {
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Background
  color: "#000000"

  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl("../assets/wallpaper.jpg")
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    cache: true
  }
}
