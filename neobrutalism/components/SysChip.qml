import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Chip dengan ikon dan "gauge" fill proporsional persentase
Item {
  id: root
  property string icon: ""
  property real pct: 0
  property string extra: ""
  readonly property int sh: Theme.shadow
  implicitWidth: 12 + 12 + 5 + ghost.implicitWidth + 12 + sh
  implicitHeight: 22 + sh

  Rectangle { x: root.sh; y: root.sh; width: face.width; height: face.height; radius: Theme.radius; color: Theme.ink }
  Rectangle {
    id: face
    width: root.width - root.sh; height: root.height - root.sh
    radius: Theme.radius
    color: Theme.cream
    border.width: Theme.border; border.color: Theme.ink
    Rectangle {
      x: 2; y: 2; height: parent.height - 4
      width: (parent.width - 4) * Math.min(100, root.pct) / 100
      visible: width >= 2
      radius: Math.min(Theme.radius - 2, width / 2)
      color: root.pct >= 85 ? Theme.pink : (root.pct >= 60 ? Theme.yellow : Theme.blueLight)
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
