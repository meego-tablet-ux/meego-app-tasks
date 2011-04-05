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
    id: bar
    source: "image://theme/tasks/bg_bottombar_l"
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

    TasksButton {
        id: saveBt
        title:labelSave
        upImageSource:"image://theme/tasks/btn_blue"
        dnImageSource:"image://theme/tasks/btn_blue"
        width: 200
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.horizontalCenter
        anchors.rightMargin: 5
        onClicked: {
            bar.clickedSave();
        }
    }
    TasksButton {
        id: cancelBt
        title: labelCancel
        upImageSource:"image://theme/tasks/btn_grey"
        dnImageSource:"image://theme/tasks/btn_grey"
        width: 200
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: deleteBt.right
        anchors.leftMargin: 5
        onClicked: {
            bar.clickedCancel();
        }
    }
    TasksButton {
        id: moveBt
        title:labelMove.arg(model.length)
        upImageSource:"image://theme/tasks/btn_blue"
        dnImageSource:"image://theme/tasks/btn_blue"
        width: 200
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: deleteBt.left
        anchors.rightMargin: 5
        onClicked: {
            bar.clickedMove();
        }
    }
    TasksButton {
        id: deleteBt
        title: labelDelete.arg(model.length)
        upImageSource:"image://theme/tasks/btn_blue"
        dnImageSource:"image://theme/tasks/btn_blue"
        width: 200
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.leftMargin: 5
        onClicked: {
            bar.clickedDelete();
        }
    }
    TasksButton {
        id: okBt
        title: labelOk
        upImageSource:"image://theme/tasks/btn_blue"
        dnImageSource:"image://theme/tasks/btn_blue"
        width: 200
        height: 66
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 5
        onClicked: {
            bar.clickedOk();
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
            AnchorChanges {
                target: cancelBt
                anchors.left: parent.horizontalCenter
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
            AnchorChanges {
                target: okBt
                anchors.left: deleteBt.right
            }
        }

    ]

}
