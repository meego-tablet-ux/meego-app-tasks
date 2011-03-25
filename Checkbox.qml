/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
Image {
    id: box
    property bool checked: false

    signal clicked(bool checked)

    smooth: true
//    source: "image://theme/tasks/btn_checkbox_off"
    MouseArea {
        anchors.fill: parent
        onClicked: {
        //    parent.checked= !parent.checked;
            box.clicked(box.checked);
        }
    }

    states: [
        State {
            name: "checked"
            when: checked
            PropertyChanges {
                target: box
                source:"image://theme/tasks/btn_checkbox_on"
            }
        },
        State {
            name: "unchecked"
            when: !checked
            PropertyChanges {
                target: box
                source:"image://theme/tasks/btn_checkbox_off"
            }
        }
    ]

}
