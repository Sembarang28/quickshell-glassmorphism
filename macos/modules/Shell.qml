import Quickshell
import Quickshell.Io
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"

ShellRoot {
  Variants {
    model: Quickshell.screens
    Wallpaper { required property var modelData; screen: modelData }
  }
  Variants {
    model: Quickshell.screens
    Bar { required property var modelData; screen: modelData }
  }
  Variants {
    model: Quickshell.screens
    Overlay { required property var modelData; screen: modelData }
  }
  Variants {
    model: Quickshell.screens
    Osd { required property var modelData; screen: modelData }
  }

  // qs ipc call panel toggle settings|launcher|wifi|bluetooth|sound
  IpcHandler {
    target: "panel"
    function toggle(name: string): void { Sys.toggle(name) }
    function close(): void { Sys.close() }
  }

  // qs ipc call osd volumeUp|volumeDown|volumeMute|brightnessUp|brightnessDown
  IpcHandler {
    target: "osd"
    function volumeUp(): void { Sys.volumeStep(5) }
    function volumeDown(): void { Sys.volumeStep(-5) }
    function volumeMute(): void { Sys.volumeMute() }
    function brightnessUp(): void { Sys.brightnessStep(5) }
    function brightnessDown(): void { Sys.brightnessStep(-5) }
  }
}
