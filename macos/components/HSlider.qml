import QtQuick
import "../services"
import "../shared/components"

// macOS Control Center slider: tall pill, white fill from the left, glyph inside
Item {
  id: root
  property real value: 0
  property color fillColor: "#FFFFFF"
  property string icon: ""
  signal moved(real v)
  implicitHeight: 28
  implicitWidth: 200
  function setFrom(x) {
    root.value = Math.round(Math.max(0, Math.min(100, x / track.width * 100)))
    root.moved(root.value)
  }
  Rectangle {
    id: track
    anchors.fill: parent
    radius: height / 2; color: "#33FFFFFF"
    clip: true
    Rectangle {
      height: parent.height
      width: Math.max(parent.height, parent.width * root.value / 100)
      radius: height / 2
      color: root.fillColor
    }
    Icon {
      visible: root.icon !== ""
      x: 7; anchors.verticalCenter: parent.verticalCenter
      name: root.icon; size: 14; color: "#8A8A8E"
    }
  }
  MouseArea {
    anchors.fill: parent
    onPressed: m => root.setFrom(m.x)
    onPositionChanged: m => { if (pressed) root.setFrom(m.x) }
  }
}
