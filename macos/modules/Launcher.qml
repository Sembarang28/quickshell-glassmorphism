import Quickshell
import Quickshell.Widgets
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// Spotlight: wide search field, results list below
Item {
  id: root
  width: 640
  height: bar.height + (list.count > 0 ? list.height + 8 : 0)

  readonly property var filtered: {
    var q = field.text.toLowerCase()
    return DesktopEntries.applications.values
      .filter(e => !e.noDisplay && (q === "" || e.name.toLowerCase().indexOf(q) >= 0
        || (e.genericName || "").toLowerCase().indexOf(q) >= 0))
      .sort((a, b) => a.name.localeCompare(b.name))
  }
  readonly property var items: field.text === "" ? [] : Spotlight.combine(filtered)

  function reset() { field.text = ""; list.currentIndex = 0; field.forceActiveFocus() }
  function launch() {
    var e = root.items[list.currentIndex]
    if (!e) return
    if (e.kind !== undefined) Spotlight.activate(e)
    else e.execute()
    Sys.close()
  }
  onVisibleChanged: if (visible) reset()

  Rectangle {
    anchors.fill: parent
    radius: 14
    color: Theme.panel
    border.width: 1; border.color: Theme.glassBorder
    MouseArea { anchors.fill: parent }
  }

  Item {
    id: bar
    width: parent.width; height: 56
    Icon { x: 18; anchors.verticalCenter: parent.verticalCenter; name: "search"; size: 24; color: Theme.textMuted }
    TextInput {
      id: field
      anchors { fill: parent; leftMargin: 56; rightMargin: 18 }
      verticalAlignment: TextInput.AlignVCenter
      font.family: Theme.font; font.pixelSize: 24; font.weight: Font.Light
      color: Theme.ink
      selectionColor: Theme.accent
      clip: true
      onTextChanged: { list.currentIndex = 0; Spotlight.query = field.text }
      Keys.onDownPressed: list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
      Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
      Keys.onReturnPressed: root.launch()
      Keys.onEnterPressed: root.launch()
      Keys.onEscapePressed: Sys.close()
      Text {
        visible: field.text === ""
        anchors.verticalCenter: parent.verticalCenter
        text: "Spotlight Search"
        color: Theme.textMuted
        font: field.font
      }
    }
  }

  ListView {
    id: list
    y: bar.height + 4
    x: 8; width: parent.width - 16
    height: Math.min(count * 40, 8 * 40)
    visible: count > 0
    clip: true
    model: root.items
    currentIndex: 0
    highlightMoveDuration: 0
    delegate: Rectangle {
      required property var modelData
      required property int index
      width: list.width
      height: 40
      radius: 8
      color: ListView.isCurrentItem ? Theme.accent : "transparent"
      IconImage {
        id: ic
        x: 8; anchors.verticalCenter: parent.verticalCenter
        implicitSize: 26
        visible: modelData.kind === undefined
        source: modelData.kind === undefined ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
      }
      Icon {
        visible: modelData.kind !== undefined
        name: modelData.kind !== undefined ? modelData.icon : ""
        size: 20; color: Theme.ink
        x: 11; anchors.verticalCenter: parent.verticalCenter
      }
      Text {
        anchors { left: parent.left; leftMargin: 44; right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        text: modelData.kind !== undefined ? modelData.title : modelData.name
        elide: Text.ElideRight
        font.family: Theme.font; font.pixelSize: 14
        color: Theme.ink
      }
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: list.currentIndex = index
        onClicked: { list.currentIndex = index; root.launch() }
      }
    }
  }
}
