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
    width: 640
    height: list.height + newrow.height
    property variant listmodel: []
    property variant listDelegateEditing: rowDelegateEditing
    property variant listDelegateNormal: rowDelegateNormal

    property int rowHeight: 30
    function addNewItem(item) {
        listmodel = listmodel.concat([item])
    }
    property bool editing: false
    property alias text: addNew.text

    signal addNew()
    ListView {
        id: list
        width: parent.width
        height: model.length * (rowHeight + spacing)

        model: listmodel
        spacing: 1
        delegate: listDelegateNormal
        interactive: false
    }
    Rectangle {
        id: newrow
        width: parent.width
        height: rowHeight
        anchors.top: list.bottom
        color:"gray"
        Text {
            id: addNew
            anchors.fill: parent
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            text: qsTr("+ Add New Item")
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                container.addNew();
            }
        }
    }

    Component {
        id: rowDelegateEditing
        Rectangle {
            id: dinstance
            width: container.width
            height :rowHeight
            color:"gray"
            Text {
                id: text
                height: dinstance.height
                width: dinstance.width - 20 - deletebt.width
                text: modelData
                anchors.left: parent.left
                anchors.leftMargin: 10
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            TasksButton {
                id: deletebt
                title: qsTr("X")
                anchors.right: parent.right
                width: rowHeight
                height: rowHeight
                onClicked: {
                    listmodel = listmodel.slice(0,index).concat(listmodel.slice(index+1, listmodel.length))
                }
            }
        }
    }
    Component {
        id: rowDelegateNormal
        Item {
            id: dinstance
            width: container.width
            height: rowHeight
            Rectangle {
                height: dinstance.height
                width: text.paintedWidth + 20
                color:"Silver"
                anchors.left: parent.left
            }

            Text {
                id: text
                height: dinstance.height
                width: dinstance.width - 20
                text: modelData
                anchors.left: parent.left
                anchors.leftMargin: 10
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    states: [
        State {
            name: "normal"
            when: !editing
            PropertyChanges {
                target: list
                delegate: listDelegateNormal
            }
            PropertyChanges {
                target: newrow
                height: 0
                visible: false
            }
        },
        State {
            name: "editing"
            when: editing
            PropertyChanges {
                target: list
                delegate: listDelegateEditing
            }
            PropertyChanges {
                target: newrow
                height: rowHeight
                visible: true
            }
        }
    ]

}
