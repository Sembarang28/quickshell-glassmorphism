import Quickshell
import Quickshell.Wayland
import QtQuick
import "../services"
import "../shared/services"
import "../components"

// Floating glass pills. Order is identical to the neobrutalism bar:
// left  = launcher | workspaces | focused app
// right = visualizer | sysmon | wifi bt volume | settings | datetime
PanelWindow {
  id: bar
  anchors { top: true; left: true; right: true }
  implicitHeight: Theme.barHeight
  exclusiveZone: Theme.barHeight
  color: "transparent"

  // clicks on the empty gap pass through to the windows below
  mask: Region {
    Region { item: leftPill }
    Region { item: rightPill }
  }

  // real blur behind the pills (ext-background-effect, supported by niri 26.04)
  BackgroundEffect.blurRegion: Region {
    Region { item: leftPill; radius: 15 }
    Region { item: rightPill; radius: 15 }
  }

  SystemClock { id: clock; precision: SystemClock.Minutes }

  component Pill: Item {
    id: pill
    default property alias content: inner.data
    property alias contentItem: inner
    implicitHeight: 30
    implicitWidth: inner.childrenRect.width + 16
    Rectangle { y: 3; width: parent.width; height: parent.height; radius: height / 2; color: Theme.shadowColor }
    Rectangle {
      anchors.fill: parent
      radius: height / 2
      color: Theme.bar
      border.width: Theme.border; border.color: Theme.glassBorder
      Rectangle {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
        height: parent.height * 0.5; radius: parent.radius
        gradient: Gradient {
          GradientStop { position: 0; color: "#66FFFFFF" }
          GradientStop { position: 1; color: "#00FFFFFF" }
        }
      }
    }
    Item { id: inner; x: 8; anchors.verticalCenter: parent.verticalCenter; height: parent.height }
  }

  // ===== LEFT =====
  Pill {
    id: leftPill
    anchors { left: parent.left; leftMargin: 12; top: parent.top; topMargin: 4 }
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      BrutButton {
        icon: "layout-grid"; width: 24; pad: 0; radius: 11
        fill: Theme.peach
        active: Sys.panel === "launcher"; activeFill: Theme.green
        onClicked: Sys.toggle("launcher")
      }
      Row {
        spacing: 6
        Repeater {
          model: Sys.workspaces.filter(w => w.output === bar.screen.name)
          BrutButton {
            required property var modelData
            text: String(modelData.idx)
            width: 22; pad: 0; radius: 11
            active: modelData.is_active; activeFill: Theme.yellow
            onClicked: Sys.focusWorkspace(modelData.idx)
          }
        }
      }
      BrutButton {
        visible: Sys.focusedApp !== ""
        text: Sys.focusedApp; radius: 11
        icon: Sys.focusedIcon === "" ? "app-window" : ""
        iconUrl: Sys.focusedIcon === "" ? "" : Quickshell.iconPath(Sys.focusedIcon, "application-x-executable")
        iconSize: 16; maxTextWidth: 220
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
      }
    }
  }

  // ===== RIGHT =====
  Pill {
    id: rightPill
    anchors { right: parent.right; rightMargin: 12; top: parent.top; topMargin: 4 }
    Row {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 10

      Visualizer {}

      Row {
        spacing: 6
        SysChip { icon: "cpu"; pct: Sys.cpu; extra: Sys.cpuTemp }
        SysChip { icon: "monitor"; pct: Sys.gpu; extra: Sys.gpuTemp }
        SysChip { icon: "memory-stick"; pct: Sys.ram }
        SysChip { icon: "hard-drive"; pct: Sys.disk }
      }

      Row {
        spacing: 6
        BrutButton {
          icon: Sys.wifi ? "wifi" : "wifi-off"; width: 24; pad: 0; radius: 11
          active: Sys.wifi; activeFill: Theme.blueLight
          onClicked: Sys.toggle("wifi")
          onRightClicked: Sys.toggleWifi()
        }
        BrutButton {
          icon: Sys.bt ? "bluetooth" : "bluetooth-off"; width: 24; pad: 0; radius: 11
          active: Sys.bt; activeFill: Theme.lavender
          onClicked: Sys.toggle("bluetooth")
          onRightClicked: Sys.toggleBt()
        }
        BrutButton {
          icon: Sys.muted ? "volume-x" : "volume-2"
          text: Sys.muted ? "" : Sys.volume + "%"
          pad: 6; radius: 11
          active: !Sys.muted; activeFill: Theme.pink
          onClicked: Sys.toggle("sound")
          onRightClicked: Sys.toggleMute()
          onWheel: d => Sys.setVolume(Math.max(0, Math.min(100, Sys.volume + (d > 0 ? 5 : -5))))
        }
      }

      BrutButton {
        icon: "settings"; width: 24; pad: 0; radius: 11
        active: Sys.panel === "settings"; activeFill: Theme.green
        onClicked: Sys.toggle("settings")
      }

      BrutButton {
        icon: "clock"; radius: 11
        text: Qt.formatDateTime(clock.date, "HH:mm MMMM dd, yyyy")
        fill: Theme.lavender
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
      }
    }
  }
}
