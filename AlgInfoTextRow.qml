import QtQuick

Row {
    spacing: 10

    property string lbl: "add label"
    property real valueMetric: 0.0
    property string unitsMetric: "add metric units"
    property real convImperial: 1.0
    property string unitsImerial: "add imperial units"
    property real decimalPlaces: 2

    property bool showConversion: unitsMetric != unitsImerial

    property font labelFont: Qt.font({ family: "Consolas", pointSize: 12 })
    property font valueFont: Qt.font({ family: "Consolas", pointSize: 12 })

    Text { color: "white"; font: labelFont; text: lbl }
    Text { color: "white"; font: valueFont;  text: valueMetric.toFixed(decimalPlaces) }
    Text { color: "white"; font: valueFont;  text: unitsMetric }
    Text { color: "white"; font: valueFont;  text: showConversion ? (valueMetric * convImperial).toFixed(decimalPlaces) : " " }
    Text { color: "white"; font: valueFont;  text: showConversion ? unitsImerial : " " }
}
