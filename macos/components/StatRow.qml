import QtQuick
import "../services"
import "../shared/components"

Item {
  id: root
  property string icon
  property string label
  property real pct
  property string extra: ""
  property color iconFill: Theme.accent
  property color barColor: Theme.accent
  height: 26
  Rectangle {
    id: box
    width: 22; height: 22; radius: 6
    anchors.verticalCenter: parent.verticalCenter
    color: root.iconFill
    Icon { anchors.centerIn: parent; name: root.icon; size: 12; color: "white" }
  }
  Text {
    x: 30; width: 34; anchors.verticalCenter: parent.verticalCenter
    text: root.label
    font.family: Theme.font; font.pixelSize: 12; color: Theme.ink
  }
  Rectangle {
    x: 66; width: root.width - 66 - 66; height: 5
    anchors.verticalCenter: parent.verticalCenter
    radius: 2.5; color: "#33FFFFFF"
    Rectangle {
      height: parent.height; radius: 2.5; color: root.barColor
      width: parent.width * Math.min(100, root.pct) / 100
      Behavior on width { NumberAnimation { duration: 250 } }
    }
  }
  Text {
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    text: Math.round(root.pct) + "%" + (root.extra ? " " + root.extra : "")
    font.family: Theme.font; font.pixelSize: 11; color: Theme.textMuted
  }
}
