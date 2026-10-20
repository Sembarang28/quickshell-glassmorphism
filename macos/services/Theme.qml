pragma Singleton
import Quickshell
import QtQuick

Singleton {
  // macOS (dark appearance): vibrant translucent surfaces, system accent colours, SF-like type.
  // Token names match the other themes so shared code keeps working.
  readonly property color panel: "#CC141416"      // Control Center / menus
  readonly property color cream: "#1FFFFFFF"      // module / tile fill
  readonly property color ink: "#FFFFFF"          // primary label
  readonly property color peach: "#FF9F0A"        // orange
  readonly property color green: "#30D158"
  readonly property color blue: "#0A84FF"         // accent
  readonly property color blueLight: "#0A84FF"
  readonly property color lavender: "#BF5AF2"
  readonly property color pink: "#FF375F"
  readonly property color red: "#FF453A"
  readonly property color yellow: "#FFD60A"
  readonly property color gray: "#8E8E93"
  readonly property color off: "#4D8E8E93"        // inactive circle / switch

  readonly property color glassBorder: "#26FFFFFF"
  readonly property color glassHover: "#2EFFFFFF"
  readonly property color shadowColor: "#66000000"
  readonly property color textMuted: "#99FFFFFF"  // secondary label
  readonly property color divider: "#26FFFFFF"
  readonly property color bar: "#B30E0E10"        // menu bar
  readonly property color accent: "#0A84FF"
  readonly property color selection: "#0A84FF"
  readonly property color scrim: "#00000000"

  readonly property int border: 1
  readonly property int shadow: 0
  readonly property int radius: 6
  readonly property int barHeight: 28
  readonly property string font: "Quicksand"
}
