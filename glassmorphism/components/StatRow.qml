import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Icon box + label + progress bar + value
Item {
  id: root
  property string icon
  property string label
  property real pct
  property string extra: ""
  property color iconFill: Theme.peach
  property color barColor: Theme.peach
  height: 28

  Rectangle {
    id: box
    width: 26; height: 26; radius: 7
    anchors.verticalCenter: parent.verticalCenter
    color: root.iconFill
    border.width: Theme.border; border.color: Theme.glassBorder
    Icon { anchors.centerIn: parent; name: root.icon; size: 14 }
  }
  Text {
    id: lb
    x: 34; width: 34
    anchors.verticalCenter: parent.verticalCenter
    text: root.label
    font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink
  }
  Rectangle {
    x: 70; width: root.width - 70 - 70; height: 12
    anchors.verticalCenter: parent.verticalCenter
    radius: 6; color: Theme.cream
    border.width: Theme.border; border.color: Theme.glassBorder
    Rectangle {
      x: 2; y: 2; height: parent.height - 4
      width: (parent.width - 4) * Math.min(100, root.pct) / 100
      visible: width >= 2
      radius: Math.min(4, width / 2); color: root.barColor
    }
  }
  Text {
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    horizontalAlignment: Text.AlignRight
    text: Math.round(root.pct) + "%" + (root.extra ? " " + root.extra : "")
    font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: Theme.ink
  }
}
