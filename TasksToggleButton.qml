/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

BorderImage {
	id: toggleSwitch

        source: "image://theme/panels/pnl_switch_bg"

        property bool on: false
	property bool suppress: true
        property string lstring
        property string rstring
        border.top: 5
        border.left:5
        border.right:5
        border.bottom:5

	signal toggled(bool isOn);

	onOnChanged: {

//               if(!toggleSwitch.suppress){
			toggleSwitch.toggled(toggleSwitch.on);
//			toggleSwitch.suppress = true
//		}
                //This is not working right now,
                //commenting
                //else toggleSwitch.suppress = false

	}

	function toggle(isOn)
	{
               //This is not working right now,
               //commenting
		toggleSwitch.on = isOn
	}

        Text {
                id: lstringLabel
                anchors.left: parent.left
                anchors.leftMargin: (toggleElement.width - lstringLabel.paintedWidth)/2
                anchors.verticalCenter: parent.verticalCenter
                text: lstring
                color: theme_fontColorHighlight
                font.pixelSize: toggleElement.height < toggleElement.width ?
                        toggleElement.height/3 : toggleElement.width/4
                z: 100
        }

        Text {
                id: rstringLabel
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: (toggleElement.width - rstringLabel.paintedWidth)/2
                text: rstring
                color: theme_fontColorHighlight
                font.pixelSize: toggleElement.height < toggleElement.width ?
                        toggleElement.height/3 : toggleElement.width/4
                z: 100
        }

        MouseArea {
                anchors.fill: parent
                onClicked: toggleSwitch.on = !toggleSwitch.on
        }

	Image {
		id: toggleElement

                anchors.top: parent.top
                anchors.bottom: parent.bottom

                width: parent.width * 0.55

		source: "image://theme/panels/pnl_switch_blue_up"

		signal clicked()

		property int tempx: 0
                property bool pressed: false

		MouseArea {
			anchors.fill: parent
			onClicked: toggleSwitch.on = !toggleSwitch.on
			onPressed: {
				toggleElement.source = "image://theme/panels/pnl_switch_blue_dn"
				toggleElement.pressed = true

				toggleElement.tempx = mouseX
			}

			onReleased: {
				toggleElement.source = "image://theme/panels/pnl_switch_blue_up"
				toggleElement.pressed = false
			}

			/*onMousePositionChanged: {
				if(toggleElement.pressed) {
					toggleElement.x -= toggleElement.tempx - mouseX;
					console.log((!toggleSwitch.on && (toggleElement.x + toggleElement.width / 2) < toggleSwitch.width / 2))
				}
			}*/
		}
	}


	states: [
		State {
			name: "on"
			PropertyChanges {
				target: toggleElement
				x: 0
			}

			when: toggleSwitch.on == true
		},
		State {
			name: "off"
			PropertyChanges {
				target: toggleElement
				x: parent.width - width
			}

			when: toggleSwitch.on == false
		},

		State {
			name: "draggedoff"
			PropertyChanges {
				target: toggleSwitch
				on: false
			}

			when: !toggleElement.pressed && !(!toggleSwitch.on && (toggleElement.x + toggleElement.width / 2) < toggleSwitch.width / 2)


		},

		State {
			name: "draggedon"
			PropertyChanges {
				target: toggleSwitch
				on: true
			}

			when: !toggleElement.pressed && (!toggleSwitch.on && (toggleElement.x + toggleElement.width / 2) < toggleSwitch.width / 2)

		}

	]

//	transitions: [
//		Transition {
//			NumberAnimation {
//				properties: "x"
//				duration: 200
//				easing.type: Easing.InCubic
//			}

//		}
//	]
}





