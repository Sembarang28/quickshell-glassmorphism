import QtQuick

// name = nama file di assets/icons (lucide), atau url = sumber lain (mis. ikon aplikasi)
Image {
  property string name: ""
  property url url: ""
  property int size: 18
  width: size; height: size
  sourceSize: Qt.size(size * 2, size * 2)
  smooth: true
  fillMode: Image.PreserveAspectFit
  source: url != "" ? url : (name !== "" ? Qt.resolvedUrl("../assets/icons/" + name + ".svg") : "")
}
