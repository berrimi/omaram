import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
BarWidget {
  id: root
  moduleName: "ram-monitor"
  property int usagePercent: 0
  property string usedG: ""
  property string totalG: ""
  property bool hasData: false
  readonly property color warnColor: Color.accent
  readonly property color critColor: bar ? bar.urgent : Color.urgent
  property int warnThreshold: 80
  property int critEnter: 92
  property int critExit: 88
  property bool critical: false
  readonly property color tierColor: critical ? critColor
    : usagePercent >= warnThreshold ? warnColor
    : (bar ? bar.barForeground : Color.foreground)
  function refresh() {
    if (!memInfoProc.running) memInfoProc.running = true
  }
  visible: hasData
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight
  Component.onCompleted: refresh()
  Process {
    id: memInfoProc
    command: ["grep", "-E", "MemTotal|MemAvailable", "/proc/meminfo"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = text.split("\n")
        var total = 0, available = 0
        for (var i = 0; i < lines.length; i++) {
          var match = lines[i].match(/^Mem(Total|Available):\s+(\d+)/)
          if (match) {
            if (match[1] === "Total") total = parseInt(match[2])
            else if (match[1] === "Available") available = parseInt(match[2])
          }
        }
        if (total > 0 && available > 0) {
          var used = total - available
          root.usagePercent = Math.floor(used * 100 / total)
          root.usedG = Math.floor(used / 1048576) + "." + Math.floor((used % 1048576) * 10 / 1048576)
          root.totalG = Math.floor(total / 1048576) + "." + Math.floor((total % 1048576) * 10 / 1048576)
          if (root.usagePercent >= root.critEnter) root.critical = true
          else if (root.usagePercent <= root.critExit) root.critical = false
          root.hasData = true
        }
      }
    }
  }
  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }
  Component {
    id: ring
    RamRing {
      value: root.usagePercent
      color: root.tierColor
      critical: root.critical
    }
  }
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: ring
    slotSize: Style.bar.iconSlot
    opticalSize: Style.bar.iconCanvas
    fontSize: Style.bar.iconFont
    tooltipText: root.hasData ? "RAM: " + root.usagePercent + "%\n" + root.usedG + "G / " + root.totalG + "G" : "RAM: loading..."
    onPressed: {
      if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation btop")
    }
  }
}
