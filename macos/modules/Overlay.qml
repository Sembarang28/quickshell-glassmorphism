import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Window below the menu bar: hosts menus / panels and closes them on outside click
PanelWindow {
  id: win
  anchors { top: true; left: true; right: true; bottom: true }
  margins.top: Theme.barHeight
  exclusionMode: ExclusionMode.Ignore
  color: Sys.panel === "prefs" ? "#33000000" : "transparent"
  visible: Sys.panel !== "" || settings.visible || prefs.visible
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: Sys.panel === "launcher" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.OnDemand

  BackgroundEffect.blurRegion: Region {
    Region { item: settings.visible ? settings : null; radius: 18 }
    Region { item: prefs.visible ? prefs : null; radius: 12 }
    Region { item: apple.visible ? apple : null; radius: 10 }
    Region { item: wifi.visible ? wifi : null; radius: 18 }
    Region { item: bluetooth.visible ? bluetooth : null; radius: 18 }
    Region { item: sound.visible ? sound : null; radius: 18 }
    Region { item: launcher.visible ? launcher : null; radius: 14 }
  }

  MouseArea { anchors.fill: parent; onClicked: Sys.close() }

  FocusScope {
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: Sys.close()

    Launcher { id: launcher; anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: parent.height * 0.18 }
               visible: Sys.panel === "launcher" }
    AppleMenu { id: apple; anchors { left: parent.left; leftMargin: 8; top: parent.top; topMargin: 2 } open: Sys.panel === "apple" }
    SettingsPanel { id: settings; anchors { right: parent.right; rightMargin: 8; top: parent.top; topMargin: 6 } open: Sys.panel === "settings" }
    SystemSettings { id: prefs; anchors.centerIn: parent; open: Sys.panel === "prefs" }

    WifiPopup { id: wifi; anchors { right: parent.right; rightMargin: 90; top: parent.top; topMargin: 6 } open: Sys.panel === "wifi" }
    BluetoothPopup { id: bluetooth; anchors { right: parent.right; rightMargin: 120; top: parent.top; topMargin: 6 } open: Sys.panel === "bluetooth" }
    SoundPopup { id: sound; anchors { right: parent.right; rightMargin: 60; top: parent.top; topMargin: 6 } open: Sys.panel === "sound" }
  }
}
