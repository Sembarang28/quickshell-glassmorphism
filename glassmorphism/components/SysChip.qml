import QtQuick
import "../services"
import "../shared/components"

// Glass chip with icon and a gauge fill proportional to the percentage
Item {
  id: root
  property string icon: ""
  property real pct: 0
  property string extra: ""
  readonly property int sh: 0
  implicitWidth: 12 + 12 + 5 + ghost.implicitWidth + 12
  implicitHeight: 22

  Rectangle { y: 2; width: parent.width; height: parent.height; radius: Theme.radius; color: Theme.shadowColor }
  Rectangle {
    id: face
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.cream
    border.width: Theme.border; border.color: Theme.glassBorder
    clip: true
    Rectangle {
      x: 1; y: 1; height: parent.height - 2
      width: (parent.width - 2) * Math.min(100, root.pct) / 100
      visible: width >= 2
      radius: Math.min(Theme.radius - 1, width / 2)
      color: root.pct >= 85 ? Theme.red : (root.pct >= 60 ? Theme.yellow : Theme.blue)
      opacity: 0.75
      Behavior on width { NumberAnimation { duration: 250 } }
    }
    Text {   // fixed-width template so the chip never jitters
      id: ghost
      visible: false
      text: root.extra ? "100% · 100°" : "100%"
      font.family: Theme.font; font.bold: true; font.pixelSize: 10
    }
    Row {
      id: row
      anchors.centerIn: parent
      spacing: 6
      Icon { name: root.icon; size: 12; anchors.verticalCenter: parent.verticalCenter }
      Text {
        anchors.verticalCenter: parent.verticalCenter
        width: ghost.implicitWidth
        horizontalAlignment: Text.AlignLeft
        text: Math.round(root.pct) + "%" + (root.extra ? " · " + root.extra : "")
        font.family: Theme.font; font.bold: true; font.pixelSize: 10
        color: Theme.ink
      }
    }
  }
}
