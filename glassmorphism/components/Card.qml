import QtQuick
import "../services"

// Glass card: translucent fill, light border, soft shadow, top highlight. Content goes into `body`.
Item {
  id: root
  property color fill: Theme.cream
  property int shadow: 4          // elevation hint (soft shadow offset)
  property int radius: 14
  property int margins: 10
  default property alias content: body.data
  readonly property alias body: body

  Rectangle {
    y: Math.min(root.shadow, 8) * 0.8
    width: parent.width; height: parent.height
    radius: root.radius; color: Theme.shadowColor
  }
  Rectangle {
    id: face
    anchors.fill: parent
    radius: root.radius
    color: root.fill
    border.width: Theme.border; border.color: Theme.glassBorder
    MouseArea { anchors.fill: parent }   // swallow clicks so the popup stays open
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: Math.min(parent.height * 0.45, 60)
      radius: root.radius
      gradient: Gradient {
        GradientStop { position: 0; color: "#59FFFFFF" }
        GradientStop { position: 1; color: "#00FFFFFF" }
      }
    }
    Item { id: body; anchors { fill: parent; margins: root.margins } }
  }
}
