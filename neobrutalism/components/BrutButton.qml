import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

Item {
  id: root
  property string text: ""
  property string icon: ""        // nama ikon lucide
  property url iconUrl: ""        // atau url ikon (mis. ikon aplikasi)
  property int iconSize: 14
  property int maxTextWidth: 400
  property bool vertical: false   // ikon di atas teks
  property color fill: Theme.cream
  property color textColor: Theme.ink
  property bool active: false
  property color activeFill: Theme.yellow
  property int pad: 10
  property int fontSize: 11
  property int radius: Theme.radius
  signal clicked()
  signal rightClicked()
  signal wheel(int delta)

  readonly property int sh: Theme.shadow
  readonly property bool hasIcon: icon !== "" || iconUrl != ""
  implicitWidth: row.implicitWidth + pad * 2
  implicitHeight: vertical ? row.implicitHeight + 20 : 22

  Rectangle {
    x: root.sh; y: root.sh
    width: face.width; height: face.height
    radius: root.radius
    color: Theme.ink
  }
  Rectangle {
    id: face
    width: root.width
    height: root.height
    radius: root.radius
    x: ma.pressed ? root.sh : 0
    y: ma.pressed ? root.sh : 0
    color: root.active ? root.activeFill : (ma.containsMouse ? Qt.lighter(root.fill, 1.12) : root.fill)
    border.width: Theme.border
    border.color: Theme.ink

    // icon-only buttons: centre the icon exactly in the face

    Icon {

      visible: root.hasIcon && root.text === ""

      anchors.centerIn: parent

      name: root.icon; url: root.iconUrl; size: root.iconSize

    }


    Grid {
      id: row
      visible: root.text !== ""
      anchors.centerIn: parent
      columns: root.vertical ? 1 : 2
      spacing: root.vertical ? 6 : 7
      horizontalItemAlignment: Grid.AlignHCenter
      verticalItemAlignment: Grid.AlignVCenter
      Icon {
        visible: root.hasIcon
        name: root.icon; url: root.iconUrl; size: root.iconSize
      }
      Text {
        visible: root.text !== ""
        width: Math.min(implicitWidth, root.maxTextWidth)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        color: root.textColor
        font.family: Theme.font
        font.bold: true
        font.pixelSize: root.fontSize
      }
    }
  }
  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: m => { if (m.button === Qt.RightButton) root.rightClicked(); else root.clicked() }
    onWheel: w => root.wheel(w.angleDelta.y)
  }
}
