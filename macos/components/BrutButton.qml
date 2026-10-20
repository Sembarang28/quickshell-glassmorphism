import QtQuick
import "../services"
import "../shared/components"

// macOS-style flat button: transparent, hover wash, accent when active
Item {
  id: root
  property string text: ""
  property string icon: ""
  property url iconUrl: ""
  property int iconSize: 14
  property int maxTextWidth: 400
  property bool vertical: false
  property color fill: "transparent"
  property color textColor: Theme.ink
  property bool active: false
  property color activeFill: Theme.accent
  property int pad: 8
  property int fontSize: 13
  property int radius: Theme.radius
  property bool bold: false
  signal clicked()
  signal rightClicked()
  signal wheel(int delta)

  readonly property int sh: 0
  readonly property bool hasIcon: icon !== "" || iconUrl != ""
  implicitWidth: row.implicitWidth + pad * 2
  implicitHeight: vertical ? row.implicitHeight + 20 : 22

  Rectangle {
    id: face
    anchors.fill: parent
    radius: root.radius
    opacity: ma.pressed ? 0.8 : 1
    color: root.active ? root.activeFill : (ma.containsMouse ? Theme.glassHover : root.fill)
    Behavior on color { ColorAnimation { duration: 90 } }

    Icon {
      visible: root.hasIcon && root.text === ""
      anchors.centerIn: parent
      name: root.icon; url: root.iconUrl; size: root.iconSize
      color: root.iconUrl != "" ? "transparent" : root.textColor
    }
    Grid {
      id: row
      visible: root.text !== ""
      anchors.centerIn: parent
      columns: root.vertical ? 1 : 2
      spacing: root.vertical ? 6 : 6
      horizontalItemAlignment: Grid.AlignHCenter
      verticalItemAlignment: Grid.AlignVCenter
      Icon { visible: root.hasIcon; name: root.icon; url: root.iconUrl; size: root.iconSize
             color: root.iconUrl != "" ? "transparent" : root.textColor }
      Text {
        visible: root.text !== ""
        width: Math.min(implicitWidth, root.maxTextWidth)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        color: root.textColor
        font.family: Theme.font; font.bold: root.bold; font.pixelSize: root.fontSize
      }
    }
  }
  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: m => { if (m.button === Qt.RightButton) root.rightClicked(); else root.clicked() }
    onWheel: w => root.wheel(w.angleDelta.y)
  }
}
