/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Tasks 0.1
Item {
    id: container
    anchors.fill: parent
    visible: false
    //color:"transparent"

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
    signal selected(variant listId)

    ListView {
        width:400
        height: 300
        anchors.centerIn: parent
        model: TasksListModel {
            id: viewmodel
            modelType: TasksListModel.AllLists
        }
        spacing: 4
        clip: true
        delegate: Rectangle {
            width: 400
            height: 40
            color:"Silver"
            Text {
                id:  text
                text: listName
                anchors.centerIn: parent
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    container.selected(listId);
                    container.visible = false;
                }
            }
        }
    }
}
