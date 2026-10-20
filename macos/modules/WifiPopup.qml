import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

PopupFrame {
  id: root
  title: "Wi-Fi"
  icon: Sys.wifi ? "wifi" : "wifi-off"
  on: Sys.wifi
  height: 430
  onToggled: Sys.toggleWifi()
  onOpenChanged: if (open) { pending = ""; Net.status = ""; Net.refresh() }

  property string pending: ""   // ssid waiting for a password

  Row {
    id: bar
    spacing: 8
    width: parent.width
    Text {
      width: parent.width - refreshBtn.width - 8
      anchors.verticalCenter: parent.verticalCenter
      text: Net.scanning ? "Scanning..." : Net.networks.length + " networks"
      font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink
    }
    BrutButton { id: refreshBtn; icon: "refresh-cw"; text: "Scan"; onClicked: Net.refresh() }
  }

  ListView {
    y: 38
    width: parent.width
    height: parent.height - 38 - 28
    clip: true
    spacing: 6
    model: Sys.wifi ? Net.networks : []
    delegate: Item {
      id: row
      required property var modelData
      readonly property bool asking: root.pending === modelData.ssid
      width: ListView.view.width
      height: 40 + Theme.shadow + (asking ? 44 : 0)

      RowButton {
        width: parent.width; height: 40 + Theme.shadow
        icon: modelData.secure ? "lock" : "wifi"
        text: modelData.ssid
        status: modelData.active ? "Connected" : modelData.signal + "%"
        active: modelData.active
        onClicked: {
          if (modelData.active) Net.disconnectFrom(modelData.ssid)
          else if (modelData.saved || !modelData.secure) Net.connectTo(modelData.ssid, "")
          else root.pending = asking ? "" : modelData.ssid
        }
      }
      Row {
        visible: row.asking
        y: 46; spacing: 8; width: parent.width
        Rectangle {
          width: parent.width - 80 - 8; height: 34; radius: 10
          color: Theme.cream
          TextInput {
            id: pw
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password; color: Theme.ink
            font.family: Theme.font; font.bold: true; font.pixelSize: 13
            clip: true
            onVisibleChanged: if (visible) forceActiveFocus()
            Keys.onReturnPressed: { Net.connectTo(modelData.ssid, text); root.pending = "" }
            Text { visible: pw.text === ""; anchors.verticalCenter: parent.verticalCenter; text: "Password"; color: Theme.textMuted; font: pw.font }
          }
        }
        BrutButton { text: "Join"; fill: Theme.accent; onClicked: { Net.connectTo(modelData.ssid, pw.text); root.pending = "" } }
      }
    }
  }
  Text {
    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
    elide: Text.ElideRight
    text: !Sys.wifi ? "Wi-Fi is off" : Net.status
    font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: Theme.textMuted
  }
}
