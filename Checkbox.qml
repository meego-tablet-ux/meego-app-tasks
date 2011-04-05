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
    property bool enabled: true

    signal clicked(bool checked)

    smooth: true
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if(box.enabled) {
                box.clicked(box.checked);
            }
        }
    }

    opacity: enabled ? 1 : 0.25

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
