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

	property real a: 0.01
	property real h: width / 2 // Vertex x

	property real distance: 1.0		        // Vision floor distance to center of hub
	property real targetDist: 0.762         // 2.5 ft in meters; 0 to 1.2192
	property real heightAboveHub: 0.161544	// 6.36 inches in meters; min 3 inches 0.0762 meters
	property real targetHeight: 2.032		// 80 inches in meters

	property int k: 100				// Vertex y (offset from top)

	ColumnLayout {
		LabeledSlider {
			id: distSlider
			width: sliderWid
			height: sliderHgt
			from: 1
			to: 6	// 6 meters ~ 20 ft
			value: distance

			label: "distance"
			initValue: distance
			stepSize: 0.25
			labelWidth: sliderLabelWidth

			onValueChanged: {
				var revs = _ballistics.calc(distance, targetDist, heightAboveHub, targetHeight);
				print("revs ", revs);
				canvas.requestPaint();
			}
		}

		LabeledSlider {
			id: heightAboveHubSlider
			width: sliderWid
			height: sliderHgt
			from: 0.0762
			to: 2
			value: heightAboveHub

			label: "heightAboveHub"
			initValue: heightAboveHub
			stepSize: 0.25
			labelWidth: sliderLabelWidth

			onValueChanged: {
				var revs = _ballistics.calc(distance, targetDist, heightAboveHub, targetHeight);
				print("revs ", revs);
				canvas.requestPaint();
			}
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
					var y = a * Math.pow(x - h, 2) + k;
					//var y = aSlider.value * Math.pow(x - hSlider.value, 2) + kSlider.value;

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
