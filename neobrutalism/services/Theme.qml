pragma Singleton
import Quickshell
import QtQuick

Singleton {
  // Soft neo-brutalism: warm cream surfaces, thick dark borders, hard shadows, pastel accents
  readonly property color panel: "#F2E8E2"
  readonly property color cream: "#FBF0E5"
  readonly property color ink: "#1C1412"
  readonly property color peach: "#FFAB95"
  readonly property color green: "#BDE3A2"
  readonly property color blue: "#8EC5F5"
  readonly property color blueLight: "#CFE5F8"
  readonly property color lavender: "#CDB6E9"
  readonly property color pink: "#FFC8D4"
  readonly property color red: "#FF8F86"
  readonly property color yellow: "#F2C230"
  readonly property color gray: "#E3DDD8"
  readonly property color off: "#E8DDD3"

  readonly property int border: 2
  readonly property int shadow: 3
  readonly property int radius: 10
  readonly property int barHeight: 32
  readonly property string font: "Quicksand"
}
