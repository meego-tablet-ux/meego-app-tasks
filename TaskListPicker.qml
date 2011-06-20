/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Tasks 0.1
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Gestures 0.1

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

    GestureArea {
        anchors.fill: parent
        Tap {
            onFinished: {
                container.visible = false;
            }
        }
    }

//    MouseArea {
//        anchors.fill: parent
//        onClicked: container.visible = false
//    }


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
                horizontalAlignment: Text.AlignHCenter
            }

            GestureArea {
                anchors.fill: parent
                Tap {
                    onFinished: {
                        container.selected(listId);
                        container.visible = false;
                    }
                }
            }

//            MouseArea {
//                anchors.fill: parent
//                onClicked: {
//                    container.selected(listId);
//                    container.visible = false;
//                }
//            }
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
                width: existingList.width
                elide: Text.ElideMiddle
            }

            GestureArea {
                anchors.fill: parent
                Tap {
                    onFinished: {
                        createDialog.show();
                    }
                }
            }

//            MouseArea {
//                anchors.fill: parent
//                onClicked: createDialog.show()
//            }
        }
    }

    ModalDialog {
        id:createDialog
        opacity: 0
        showCancelButton: true
        showAcceptButton: true

        acceptButtonText: qsTr("OK")
        cancelButtonText: qsTr("Cancel")
        title:qsTr("Please name the new list")

        content: TextEntry {
            id: inputText
            anchors.fill: parent
            defaultText: qsTr("List name")
        }
        onAccepted: {
            viewmodel.addList(inputText.text);
        }
    }
}
