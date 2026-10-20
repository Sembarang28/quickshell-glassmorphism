import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// System Settings window: sidebar + detail pane
Item {
  id: root
  property bool open: false
  width: 780; height: 520
  visible: opacity > 0
  opacity: open ? 1 : 0
  scale: open ? 1 : 0.97
  Behavior on opacity { NumberAnimation { duration: 130 } }
  Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
  onOpenChanged: if (open) page = "about"

  property string page: "about"
  readonly property var pages: [
    { id: "wifi", title: "Wi-Fi", icon: "wifi", color: Theme.accent },
    { id: "bt", title: "Bluetooth", icon: "bluetooth", color: Theme.accent },
    { id: "sound", title: "Sound", icon: "volume-2", color: Theme.red },
    { id: "display", title: "Displays", icon: "sun", color: Theme.accent },
    { id: "energy", title: "Battery & Energy", icon: "leaf", color: Theme.green },
    { id: "about", title: "General", icon: "settings", color: Theme.gray }
  ]
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
  PwObjectTracker { objects: root.sinks }

  component Label: Text { font.family: Theme.font; font.pixelSize: 13; color: Theme.ink }
  component Group: Rectangle {
    default property alias rows: col.data
    width: parent.width; height: col.height
    radius: 10; color: "#14FFFFFF"; border.width: 1; border.color: "#14FFFFFF"
    Column { id: col; width: parent.width }
  }
  component Row_: Item {
    property string label; property string value
    width: parent.width; height: 34
    Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: parent.label }
    Label { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
            width: parent.width - 150; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight
            text: parent.value; color: Theme.textMuted }
    Rectangle { anchors.bottom: parent.bottom; x: 14; width: parent.width - 14; height: 1; color: Theme.divider }
  }

  Rectangle { anchors.fill: parent; radius: 12; color: Theme.panel; border.width: 1; border.color: Theme.glassBorder; clip: true
    MouseArea { anchors.fill: parent }

    // traffic lights
    Row {
      x: 14; y: 14; spacing: 8
      Rectangle { width: 12; height: 12; radius: 6; color: "#FF5F57"
                  MouseArea { anchors.fill: parent; onClicked: Sys.close() } }
      Rectangle { width: 12; height: 12; radius: 6; color: "#FEBC2E" }
      Rectangle { width: 12; height: 12; radius: 6; color: "#28C840" }
    }

    // ===== sidebar =====
    Rectangle { x: 0; y: 0; width: 230; height: parent.height; color: "#14000000"
      Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.divider }
      Column {
        x: 12; y: 48; width: parent.width - 24; spacing: 2
        // profile
        Item {
          width: parent.width; height: 56
          Rectangle { id: av; width: 40; height: 40; radius: 20; clip: true; anchors.verticalCenter: parent.verticalCenter; color: Theme.gray
            Image { anchors.fill: parent; source: Qt.resolvedUrl("../shared/assets/profile.jpeg"); fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(96, 96) } }
          Column { x: 50; anchors.verticalCenter: parent.verticalCenter
            Label { text: Quickshell.env("USER") || "user"; font.bold: true }
            Label { text: Sys.specs.host || ""; font.pixelSize: 11; color: Theme.textMuted } }
        }
        Item { width: 1; height: 8 }
        Repeater {
          model: root.pages
          Rectangle {
            required property var modelData
            width: parent.width; height: 32; radius: 7
            color: root.page === modelData.id ? Theme.accent : "transparent"
            Rectangle { id: sq; x: 6; width: 22; height: 22; radius: 6; anchors.verticalCenter: parent.verticalCenter; color: modelData.color
              Icon { anchors.centerIn: parent; name: modelData.icon; size: 13; color: "white" } }
            Label { x: 36; anchors.verticalCenter: parent.verticalCenter; text: modelData.title }
            MouseArea { anchors.fill: parent; onClicked: root.page = modelData.id }
          }
        }
      }
    }

    // ===== detail =====
    Item {
      x: 230; width: parent.width - 230; height: parent.height
      Icon { visible: root.page === "about"; x: parent.width / 2 - 28; y: 48; name: "arch"; size: 56; color: "#1793D1" }
      Label { visible: root.page === "about"; width: parent.width; y: 110; horizontalAlignment: Text.AlignHCenter
              text: "Arch Linux"; font.bold: true; font.pixelSize: 20 }
      Label { x: 24; y: 14; text: { for (var i = 0; i < root.pages.length; i++) if (root.pages[i].id === root.page) return root.pages[i].title; return "" }
              font.bold: true; font.pixelSize: 16 }

      Flickable {
        x: 24; y: root.page === "about" ? 146 : 52; width: parent.width - 48; height: parent.height - y - 16
        contentHeight: pane.height; clip: true
        Column {
          id: pane
          width: parent.width; spacing: 16

          // --- General / About ---
          Group { visible: root.page === "about"
            Row_ { label: "Name"; value: Sys.specs.host || "-" }
            Row_ { label: "Operating System"; value: Sys.specs.os || "-" }
            Row_ { label: "Kernel"; value: Sys.specs.kernel || "-" }
            Row_ { label: "Window Manager"; value: "niri" }
            Row_ { label: "Shell"; value: Sys.specs.shell || "-" }
            Row_ { label: "Processor"; value: Sys.specs.cpu || "-" }
            Row_ { label: "Graphics"; value: Sys.specs.gpu || "-" }
            Row_ { label: "Memory"; value: Sys.specs.ramTotal ? Sys.specs.ramTotal + " GB" : "-" }
            Row_ { label: "Packages"; value: Sys.specs.pkgs || "-" }
            Row_ { label: "Uptime"; value: Sys.specs.uptime || "-" }
          }

          // --- Wi-Fi / Bluetooth / Airplane ---
          Group { visible: root.page === "wifi"
            Item { width: parent.width; height: 40
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Wi-Fi" }
              Switch { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } checked: Sys.wifi; onClicked: Sys.toggleWifi() } }
            Row_ { label: "Network"; value: Sys.wifi ? (Sys.wifiName || "Not connected") : "Off" }
          }
          Group { visible: root.page === "bt"
            Item { width: parent.width; height: 40
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Bluetooth" }
              Switch { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } checked: Sys.bt; onClicked: Sys.toggleBt() } }
            Item { width: parent.width; height: 40
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Airplane Mode" }
              Switch { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } checked: Sys.airplane; onClicked: Sys.toggleAirplane() } }
          }

          // --- Sound ---
          Group { visible: root.page === "sound"
            Item { width: parent.width; height: 48
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Output volume" }
              HSlider { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } width: 240
                        icon: Sys.muted ? "volume-x" : "volume-2"; value: Sys.volume; onMoved: v => Sys.setVolume(v) } }
            Item { width: parent.width; height: 40
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Mute" }
              Switch { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } checked: Sys.muted; onClicked: Sys.toggleMute() } }
          }
          Group { visible: root.page === "sound"
            Repeater {
              model: root.sinks
              Item {
                required property var modelData
                width: pane.width; height: 36
                Label { x: 14; width: parent.width - 60; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter
                        text: modelData.description || modelData.nickname || modelData.name }
                Icon { visible: Pipewire.defaultAudioSink === modelData; anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                       name: "check"; size: 16; color: Theme.accent }
                MouseArea { anchors.fill: parent; onClicked: Pipewire.preferredDefaultAudioSink = modelData }
              }
            }
          }

          // --- Displays ---
          Group { visible: root.page === "display"
            Item { width: parent.width; height: 48
              Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: "Brightness" }
              HSlider { anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter } width: 240
                        icon: "sun"; value: Sys.brightness; onMoved: v => Sys.setBrightness(v) } }
          }

          // --- Energy ---
          Group { visible: root.page === "energy"
            Repeater {
              model: [["power-saver", "Low Power"], ["balanced", "Balanced"], ["performance", "High Performance"]]
              Item {
                required property var modelData
                width: pane.width; height: 38
                Label { x: 14; anchors.verticalCenter: parent.verticalCenter; text: modelData[1] }
                Icon { visible: Sys.profile === modelData[0]; anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                       name: "check"; size: 16; color: Theme.accent }
                MouseArea { anchors.fill: parent; onClicked: Sys.setProfile(modelData[0]) }
              }
            }
          }
        }
      }
    }
  }
}
