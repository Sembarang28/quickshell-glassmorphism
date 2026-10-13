import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// Dashboard popup in the center of the screen
Item {
  id: root
  width: 788 + 24 + 7
  height: 550 + 24 + 7

  property bool open: false
  property string armed: ""   // press twice to confirm session actions
  visible: opacity > 0
  opacity: open ? 1 : 0
  scale: open ? 1 : 0.93
  Behavior on opacity { NumberAnimation { duration: 140 } }
  Behavior on scale { NumberAnimation { duration: 170; easing.type: Easing.OutBack } }
  onOpenChanged: if (!open) armed = ""
  Timer { interval: 3000; running: root.armed !== ""; onTriggered: root.armed = "" }
  function session(name, cmd) { if (armed === name) { Sys.run(cmd); Sys.close() } else armed = name }

  SystemClock { id: clock; precision: SystemClock.Seconds }

  readonly property var player: {
    var ps = Mpris.players.values
    for (var i = 0; i < ps.length; i++) if (ps[i].isPlaying) return ps[i]
    return ps.length ? ps[0] : null
  }
  Timer {
    interval: 1000; repeat: true
    running: root.open && root.player !== null && root.player.isPlaying
    onTriggered: root.player.positionChanged()
  }
  function fmt(s) { s = Math.max(0, Math.floor(s)); return Math.floor(s / 60) + ":" + ("0" + (s % 60)).slice(-2) }

  readonly property string greeting: {
    var h = clock.date.getHours()
    return h < 5 ? "Burning the midnight oil. Don't forget to sleep."
         : h < 11 ? "Good morning! A fresh start for the day."
         : h < 15 ? "Good afternoon. Keep up the momentum."
         : h < 19 ? "Good evening. Almost wrapping up."
         : "A peaceful evening, perfect for compiling."
  }

  readonly property int g: 10
  readonly property int c1: 170
  readonly property int c2: 250
  readonly property int c3: 90
  readonly property int c4: 248
  readonly property int x2: c1 + g
  readonly property int x3: x2 + c2 + g
  readonly property int x4: x3 + c3 + g

  component Small: Text {
    font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: "#6b5c55"
  }

  Card {
    anchors.fill: parent
    fill: Theme.panel; shadow: 7; radius: 18; margins: 12

    // ===== profile =====
    Card {
      x: 0; y: 0; width: root.c1; height: 150
      Column {
        anchors.centerIn: parent; spacing: 6
        Rectangle {
          width: 64; height: 64; radius: 14
          clip: true
          anchors.horizontalCenter: parent.horizontalCenter
          color: Theme.blueLight; border.width: Theme.border; border.color: Theme.ink
          Image {
            anchors.fill: parent; anchors.margins: 2
            source: Qt.resolvedUrl("../shared/assets/profile.jpeg")
            fillMode: Image.PreserveAspectCrop
            asynchronous: true; smooth: true
            sourceSize: Qt.size(160, 160)
          }
        }
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: Quickshell.env("USER") || "user"
          font.family: Theme.font; font.bold: true; font.pixelSize: 15; color: Theme.ink
        }
        Small { anchors.horizontalCenter: parent.horizontalCenter; text: (Quickshell.env("USER") || "user") + "@" + Sys.specs.host }
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          width: online.implicitWidth + 24; height: 18; radius: 9
          color: Theme.green; border.width: Theme.border; border.color: Theme.ink
          Text { id: online; anchors.centerIn: parent; text: "● Online"; font.family: Theme.font; font.bold: true; font.pixelSize: 10; color: Theme.ink }
        }
      }
    }

    // ===== quick list =====
    Card {
      x: 0; y: 160; width: root.c1; height: 390
      Column {
        anchors.fill: parent; spacing: 6
        RowButton { width: parent.width; height: 68; icon: Sys.wifi ? "wifi" : "wifi-off"; text: "Wi-Fi"
          status: Sys.wifi ? (Sys.wifiName || "On") : "Off"; active: Sys.wifi; activeFill: Theme.blueLight
          onClicked: Sys.panel = "wifi" }
        RowButton { width: parent.width; height: 68; icon: Sys.bt ? "bluetooth" : "bluetooth-off"; text: "Bluetooth"
          status: Sys.bt ? "On" : "Off"; active: Sys.bt; activeFill: Theme.lavender
          onClicked: Sys.panel = "bluetooth" }
        RowButton { width: parent.width; height: 68; icon: Sys.muted ? "volume-x" : "volume-2"; text: "Sound"
          status: Sys.muted ? "Muted" : Sys.volume + "%"; active: !Sys.muted; activeFill: Theme.peach
          onClicked: Sys.panel = "sound" }
        RowButton { width: parent.width; height: 68; icon: "plane"; text: "Airplane"
          status: Sys.airplane ? "On" : "Off"; active: Sys.airplane; activeFill: Theme.pink
          onClicked: Sys.toggleAirplane() }
        RowButton { width: parent.width; height: 68; icon: "layout-grid"; text: "Apps"
          onClicked: Sys.panel = "launcher" }
      }
    }

    // ===== clock =====
    Card {
      x: root.x2; y: 0; width: root.c2; height: 80
      Row {
        anchors.centerIn: parent; spacing: 14
        Row {
          anchors.verticalCenter: parent.verticalCenter; spacing: 3
          Text {
            text: Qt.formatDateTime(clock.date, "hh:mm")
            font.family: Theme.font; font.bold: true; font.pixelSize: 34; color: Theme.ink
          }
          Text {
            anchors.baseline: undefined; y: 18
            text: Qt.formatDateTime(clock.date, "AP")
            font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: "#6b5c55"
          }
        }
        Rectangle { width: 2; height: 40; color: Theme.ink; anchors.verticalCenter: parent.verticalCenter }
        Column {
          anchors.verticalCenter: parent.verticalCenter; spacing: 2
          Text { text: Qt.formatDateTime(clock.date, "dddd").toUpperCase(); font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink }
          Small { text: Qt.formatDateTime(clock.date, "MMMM d, yyyy") }
        }
      }
    }

    // ===== weather + greeting =====
    Card {
      x: root.x2; y: 90; width: root.c2; height: 210
      Column {
        anchors.fill: parent; spacing: 8
        Rectangle {
          width: parent.width; height: 48; radius: 12
          color: Theme.cream; border.width: Theme.border; border.color: Theme.ink
          Row {
            anchors.centerIn: parent; spacing: 10
            Icon { name: "cloud-sun"; size: 22; anchors.verticalCenter: parent.verticalCenter }
            Text { text: Sys.weather || "--"; font.family: Theme.font; font.bold: true; font.pixelSize: 22; color: Theme.ink; anchors.verticalCenter: parent.verticalCenter }
            Rectangle { width: 2; height: 24; color: Theme.ink; anchors.verticalCenter: parent.verticalCenter }
            Text { text: Sys.weatherCond || "No data"; font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink; anchors.verticalCenter: parent.verticalCenter
                   width: Math.min(implicitWidth, 100); elide: Text.ElideRight }
          }
        }
        Rectangle {
          width: parent.width; height: parent.height - 56; radius: 12
          color: Theme.cream; border.width: Theme.border; border.color: Theme.ink
          Text {
            anchors { fill: parent; margins: 10 }
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            text: root.greeting
            font.family: Theme.font; font.bold: true; font.pixelSize: 15; color: Theme.ink
          }
        }
      }
    }

    // ===== sliders =====
    Card {
      x: root.x3; y: 0; width: root.c3; height: 300
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height; spacing: 10
        Column {
          spacing: 6
          BrutButton { icon: Sys.muted ? "volume-x" : "volume-2"; pad: 6; fill: Theme.peach; onClicked: Sys.toggleMute() }
          VSlider { height: 210; width: 28; fillColor: Theme.peach; value: Sys.volume; onMoved: v => Sys.setVolume(v) }
          Small { anchors.horizontalCenter: parent.horizontalCenter; text: Sys.volume + "%" }
        }
        Column {
          spacing: 6
          BrutButton { icon: "sun"; pad: 6; fill: Theme.green }
          VSlider { height: 210; width: 28; fillColor: Theme.green; value: Sys.brightness; onMoved: v => Sys.setBrightness(v) }
          Small { anchors.horizontalCenter: parent.horizontalCenter; text: Sys.brightness + "%" }
        }
      }
    }

    // ===== system specs =====
    Card {
      x: root.x4; y: 0; width: root.c4; height: 300
      Row {
        spacing: 6
        Icon { name: "monitor"; size: 16; anchors.verticalCenter: parent.verticalCenter }
        Text { text: "System Specs"; font.family: Theme.font; font.bold: true; font.pixelSize: 13; color: Theme.ink }
      }
      Rectangle { y: 24; width: parent.width; height: 1; color: "#b9aaa2" }
      Column {
        y: 34; spacing: 6
        component Spec: Rectangle {
          property string icon; property string label; property string value; property color tint
          property int span: 1
          property int w: 0
          width: w > 0 ? w : (span === 2 ? 228 : 110); height: 36; radius: 9
          color: Theme.cream; border.width: Theme.border; border.color: Theme.ink
          Rectangle {
            x: 6; width: 22; height: 22; radius: 6; anchors.verticalCenter: parent.verticalCenter
            color: tint; border.width: Theme.border; border.color: Theme.ink
            Icon { anchors.centerIn: parent; name: icon; size: 12 }
          }
          Column {
            x: 34; width: parent.width - 34 - 6; anchors.verticalCenter: parent.verticalCenter
            Text { text: label; font.family: Theme.font; font.pixelSize: 8; font.bold: true; color: "#6b5c55" }
            Text { width: parent.width; elide: Text.ElideRight; text: value; font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: Theme.ink }
          }
        }
        Row { spacing: 8
          Spec { icon: "layout-grid"; label: "OS"; value: Sys.specs.os || "-"; tint: Theme.peach }
          Spec { icon: "app-window"; label: "WM"; value: "Niri"; tint: Theme.blue } }
        Row { spacing: 8
          Spec { w: 144; icon: "settings"; label: "KERNEL"; value: Sys.specs.kernel || "-"; tint: Theme.yellow }
          Spec { w: 76; icon: "user"; label: "SHELL"; value: Sys.specs.shell || "-"; tint: Theme.green } }
        Row { spacing: 8
          Spec { icon: "monitor"; label: "HOST"; value: Sys.specs.host || "-"; tint: Theme.red }
          Spec { icon: "clock"; label: "UPTIME"; value: Sys.specs.uptime || "-"; tint: Theme.lavender } }
        Row { spacing: 8
          Spec { icon: "hard-drive"; label: "PACKAGES"; value: Sys.specs.pkgs || "-"; tint: Theme.green }
          Spec { icon: "memory-stick"; label: "RAM"; tint: Theme.blue
                 value: Sys.specs.ramTotal ? (Sys.specs.ramTotal * Sys.ram / 100).toFixed(1) + "/" + Sys.specs.ramTotal + " GB" : "-" } }
        Spec { span: 2; icon: "cpu"; label: "CPU"; value: Sys.specs.cpu || "-"; tint: Theme.peach }
        Spec { span: 2; icon: "monitor"; label: "GPU"; value: Sys.specs.gpu || "-"; tint: Theme.lavender }
      }
    }

    // ===== media player =====
    Card {
      x: root.x2; y: 310; width: root.c2 + root.g + root.c3; height: 140
      Rectangle {
        id: art
        width: 108; height: 108; radius: 12
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.blueLight; border.width: Theme.border; border.color: Theme.ink
        clip: true
        Image {
          anchors.fill: parent; anchors.margins: 2
          fillMode: Image.PreserveAspectCrop
          source: root.player ? root.player.trackArtUrl : ""
        }
        Icon { visible: !root.player || root.player.trackArtUrl === ""; anchors.centerIn: parent; name: "headphones"; size: 36 }
      }
      Column {
        x: 124; width: parent.width - 124
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        Text {
          width: parent.width; elide: Text.ElideRight
          text: root.player ? (root.player.trackTitle || "Unknown") : "Nothing playing"
          font.family: Theme.font; font.bold: true; font.pixelSize: 16; color: Theme.ink
        }
        Small { width: parent.width; elide: Text.ElideRight; text: root.player ? (root.player.trackArtist || "") : "Play something to see it here" }
        Item {
          id: dotsBox
          width: parent.width; height: 22
          readonly property int n: 18
          readonly property real prog: root.player && root.player.length > 0 ? root.player.position / root.player.length : 0
          Repeater {
            model: dotsBox.n
            Rectangle {
              required property int index
              readonly property bool filled: index / dotsBox.n < dotsBox.prog
              x: index * (dotsBox.width - 8) / (dotsBox.n - 1)
              anchors.verticalCenter: parent.verticalCenter
              width: filled ? 8 : 6; height: width; radius: width / 2
              color: filled ? [Theme.peach, Theme.peach, Theme.pink, Theme.yellow, Theme.green, Theme.green, Theme.blue, Theme.lavender][Math.floor(index / dotsBox.n * 8)] : Theme.gray
              Behavior on width { NumberAnimation { duration: 120 } }
            }
          }
        }
        Item {
          width: parent.width; height: 34
          Small { anchors.verticalCenter: parent.verticalCenter; text: root.fmt(root.player ? root.player.position : 0) }
          Row {
            anchors.centerIn: parent; spacing: 8
            BrutButton { icon: "skip-back"; pad: 7; onClicked: if (root.player) root.player.previous() }
            BrutButton { icon: root.player && root.player.isPlaying ? "pause" : "play"; pad: 9; fill: Theme.peach
                         onClicked: if (root.player) root.player.togglePlaying() }
            BrutButton { icon: "skip-forward"; pad: 7; onClicked: if (root.player) root.player.next() }
          }
          Small { anchors { right: parent.right; verticalCenter: parent.verticalCenter } text: root.fmt(root.player ? root.player.length : 0) }
        }
      }
    }

    // ===== usage =====
    Card {
      x: root.x4; y: 310; width: root.c4; height: 140
      Column {
        anchors.fill: parent; spacing: 2
        StatRow { width: parent.width; icon: "cpu"; label: "CPU"; pct: Sys.cpu; extra: Sys.cpuTemp; iconFill: Theme.peach; barColor: Theme.peach }
        StatRow { width: parent.width; icon: "monitor"; label: "GPU"; pct: Sys.gpu; extra: Sys.gpuTemp; iconFill: Theme.lavender; barColor: Theme.lavender }
        StatRow { width: parent.width; icon: "memory-stick"; label: "RAM"; pct: Sys.ram; iconFill: Theme.blue; barColor: Theme.blue }
        StatRow { width: parent.width; icon: "hard-drive"; label: "Disk"; pct: Sys.disk; iconFill: Theme.green; barColor: Theme.green }
      }
    }

    // ===== power profile + session tiles =====
    Card {
      x: root.x2; y: 460; width: 788 - root.x2; height: 90
      Row {
        anchors.fill: parent; spacing: 8
        readonly property real tw: (width - 48) / 7
        Repeater {
          model: [["power-saver", "leaf", "Saver"], ["balanced", "scale", "Balanced"], ["performance", "rocket", "Performance"]]
          BrutButton {
            required property var modelData
            width: parent.tw; height: parent.height - 4
            vertical: true; iconSize: 22; fontSize: 11; pad: 4
            icon: modelData[1]; text: modelData[2]
            fill: Theme.gray; active: Sys.profile === modelData[0]; activeFill: Theme.green
            onClicked: Sys.setProfile(modelData[0])
          }
        }
        BrutButton {
          width: parent.tw; height: parent.height - 4
          vertical: true; iconSize: 22; fontSize: 11; pad: 4
          icon: "log-out"; text: root.armed === "logout" ? "Sure?" : "Log out"
          fill: Theme.blueLight; active: root.armed === "logout"; activeFill: Theme.red
          onClicked: root.session("logout", ["niri", "msg", "action", "quit", "--skip-confirmation"])
        }
          BrutButton {
          width: parent.tw; height: parent.height - 4
          vertical: true; iconSize: 22; fontSize: 11; pad: 4
          icon: "moon"; text: root.armed === "hibernate" ? "Sure?" : "Hibernate"
          fill: Theme.lavender; active: root.armed === "hibernate"; activeFill: Theme.red
          onClicked: root.session("hibernate", ["systemctl", "hibernate"])
        }
        BrutButton {
          width: parent.tw; height: parent.height - 4
          vertical: true; iconSize: 22; fontSize: 11; pad: 4
          icon: "rotate-ccw"; text: root.armed === "restart" ? "Sure?" : "Restart"
          fill: Theme.pink; active: root.armed === "restart"; activeFill: Theme.red
          onClicked: root.session("restart", ["systemctl", "reboot"])
        }
        BrutButton {
          width: parent.tw; height: parent.height - 4
          vertical: true; iconSize: 22; fontSize: 11; pad: 4
          icon: "power"; text: root.armed === "shutdown" ? "Sure?" : "Shut down"
          fill: Theme.peach; active: root.armed === "shutdown"; activeFill: Theme.red
          onClicked: root.session("shutdown", ["systemctl", "poweroff"])
        }
      }
    }
  }
}
