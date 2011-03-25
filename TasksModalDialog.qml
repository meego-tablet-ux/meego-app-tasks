/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

Item {
    id: container

    property alias contentLoader: contentLoader
    property alias leftButtonText: button1.title
    property alias rightButtonText: button2.title
    property alias dialogTitle: title.text
    property alias dialog: contents

    property bool checkBoxVisible: false
    property string checkBoxText: ""
    property alias checkBoxChecked: checkBox.isChecked

    anchors.fill: parent

    signal dialogClicked (int button)

    Rectangle {
        id: fog

        anchors.fill: parent
        color: theme_dialogFogColor
        opacity: theme_dialogFogOpacity
        Behavior on opacity {
            PropertyAnimation { duration: theme_dialogAnimationDuration }
        }
    }

    /* This mousearea is to prevent clicks from passing through the fog */
    MouseArea {
        anchors.fill: parent
    }

    BorderImage {
        id: dialog

        border.top: 14
        border.left: 20
        border.right: 20
        border.bottom: 20

        source: "image://theme/notificationBox_bg"

        x: (container.width - width) / 2
        y: (container.height - height) / 2
        width: contents.width + 40 //478
        height: contents.height + 40 //318

        Item {
            id: contents
            x: 20
            y: 20

            width: 438
            height: 200

            Column {
                id: contentColumn
                anchors.fill: parent

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: title
                    text: qsTr("Title text")
                    font.weight: Font.Bold
                    font.pixelSize: theme_fontPixelSizeLarge

                    height: 32
                }

                Loader {
                    id: contentLoader
                    width: 438
                    height: contents.height - (buttonBar.height + title.height)  - (checkBoxVisible ? checkboxTextArea.height*2 : 0)
                }

                Row {
                    visible: checkBoxVisible
                    spacing: 35
                    CheckBox {
                        id: checkBox
                    }

                    Text {
                        id: checkboxTextArea
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: checkBoxText
                        font.weight: Font.Bold
                        font.pixelSize: theme_fontPixelSizeLarge

                        height: 28
                    }


                }

                Item {
                    id: placeholder
                    width: 438
                    height: checkboxTextArea.height
                    visible: checkBoxVisible
                }

                Row {

                    id: buttonBar
                    width: parent.width
                    height: 60
                    spacing: 18

                    Button {
                        id: button1
                        width: 210
                        height: 60
                        onClicked: {
                            container.dialogClicked (1);
                        }
                    }

                    Button {
                        id: button2
                        width: 210
                        height: 60
                        onClicked: {
                            container.dialogClicked (2);
                        }
                    }
                }
            }
        }
    }
}
