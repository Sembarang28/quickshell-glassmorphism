import QtQuick
import "../services"
import "../shared/components"

Item {
  id: root
  property real value: 0
  property color fillColor: "#FFFFFF"
  signal moved(real v)
  signal released(real v)
  implicitWidth: 34
  implicitHeight: 140
  function setFrom(y) {
    root.value = Math.round(Math.max(0, Math.min(100, 100 * (1 - y / track.height))))
    root.moved(root.value)
  }
  Rectangle {
    id: track
    anchors.fill: parent
    radius: width / 2; color: "#33FFFFFF"; clip: true
    Rectangle {
      width: parent.width; anchors.bottom: parent.bottom
      height: Math.max(parent.width, parent.height * root.value / 100)
      radius: width / 2; color: root.fillColor
    }
  }
  MouseArea {
    anchors.fill: parent
    onPressed: m => root.setFrom(m.y)
    onPositionChanged: m => { if (pressed) root.setFrom(m.y) }
    onReleased: root.released(root.value)
  }
}
