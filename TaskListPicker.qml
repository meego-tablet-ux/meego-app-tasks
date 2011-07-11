/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import QtQuick 1.0
import MeeGo.App.Tasks 0.1
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Gestures 0.1
import MeeGo.Ux.Components 0.1

ModalFog {
    id: container

    fogClickable: true

    // Move this to center
    x: window.width / 2 - tasksList.width / 2
    y: window.height / 2 - tasksList.height / 2

    signal selected(variant listId)

    modalSurface: Item {
        width: 400
        height: 300

        ListView {
            id: tasksList
            clip: true

            anchors.fill:  parent

            model: TasksListModel {
                modelType: TasksListModel.AllLists
            }

            delegate: Item {
                width: tasksList.width
                height: 50
                Rectangle {
                    color:"White"
                    width: parent.width
                    height: 40
                    anchors.centerIn: parent
                    Text {
                        id:  listNameText
                        text: listName
                        anchors.centerIn: parent
                        width: parent.width
                        elide: Text.ElideMiddle
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

// GestureArea still not working correctly
//                GestureArea {
//                    anchors.fill: parent
//                    Tap {
//                        onFinished: {
//                            container.selected(listId);
//                            container.visible = false;
//                        }
//                    }
//                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        container.selected(listId);
                        container.visible = false;
                    }
                }
            }
            footer: Item {
                id: createNewList
                width: tasksList.width
                height: 50
                Rectangle {
                    color:"White"
                    width: parent.width
                    height: 40
                    anchors.centerIn: parent
                    Text {
                        id: textElement
                        text: qsTr("Create a new list")
                        anchors.centerIn: parent
                    }
                }
//GestureArea still not working correctly
//                GestureArea {
//                    anchors.fill: parent
//                    Tap {
//                        onFinished: {
//                            createDialog.show();
//                        }
//                    }
//                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        createDialog.show();
                    }
                }
            }
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
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            defaultText: qsTr("List name")
        }
        onAccepted: {
            viewModel.addList(inputText.text);
            container.show()
        }
        onRejected: {
            container.show()
        }
    }
}
