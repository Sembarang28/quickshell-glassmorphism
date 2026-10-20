import QtQuick
import "../services"
import "../shared/components"

// Menu-bar status item: glyph + value, no chrome
Item {
  id: root
  property string icon: ""
  property real pct: 0
  property string extra: ""
  readonly property int sh: 0
  implicitWidth: row.implicitWidth
  implicitHeight: 22
  Row {
    id: row
    anchors.verticalCenter: parent.verticalCenter
    spacing: 4
    Icon { name: root.icon; size: 12; color: root.pct >= 85 ? Theme.red : Theme.ink; anchors.verticalCenter: parent.verticalCenter }
    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Math.round(root.pct) + "%" + (root.extra && root.extra !== "--" ? " " + root.extra : "")
      font.family: Theme.font; font.pixelSize: 12; color: Theme.ink
    }
  }
}
