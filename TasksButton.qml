/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: container

    property alias title: label.text
    property alias font: label.font
    property alias color: label.color
    property bool pressed: false
    property bool active: true
    opacity: active ? 1.0 : 0.5
    property string upImageSource: "image://theme/tasks/btn_createnewtask_up"
    property string dnImageSource: "image://theme/tasks/btn_createnewtask_dn"

    signal clicked(variant mouse)
    Image {
        id: icon
        anchors.fill: parent
        source: upImageSource
        states: [
            State {
                name: "pressed"
                when: container.pressed
                PropertyChanges {
                    target: icon
                    rotation: 180
                    //source: dnImageSource
                }
            }
        ]

    }

    Text {
        id: label
        anchors.fill: parent
        anchors.margins: 10
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.pixelSize: theme_fontPixelSizeLarge
        color:theme_buttonFontColor
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (container.active)
            {
                container.clicked(mouse)
            }
        }
        onPressed: if (container.active) parent.pressed = true
        onReleased: if (container.active) parent.pressed = false
    }
}
