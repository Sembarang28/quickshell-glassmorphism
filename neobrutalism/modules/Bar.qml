import Quickshell
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

PanelWindow {
  id: bar
  anchors { top: true; left: true; right: true }
  implicitHeight: Theme.barHeight
  color: Theme.panel

  SystemClock { id: clock; precision: SystemClock.Minutes }

  Rectangle {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
    height: 3; color: Theme.ink
  }

  // ===== KIRI: launcher | workspaces | aplikasi aktif =====
  Row {
    anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter; verticalCenterOffset: -1 }
    spacing: 10

    BrutButton {
      icon: "layout-grid"
      pad: 8
      fill: Theme.peach
      active: Sys.panel === "launcher"
      activeFill: Theme.green
      onClicked: Sys.toggle("launcher")
    }

    Row {
      spacing: 6
      Repeater {
        model: Sys.workspaces.filter(w => w.output === bar.screen.name)
        BrutButton {
          required property var modelData
          text: String(modelData.idx)
          width: 22; pad: 0;
          active: modelData.is_active
          activeFill: Theme.yellow
          onClicked: Sys.focusWorkspace(modelData.idx)
        }
      }
    }

    BrutButton {
      visible: Sys.focusedApp !== ""
      text: Sys.focusedApp
      icon: Sys.focusedIcon === "" ? "app-window" : ""
      iconUrl: Sys.focusedIcon === "" ? "" : Quickshell.iconPath(Sys.focusedIcon, "application-x-executable")
      iconSize: 16
      maxTextWidth: 220
      MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
    }
  }

  // ===== KANAN (kiri -> kanan): sysmon | shortcut | settings | datetime =====
  Row {
    anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter; verticalCenterOffset: -1 }
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
        icon: Sys.wifi ? "wifi" : "wifi-off"; width: 24; pad: 0;
        active: Sys.wifi; fill: Theme.off; activeFill: Theme.blueLight
        onClicked: Sys.toggle("wifi")
        onRightClicked: Sys.toggleWifi()
      }
      BrutButton {
        icon: Sys.bt ? "bluetooth" : "bluetooth-off"; width: 24; pad: 0;
        active: Sys.bt; fill: Theme.off; activeFill: Theme.lavender
        onClicked: Sys.toggle("bluetooth")
        onRightClicked: Sys.toggleBt()
      }
      BrutButton {
        icon: Sys.muted ? "volume-x" : "volume-2"
        text: Sys.muted ? "" : Sys.volume + "%"
        pad: 6;
        active: !Sys.muted; fill: Theme.off; activeFill: Theme.pink
        onClicked: Sys.toggle("sound")
        onRightClicked: Sys.toggleMute()
        onWheel: d => Sys.setVolume(Math.max(0, Math.min(100, Sys.volume + (d > 0 ? 5 : -5))))
      }
    }

    BrutButton {
      icon: "settings"
      width: 24; pad: 0;
      active: Sys.panel === "settings"
      activeFill: Theme.green
      onClicked: Sys.toggle("settings")
    }

    BrutButton {
      icon: "clock"
      text: Qt.formatDateTime(clock.date, "HH:mm MMMM dd, yyyy")
      fill: Theme.lavender
      MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
    }
  }
}
