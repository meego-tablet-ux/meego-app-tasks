/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1
BorderImage {
    id: bar
    source: "image://meegotheme/widgets/common/action-bar/action-bar-background"
    width: 1024
    height:80
    border.left: 20
    border.top: 5
    border.right: 20
    border.bottom: 5
    property string labelSave: qsTr("Save")
    property string labelCancel: qsTr("Cancel")
    property string labelMove: qsTr("Move to (%1)")
    property string labelDelete: qsTr("Delete (%1)")
    property string labelOk: qsTr("OK")
    property alias saveButtonActive: saveBt.active


    property variant model

    // mode 0: save and cancel button
    // mode 1: move, delete and OK button
    property int mode: 0

    signal clickedSave()
    signal clickedMove()
    signal clickedDelete()
    signal clickedCancel()
    signal clickedOk()

    Image {
        source: "image://meegotheme/widgets/common/action-bar/action-bar-shadow"
        anchors.bottom: bar.top
        width: parent.width
    }

    Row {
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Button {
            id: saveBt
            text:labelSave
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            onClicked: {
                bar.clickedSave();
            }
        }

        Button {
            id: moveBt
            text:labelMove.arg(model.length)
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            active: model.length > 0
            onClicked: {
                bar.clickedMove();
            }
        }
        Button {
            id: deleteBt
            text: labelDelete.arg(model.length)
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            active: model.length > 0
            onClicked: {
                bar.clickedDelete();
            }
        }
        Button {
            id: okBt
            text: labelOk
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            onClicked: {
                bar.clickedOk();
            }
        }
        Button {
            id: cancelBt
            text: labelCancel
            onClicked: {
                bar.clickedCancel();
            }
        }
    }

    states: [
        State {
            name: "savecacel"
            when: mode == 0
            PropertyChanges {
                target: moveBt
                visible: false
            }
            PropertyChanges {
                target: deleteBt
                visible: false
            }
            PropertyChanges {
                target: saveBt
                visible: true
            }
            PropertyChanges {
                target: okBt
                visible:false
            }

            PropertyChanges {
                target: cancelBt
                visible: true
            }
        },
        State {
            name: "movedeletecacel"
            when: mode == 1
            PropertyChanges {
                target: moveBt
                visible: true
            }
            PropertyChanges {
                target: deleteBt
                visible: true
            }
            PropertyChanges {
                target: saveBt
                visible: false
            }
            PropertyChanges {
                target: cancelBt
                visible: true
            }
            PropertyChanges {
                target: okBt
                visible: false

            }
        }

    ]

}
