/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1 as Ux
import MeeGo.Labs.Components 0.1 as Labs

Item {
    id: row
    height: 60
    width: 500
    property string labelCreateNewTask: qsTr("Tap to add task")
    property int textLeftMargin: 20
    property bool editing: false
    property int editorVerticalMargin: 15
    property alias extraHeight: dropdownbox.contentHeight
    property alias textinput: textinput
    property alias actions: actions.model
    property bool selectedDueDate: false
    property date selectedDate

    signal confirmedInput();
    signal requestForEditing();

    Rectangle {
        color: "white"
        anchors.fill: parent
    }

    Image {
        id: separator
        width: parent.width
        anchors.bottom: parent.bottom
        source: "image://theme/tasks/ln_grey_l"
    }

    Checkbox {
        id: checkbox
        anchors.left: parent.left
        anchors.leftMargin: (row.height - width)/2
        anchors.top:  parent.top
        anchors.topMargin: (row.height - height)/2
        enabled: false
    }

    Image {
        id: vDivider
        source: "image://theme/tasks/ln_grey_p"
        height: parent.height
        width: 1
        anchors.left: checkbox.right
        anchors.leftMargin: 20
    }

    Labs.TextEntry {
        id: textinput
        //anchors.left: parent.left
        anchors.left: checkbox.right
        anchors.leftMargin: row.height / 2
        anchors.right: dropdownbox.left
        height: row.height - 10
        anchors.verticalCenter: parent.verticalCenter
        defaultText: labelCreateNewTask
        onTextChanged: requestForEditing();
    }


    Ux.DatePicker {
        id: datePicker
        onDateSelected: {
            row.selectedDate = date;
        }
    }



    DropdownBox {
        id: dropdownbox
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        contentHeight: actions.height
        TasksActionMenu{
            id: actions
            interactive: false
            width: dropdownbox.contentWidth - 40
            parent: dropdownbox.content
            anchors.centerIn: parent
            onClickedAt: {
                dropdownbox.open = false;
                if(index > 0) {
                    selectedDueDate = true;
                    if(index == 1) {
                        selectedDate = new Date();
                    } else if(index == 2) {
                        var tempDate = new Date(); //need a temp because this doesn't work otherwise
                        tempDate.setDate(tempDate.getDate() + 1); //I don't know why
                        selectedDate = tempDate;
                    } else if(index == 3) {
                        var tempDate = new Date();
                        tempDate.setDate(tempDate.getDate() + 7);
                        selectedDate = tempDate;
                    }
                    else if(index == 4) {
                        datePicker.show(row.width/2,mouseY);
                    }
                } else {
                    selectedDueDate = false;
                }
            }
        }
    }
}
