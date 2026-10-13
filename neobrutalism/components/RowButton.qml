import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Wide button: icon + label on the left, status on the right
Item {
  id: root
  property string icon: ""
  property string text: ""
  property string status: ""
  property bool active: false
  property color fill: Theme.cream
  property color activeFill: Theme.green
  signal clicked()
  readonly property int sh: Theme.shadow
  implicitHeight: 40 + sh

  Rectangle { x: root.sh; y: root.sh; width: face.width; height: face.height; radius: Theme.radius; color: Theme.ink }
  Rectangle {
    id: face
    width: root.width - root.sh; height: root.height - root.sh
    x: ma.pressed ? root.sh : 0; y: ma.pressed ? root.sh : 0
    radius: Theme.radius
    color: root.active ? root.activeFill : (ma.containsMouse ? Qt.lighter(root.fill, 1.08) : root.fill)
    border.width: Theme.border; border.color: Theme.ink
    Icon { id: ic; name: root.icon; size: 18; x: 10; anchors.verticalCenter: parent.verticalCenter }
    Text {
      id: lbl
      x: 36; anchors.verticalCenter: parent.verticalCenter
      width: Math.min(implicitWidth, parent.width - 36 - 10)
      elide: Text.ElideRight
      text: root.text
      font.family: Theme.font; font.bold: true; font.pixelSize: 13; color: Theme.ink
    }
    Text {
      anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
      width: Math.max(0, Math.min(implicitWidth, face.width - 36 - lbl.width - 10 - 8))
      elide: Text.ElideRight
      horizontalAlignment: Text.AlignRight
      text: root.status
      font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: "#6b5c55"
    }
  }
  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
