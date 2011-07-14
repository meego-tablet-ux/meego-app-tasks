/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Components.DateTime 0.1
import MeeGo.Ux.Gestures 0.1
import MeeGo.Ux.Components 0.1

Item {
    id: row
    height: 60
    width: 500
    property string labelCreateNewTask: qsTr("Tap to add task")
    property int textLeftMargin: 20
    property bool editing: false
    property int editorVerticalMargin: 15
    property int extraHeight: 200
    property alias textinput: textinput
    //property alias actions: actions.model
    property bool selectedDueDate: false
    property date selectedDate
    property date nullDate //used for resetting the selected date
    property variant timeSelectModel: [ labelSomeday, labelToday, labelTomorrow,
        labelNextWeek, labelSetDueDate];

    signal confirmedInput();
    signal requestForEditing();
    signal cancelEditing();

    function reset() {
        textinput.text = "";
        textinput.focus = false;
        selectedDueDate = false;
        selectedDate = nullDate;
        timeMenu.selectedIndex =0;
    }

    Image {
        source: "image://themedimage/widgets/common/list/list"
        anchors.fill: parent
    }

    Image {
        id: separator
        width: parent.width
        anchors.bottom: parent.bottom
        source: "image://themedimage/widgets/common/dividers/divider-horizontal-single"
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
        source: "image://themedimage/widgets/common/dividers/divider-vertical-single"
        height: parent.height
        anchors.left: checkbox.right
        anchors.leftMargin: 20
    }

    DatePicker {
        id: datePicker
        onDateSelected: {
            row.selectedDate = date;
        }
    }

    Row {
        anchors.left: checkbox.right
        anchors.leftMargin: row.height / 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20

        spacing: 5

        TextEntry {
            id: textinput
            width: parent.width - timeMenu.width
            height: row.height - 10
            defaultText: labelCreateNewTask
            onTextChanged: {
                if(text.length > 0) {
                    requestForEditing();
                } else {
                    cancelEditing();
                }
            }
            onAccepted:confirmedInput();
        }

        DropDown {
            id: timeMenu
            width: 200
            minWidth: 300
            title: qsTr("Select Due Date")
            height: textinput.height
            showTitleInMenu: true
            titleColor: "black"
            model:timeSelectModel
            Component.onCompleted: {
                selectedIndex = 0
            }
            onTriggered: {
                if(index > 0) {
                    selectedDueDate = true;
                    if(index == 1) {
                        selectedDate = new Date();
                    } else if(index == 2) {
                        var tempDate = new Date(); //need a temp because this doesn't work otherwise
                        tempDate.setDate(tempDate.getDate() + 1);
                        selectedDate = tempDate;
                    } else if(index == 3) {
                        var tempDate = new Date();
                        tempDate.setDate(tempDate.getDate() + 7);
                        selectedDate = tempDate;
                    }
                    else if(index == 4) {
                        datePicker.show();
                    }
                } else {
                    selectedDueDate = false;
                    selectedDate = nullDate;
                }
            }
        }
    }
}
