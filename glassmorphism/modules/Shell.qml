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

  // qs ipc call panel toggle settings|launcher|wifi|bluetooth|sound
  IpcHandler {
    target: "panel"
    function toggle(name: string): void { Sys.toggle(name) }
    function close(): void { Sys.close() }
  }
}
