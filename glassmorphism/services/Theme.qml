pragma Singleton
import Quickshell
import QtQuick

Singleton {
  // Glassmorphism (light): translucent frosted surfaces, soft shadows, pastel accents.
  // Token names match the neobrutalism Theme so modules can be shared 1:1.
  readonly property color panel: "#D0A9B2DA"      // popup panels
  readonly property color cream: "#59FFFFFF"      // cards / chips (glass fill)
  readonly property color ink: "#2B2F4A"          // text + icons
  readonly property color peach: "#F5B3A0"
  readonly property color green: "#A8DDBE"
  readonly property color blue: "#93B4F5"
  readonly property color blueLight: "#BCCDF2"
  readonly property color lavender: "#C2B2F0"
  readonly property color pink: "#F2B5CE"
  readonly property color red: "#F29399"
  readonly property color yellow: "#F2D88F"
  readonly property color gray: "#B5BDD9"
  readonly property color off: "#40FFFFFF"

  // glass-only tokens
  readonly property color glassBorder: "#99FFFFFF"
  readonly property color glassHover: "#80FFFFFF"
  readonly property color shadowColor: "#26283C64"
  readonly property color textMuted: "#4F5578"
  readonly property color divider: "#40283C64"
  readonly property color bar: "#99A3ACD8"        // floating bar pills

  readonly property int border: 1
  readonly property int shadow: 0
  readonly property int radius: 12
  readonly property int barHeight: 40
  readonly property string font: "Quicksand"
}
