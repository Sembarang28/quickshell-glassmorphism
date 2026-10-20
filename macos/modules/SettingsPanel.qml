import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// Control Center
Item {
  id: root
  width: 340
  height: content.height + 24

  property bool open: false
  visible: opacity > 0
  opacity: open ? 1 : 0
  scale: open ? 1 : 0.97
  transformOrigin: Item.TopRight
  Behavior on opacity { NumberAnimation { duration: 120 } }
  Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

  readonly property var player: {
    var ps = Mpris.players.values
    for (var i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
    return ps.length ? ps[0] : null
  }

  readonly property var order: ["power-saver", "balanced", "performance"]
  readonly property var names: ({ "power-saver": "Low Power", "balanced": "Balanced", "performance": "Performance" })
  readonly property int cw: 154   // half-width cell
  readonly property int g: 8

  component Label: Text { font.family: Theme.font; font.pixelSize: 13; color: Theme.ink }
  component Sub: Text { font.family: Theme.font; font.pixelSize: 11; color: Theme.textMuted; elide: Text.ElideRight }

  component RateRow: Item {
    property string icon; property string label; property string value
    width: parent.width; height: 22
    Icon { x: 3; anchors.verticalCenter: parent.verticalCenter; name: icon; size: 14; color: Theme.textMuted }
    Label { x: 30; anchors.verticalCenter: parent.verticalCenter; text: parent.label; font.pixelSize: 12 }
    Sub { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: parent.value }
  }

  // round icon badge used by every toggle in Control Center
  component Badge: Rectangle {
    property string icon
    property bool on
    property color onColor: Theme.accent
    width: 30; height: 30; radius: 15
    color: on ? onColor : Theme.off
    Behavior on color { ColorAnimation { duration: 100 } }
    Icon { anchors.centerIn: parent; name: parent.icon; size: 15; color: "white" }
  }

  // one row inside the connectivity module
  component Toggle: Item {
    id: t
    property string icon; property string label; property string sub
    property bool on; property color onColor: Theme.accent
    signal clicked()
    signal rightClicked()
    width: parent.width; height: 44
    Badge { id: b; icon: t.icon; on: t.on; onColor: t.onColor; anchors.verticalCenter: parent.verticalCenter }
    Column {
      x: 38; width: parent.width - 38; anchors.verticalCenter: parent.verticalCenter
      Label { width: parent.width; text: t.label; font.bold: true; font.pixelSize: 12; elide: Text.ElideRight }
      Sub { width: parent.width; text: t.sub }
    }
    MouseArea { anchors.fill: parent; acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: m => { if (m.button === Qt.RightButton) t.rightClicked(); else t.clicked() } }
  }

  Rectangle { anchors.fill: parent; anchors.margins: -1; radius: 19; color: "transparent"; border.width: 1; border.color: Theme.glassBorder }
  Card {
    anchors.fill: parent
    fill: Theme.panel; radius: 18; margins: 12

    Column {
      id: content
      width: parent.width
      spacing: root.g

      // ===== connectivity + tiles =====
      Item {
        width: parent.width; height: 146
        Card {
          width: root.cw; height: parent.height; margins: 10
          Column {
            anchors.fill: parent; spacing: 4
            Toggle { icon: Sys.wifi ? "wifi" : "wifi-off"; label: "Wi-Fi"; sub: Sys.wifi ? (Sys.wifiName || "On") : "Off"; on: Sys.wifi
                     onClicked: Sys.panel = "wifi"; onRightClicked: Sys.toggleWifi() }
            Toggle { icon: Sys.bt ? "bluetooth" : "bluetooth-off"; label: "Bluetooth"; sub: Sys.bt ? "On" : "Off"; on: Sys.bt
                     onClicked: Sys.panel = "bluetooth"; onRightClicked: Sys.toggleBt() }
            Toggle { icon: "plane"; label: "Airplane Mode"; sub: Sys.airplane ? "On" : "Off"; on: Sys.airplane; onColor: Theme.peach
                     onClicked: Sys.toggleAirplane() }
          }
        }
        Column {
          x: root.cw + root.g; width: root.cw; spacing: root.g
          Card {
            width: parent.width; height: 69; margins: 10
            Row {
              anchors.verticalCenter: parent.verticalCenter; spacing: 8
              Badge { icon: Sys.profile === "power-saver" ? "leaf" : (Sys.profile === "performance" ? "rocket" : "scale")
                      on: Sys.profile !== "balanced"; onColor: Sys.profile === "performance" ? Theme.red : Theme.accent }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                Label { text: "Power Mode"; font.bold: true; font.pixelSize: 12 }
                Sub { text: root.names[Sys.profile] || Sys.profile }
              }
            }
            MouseArea { anchors.fill: parent; anchors.margins: -10
                        onClicked: { var o = root.order; Sys.setProfile(o[(o.indexOf(Sys.profile) + 1) % o.length]) } }
          }
          Row {
            spacing: root.g
            Card {
              width: (root.cw - root.g) / 2; height: 69; margins: 0
              Badge { anchors.centerIn: parent; icon: Sys.muted ? "volume-x" : "volume-2"; on: Sys.muted; onColor: Theme.red }
              MouseArea { anchors.fill: parent; onClicked: Sys.toggleMute() }
            }
            Card {
              width: (root.cw - root.g) / 2; height: 69; margins: 0
              Badge { anchors.centerIn: parent; icon: "search"; on: false }
              MouseArea { anchors.fill: parent; onClicked: Sys.panel = "launcher" }
            }
          }
        }
      }

      // ===== display =====
      Card {
        width: parent.width; height: 62; margins: 12
        Label { text: "Display"; font.bold: true; font.pixelSize: 12 }
        HSlider { y: 22; width: parent.width; icon: "sun"; value: Sys.brightness; onMoved: v => Sys.setBrightness(v) }
      }

      // ===== sound =====
      Card {
        width: parent.width; height: 62; margins: 12
        Label { text: "Sound"; font.bold: true; font.pixelSize: 12 }
        HSlider { y: 22; width: parent.width; icon: Sys.muted ? "volume-x" : "volume-2"; value: Sys.volume; onMoved: v => Sys.setVolume(v) }
      }

      // ===== now playing =====
      Card {
        width: parent.width; height: 64; margins: 10
        Rectangle {
          id: art
          width: 44; height: 44; radius: 8; clip: true
          anchors.verticalCenter: parent.verticalCenter
          color: "#33FFFFFF"
          Image { anchors.fill: parent; fillMode: Image.PreserveAspectCrop; source: root.player ? root.player.trackArtUrl : "" }
          Icon { visible: !root.player || root.player.trackArtUrl === ""; anchors.centerIn: parent; name: "headphones"; size: 22; color: Theme.textMuted }
        }
        Column {
          x: 54; width: parent.width - 54 - 104
          anchors.verticalCenter: parent.verticalCenter
          Label { width: parent.width; elide: Text.ElideRight; font.bold: true; font.pixelSize: 12
                  text: root.player ? (root.player.trackTitle || "Unknown") : "Not Playing" }
          Sub { width: parent.width; text: root.player ? (root.player.trackArtist || "") : "" }
        }
        Row {
          anchors { right: parent.right; verticalCenter: parent.verticalCenter }
          spacing: 2
          BrutButton { icon: "skip-back"; iconSize: 15; width: 32; height: 32; radius: 16; pad: 0; onClicked: if (root.player) root.player.previous() }
          BrutButton { icon: root.player && root.player.isPlaying ? "pause" : "play"; iconSize: 17; width: 32; height: 32; radius: 16; pad: 0
                       onClicked: if (root.player) root.player.togglePlaying() }
          BrutButton { icon: "skip-forward"; iconSize: 15; width: 32; height: 32; radius: 16; pad: 0; onClicked: if (root.player) root.player.next() }
        }
      }

      // ===== activity =====
      Card {
        width: parent.width; height: 4 * 26 + 2 * 22 + 24; margins: 12
        Column {
          anchors.fill: parent
          StatRow { width: parent.width; icon: "cpu"; label: "CPU"; pct: Sys.cpu; extra: Sys.cpuTemp; iconFill: Theme.accent; barColor: Theme.accent }
          StatRow { width: parent.width; icon: "monitor"; label: "GPU"; pct: Sys.gpu; extra: Sys.gpuTemp; iconFill: Theme.lavender; barColor: Theme.lavender }
          StatRow { width: parent.width; icon: "memory-stick"; label: "RAM"; pct: Sys.ram; extra: Sys.ramTemp; iconFill: Theme.accent; barColor: Theme.accent }
          StatRow { width: parent.width; icon: "hard-drive"; label: "Disk"; pct: Sys.disk; extra: Sys.diskTemp; iconFill: Theme.peach; barColor: Theme.peach }
          RateRow { icon: "hard-drive"; label: "Disk I/O"; value: "R " + Sys.fmtRate(Sys.diskRead) + "   W " + Sys.fmtRate(Sys.diskWrite) }
          RateRow { icon: "signal"; label: "Network"; value: "↓ " + Sys.fmtRate(Sys.netDown) + "   ↑ " + Sys.fmtRate(Sys.netUp) }
        }
      }

      // ===== footer =====
      Item {
        width: parent.width; height: 24
        Label { anchors.verticalCenter: parent.verticalCenter; text: "System Settings…"; font.pixelSize: 12; color: Theme.textMuted
                MouseArea { anchors.fill: parent; onClicked: Sys.panel = "prefs" } }
        Sub { anchors { right: parent.right; verticalCenter: parent.verticalCenter }
              text: Sys.weather ? (Sys.weather + "  " + Sys.weatherCond) : "" }
      }
    }
  }
}
