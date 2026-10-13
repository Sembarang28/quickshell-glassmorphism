import QtQuick
import "../services"
import "../shared/services"

// Audio visualizer (cava data) in a glass chip
Item {
  id: root
  readonly property int sh: 0
  implicitWidth: bars.implicitWidth + 20
  implicitHeight: 22

  Rectangle { y: 2; width: parent.width; height: parent.height; radius: Theme.radius; color: Theme.shadowColor }
  Rectangle {
    anchors.fill: parent
    radius: Theme.radius
    color: Theme.cream
    border.width: Theme.border; border.color: Theme.glassBorder
    Row {
      id: bars
      anchors.centerIn: parent
      spacing: 2
      Repeater {
        model: 14
        Item {
          required property int index
          width: 3; height: 11
          Rectangle {
            width: parent.width
            height: Math.max(3, parent.height * (Sys.cava[index] || 0) / 100)
            anchors.bottom: parent.bottom
            radius: 2
            color: index % 3 === 0 ? "#8FB0FF" : (index % 3 === 1 ? "#E9A6D0" : "#B9A6F5")
          }
        }
      }
    }
  }
}
