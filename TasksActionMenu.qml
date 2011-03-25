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
    id: menu
    width: 300
    height: childrenRect.height

    property int menuEntryHeight: 50
    property variant model
    property alias interactive: listview.interactive

    function executeActionAtIndex(index) {
        if (index >= 0 && index < model.length) {
           // if (privatePart.clickedIndex != index) {
           //     privatePart.clickedIndex = index;
                model[index].triggered();
           // }
        }
    }
    signal clickedAt(int index, variant payload,int mouseX, int mouseY)
    signal pressAndHoldAt(int index, variant payload,int mouseX, int mouseY)
    signal doubleClickedAt(int index, variant payload,int mouseX, int mouseY)
    ListView{
        id: listview
        interactive: true
        width: parent.width
        height: parent.menuEntryHeight * count
        model: menu.model
        delegate: Rectangle {
            id: dinstance
            width: parent.width
            height: menu.menuEntryHeight
            property bool selected: modelData.checked

            color: selected ? "#281832": "transparent"
            Image {
                id: icon
                source: modelData.iconSource
                width: parent.width/10
                height: width
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                smooth: true
            }

            Text {
                id: title
                text: modelData.text
                height: parent.height
                width:parent.width * 0.7
                verticalAlignment: Text.AlignVCenter
                anchors.left: icon.right
                anchors.leftMargin: 5
                font.pixelSize: theme_fontPixelSizeLarge
                elide: Text.ElideRight
                color:selected? theme_fontColorHighlight:theme_fontColorNormal
            }
            Rectangle {
                width: parent.width/ 10
                height: width - 10 > 0 ? width -10 : 10
                radius: width/4
                color:"lightgray"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: title.right
                anchors.leftMargin: 5
                opacity: modelData.badgeText ? 1: 0
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData.badgeText
                    font.pixelSize: theme_fontPixelSizeSmaller
                }

            }
            ExtendedMouseArea {
                anchors.fill: parent
                onClicked: {
                    menu.executeActionAtIndex(index);
                    menu.clickedAt(index, dinstance,mouseX,mouseY);
                }
                onLongPressAndHold: {
                    menu.pressAndHoldAt(index,dinstance,mouseX,mouseY);
                }
                onDoubleClicked: {
                    menu.doubleClickedAt(index,dinstance,mouseX,mouseY);
                }
            }
        }

        Component {
            id: menuEntry
            Rectangle {
                width: menu.width
                height: menu.menuEntryHeight
                color:"red"
                opacity: 0.8
            }
        }

        Component {
            id: separator
            BorderImage {
                source: "images/separator.png"
                width: menu.width;
                border.left: 5; border.top: 0
                border.right: 5; border.bottom: 0
            }

        }
    }
}
