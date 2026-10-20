import QtQuick
import "../services"
import "../shared/services"

// Tiny audio meter for the menu bar
Item {
  id: root
  readonly property int sh: 0
  implicitWidth: bars.implicitWidth
  implicitHeight: 22
  Row {
    id: bars
    anchors.verticalCenter: parent.verticalCenter
    spacing: 2
    Repeater {
      model: 10
      Item {
        required property int index
        width: 2; height: 12
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        Rectangle {
          width: parent.width
          height: Math.max(2, parent.height * (Sys.cava[index] || 0) / 100)
          anchors.verticalCenter: parent.verticalCenter
          radius: 1; color: Theme.ink; opacity: 0.85
        }
      }
    }
  }
}
