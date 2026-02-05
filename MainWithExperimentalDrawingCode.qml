import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls

Window {
	id: mainWindow
	width: 800
	height: 800
	visible: true
	title: "Team 1259 Paradigm Shift Ballistics Viewer"
	color: "grey"

	property bool windowReady: false

	property real sliderWid: 300
	property real sliderHgt: 30
	property real sliderLabelWidth: 90

	property font labelFont: Qt.font({ family: "Consolas", pointSize: 16 })

	// Inputs to _ballistics.calc
	//	meter_t distance        // Floor distance to "front" rim of cone (vision dist was to center of hub)
	//	meter_t targetDist      // Target distance within cone from rim
	//	meter_t heightAboveHub  // How far above Hub to palce the shot
	//	meter_t targetHeight    // Height at end point within cone
	//property real hubConeDiameter: 1.2192				// Upper hub cone was 4 ft across (1.2192 meters; radius 0.6096)
	property real hubConeDiameter: 42 / inchesPerMeter				// Upper hub cone is ~42 inches across (hex shape)
	property real hubConeRadius: hubConeDiameter / 2	// Upper hub cone radius 2ft (0.6096 meters)
	property real distance: 2.0							// Vision floor distance to center of hub in meters
	property real targetDist: 21 / inchesPerMeter

	// Live reactive bound values
	readonly property real inputDist: distSlider.value - hubConeRadius
	readonly property real inputTargetDist: targetDistSlider.value
	readonly property real inputHeightAbove:  hubHeightSlider.value + heightAboveHubSlider.value
	readonly property real inputTargetHeight: targetHeightSlider.value

	property real initFlywheelMass: _ballistics ? _ballistics.flywheelMass : 0.680389
	property real initFlywheelRadius: _ballistics ? _ballistics.flywheelRadius : 0.0508
	property real initMinAngle: _ballistics ? _ballistics.minAngle : 20
	property real initMaxAngle: _ballistics ? _ballistics.maxAngle : 80

	// The cpp function subtracts the robot height
	//property real robotHeight: 0.9144						// 3 ft in meters
	property real robotHeight: 30 / inchesPerMeter
	//property real hubHeight: 2.6416							// Hub was 8 ft 8 inches in 2022 (104 inches), 2.6416 in meters
	property real hubHeight: 72 / inchesPerMeter
	property real heightAboveHub: 6 / inchesPerMeter		// 6 inches above rim in meters; minimum 3 inches 0.0762 meters
	property real targetHeight: hubHeight - 4 / inchesPerMeter
	//property real targetHeight: 2.032						// 80 inches in meters in 2022

	readonly property real inchesPerMeter: 39.37008
	readonly property real feetPerMeter: 3.28084
	readonly property real poundPerkilogram: 2.204623
	readonly property real degPerRad: 0.017453

	Component.onCompleted: windowReady = true

	Timer {
		id: refreshTimer
		interval: 100
		running: false
		repeat: false
		onTriggered: {
			running = false;
			updateView();
		}
	}

	function updateView()
	{
		if (_ballistics && mainWindow.windowReady && flywheelMassSlider.value !== 128)
		{
			_ballistics.setPhysicalProperties(flywheelMassSlider.value
											, flywheelRadiusSlider.value
											, minAngleSlider.value
											, maxAngleSlider.value
											);

			// _heightAboveHub is the hub height plus the height above the rim
			var revs = _ballistics.calc(inputDist, inputTargetDist, inputHeightAbove, inputTargetHeight);
			//print("distance ", inputDist, " targetDist ", inputTargetDist, " heightAboveHub ", inputHeightAbove, " targetHeight ", inputTargetHeight, " revs ", revs);
			canvas.requestPaint();
		}
	}

	Row {
		spacing: 50

		ColumnLayout {
			LabeledSlider {
				id: distSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 1
				to: 7	// Leave room for hex cone radius 6 meters ~ 20 ft6
				value: distance
				label: "distance"
				initValue: distance
				stepSize: 0.25
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: targetDistSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 0
				to: hubConeDiameter
				value: targetDist
				label: "targetDist"
				initValue: targetDist
				stepSize: 2 / inchesPerMeter
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: heightAboveHubSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 0
				to: 96 / inchesPerMeter
				value: heightAboveHub
				label: "heightAboveHub"
				initValue: heightAboveHub
				stepSize: 3 / inchesPerMeter
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: targetHeightSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 49.75 / inchesPerMeter
				to: hubHeightSlider.value
				value: targetHeight
				label: "targetHeight"
				initValue: targetHeight
				stepSize:  2 / inchesPerMeter
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: hubHeightSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 72 / inchesPerMeter
				to: 104 / inchesPerMeter
				value: hubHeight
				label: "hubHeight"
				initValue: hubHeight
				stepSize:  6 / inchesPerMeter
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: flywheelMassSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 0.25	// kg
				to: 2
				value: initFlywheelMass
				label: "flywheelMass"
				initValue: initFlywheelMass
				stepSize: 0.25
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: flywheelRadiusSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 0.0254	// 1 inch
				to: 0.0254 * 6	// 6 inches
				value: initFlywheelRadius
				label: "flywheelRadius"
				initValue: initFlywheelRadius
				stepSize: 0.0254 / 2	// half inch
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: minAngleSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 20
				to: 40
				value: initMinAngle
				label: "minAngle"
				initValue: initMinAngle
				stepSize: 5
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			LabeledSlider {
				id: maxAngleSlider
				width: sliderWid; height: sliderHgt; labelWidth: sliderLabelWidth;
				from: 40
				to: 80
				value: initMaxAngle
				label: "maxAngle"
				initValue: initMaxAngle
				stepSize:  5
				onValueChanged:	{
					updateView();
					refreshTimer.restart();
				}
			}

			Button {
				text: "Recalculate"
				onClicked: updateView()
			}
		}

		ColumnLayout {
			Text { font: labelFont; text: "Algorithm Inputs" }

			AlgInfoTextRow { lbl: "  Floor Dist"; valueMetric: _ballistics ? _ballistics.inputDist : 0; unitsMetric: "[m]"; convImperial: feetPerMeter; unitsImerial: "[ft]" }
			AlgInfoTextRow { lbl: "  Landing Dist in Hub Cone"; valueMetric: _ballistics ? _ballistics.inputTargetDist : 0; unitsMetric: "[m]"; convImperial: inchesPerMeter; unitsImerial:"[in]" }
			AlgInfoTextRow { lbl: "  Height Above Front Rim"; valueMetric: _ballistics ? _ballistics.inputHeightAbove : 0; unitsMetric: "[m]"; convImperial: inchesPerMeter; unitsImerial:"[in]" }
			AlgInfoTextRow { lbl: "  Landing Height"; valueMetric: _ballistics ? _ballistics.inputTargetHeight : 0; unitsMetric: "[m]"; convImperial: inchesPerMeter; unitsImerial:"[in]" }

			Text { font: labelFont; text: "Intermediate Results" }
			AlgInfoTextRow { lbl: "  Time of Flight"; valueMetric: _ballistics ? _ballistics.interMedTimeOfFlight : 0; unitsMetric: "[s]"; convImperial: 1.0; unitsImerial:"[s]"; decimalPlaces: 3 }
			AlgInfoTextRow { lbl: "  Max Height"; valueMetric: _ballistics ? _ballistics.interMedMaxHeight : 0; unitsMetric: "[m]"; convImperial: feetPerMeter; unitsImerial:"[ft]" }
			AlgInfoTextRow { lbl: "  Init Vel X"; valueMetric: _ballistics ? _ballistics.interMedInitVelX : 0; unitsMetric: "[m/s]"; convImperial: feetPerMeter; unitsImerial:"[ft/s]" }
			AlgInfoTextRow { lbl: "  Init Vel Y"; valueMetric: _ballistics ? _ballistics.interMedmInitVelY : 0; unitsMetric: "[m/s]"; convImperial: feetPerMeter; unitsImerial:"[ft/s]" }
			AlgInfoTextRow { lbl: "  Init Vel"; valueMetric: _ballistics ? _ballistics.interMedInitVel : 0; unitsMetric: "[m/s]"; convImperial: feetPerMeter; unitsImerial:"[ft/s]" }

			Text { font: labelFont; text: "Algorithm Outputs" }
			AlgInfoTextRow { lbl: "  Flywheel RPM"; valueMetric: _ballistics ? _ballistics.outputRpms : 0; unitsMetric: "[RPM]"; convImperial: 1.0 / 9.5493 ; unitsImerial:"[rads/s]"; decimalPlaces: 0 }
			AlgInfoTextRow { lbl: "  Shot Angle"; valueMetric: _ballistics ? _ballistics.outputInitAngle : 0; unitsMetric: "[deg]"; convImperial: degPerRad; unitsImerial:"[rad]" }
			AlgInfoTextRow { lbl: "  Landing Angle"; valueMetric: _ballistics ? _ballistics.outputLandingAngle : 0; unitsMetric: "[deg]"; convImperial: degPerRad; unitsImerial:"[rad]" }

			Text { font: labelFont; text: "Physical Constraints" }
			AlgInfoTextRow { lbl: "  flywheelMass"; valueMetric: _ballistics ? _ballistics.flywheelMass : 0; unitsMetric: "[kg]"; convImperial: poundPerkilogram ; unitsImerial:"[lb]"; decimalPlaces: 1 }
			AlgInfoTextRow { lbl: "  flywheelRadius"; valueMetric: _ballistics ? _ballistics.flywheelRadius : 0; unitsMetric: "[m]"; convImperial: inchesPerMeter ; unitsImerial:"[in]"; decimalPlaces: 1 }
			AlgInfoTextRow { lbl: "  minAngle"; valueMetric: _ballistics ? _ballistics.minAngle : 0; unitsMetric: "[deg]"; convImperial: degPerRad ; unitsImerial:"[rad]"; decimalPlaces: 1 }
			AlgInfoTextRow { lbl: "  maxAngle"; valueMetric: _ballistics ? _ballistics.maxAngle : 0; unitsMetric: "[deg]"; convImperial: degPerRad ; unitsImerial:"[rad]"; decimalPlaces: 1 }
		}
	}

	Canvas {
		id: canvas
		anchors.fill: parent

		onPaint: {
			var ctx = getContext("2d");
			ctx.reset();

			// The QML Canvas element uses a standard two-dimensional Cartesian
			// coordinate system where the origin (0, 0) is at the top-left corner.

			var a = _ballistics.parabolaFitAcoeff;
			var b = _ballistics.parabolaFitBcoeff;
			var c = 0.0;
			var meterPerPxH = 8.0 / canvas.width;	// Max shot dist 6.0 meters ~ 20 ft, use 8 meters wide for some margin
			var meterPerPxV = 5.0 / canvas.height;	// Ceiling height 5 meters

			var floorOffset = 20;
			var ceilingOffset = canvas.height - 350;
			var xOffset = 1 / meterPerPxH;
			var yOffset = canvas.height / 4;
			var markerSize = 10;
			var markerOffset =  markerSize / 2;
			var xMarker = xOffset;
			var yMarker = canvas.height - yOffset;
			var wRobot = 0.762 / meterPerPxH;
			var xRobot = xMarker - wRobot / 2;
			//var yRobot = canvas.height - 0.9144 / meterPerPxV;	// bot was 36 inches in 2022
			var yRobot = canvas.height - (0.762 / meterPerPxV);	// bot is max 30 inches in 2026

			// Stylings
			ctx.strokeStyle = "blue";
			ctx.lineWidth = 2;

			// Draw Parabola
			//---------------------------------------------------
			ctx.beginPath();
			//print("window xywh ", mainWindow.x, " ", mainWindow.y, " ", mainWindow.width, " ", mainWindow.height);
			//print("canvas xywh ", canvas.x, " ", canvas.y, " ", canvas.width, " ", canvas.height);
			//print("meterPerPxH ", meterPerPxH, " xOffset ", xOffset, " yOffset ", yOffset);

			//print("x [meter],y [meter],x [px],y [px]");

			for (var xPx = 0; xPx <= width; xPx++) {
				// Distance in meters to pixels
				var xMeters = xPx * meterPerPxH;
				// Parabola equation
				var yMeters = a * Math.pow(xMeters, 2) + b * xMeters + c;

				var yPx = canvas.height - yOffset - (yMeters / meterPerPxV);	// Put y in pixels, invert to the canvas y axis

				//if (xPx === 0 || xPx === width / 2 || xPx === width)
				//	print(xMeters, ",", yMeters, ",",  xPx, ",", yPx);

				//if (xPx > _ballistics.parabolaFitX3 / meterPerPxH) {
					//print(xMeters, ",", yMeters, ",",  xPx, ",", yPx, " breaking loop xOffset ", xOffset, " _ballistics.parabolaFitX3 ", _ballistics.parabolaFitX3 / meterPerPxH);
				//	break;
				//}

				if ((yPx < canvas.height - yOffset)) {
					if (xPx === 0) {
						ctx.moveTo(xPx + xOffset, yPx);
					} else {
						ctx.lineTo(xPx + xOffset, yPx);
					}
				}
			}
			ctx.stroke();
			//---------------------------------------------------

			//---------------------------------------------------
			// Highlight the 3 points on the parabola
			ctx.strokeStyle = "red";
			ctx.lineWidth = 1;

			xOffset = xOffset - markerOffset;
			yOffset = yOffset + markerOffset;

			// Origin
			ctx.beginPath();
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			// Point above front rim
			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX2 / meterPerPxH
			yMarker = canvas.height - yOffset - _ballistics.parabolaFitY2 / meterPerPxV;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			// Landing target point
			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX3 / meterPerPxH
			yMarker = canvas.height - yOffset - _ballistics.parabolaFitY3 / meterPerPxV;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();
			//---------------------------------------------------

			ctx.strokeStyle = "black";
			// Set the line dash pattern: 5 pixels on, 3 pixels off
			ctx.setLineDash([5, 3]);
			ctx.lineWidth = 1;

			// Draw floor line
			//---------------------------------------------------
			ctx.beginPath();
			ctx.moveTo(0, canvas.height - floorOffset);
			ctx.lineTo(canvas.width, canvas.height - floorOffset)
			ctx.stroke();
			//---------------------------------------------------

			// Draw ceiling line
			//---------------------------------------------------
			ctx.beginPath();
			ctx.moveTo(0, canvas.height - ceilingOffset);
			ctx.lineTo(canvas.width, canvas.height - ceilingOffset)
			ctx.stroke();
			//---------------------------------------------------

			ctx.setLineDash([]);
			// Draw robot
			//---------------------------------------------------
			ctx.beginPath();
			ctx.moveTo(xRobot, yRobot);
			//ctx.ellipse(xRobot, yRobot, markerSize, markerSize);
			ctx.rect(xRobot, yRobot, wRobot, 0.127 / meterPerPxV);	// 0.127 m = 5 inch bumper height
			ctx.moveTo(xRobot + 30, yRobot - robotHeight / meterPerPxV);	// 30 pixel "indent" for robot superstructure
			ctx.rect(xRobot + 30, yRobot - robotHeight / meterPerPxV, wRobot - 60, robotHeight / meterPerPxV);
			ctx.stroke();
			//---------------------------------------------------

			// Draw hub
			//---------------------------------------------------
			// Reset marker coords to point above front rim
			xMarker = xOffset + _ballistics.parabolaFitX2 / meterPerPxH
			yMarker = canvas.height - yOffset - _ballistics.parabolaFitY2 / meterPerPxV;
			var wHub = hubConeDiameter / meterPerPxH;
			var hHub = hubHeightSlider.value / meterPerPxV;

			var xHub = xMarker;

			//var yHub = canvas.height - hHub + kSlider.value * canvas.width / 400;
			//var yHub = canvas.height - hHub;// + -40 * canvas.width / 400;
			//var yHub = canvas.height - (_ballistics.parabolaFitY2 - heightAboveHubSlider.value) / meterPerPxV;
			var yHub = yMarker + heightAboveHubSlider.value / meterPerPxV;	// Adding to flip the y axis

			ctx.beginPath();
			ctx.moveTo(xHub, yHub);
			//ctx.ellipse(xHub, yHub, markerSize, markerSize);
			ctx.rect(xHub, yHub, wHub, hHub);
			ctx.fillStyle= Qt.rgba(0, 0, 0, 0.0);
			ctx.fillRect(xHub + 1, yHub + 1, wHub - 2, hHub - 2);
			//print("Hub xywh ", xHub, " ", yHub, " ", wHub, " ", hubHeight / meterPerPxV);
			ctx.stroke();
			//---------------------------------------------------
		}
	}
 }
