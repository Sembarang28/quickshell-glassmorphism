import Quickshell.Bluetooth
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

PopupFrame {
  id: root
  title: "Bluetooth"
  icon: adapter && adapter.enabled ? "bluetooth" : "bluetooth-off"
  height: 400
  showSwitch: adapter !== null
  on: adapter ? adapter.enabled : false
  onToggled: if (adapter) adapter.enabled = !adapter.enabled
  onOpenChanged: if (adapter) adapter.discovering = open && adapter.enabled

  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property var devices: {
    if (!adapter) return []
    return adapter.devices.values.filter(d => d.name && d.name !== "")
      .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
  }

  Text {
    visible: !root.adapter
    width: parent.width
    wrapMode: Text.WordWrap
    text: "No Bluetooth adapter found.\nStart the service:\nsudo systemctl enable --now bluetooth"
    font.family: Theme.font; font.bold: true; font.pixelSize: 13; color: Theme.ink
  }
  Row {
    visible: root.adapter !== null
    id: bar
    spacing: 8
    width: parent.width
    Text {
      width: parent.width - scanBtn.width - 8
      anchors.verticalCenter: parent.verticalCenter
      text: root.adapter && root.adapter.discovering ? "Scanning..." : root.devices.length + " devices"
      font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink
    }
    BrutButton {
      id: scanBtn; icon: "refresh-cw"; text: "Scan"
      active: root.adapter && root.adapter.discovering
      onClicked: root.adapter.discovering = !root.adapter.discovering
    }
  }
  ListView {
    visible: root.adapter !== null
    y: 38
    width: parent.width
    height: parent.height - 38
    clip: true
    spacing: 6
    model: root.adapter && root.adapter.enabled ? root.devices : []
    delegate: RowButton {
      required property var modelData
      width: ListView.view.width
      icon: modelData.connected ? "bluetooth" : "signal"
      text: modelData.name
      status: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "")
      active: modelData.connected
      onClicked: {
        if (modelData.connected) modelData.disconnect()
        else if (modelData.paired) modelData.connect()
        else modelData.pair()
      }
    }
  }
}
