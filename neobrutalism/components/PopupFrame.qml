import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Dropdown popup frame under the bar: header (icon, title, optional switch, close) + content
Item {
  id: root
  property bool open: false
  property string title: ""
  property string icon: ""
  property bool showSwitch: true
  property bool on: false
  signal toggled()
  default property alias content: body.data
  readonly property alias body: body
  width: 340; height: 420

  visible: opacity > 0
  opacity: open ? 1 : 0
  scale: open ? 1 : 0.94
  transformOrigin: Item.TopRight
  Behavior on opacity { NumberAnimation { duration: 120 } }
  Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  Card {
    anchors.fill: parent
    fill: Theme.panel; shadow: 6; radius: 16; margins: 12

    Item {
      id: header
      width: parent.width; height: 30
      Row {
        spacing: 8; anchors.verticalCenter: parent.verticalCenter
        Icon { name: root.icon; size: 20; anchors.verticalCenter: parent.verticalCenter }
        Text {
          text: root.title
          font.family: Theme.font; font.bold: true; font.pixelSize: 17; color: Theme.ink
          anchors.verticalCenter: parent.verticalCenter
        }
      }
      Row {
        anchors.right: parent.right; spacing: 8
        BrutButton {
          visible: root.showSwitch
          text: root.on ? "ON" : "OFF"
          active: root.on; fill: Theme.off; activeFill: Theme.green
          onClicked: root.toggled()
        }
        BrutButton { icon: "x"; pad: 8; fill: Theme.pink; onClicked: Sys.close() }
      }
    }
    Item {
      id: body
      y: header.height + 10
      width: parent.width; height: parent.height - y
    }
  }
}
