import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// Pill kecil di tengah bawah layar (gaya Windows) saat volume / brightness diubah dari shortcut
PanelWindow {
  id: win
  anchors { bottom: true; left: true; right: true }
  margins.bottom: 64
  implicitHeight: pill.height
  exclusionMode: ExclusionMode.Ignore
  color: "transparent"
  visible: pill.opacity > 0
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
  mask: Region { item: pill }   // klik tembus ke window di bawahnya

  readonly property bool isVolume: Sys.osd === "volume"
  readonly property int level: isVolume ? Sys.volume : Sys.brightness
  readonly property bool silent: isVolume && Sys.muted

  Card {
    id: pill
    anchors.horizontalCenter: parent.horizontalCenter
    width: 300; height: 56; radius: 18; margins: 14
    fill: Theme.panel; shadow: 6
    opacity: Sys.osd !== "" ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 12
      Icon {
        name: win.isVolume ? (Sys.muted ? "volume-x" : "volume-2") : "sun"
        size: 20; anchors.verticalCenter: parent.verticalCenter
      }
      Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: 184; height: 14; radius: height / 2
        color: Theme.cream
        border.width: Theme.border; border.color: Theme.ink
        Rectangle {
          x: 2; y: 2; height: parent.height - 4
          width: Math.max(0, (parent.width - 4) * win.level / 100)
          visible: width >= 2
          radius: height / 2
          color: win.isVolume ? Theme.peach : Theme.yellow
          border.width: win.silent ? 0 : 1; border.color: Theme.ink
        }
      }
      Text {
        width: 46; horizontalAlignment: Text.AlignRight
        anchors.verticalCenter: parent.verticalCenter
        text: win.silent ? "Mute" : win.level + "%"
        font.family: Theme.font; font.bold: true; font.pixelSize: 13; color: Theme.ink
      }
    }
  }
}
