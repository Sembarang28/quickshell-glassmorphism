import Quickshell
import Quickshell.Widgets
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

Item {
  id: root
  width: 420
  height: 480

  readonly property var filtered: {
    var q = field.text.toLowerCase()
    return DesktopEntries.applications.values
      .filter(e => !e.noDisplay && (q === "" || e.name.toLowerCase().indexOf(q) >= 0
        || (e.genericName || "").toLowerCase().indexOf(q) >= 0))
      .sort((a, b) => a.name.localeCompare(b.name))
  }

  function reset() { field.text = ""; list.currentIndex = 0; field.forceActiveFocus() }
  function launch() {
    var e = root.filtered[list.currentIndex]
    if (e) { e.execute(); Sys.close() }
  }
  onVisibleChanged: if (visible) reset()

  Rectangle { x: 6; y: 6; width: panel.width; height: panel.height; radius: 16; color: Theme.ink }
  Rectangle {
    id: panel
    width: root.width - 6; height: root.height - 6
    radius: 16
    color: Theme.blueLight
    border.width: 3; border.color: Theme.ink

    Column {
      anchors { fill: parent; margins: 12 }
      spacing: 10

      Rectangle {
        width: parent.width; height: 38
        radius: 10
        color: Theme.cream
        border.width: Theme.border; border.color: Theme.ink
        TextInput {
          id: field
          anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
          verticalAlignment: TextInput.AlignVCenter
          font.family: Theme.font; font.bold: true; font.pixelSize: 15
          color: Theme.ink
          clip: true
          onTextChanged: list.currentIndex = 0
          Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
          Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
          Keys.onReturnPressed: root.launch()
          Keys.onEnterPressed: root.launch()
          Keys.onEscapePressed: Sys.close()
          Text {
            visible: field.text === ""
            anchors.verticalCenter: parent.verticalCenter
            text: "Cari aplikasi..."
            color: "#6b6b6b"
            font: field.font
          }
        }
      }

      ListView {
        id: list
        width: parent.width
        height: parent.height - 48
        clip: true
        spacing: 4
        model: root.filtered
        currentIndex: 0
        highlightMoveDuration: 0
        delegate: Rectangle {
          required property var modelData
          required property int index
          width: list.width
          height: 38
          radius: 10
          color: ListView.isCurrentItem ? Theme.yellow : (hover.containsMouse ? Theme.cream : "#E8F0FF")
          border.width: Theme.border; border.color: Theme.ink
          IconImage {
            id: ic
            x: 8; anchors.verticalCenter: parent.verticalCenter
            implicitSize: 24
            source: Quickshell.iconPath(modelData.icon, "application-x-executable")
          }
          Text {
            anchors { left: ic.right; leftMargin: 10; right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
            text: modelData.name
            elide: Text.ElideRight
            font.family: Theme.font; font.bold: true; font.pixelSize: 13
            color: Theme.ink
          }
          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onEntered: list.currentIndex = index
            onClicked: { list.currentIndex = index; root.launch() }
          }
        }
      }
    }
  }
}
