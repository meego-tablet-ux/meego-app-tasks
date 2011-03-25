/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1

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

    Image {
        id: separator
        width: parent.width
        anchors.bottom: parent.bottom
        source: "image://theme/tasks/ln_grey_l"
    }

    BorderImage {
        id: editor
        source: "image://theme/tasks/frm_textbox_l"
        anchors.right: dropdownbox.left
        anchors.rightMargin: 10
        height: row.height - 2* editorVerticalMargin
        border.left: 10
        border.top: 10
        border.right: 10
        border.bottom: 10
        y: editorVerticalMargin

        TextEntry {
            id: textinput
            x: 25
            anchors.left: editor.left
            anchors.right: parent.right
            height: row.height - 10
            anchors.verticalCenter: parent.verticalCenter
            defaultText: labelCreateNewTask
            onTextChanged: requestForEditing();
        }
    }

    DatePickerDialog {
        id: datePicker
        onTriggered: {
            selectedDate = date;
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
