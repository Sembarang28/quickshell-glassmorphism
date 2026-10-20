import QtQuick
import "../services"

// macOS toggle switch
Item {
  id: root
  property bool checked: false
  signal clicked()
  implicitWidth: 38; implicitHeight: 22
  Rectangle {
    anchors.fill: parent; radius: height / 2
    color: root.checked ? Theme.accent : "#4D8E8E93"
    Behavior on color { ColorAnimation { duration: 120 } }
    Rectangle {
      y: 2; width: 18; height: 18; radius: 9; color: "white"
      x: root.checked ? parent.width - width - 2 : 2
      Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
  }
  MouseArea { anchors.fill: parent; onClicked: root.clicked() }
}
