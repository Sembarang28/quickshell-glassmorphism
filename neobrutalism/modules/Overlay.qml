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
  color: Sys.panel === "settings" ? "#66000000" : "transparent"
  visible: Sys.panel !== "" || settings.visible
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: Sys.panel === "launcher" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

  MouseArea { anchors.fill: parent; onClicked: Sys.close() }

  FocusScope {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: Sys.close()

    Launcher { x: 12; y: 10; visible: Sys.panel === "launcher" }
    SettingsPanel { id: settings; anchors.centerIn: parent; open: Sys.panel === "settings" }

    WifiPopup { anchors { right: parent.right; rightMargin: 150; top: parent.top; topMargin: 10 } open: Sys.panel === "wifi" }
    BluetoothPopup { anchors { right: parent.right; rightMargin: 110; top: parent.top; topMargin: 10 } open: Sys.panel === "bluetooth" }
    SoundPopup { anchors { right: parent.right; rightMargin: 70; top: parent.top; topMargin: 10 } open: Sys.panel === "sound" }
  }
}
