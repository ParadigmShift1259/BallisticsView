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

		// Define the world size in meters visible across the window.
		// Adjust these to match your desired "meters per view".
		property real viewMetersWidth: 8.0			// Max shot dist 6.0 meters ~ 20 ft, use 8 meters wide for some margin
		property real viewMetersHeight: 5.0			// Ceiling height 5 meters

		// Pixels per meter based on current window size.
		property real pxPerMeterX: width / viewMetersWidth;
		property real pxPerMeterY: height / viewMetersHeight;

		onPaint: {
			var ctx = getContext("2d");
			ctx.reset();
			ctx.resetTransform();
			ctx.clearRect(0, 0, width, height);

			// The QML Canvas element uses a standard two-dimensional Cartesian
			// coordinate system where the origin (0, 0) is at the top-left corner.
			// Set origin to lower-left, meters increasing right/up.
			ctx.translate(0, height);
			ctx.scale(pxPerMeterX, -pxPerMeterY);

			var floorOffset = 0.25;
			drawFloor(ctx, floorOffset);

			var xOffset = 1.0;							// Start the drawing 1 meter from the left side
			var yOffset = floorOffset + robotHeight;	// The parabola origin is at the top of the robot where the shooter spits it out
			drawParabola(ctx, xOffset, yOffset);
			drawParabolaFitPoints(ctx, xOffset, yOffset);

			yOffset = floorOffset;						// Reset to the floor
			drawRobot(ctx, xOffset, yOffset);
			drawHub(ctx, xOffset, yOffset);
		}

		function drawParabola(ctx, xOffset, yOffset) {
			var a = _ballistics.parabolaFitAcoeff;
			var b = _ballistics.parabolaFitBcoeff;
			var c = 0.0;

			// Stylings
			ctx.strokeStyle = "blue";
			ctx.lineWidth = 0.01; // meters

			ctx.beginPath();

			const xStart = 0.0;
			const xEnd = inputDist + inputTargetDist;
			const steps = 80;
			const dx = (xEnd - xStart) / steps;

			for (var i = 0; i <= steps; i++) {
				// Parabola equation
				const xMeters = xStart + i * dx;
				var yMeters = a * Math.pow(xMeters, 2) + b * xMeters + c;

				if (yMeters < viewMetersHeight) {
					if (i === 0) {
						ctx.moveTo(xMeters + xOffset, yMeters + yOffset);
					} else {
						ctx.lineTo(xMeters + xOffset, yMeters + yOffset);
					}
				}
			}
			ctx.stroke();
		}

		function drawParabolaFitPoints(ctx, xOffset, yOffset) {
			// Highlight the 3 points on the parabola
			ctx.strokeStyle = "red";
			ctx.lineWidth = 0.01; // meters

			var markerSize = 0.05;
			var markerOffset =  markerSize / 2;
			// print("marker xOffset, yOffset ", xOffset, " ", yOffset);
			// print("marker x2, y2 ", _ballistics.parabolaFitX2, " ", _ballistics.parabolaFitY2);
			// print("marker x2 + ofs, y2 + ofs ", xOffset + _ballistics.parabolaFitX2, " ", yOffset + _ballistics.parabolaFitY2);
			xOffset = xOffset - markerOffset;
			yOffset = yOffset - markerOffset;

			// Origin of parabola
			var xMarker = xOffset;
			var yMarker = yOffset;
			ctx.beginPath();
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			// Point above front rim
			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX2;
			yMarker = yOffset + _ballistics.parabolaFitY2;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();

			// Landing target point
			ctx.beginPath();
			xMarker = xOffset + _ballistics.parabolaFitX3;
			yMarker = yOffset + _ballistics.parabolaFitY3;
			ctx.moveTo(xMarker, yMarker);
			ctx.ellipse(xMarker, yMarker, markerSize, markerSize);
			ctx.stroke();
		}

		function drawFloor(ctx, floorOffset) {
			ctx.strokeStyle = "black";
			// Set the line dash pattern: 5 pixels on, 3 pixels off
			ctx.setLineDash([5, 3]);
			ctx.lineWidth = 0.01; // meters

			// Draw floor line
			ctx.beginPath();
			ctx.moveTo(0, floorOffset);
			ctx.lineTo(viewMetersWidth, floorOffset);
			ctx.stroke();
			ctx.setLineDash([]);
		}

		function drawRobot(ctx, xOffset, yOffset) {
			ctx.strokeStyle = "black";
			ctx.lineWidth = 0.01; // meters

			var wRobot = 0.762;

			var wheelHeight = 0.03;
			var xRobot = xOffset - wRobot / 2;
			var yRobot = yOffset + wheelHeight;

			ctx.beginPath();
			// Bumpers
			var bumperHeight = 0.127;
			ctx.moveTo(xRobot, yRobot);
			ctx.rect(xRobot, yRobot, wRobot, bumperHeight);

			// Robot superstructure
			var indent = 0.1;
			ctx.moveTo(xRobot + indent, yRobot + bumperHeight);	// 0.1 meter "indent" for robot superstructure
			ctx.rect(xRobot + indent, yRobot + bumperHeight, wRobot - indent * 2, robotHeight - wheelHeight - bumperHeight);
			ctx.stroke();
		}

		function drawHub(ctx, xOffset, yOffset) {
			ctx.strokeStyle = "black";
			ctx.lineWidth = 0.01; // meters

			var wHub = hubConeDiameter;
			var hHub = 49.75 / inchesPerMeter; //hubHeightSlider.value;

			// Coords to point above front rim
			var xHub = xOffset + _ballistics.parabolaFitX2;
			var yHub = yOffset;
			// print("hub xOffset, yOffset ", xOffset, " ", yOffset);
			// print("hub xHub, yHub ", xHub, " ", yHub);
			// print("hub wHub, hHub ", wHub, " ", hHub);
			// print("hub inputHeightAbove ", inputHeightAbove);

			ctx.beginPath();
			ctx.moveTo(xHub, yHub);
			ctx.rect(xHub, yHub, wHub, hHub);
			ctx.fillStyle= Qt.rgba(0, 0, 0, 0.0);
			ctx.fillRect(xHub + 0.1, yHub + 0.1, wHub - 0.2, hHub - 0.2);
			ctx.stroke();

			xHub = xOffset + _ballistics.parabolaFitX2 + ((47 - 41.92) / 2) / inchesPerMeter;
			yHub = yOffset + 72.0 / inchesPerMeter;
			ctx.beginPath();
			ctx.moveTo(xHub, yHub);
			xHub = xHub + 10 / inchesPerMeter;
			yHub = yOffset + 49.75 / inchesPerMeter;
			ctx.lineTo(xHub, yHub);
			ctx.stroke();

			xHub = xOffset + _ballistics.parabolaFitX2 + 41.92 / inchesPerMeter;
			yHub = yOffset + 72.0 / inchesPerMeter;
			ctx.beginPath();
			ctx.moveTo(xHub, yHub);
			xHub = xHub - 10 / inchesPerMeter;
			yHub = yOffset + 49.75 / inchesPerMeter;
			ctx.lineTo(xHub, yHub);
			ctx.stroke();
		}
	}
 }
