import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Audio visualizer (data dari cava)
Item {
  id: root
  readonly property int sh: Theme.shadow
  implicitWidth: bars.implicitWidth + 20 + sh
  implicitHeight: 22 + sh

  Rectangle { x: root.sh; y: root.sh; width: face.width; height: face.height; radius: Theme.radius; color: Theme.ink }
  Rectangle {
    id: face
    width: root.width - root.sh; height: root.height - root.sh
    radius: Theme.radius
    color: Theme.cream
    border.width: Theme.border; border.color: Theme.ink

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
            color: index % 3 === 0 ? Theme.blue : (index % 3 === 1 ? Theme.pink : Theme.yellow)
            border.width: 1; border.color: Theme.ink
          }
        }
      }
    }
  }
}
