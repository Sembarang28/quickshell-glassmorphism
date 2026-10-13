import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Slider vertikal 0..100 (bar isi dari bawah)
Item {
  id: root
  property real value: 0
  property color fillColor: Theme.peach
  signal moved(real v)
  signal released(real v)
  implicitWidth: 34
  implicitHeight: 140

  function setFrom(y) {
    var v = 100 * (1 - (y - 3) / (track.height - 6))
    root.value = Math.round(Math.max(0, Math.min(100, v)))
    root.moved(root.value)
  }

  Rectangle {
    id: track
    anchors.fill: parent
    radius: 10
    color: Theme.cream
    border.width: Theme.border; border.color: Theme.glassBorder
    Rectangle {
      x: 3; width: parent.width - 6
      height: (parent.height - 6) * root.value / 100
      visible: height >= 2
      anchors.bottom: parent.bottom; anchors.bottomMargin: 3
      radius: Math.min(7, height / 2)
      color: root.fillColor
      border.width: root.value > 0 ? 2 : 0; border.color: Theme.glassBorder
    }
  }
  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onPressed: m => root.setFrom(m.y)
    onPositionChanged: m => { if (pressed) root.setFrom(m.y) }
    onReleased: root.released(root.value)
  }
}
