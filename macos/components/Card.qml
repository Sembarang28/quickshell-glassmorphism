import QtQuick
import "../services"

// macOS module: rounded translucent tile, no border/shadow. Content goes into `body`.
Item {
  id: root
  property color fill: Theme.cream
  property int shadow: 0
  property int radius: 12
  property int margins: 12
  default property alias content: body.data
  readonly property alias body: body

  Rectangle {
    id: face
    anchors.fill: parent
    radius: root.radius
    color: root.fill
    MouseArea { anchors.fill: parent }   // swallow clicks so the popup stays open
    Item { id: body; anchors { fill: parent; margins: root.margins } }
  }
}
