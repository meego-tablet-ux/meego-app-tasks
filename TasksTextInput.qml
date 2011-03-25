/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
BorderImage {
    id: container
    source: "image://theme/tasks/frm_textbox_l"
    width: 200; height: 40
    border.left: 8
    border.top: 8
    border.right: 8
    border.bottom: 8

    property alias text: textinput.text
    property alias textInput: textinput

    TextInput {
        id: textinput
        width: parent.width - 20
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
    }
}
