import QtQuick
import QtQuick.Layouts
import QtQuick.Window

Window {
	width: 400
	height: 400
	visible: true
	title: "QML Parabola"
	color: "grey"

	property real sliderWid: 300
	property real sliderHgt: 30
	property real sliderLabelWidth: 90

	// Parabola parameters: y = a(x-h)^2 + k
	property real a: 0.01
	property real h: width / 2 // Vertex x
	property int k: 100        // Vertex y (offset from top)

	ColumnLayout {
		LabeledSlider {
			id: aSlider
			width: sliderWid
			height: sliderHgt
			from: 0.001
			to: 0.1
			value: a

			label: "a param"
			initValue: a
			stepSize: 0.005
			labelWidth: sliderLabelWidth

			onValueChanged: canvas.requestPaint()
		}

		LabeledSlider {
			id: hSlider
			width: sliderWid
			height: sliderHgt
			from: 50
			to: 400
			value: h

			label: "h param"
			initValue: h
			stepSize: 25
			labelWidth: sliderLabelWidth

			onValueChanged: canvas.requestPaint()
		}

		LabeledSlider {
			id: kSlider
			width: sliderWid
			height: sliderHgt
			from: 100
			to: 200
			value: k

			label: "k param"
			initValue: k
			stepSize: 10
			labelWidth: sliderLabelWidth

			onValueChanged: canvas.requestPaint()
		}
	}

		Canvas {
			id: canvas
			anchors.fill: parent

			onPaint: {
				var ctx = getContext("2d");
				ctx.reset();

				// Stylings
				ctx.strokeStyle = "blue";
				ctx.lineWidth = 2;
				ctx.beginPath();

				// Drawing loop
				for (var x = 0; x <= width; x++) {
					// Parabola equation
					//var y = a * Math.pow(x - h, 2) + k;
					var y = aSlider.value * Math.pow(x - hSlider.value, 2) + kSlider.value;

					if (x === 0) {
						ctx.moveTo(x, y);
					} else {
						ctx.lineTo(x, y);
					}
				}
				ctx.stroke();
			}
		}
 }
