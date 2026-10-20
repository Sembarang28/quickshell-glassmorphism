import Quickshell
import QtQuick
import "../services"
import "../shared/services"
import "../shared/components"
import "../components"

// Apple menu: About, System Settings, then session actions (second click confirms)
Item {
  id: root
  property bool open: false
  property string armed: ""
  width: 240
  height: col.height + 12
  visible: opacity > 0
  opacity: open ? 1 : 0
  Behavior on opacity { NumberAnimation { duration: 90 } }
  onOpenChanged: if (!open) armed = ""
  Timer { interval: 3000; running: root.armed !== ""; onTriggered: root.armed = "" }
  function session(name, cmd) { if (armed === name) { Sys.run(cmd); Sys.close() } else armed = name }

  component Entry: Item {
    id: e
    property string label
    property string hint: ""
    property bool danger: false
    signal activated()
    width: col.width; height: 22
    Rectangle { anchors.fill: parent; radius: 5; color: ma.containsMouse ? (e.danger ? Theme.red : Theme.accent) : "transparent" }
    Text { x: 10; anchors.verticalCenter: parent.verticalCenter; text: e.label
           font.family: Theme.font; font.pixelSize: 13; color: Theme.ink }
    Text { anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter } text: e.hint
           font.family: Theme.font; font.pixelSize: 11; color: Theme.textMuted }
    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: e.activated() }
  }
  component Sep: Rectangle { width: col.width; height: 1; color: Theme.divider }

  Rectangle { anchors.fill: parent; radius: 10; color: Theme.panel; border.width: 1; border.color: Theme.glassBorder
              MouseArea { anchors.fill: parent } }
  Column {
    id: col
    x: 6; y: 6; width: root.width - 12; spacing: 4
    Entry { label: "About This PC"; onActivated: Sys.panel = "prefs" }
    Sep {}
    Entry { label: "System Settings…"; onActivated: Sys.panel = "prefs" }
    Sep {}
    Entry { label: root.armed === "sleep" ? "Click again to Sleep" : "Sleep"; onActivated: root.session("sleep", ["systemctl", "suspend"]) }
    Entry { label: root.armed === "restart" ? "Click again to Restart" : "Restart…"; danger: true; onActivated: root.session("restart", ["systemctl", "reboot"]) }
    Entry { label: root.armed === "shutdown" ? "Click again to Shut Down" : "Shut Down…"; danger: true; onActivated: root.session("shutdown", ["systemctl", "poweroff"]) }
    Sep {}
    Entry { label: root.armed === "hibernate" ? "Click again to Hibernate" : "Hibernate…"; onActivated: root.session("hibernate", ["systemctl", "hibernate"]) }
    Entry { label: root.armed === "logout" ? "Click again to Log Out" : "Log Out " + (Quickshell.env("USER") || "") + "…"; danger: true
            onActivated: root.session("logout", ["niri", "msg", "action", "quit", "--skip-confirmation"]) }
  }
}
