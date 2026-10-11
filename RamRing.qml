import QtQuick
import QtQuick.Shapes
import qs.Commons

Item {
  id: ring

  property real value: 0            // 0..100
  property color color: Color.foreground
  property bool critical: false
  property real lineWidth: Style.spacing.xs
  property color trackColor: Qt.rgba(color.r, color.g, color.b, 0.25)

  implicitWidth: Style.bar.iconFont
  implicitHeight: Style.bar.iconFont

  property real shown: value
  Behavior on shown { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
  Behavior on color { ColorAnimation { duration: 250 } }

  // Outer diameter. Bar glyphs paint ~11px of ink inside their 13px font box
  // (battery 12, speaker/headphones 11), and a circle reads fuller than a
  // glyph, so cap here to keep the ring the same visual size as its neighbours.
  // ponytail: fixed to this font's ink; bump the token if the bar font changes.
  property real diameter: Math.min(width, height, Style.font.iconSmall)
  readonly property real r: Math.max(0, (diameter - lineWidth) / 2)

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    visible: !ring.critical

    // track
    ShapePath {
      fillColor: "transparent"
      strokeColor: ring.trackColor
      strokeWidth: ring.lineWidth
      PathAngleArc {
        centerX: ring.width / 2; centerY: ring.height / 2
        radiusX: ring.r; radiusY: ring.r
        startAngle: 0; sweepAngle: 360
      }
    }

    // value arc, starts at 12 o'clock
    ShapePath {
      fillColor: "transparent"
      strokeColor: ring.shown > 0.5 ? ring.color : "transparent"
      strokeWidth: ring.lineWidth
      capStyle: ShapePath.RoundCap
      PathAngleArc {
        centerX: ring.width / 2; centerY: ring.height / 2
        radiusX: ring.r; radiusY: ring.r
        startAngle: -90
        sweepAngle: 360 * ring.shown / 100
      }
    }
  }

  // critical: shape change, not just color
  Rectangle {
    anchors.centerIn: parent
    width: ring.diameter
    height: width
    radius: width / 2
    color: ring.color
    visible: ring.critical

    SequentialAnimation on opacity {
      running: ring.critical
      loops: Animation.Infinite
      NumberAnimation { to: 0.45; duration: 700 }
      NumberAnimation { to: 1.0; duration: 700 }
    }
  }
}
