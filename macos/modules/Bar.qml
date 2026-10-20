import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// macOS menu bar: full-width translucent strip.
// left  = apple menu | focused app (bold) | workspaces
// right = visualizer | sysmon | wifi bt sound | spotlight | control center | date + time
PanelWindow {
  id: bar
  anchors { top: true; left: true; right: true }
  implicitHeight: Theme.barHeight
  exclusiveZone: Theme.barHeight
  color: "transparent"

  BackgroundEffect.blurRegion: Region { item: strip }

  SystemClock { id: clock; precision: SystemClock.Minutes }

  component Item_: Item {
    id: it
    property bool active: false
    property bool bold: false
    property string text: ""
    property string icon: ""
    property int iconSize: 14
    property url iconUrl: ""
    property int maxTextWidth: 240
    signal clicked()
    signal rightClicked()
    signal wheel(int delta)
    height: 22
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    implicitWidth: r.implicitWidth + 14
    width: implicitWidth
    Rectangle {
      anchors.fill: parent; radius: 5
      color: it.active ? "#33FFFFFF" : (ma.containsMouse ? "#1FFFFFFF" : "transparent")
    }
    Row {
      id: r
      anchors.centerIn: parent
      spacing: 5
      Icon { visible: it.icon !== "" || it.iconUrl != ""; name: it.icon; url: it.iconUrl; size: it.iconSize
             color: it.iconUrl != "" ? "transparent" : Theme.ink; anchors.verticalCenter: parent.verticalCenter }
      Text {
        visible: it.text !== ""
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, it.maxTextWidth); elide: Text.ElideRight
        text: it.text
        font.family: Theme.font; font.pixelSize: 13; font.bold: it.bold; color: Theme.ink
      }
    }
    MouseArea {
      id: ma
      anchors.fill: parent; hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      onClicked: m => { if (m.button === Qt.RightButton) it.rightClicked(); else it.clicked() }
      onWheel: w => it.wheel(w.angleDelta.y)
    }
  }

  Rectangle {
    id: strip
    anchors.fill: parent
    color: Theme.bar
    Rectangle { anchors { left: parent.left; right: parent.right; bottom: parent.bottom } height: 1; color: "#14FFFFFF" }
  }

  // ===== LEFT =====
  Row {
    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
    spacing: 2

    Item_ {
      icon: "arch"; iconSize: 16
      active: Sys.panel === "apple"
      onClicked: Sys.toggle("apple")
    }
    Item_ {
      visible: Sys.focusedApp !== ""
      text: Sys.focusedApp; bold: true; maxTextWidth: 260
      icon: Sys.focusedIcon === "" ? "" : ""
      MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
    }
    Repeater {
      model: Sys.workspaces.filter(w => w.output === bar.screen.name)
      Item_ {
        required property var modelData
        text: String(modelData.idx)
        bold: modelData.is_active
        active: modelData.is_active
        onClicked: Sys.focusWorkspace(modelData.idx)
      }
    }
  }

  // ===== RIGHT =====
  Row {
    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
    spacing: 2

    Visualizer { anchors.verticalCenter: parent.verticalCenter }
    Item { width: 8; height: 1 }
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10
      SysChip { icon: "cpu"; pct: Sys.cpu; extra: Sys.cpuTemp }
      SysChip { icon: "monitor"; pct: Sys.gpu; extra: Sys.gpuTemp }
      SysChip { icon: "memory-stick"; pct: Sys.ram; extra: Sys.ramTemp }
      SysChip { icon: "hard-drive"; pct: Sys.disk; extra: Sys.diskTemp }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "R " + Sys.fmtRate(Sys.diskRead) + "  W " + Sys.fmtRate(Sys.diskWrite)
        font.family: Theme.font; font.pixelSize: 12; color: Theme.ink
      }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "↓ " + Sys.fmtRate(Sys.netDown) + "  ↑ " + Sys.fmtRate(Sys.netUp)
        font.family: Theme.font; font.pixelSize: 12; color: Theme.ink
      }
    }
    Item { width: 8; height: 1 }

    Item_ {
      icon: Sys.bt ? "bluetooth" : "bluetooth-off"
      active: Sys.panel === "bluetooth"
      onClicked: Sys.toggle("bluetooth")
      onRightClicked: Sys.toggleBt()
    }
    Item_ {
      icon: Sys.wifi ? "wifi" : "wifi-off"
      active: Sys.panel === "wifi"
      onClicked: Sys.toggle("wifi")
      onRightClicked: Sys.toggleWifi()
    }
    Item_ {
      icon: Sys.muted ? "volume-x" : "volume-2"
      active: Sys.panel === "sound"
      onClicked: Sys.toggle("sound")
      onRightClicked: Sys.toggleMute()
      onWheel: d => Sys.setVolume(Math.max(0, Math.min(100, Sys.volume + (d > 0 ? 5 : -5))))
    }
    Item_ {
      icon: "search"
      active: Sys.panel === "launcher"
      onClicked: Sys.toggle("launcher")
    }
    Item_ {
      icon: "sliders"
      active: Sys.panel === "settings"
      onClicked: Sys.toggle("settings")
    }
    Item_ {
      text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")
      active: Sys.panel === "settings"
      onClicked: Sys.toggle("settings")
    }
  }
}
