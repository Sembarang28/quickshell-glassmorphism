pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // ---- panel state (launcher / settings) ----
  // absolute path of a file inside shared/ (independent of which theme is active)
  function sharedPath(p) { return Qt.resolvedUrl("../" + p).toString().replace("file://", "") }

  property string panel: ""
  function toggle(name) { panel = (panel === name ? "" : name) }
  function close() { panel = "" }
  onPanelChanged: if (panel === "settings" || panel === "prefs") { specsProc.running = true; if (weather === "") weatherProc.running = true }

  // ---- specs & weather (dashboard) ----
  property var specs: ({ os: "-", host: "-", shell: "-", uptime: "-", pkgs: "-" })
  property string weather: ""
  property string weatherCond: ""
  Process {
    id: specsProc
    command: ["bash", root.sharedPath("scripts/specs.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        var d = {}
        text.split("\n").forEach(l => { var i = l.indexOf("="); if (i > 0) d[l.slice(0, i)] = l.slice(i + 1).trim() })
        root.specs = d
      }
    }
  }
  Process {
    id: weatherProc
    command: ["curl", "-s", "-m", "6", "wttr.in/?format=%t|%C"]
    stdout: StdioCollector {
      onStreamFinished: {
        var p = text.trim().split("|")
        if (p.length === 2 && text.length < 80) { root.weather = p[0].replace("+", ""); root.weatherCond = p[1] }
      }
    }
  }
  Timer { interval: 900000; running: true; repeat: true; onTriggered: weatherProc.running = true }

  // ---- stats ----
  property real cpu: 0
  property real gpu: 0
  property real ram: 0
  property real disk: 0
  property string cpuTemp: "--"
  property string gpuTemp: "--"
  property string ramTemp: "--"
  property string diskTemp: "--"
  property real diskRead: 0     // bytes/s
  property real diskWrite: 0
  property real netDown: 0
  property real netUp: 0
  property var _io: null
  function fmtRate(b) {
    var u = ["B/s", "KB/s", "MB/s", "GB/s"], i = 0
    while (b >= 1024 && i < 3) { b /= 1024; i++ }
    return (b >= 100 || i === 0 ? Math.round(b) : b.toFixed(1)) + " " + u[i]
  }

  // ---- controls ----
  property int volume: 0
  property bool muted: false
  property bool wifi: false
  property string wifiName: ""
  property bool bt: false
  property bool airplane: false
  property string profile: "balanced"
  property int brightness: 50

  // ---- niri ----
  property var workspaces: []
  property string focusedApp: ""
  property string focusedIcon: ""

  property var _prev: null

  // ---- cava (audio visualizer): array nilai 0..100 ----
  property var cava: []
  Process {
    running: true
    command: ["cava", "-p", root.sharedPath("config/cava.conf")]
    stdout: SplitParser {
      onRead: line => root.cava = line.split(";").filter(x => x !== "").map(Number)
    }
  }

  function run(cmd) {
    Quickshell.execDetached(cmd)
    refreshSoon.restart()
  }
  function setVolume(v) {
    volume = Math.round(v)
    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (volume / 100).toFixed(2)])
  }
  function toggleMute() { run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]) }

  // ---- on-screen display: volume / brightness pill shown after a shortcut ----
  // osd = "volume" | "brightness" | "" (empty = hidden); the pill reads volume/brightness/muted live
  property string osd: ""
  Timer { id: osdHide; interval: 1500; onTriggered: root.osd = "" }
  function showOsd(kind) { osd = kind; osdHide.restart() }
  function volumeStep(d) {
    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (Math.abs(d) / 100).toFixed(2) + (d > 0 ? "+" : "-"), "-l", "1.0"])
    showOsd("volume")
    volumeRead.restart()
  }
  function volumeMute() {
    Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
    showOsd("volume")
    volumeRead.restart()
  }
  function brightnessStep(d) {
    brightness = Math.max(0, Math.min(100, Math.round(brightness + d)))
    ddcSet.restart()
    showOsd("brightness")
  }
  // wpctl dibaca sebentar setelah tombol dilepas, supaya OSD menampilkan nilai hasil akhir
  Timer { id: volumeRead; interval: 120; onTriggered: volumeGet.running = true }
  Process {
    id: volumeGet
    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
    stdout: StdioCollector {
      onStreamFinished: {
        var m = text.match(/([0-9.]+)/)
        if (m) root.volume = Math.round(Number(m[1]) * 100)
        root.muted = text.indexOf("MUTED") >= 0
      }
    }
  }

  function toggleWifi() { run(["nmcli", "radio", "wifi", wifi ? "off" : "on"]) }
  function toggleBt() { run(["bluetoothctl", "power", bt ? "off" : "on"]) }
  function toggleAirplane() { run(["rfkill", airplane ? "unblock" : "block", "all"]) }
  function setProfile(p) { profile = p; run(["busctl", "set-property", "net.hadess.PowerProfiles", "/net/hadess/PowerProfiles", "net.hadess.PowerProfiles", "ActiveProfile", "s", p]) }
  function setBrightness(v) {
    brightness = Math.round(v)
    ddcSet.restart()
  }
  function focusWorkspace(idx) { Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]) }

  // ---------- polling ----------
  Timer {
    interval: 2000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: if (!stats.running) stats.running = true
  }
  Timer { id: refreshSoon; interval: 500; onTriggered: if (!stats.running) stats.running = true }

  Process {
    id: stats
    command: ["bash", root.sharedPath("scripts/stats.sh")]
    stdout: StdioCollector {
      onStreamFinished: {
        var d = {}
        text.split("\n").forEach(l => {
          var i = l.indexOf("=")
          if (i > 0) d[l.slice(0, i)] = l.slice(i + 1).trim()
        })
        if (d.stat) {
          var p = d.stat.split(/\s+/).slice(1).map(Number)
          var idle = p[3] + (p[4] || 0)
          var total = p.reduce((a, b) => a + b, 0)
          if (root._prev) {
            var dt = total - root._prev.total
            if (dt > 0) root.cpu = 100 * (1 - (idle - root._prev.idle) / dt)
          }
          root._prev = { idle: idle, total: total }
        }
        if (d.ram) root.ram = Number(d.ram)
        if (d.disk) root.disk = Number(d.disk)
        root.cpuTemp = d.ctemp ? Math.round(Number(d.ctemp)) + "°" : "--"
        if (d.gpu !== undefined) root.gpu = Number(d.gpu)
        root.ramTemp = d.rtemp ? Math.round(Number(d.rtemp)) + "°" : "--"
        root.diskTemp = d.dtemp ? Math.round(Number(d.dtemp)) + "°" : "--"
        if (d.dio && d.net) {
          var a = d.dio.split(" ").map(Number), n = d.net.split(" ").map(Number), now = Date.now()
          if (root._io) {
            var dt = (now - root._io.t) / 1000
            if (dt > 0) {
              root.diskRead = Math.max(0, (a[0] - root._io.a[0]) / dt)
              root.diskWrite = Math.max(0, (a[1] - root._io.a[1]) / dt)
              root.netDown = Math.max(0, (n[0] - root._io.n[0]) / dt)
              root.netUp = Math.max(0, (n[1] - root._io.n[1]) / dt)
            }
          }
          root._io = { t: now, a: a, n: n }
        }
        root.gpuTemp = d.gtemp ? Math.round(Number(d.gtemp)) + "°" : "--"
        if (d.vol) {
          var m = d.vol.match(/([0-9.]+)/)
          if (m) root.volume = Math.round(Number(m[1]) * 100)
          root.muted = d.vol.indexOf("MUTED") >= 0
        }
        root.wifi = d.wifi === "enabled"
        root.wifiName = d.wname || ""
        root.bt = d.bt === "yes"
        var rf = d.rf || ""
        root.airplane = rf.indexOf("blocked") >= 0 && rf.indexOf("unblocked") < 0
        if (d.prof) root.profile = d.prof
      }
    }
  }

  // ---------- brightness (DDC/CI, lambat -> hanya saat start & setelah slider dilepas) ----------
  Process {
    id: ddcGet
    running: true
    command: ["ddcutil", "getvcp", "10", "--brief"]
    stdout: StdioCollector {
      onStreamFinished: {
        var p = text.trim().split(/\s+/)   // VCP 10 C cur max
        if (p.length >= 5 && Number(p[4]) > 0) root.brightness = Math.round(Number(p[3]) / Number(p[4]) * 100)
      }
    }
  }
  Timer {
    id: ddcSet
    interval: 350
    onTriggered: Quickshell.execDetached(["ddcutil", "setvcp", "10", String(root.brightness), "--noverify"])
  }

  // ---------- niri ----------
  Process {
    id: nWs
    command: ["niri", "msg", "--json", "workspaces"]
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.workspaces = JSON.parse(text).sort((a, b) => a.idx - b.idx) } catch (e) {}
      }
    }
  }
  Process {
    id: nWin
    command: ["niri", "msg", "--json", "focused-window"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          var w = JSON.parse(text)
          if (!w) { root.focusedApp = ""; root.focusedIcon = ""; return }
          var e = w.app_id ? DesktopEntries.heuristicLookup(w.app_id) : null
          root.focusedApp = e ? e.name : (w.app_id || w.title || "")
          root.focusedIcon = e ? e.icon : (w.app_id || "")
        } catch (e) { root.focusedApp = ""; root.focusedIcon = "" }
      }
    }
  }
  Timer {
    id: niriRefresh
    interval: 60
    onTriggered: { nWs.running = true; nWin.running = true }
  }
  Process {
    running: true
    command: ["niri", "msg", "--json", "event-stream"]
    stdout: SplitParser { onRead: niriRefresh.restart() }
  }
  Component.onCompleted: niriRefresh.restart()
}
