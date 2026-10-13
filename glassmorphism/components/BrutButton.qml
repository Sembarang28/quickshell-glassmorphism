import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

// Glass button (same API as the neobrutalism BrutButton)
Item {
  id: root
  property string text: ""
  property string icon: ""
  property url iconUrl: ""
  property int iconSize: 14
  property int maxTextWidth: 400
  property bool vertical: false
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

  readonly property int sh: 0
  readonly property bool hasIcon: icon !== "" || iconUrl != ""
  implicitWidth: row.implicitWidth + pad * 2
  implicitHeight: vertical ? row.implicitHeight + 20 : 22

  Rectangle {   // soft shadow
    y: ma.pressed ? 1 : 2
    width: parent.width; height: parent.height
    radius: root.radius
    color: Theme.shadowColor
  }
  Rectangle {
    id: face
    anchors.fill: parent
    radius: root.radius
    scale: ma.pressed ? 0.97 : 1
    Behavior on scale { NumberAnimation { duration: 80 } }
    color: root.active ? root.activeFill : (ma.containsMouse ? Theme.glassHover : root.fill)
    border.width: Theme.border
    border.color: Theme.glassBorder
    Rectangle {   // top highlight
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
      height: parent.height * 0.5
      radius: parent.radius
      gradient: Gradient {
        GradientStop { position: 0; color: "#66FFFFFF" }
        GradientStop { position: 1; color: "#00FFFFFF" }
      }
    }
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
      Icon { visible: root.hasIcon; name: root.icon; url: root.iconUrl; size: root.iconSize }
      Text {
        visible: root.text !== ""
        width: Math.min(implicitWidth, root.maxTextWidth)
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        text: root.text
        color: root.textColor
        font.family: Theme.font; font.bold: true; font.pixelSize: root.fontSize
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
