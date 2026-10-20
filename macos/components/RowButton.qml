import QtQuick
import "../services"
import "../shared/components"

// macOS list row (Control Center sub-page style): round icon badge, label, trailing status
Item {
  id: root
  property string icon: ""
  property string text: ""
  property string status: ""
  property bool active: false
  property color fill: "transparent"
  property color activeFill: Theme.accent
  signal clicked()
  readonly property int sh: 0
  implicitHeight: 40

  Rectangle {
    anchors.fill: parent
    radius: 8
    color: ma.containsMouse ? Theme.glassHover : root.fill
  }
  Rectangle {
    id: badge
    x: 4; width: 28; height: 28; radius: 14
    anchors.verticalCenter: parent.verticalCenter
    color: root.active ? root.activeFill : Theme.off
    Icon { anchors.centerIn: parent; name: root.icon; size: 15; color: "white" }
  }
  Text {
    id: lbl
    x: 40; anchors.verticalCenter: parent.verticalCenter
    width: Math.min(implicitWidth, parent.width - 40 - 8)
    elide: Text.ElideRight
    text: root.text
    font.family: Theme.font; font.pixelSize: 13; color: Theme.ink
  }
  Text {
    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
    width: Math.max(0, Math.min(implicitWidth, root.width - 40 - lbl.width - 16))
    elide: Text.ElideRight
    horizontalAlignment: Text.AlignRight
    text: root.status
    font.family: Theme.font; font.pixelSize: 11; color: Theme.textMuted
  }
  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    onClicked: root.clicked()
  }
}
