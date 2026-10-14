pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Spotlight-style extras for the launcher: open a URL, calculate, or search the web.
// Rows are plain objects {kind, title, icon, action}; they are merged with app entries in combine().
Singleton {
  id: root
  property string query: ""
  property string calcResult: ""

  readonly property string trimmed: query.trim()
  readonly property bool isUrl: /^(https?:\/\/\S+|www\.\S+|[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+(\/\S*)?)$/.test(trimmed)
  readonly property bool looksMath: /\d/.test(trimmed) && !isUrl && /[+\-*\/^%()]|sqrt|log|sin|cos|tan/.test(trimmed)

  function normalizeUrl(q) { return /^https?:\/\//.test(q) ? q : "https://" + q }

  // Recomputed whenever query or calcResult changes (QML tracks the property reads)
  readonly property var extraRows: {
    var out = []
    if (trimmed === "") return out
    if (isUrl) out.push({ kind: "url", title: "Open " + trimmed, icon: "globe", action: normalizeUrl(trimmed) })
    if (looksMath && calcResult !== "" && calcResult !== trimmed)
      out.push({ kind: "calc", title: "= " + calcResult, icon: "calculator", action: calcResult })
    if (!isUrl) out.push({ kind: "search", title: "Search DuckDuckGo for \"" + trimmed + "\"", icon: "search",
                           action: "https://duckduckgo.com/?q=" + encodeURIComponent(trimmed) })
    return out
  }

  // URL and calculator results go above the apps; the web search row always goes last
  function combine(apps) {
    var top = extraRows.filter(r => r.kind !== "search")
    var web = extraRows.filter(r => r.kind === "search")
    return top.concat(apps, web)
  }

  function activate(row) {
    if (!row) return
    if (row.kind === "calc") Quickshell.execDetached(["wl-copy", row.action])   // no shell, query never interpolated
    else Quickshell.execDetached(["firefox", row.action])
  }

  onQueryChanged: { calcResult = ""; calcTimer.restart() }
  Timer {
    id: calcTimer
    interval: 150
    onTriggered: {
      if (!root.looksMath) return
      qalc.running = false
      qalc.command = ["qalc", "-t", "--", root.trimmed]
      qalc.running = true
    }
  }
  Process {
    id: qalc
    stdout: StdioCollector { onStreamFinished: root.calcResult = text.trim() }
  }
}
