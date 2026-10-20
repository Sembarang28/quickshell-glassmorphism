import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// macOS HUD: 200px rounded square, glyph above a 16-step level meter
PanelWindow {
  id: win
  anchors { bottom: true; left: true; right: true }
  margins.bottom: 90
  implicitHeight: hud.height
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  visible: hud.opacity > 0
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region { item: hud }
  BackgroundEffect.blurRegion: Region { item: hud; radius: 22 }

  readonly property bool isVolume: Sys.osd === "volume"
  readonly property int level: isVolume ? Sys.volume : Sys.brightness
  readonly property bool silent: isVolume && Sys.muted

  Rectangle {
    id: hud
    anchors.horizontalCenter: parent.horizontalCenter
    width: 200; height: 200; radius: 22
    color: "#B31C1C1E"
    border.width: 1; border.color: "#1FFFFFFF"
    opacity: Sys.osd !== "" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 180 } }

    Icon {
      anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 44 }
      name: win.isVolume ? (win.silent ? "volume-x" : "volume-2") : "sun"
      size: 84; color: "#E6FFFFFF"
    }
    Row {
      anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 22 }
      spacing: 2
      Repeater {
        model: 16
        Rectangle {
          required property int index
          width: 8; height: 6
          color: !win.silent && index < Math.round(win.level / 100 * 16) ? "#F2FFFFFF" : "#40FFFFFF"
        }
      }
    }
  }
}
