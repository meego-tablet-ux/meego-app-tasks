/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.0
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Kernel 0.1
import MeeGo.Ux.Components 0.1

Rectangle {
    id: slate

    property alias title: headerTitle.text
    property alias subTitle: headerSubTitle.text
    property alias buttonText: headerButton.text
    property alias buttonVisible: headerButton.visible
    property alias viewVisible: view.visible
    property alias viewModel: view.model

    signal buttonClicked()
    signal viewItemButtonClicked()

    Theme {
        id: theme
    }

    Column {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 20

        Item {
            anchors.left: parent.left
            anchors.right: parent.right

            height: Math.max(headerTitle.height + headerSubTitle.height, headerButton.height) + 25

            Image {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                source: "image://themedimage/images/tasks/ln_grey_l"
            }

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 40
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: headerTitle

                    font.pixelSize: theme.fontPixelSizeLargest
                    font.bold: true
                }

                Text {
                    id: headerSubTitle

                    font.pixelSize: theme.fontPixelSizeMedium
                    font.bold: true
                }
            }

            Button {
                id: headerButton

                anchors.right: parent.right
                anchors.rightMargin: 40
                anchors.verticalCenter: parent.verticalCenter

                elideText: false
                minWidth: 300
                height: 60

                onClicked: slate.buttonClicked()
            }

            Image {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                source: "image://themedimage/images/tasks/ln_grey_l"
            }
        }

        ListView {
            id: view

            anchors.left: parent.left
            anchors.right: parent.right

            height: 100

            orientation: ListView.Horizontal

            delegate: Item {
                id: item
                width: view.width / 3
                Column {
                    spacing: 5

                    Rectangle {
                        id: imageRect

                        width: item.width - 40
                        height: item.width / 2

                        border.width: 1
                        border.color: "gray"

                        Image {
                            anchors.fill: parent
                            source: model.source

                            Button {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 10

                                minWidth: parent.width - 60
                                height: 60

                                visible: text.length > 0

                                text: model.buttonText

                                onClicked: slate.viewItemButtonClicked()
                            }
                        }
                    }
                    Text {
                        width: imageRect.width
                        font.pixelSize: theme.fontPixelSizeLargest
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: model.title
                    }
                    Text {
                        width: imageRect.width
                        font.pixelSize: theme.fontPixelSizeMedium
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: model.subTitle
                    }
                }
            }
        }
    }
}
