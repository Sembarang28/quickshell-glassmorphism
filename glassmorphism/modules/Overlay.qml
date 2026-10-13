import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Window below the bar: hosts the popups and closes them on outside click
PanelWindow {
  id: win
  anchors { top: true; left: true; right: true; bottom: true }
  margins.top: Theme.barHeight
  exclusionMode: ExclusionMode.Ignore
  color: Sys.panel === "settings" ? "#3D1E2040" : "transparent"
  visible: Sys.panel !== "" || settings.visible
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: Sys.panel === "launcher" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

  // blur only behind the popup that is currently shown
  BackgroundEffect.blurRegion: Region {
    Region { item: settings.visible ? settings : null; radius: 20 }
    Region { item: wifi.visible ? wifi : null; radius: 16 }
    Region { item: bluetooth.visible ? bluetooth : null; radius: 16 }
    Region { item: sound.visible ? sound : null; radius: 16 }
    Region { item: launcher.visible ? launcher : null; radius: 18 }
  }

  MouseArea { anchors.fill: parent; onClicked: Sys.close() }

  FocusScope {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: Sys.close()

    Launcher { id: launcher; x: 12; y: 10; visible: Sys.panel === "launcher" }
    SettingsPanel { id: settings; anchors.centerIn: parent; open: Sys.panel === "settings" }

    WifiPopup { id: wifi; anchors { right: parent.right; rightMargin: 150; top: parent.top; topMargin: 10 } open: Sys.panel === "wifi" }
    BluetoothPopup { id: bluetooth; anchors { right: parent.right; rightMargin: 110; top: parent.top; topMargin: 10 } open: Sys.panel === "bluetooth" }
    SoundPopup { id: sound; anchors { right: parent.right; rightMargin: 70; top: parent.top; topMargin: 10 } open: Sys.panel === "sound" }
  }
}
