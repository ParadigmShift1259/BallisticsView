import QtQuick
import QtQuick.Layouts
import QtQuick.Window

Window {
	id: mainWindow
	//width: 400
	//height: 400
	width: 800
	height: 800
	visible: true
	title: "QML Parabola"
	color: "grey"

	property real sliderWid: 300
	property real sliderHgt: 30
	property real sliderLabelWidth: 90

	//property real a: 0.01
	//property real h: width / 2 // Vertex x

	// Inputs to _ballistics.calc
	//	meter_t distance        // Floor distance to "front" rim of cone (vision dist was to center of hub)
	//	meter_t targetDist      // Target distance within cone from rim
	//	meter_t heightAboveHub  // How far above Hub to palce the shot
	//	meter_t targetHeight    // Height at end point within cone
	property real hubConeDiameter: 1.2192				// Upper hub cone was 4 ft across (1.2192 meters; radius 0.6096)
	property real hubConeRadius: hubConeDiameter / 2	// Upper hub cone radius 2ft (0.6096 meters)
	property real distance: 2.0							// Vision floor distance to center of hub in meters
	property real targetDist: 0.762						// 2.5 ft in meters; 0 to 1.2192

	// The cpp function subtracts the robot height
	//property real robotHeight: 0.9144						// 3 ft in meters
	property real hubHeight: 2.6416							// Hub was 8 ft 8 inches in 2022 (104 inches), 2.6416 in meters
	property real heightAboveHub: hubHeight + 0.161544		// 6.36 inches above rim in meters; minimum 3 inches 0.0762 meters
	property real targetHeight: 2.032						// 80 inches in meters

	property int k: -40

	ColumnLayout {
		LabeledSlider {
			id: distSlider
			width: sliderWid
			height: sliderHgt
			from: 1
			to: 6	// 6 meters ~ 20 ft6
			value: distance

			label: "distance"
			initValue: distance
			stepSize: 0.25
			labelWidth: sliderLabelWidth

			onValueChanged:
			{
				var revs = _ballistics.calc(distSlider.value - hubConeRadius, targetDistSlider.value, heightAboveHubSlider.value, targetHeight);
				print("distance ", distSlider.value - hubConeRadius, " targetDist ", targetDistSlider.value, " heightAboveHub ", heightAboveHubSlider.value, " targetHeight ", targetHeight, " revs ", revs);
				canvas.requestPaint();
			}

		}

		LabeledSlider {
			id: heightAboveHubSlider
			width: sliderWid
			height: sliderHgt
			from: 0.0762
			to: 5.0			// 3 meters
			value: heightAboveHub

			label: "heightAboveHub"
			initValue: heightAboveHub
			stepSize: 0.0508
			labelWidth: sliderLabelWidth

			onValueChanged:
			{
				var revs = _ballistics.calc(distSlider.value - hubConeRadius, targetDistSlider.value, heightAboveHubSlider.value, targetHeight);
				print("distance ", distSlider.value - hubConeRadius, " targetDist ", targetDistSlider.value, " heightAboveHub ", heightAboveHubSlider.value, " targetHeight ", targetHeight, " revs ", revs);
				canvas.requestPaint();
			}
		}

		LabeledSlider {
			id: targetDistSlider
			width: sliderWid
			height: sliderHgt
			from: 0
			to: 1.2192
			value: targetDist

			label: "targetDist"
			initValue: targetDist
			stepSize: 0.0508
			labelWidth: sliderLabelWidth

			onValueChanged:
			{
				var revs = _ballistics.calc(distSlider.value - hubConeRadius, targetDistSlider.value, heightAboveHubSlider.value, targetHeight);
				print("distance ", distSlider.value - hubConeRadius, " targetDist ", targetDistSlider.value, " heightAboveHub ", heightAboveHubSlider.value, " targetHeight ", targetHeight, " revs ", revs);
				canvas.requestPaint();
			}
		}

		/*
		LabeledSlider {
			id: kSlider
			width: sliderWid
			height: sliderHgt
			from: -500
			to: 500
			value: k

			label: "k param"
			initValue: k
			stepSize: 10
			labelWidth: sliderLabelWidth

			onValueChanged: canvas.requestPaint()
		}
		*/
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
			// The QML Canvas element uses a standard two-dimensional Cartesian
			// coordinate system where the origin (0, 0) is at the top-left corner.
			var a = _ballistics.parabolaFitAcoeff;
			var b = _ballistics.parabolaFitBcoeff;
			var c = 0.0;
			var meterPerPx = 8.0 / canvas.width;	// Max shot dist 6.0 meters ~ 20 ft, use 8 meters wide for some margin
			var xOffset = 1 / meterPerPx;
			var yOffset = canvas.height / 4;//100;
			//print("window xywh ", mainWindow.x, " ", mainWindow.y, " ", mainWindow.width, " ", mainWindow.height);
			//print("canvas xywh ", canvas.x, " ", canvas.y, " ", canvas.width, " ", canvas.height);
			//print("meterPerPx ", meterPerPx, " xOffset ", xOffset, " yOffset ", yOffset);

			print("x [meter],y [meter],x [px],y [px]");

			for (var xPx = 0; xPx <= width; xPx++) {
				// Distance in meters to pixels
				var xMeters = xPx * meterPerPx;
				// Parabola equation
				var yMeters = a * Math.pow(xMeters, 2) + b * xMeters + c;

				var yPx = canvas.height - yOffset - (yMeters / meterPerPx);	// Put y in pixels, invert to the canvas y axis

				if (xPx === 0 || xPx === width / 2 || xPx === width)
					print(xMeters, ",", yMeters, ",",  xPx, ",", yPx);

				if (xPx > _ballistics.parabolaFitX3 / meterPerPx) {
					//print(xMeters, ",", yMeters, ",",  xPx, ",", yPx, " breaking loop xOffset ", xOffset, " _ballistics.parabolaFitX3 ", _ballistics.parabolaFitX3 / meterPerPx);
					break;
				}

				if ((yPx < canvas.height - yOffset)) {
					if (xPx === 0) {
						ctx.moveTo(xPx + xOffset, yPx);
					} else {
						ctx.lineTo(xPx + xOffset, yPx);
					}
				}
			}
			ctx.stroke();

			// Highlight the 3 points on the parabola
			ctx.strokeStyle = "red";
			ctx.lineWidth = 1;

			var markerSize = 10;
			var markerOffset =  markerSize / 2;
			xOffset = xOffset - markerOffset;
			yOffset = yOffset + markerOffset;

			var xMarker = xOffset;
			var yMarker = canvas.height - yOffset;
			ctx.beginPath();
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX2 / meterPerPx
			yMarker = canvas.height - yOffset - _ballistics.parabolaFitY2 / meterPerPx;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX3 / meterPerPx
			yMarker = canvas.height - yOffset - _ballistics.parabolaFitY3 / meterPerPx;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			// Draw robot and hub
			ctx.strokeStyle = "black";
			ctx.lineWidth = 1;
			ctx.beginPath();

			xMarker = 1 / meterPerPx;
			yMarker = canvas.height - yOffset;
			var wRobot = 0.762 / meterPerPx;
			var xRobot = xMarker - wRobot / 2;
			var yRobot = canvas.height - 0.9144 / meterPerPx;	// bot was 36 inches in 2022
			ctx.moveTo(xRobot, yRobot);
			ctx.rect(xRobot, yRobot, wRobot, 0.127 / meterPerPx);
			ctx.moveTo(xRobot + 30, yRobot - 0.9144 / meterPerPx);
			ctx.rect(xRobot + 30, yRobot - 0.9144 / meterPerPx, wRobot - 60, 0.9144 / meterPerPx);
			ctx.stroke();

			ctx.beginPath();
			var wHub = hubConeDiameter / meterPerPx;
			var hHub = hubHeight / meterPerPx;
			//var xHub = (distSlider.value - hubConeRadius) / meterPerPx;
			var xHub = xMarker + _ballistics.parabolaFitX2 / meterPerPx;
			//var yHub = canvas.height - hHub + kSlider.value * canvas.width / 400;
			var yHub = canvas.height - hHub + -40 * canvas.width / 400;
			//var yHub = canvas.height - (_ballistics.parabolaFitY2 - heightAboveHubSlider.value) / meterPerPx;
			ctx.moveTo(xHub, yHub);
			ctx.rect(xHub, yHub, wHub, hHub);
			//print("Hub xywh ", xHub, " ", yHub, " ", wHub, " ", hubHeight / meterPerPx);
			ctx.stroke();
		}
	}
 }
