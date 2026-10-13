import QtQuick
import "../services"
import "../shared/components"

// Wide glass button: icon + label on the left, status on the right
Item {
  id: root
  property string icon: ""
  property string text: ""
  property string status: ""
  property bool active: false
  property color fill: Theme.cream
  property color activeFill: Theme.green
  signal clicked()
  readonly property int sh: 0
  implicitHeight: 40

  Rectangle { y: ma.pressed ? 1 : 2; width: parent.width; height: parent.height; radius: Theme.radius; color: Theme.shadowColor }
  Rectangle {
    id: face
    anchors.fill: parent
    radius: Theme.radius
    scale: ma.pressed ? 0.98 : 1
    Behavior on scale { NumberAnimation { duration: 80 } }
    color: root.active ? root.activeFill : (ma.containsMouse ? Theme.glassHover : root.fill)
    border.width: Theme.border; border.color: Theme.glassBorder
    Rectangle {
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: parent.height * 0.5; radius: parent.radius
      gradient: Gradient {
        GradientStop { position: 0; color: "#66FFFFFF" }
        GradientStop { position: 1; color: "#00FFFFFF" }
      }
    }
    Icon { name: root.icon; size: 18; x: 10; anchors.verticalCenter: parent.verticalCenter }
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
      font.family: Theme.font; font.bold: true; font.pixelSize: 11; color: Theme.textMuted
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
