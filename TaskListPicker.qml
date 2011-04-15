/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Tasks 0.1
import MeeGo.Labs.Components 0.1

Item {
    id: container
    anchors.fill: parent
    visible: false

    signal selected(variant listId)



    Rectangle {
        anchors.fill:parent
        color:"black"
        opacity: 0.5
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            container.visible = false;
        }
    }


    TasksListModel {
        id: viewmodel
        modelType: TasksListModel.AllLists
    }

    ListView {
        id: existingList
        width:400
        height: 300
        anchors.centerIn: parent
        model: viewmodel
        clip: true
        delegate: Item {
            width: 400
            height: 50
            Rectangle {
                color:"White"
                width: parent.width
                height: 40
                anchors.centerIn: parent
            }
            Text {
                id:  text
                text: listName
                anchors.centerIn: parent
                width: parent.width
                elide: Text.ElideMiddle
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    container.selected(listId);
                    container.visible = false;
                }
            }

        }

        footer:  Item {
            width: 400
            height: 50
            Rectangle {
                color:"White"
                width: parent.width
                height: 40
                anchors.centerIn: parent
            }
            Text {
                id:  text
                text: qsTr("Create a new list")
                anchors.centerIn: parent
                elide: Text.ElideMiddle
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    createDialog.opacity = 1

                }
            }

        }
    }

    ModalDialog {
        id:createDialog
        opacity: 0
        leftButtonText: qsTr("OK")
        rightButtonText: qsTr("Cancel")
        bgSourceUpLeft:"image://theme/btn_blue_up"
        bgSourceDnLeft:"image://theme/btn_blue_dn"
        dialogTitle:qsTr("Please name the new list")
        dialogWidth: 300
        dialogHeight: 200

        TextEntry {
            id: inputText
            anchors.centerIn: parent
            width: parent.dialogWidth
            defaultText: qsTr("List name")
        }
        onDialogClicked : {
            if(button == 1) {
                viewmodel.addList(inputText.text);
            }
            createDialog.opacity = 0;
        }
    }
}
