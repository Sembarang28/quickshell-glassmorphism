import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Control Center sub-panel: bold title, iOS-style switch, content
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
  width: 320; height: 420

  visible: opacity > 0
  opacity: open ? 1 : 0
  scale: open ? 1 : 0.96
  transformOrigin: Item.Top
  Behavior on opacity { NumberAnimation { duration: 120 } }
  Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

  Rectangle { anchors.fill: parent; anchors.margins: -1; radius: 19; color: "transparent"; border.width: 1; border.color: Theme.glassBorder }
  Card {
    anchors.fill: parent
    fill: Theme.panel; radius: 18; margins: 14

    Item {
      id: header
      width: parent.width; height: 28
      Text {
        text: root.title
        font.family: Theme.font; font.bold: true; font.pixelSize: 15; color: Theme.ink
        anchors.verticalCenter: parent.verticalCenter
      }
      Switch {
        visible: root.showSwitch
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        checked: root.on
        onClicked: root.toggled()
      }
    }
    Rectangle { y: header.height + 6; width: parent.width; height: 1; color: Theme.divider }
    Item {
      id: body
      y: header.height + 14
      width: parent.width; height: parent.height - y
    }
  }
}
