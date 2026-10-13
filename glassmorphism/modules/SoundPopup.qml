import Quickshell.Services.Pipewire
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

PopupFrame {
  id: root
  title: "Sound"
  icon: Sys.muted ? "volume-x" : "volume-2"
  height: 360
  on: !Sys.muted
  onToggled: Sys.toggleMute()

  readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
  PwObjectTracker { objects: root.sinks }

  Row {
    id: vol
    width: parent.width; spacing: 10
    Icon { name: "volume-2"; size: 18; anchors.verticalCenter: parent.verticalCenter }
    HSlider {
      width: parent.width - 28 - 46 - 20
      anchors.verticalCenter: parent.verticalCenter
      value: Sys.volume
      fillColor: Sys.muted ? Theme.off : Theme.peach
      onMoved: v => Sys.setVolume(v)
    }
    Text {
      width: 46; horizontalAlignment: Text.AlignRight
      anchors.verticalCenter: parent.verticalCenter
      text: Sys.volume + "%"
      font.family: Theme.font; font.bold: true; font.pixelSize: 13; color: Theme.ink
    }
  }
  Text {
    y: 36
    text: "Output device"
    font.family: Theme.font; font.bold: true; font.pixelSize: 12; color: Theme.ink
  }
  ListView {
    y: 58
    width: parent.width; height: parent.height - 58
    clip: true; spacing: 6
    model: root.sinks
    delegate: RowButton {
      required property var modelData
      width: ListView.view.width
      icon: "speaker"
      text: modelData.description || modelData.nickname || modelData.name
      active: Pipewire.defaultAudioSink === modelData
      onClicked: Pipewire.preferredDefaultAudioSink = modelData
    }
  }
}
