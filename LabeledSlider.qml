import QtQuick
import QtQuick.Controls

Item {
	width: 512
	height: 30
	
	property alias label: sliderLabel.text
	property alias from: slider.from
	property alias to: slider.to
	property alias value: slider.value
	property alias stepSize: slider.stepSize

	property real initValue: 0
	property int labelWidth: 50
	
	Row {
		id: labeledSliderRow
		spacing: 10
		width: parent.width
		height: parent.height
		
		Label {
			id: sliderLabel
			width: labelWidth
			height: parent.height
			color: "white"
		}
		
		Slider {
			id: slider
			width: parent.width - 2 * labeledSliderRow.spacing - labelWidth - resetBtn.width
			from: 0
			to: 255
			value: 128
			stepSize: 1
		}

		Label {
			width: 30
			height: parent.height
			color: "white"
			text: slider.value.toFixed(2)
		}

		Button { id: resetBtn; text: "Reset"; onClicked: { slider.value = initValue } }
	}
}

