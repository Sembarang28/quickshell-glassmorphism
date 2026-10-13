import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Horizontal slider 0..100
Item {
  id: root
  property real value: 0
  property color fillColor: Theme.peach
  signal moved(real v)
  implicitHeight: 22
  implicitWidth: 200
  function setFrom(x) {
    root.value = Math.round(Math.max(0, Math.min(100, (x - 3) / (track.width - 6) * 100)))
    root.moved(root.value)
  }
  Rectangle {
    id: track
    anchors.fill: parent
    radius: height / 2; color: Theme.cream
    border.width: Theme.border; border.color: Theme.ink
    Rectangle {
      x: 3; y: 3; height: parent.height - 6
      width: (parent.width - 6) * root.value / 100
      visible: width >= 2
      radius: Math.min(height / 2, width / 2); color: root.fillColor
      border.width: root.value > 0 ? 2 : 0; border.color: Theme.ink
    }
  }
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onPressed: m => root.setFrom(m.x)
    onPositionChanged: m => { if (pressed) root.setFrom(m.x) }
  }
}
