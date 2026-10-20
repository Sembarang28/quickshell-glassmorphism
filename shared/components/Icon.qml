import QtQuick
import QtQuick.Effects

// name = nama file di assets/icons (lucide), atau url = sumber lain (mis. ikon aplikasi)
// color (optional): recolour the glyph (used by the macOS theme on dark surfaces)
Image {
  property string name: ""
  property url url: ""
  property int size: 18
  property color color: "transparent"
  width: size; height: size
  sourceSize: Qt.size(size * 2, size * 2)
  smooth: true
  fillMode: Image.PreserveAspectFit
  source: url != "" ? url : (name !== "" ? Qt.resolvedUrl("../assets/icons/" + name + ".svg") : "")
  layer.enabled: color.a > 0
  layer.effect: MultiEffect {
    colorization: 1.0
    colorizationColor: color
    brightness: 1.0
  }
}
