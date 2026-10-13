import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Kartu: kotak membulat + border + bayangan keras. Isi masuk ke area `body`.
Item {
  id: root
  property color fill: Theme.cream
  property int shadow: 4
  property int radius: 14
  property int margins: 10
  default property alias content: body.data
  readonly property alias body: body

  Rectangle {
    x: root.shadow; y: root.shadow
    width: face.width; height: face.height
    radius: root.radius; color: Theme.ink
  }
  Rectangle {
    id: face
    width: root.width - root.shadow; height: root.height - root.shadow
    radius: root.radius
    color: root.fill
    border.width: Theme.border; border.color: Theme.ink
    MouseArea { anchors.fill: parent }   // serap klik agar tidak menutup popup
    Item {
      id: body
      anchors { fill: parent; margins: root.margins }
    }
  }
}
