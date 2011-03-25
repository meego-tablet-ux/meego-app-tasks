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
    id: box
    width: closedTop.width
    height: closedTop.height
    property int contentWidth: 300
    property int contentHeight: 300
    property alias content: contentItem

    onWidthChanged: {
        width = closedTop.width
    }
    onHeightChanged: {
        height = closedTop.height
    }

    property bool open: false
    Item{
        id: baseItem
        width: closedTop.width
        height: closedTop.height
        Image {
            id: closedTop
            source: "image://theme/tasks/frm_dropdown"
        }
        Image {
            id: icon
            source: "image://theme/tasks/icn_calendardropdown"
            anchors.left: closedTop.left
            anchors.leftMargin: 10
            anchors.verticalCenter: closedTop.verticalCenter
            z: 100
        }
    }
    Item {
        id: openbox
        width: contentWidth
        height: contentHeight + top.height + bottom.height
        parent: baseItem
        opacity: 0
        onParentChanged : {
            if (parent) {
                anchors.top= parent.top;
                anchors.right = parent.right;
                anchors.rightMargin = -2;
            }
        }

        BorderImage {
            id: top
            source: "image://theme/tasks/frm_dropdown_open_top"
            width: openbox.width
            border.left: 10
            border.top:0
            border.right:120
            border.bottom: 0
        }
        BorderImage {
            id: middle
            source: "image://theme/tasks/frm_dropdown_open_middle"
            width: openbox.width
            height: contentHeight
            border.left: 10
            border.top:10
            border.right:10
            border.bottom: 10
            anchors.top: top.bottom
        }
        Item {
            id: contentItem
            parent:middle
            anchors.fill: parent

        }

        BorderImage {
            id: bottom
            source: "image://theme/tasks/frm_dropdown_open_bottom"
            width: openbox.width
            border.left: 10
            border.top:0
            border.right:10
            border.bottom: 0
            anchors.top: middle.bottom
        }

    }

    states: [
        State {
            name: "closed"
            when: !open
            PropertyChanges {
                target: closedTop
                opacity: 1
            }
            PropertyChanges {
                target: openbox
                opacity: 0

            }

        },
        State {
            name: "open"
            when: open
            PropertyChanges {
                target: closedTop
                opacity: 0
            }
            PropertyChanges {
                target: openbox
                opacity: 1

            }
        }
    ]

    transitions: [
        Transition {
            reversible: true
            PropertyAnimation {
                property:"opacity"
                duration: 200
            }

        }
    ]


    MouseArea {
        x: closedTop.x
        y: closedTop.y
        width: closedTop.width
        height:closedTop.height
        onClicked: {
            box.open = !box.open;

        }
    }


}
