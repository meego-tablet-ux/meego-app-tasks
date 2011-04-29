/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Components 0.1

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
    property variant checkMark: qsTr("* ");
    property variant timeSelectModel: [ checkMark +labelSomeday, labelToday, labelTomorrow,
        labelNextWeek, labelSetDueDate];

    signal confirmedInput();
    signal requestForEditing();

    function reset() {
        textinput.text = "";
        textinput.focus = false;
        selectedDueDate = false;
        selectedDate = nullDate;
        timeSelectModel = [ checkMark +labelSomeday, labelToday, labelTomorrow,
                           labelNextWeek, labelSetDueDate];
    }

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

    TextEntry {
        id: textinput
        anchors.left: checkbox.right
        anchors.leftMargin: row.height / 2
        anchors.right: icon.left
        height: row.height - 10
        anchors.verticalCenter: parent.verticalCenter
        defaultText: labelCreateNewTask
        onTextChanged:requestForEditing();
    }


    DatePicker {
        id: datePicker
        onDateSelected: {
            row.selectedDate = date;
        }
    }

    Image {
        id: icon
        source: "image://theme/tasks/frm_dropdown"
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        Image {
            id: closedTop
            x: 10
            source: "image://theme/tasks/icn_calendardropdown"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var map = icon.mapToItem(null,mouseX, mouseY);
                //landingScreenContextMenu.payload = dinstance;
                timeMenu.setPosition(map.x,map.y);
                timeMenu.show();
            }
        }
    }

    ContextMenu {
        id: timeMenu
        content: ActionMenu {
            model:timeSelectModel
            onTriggered: {
                timeMenu.hide();
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
                        datePicker.show();
                    }
                } else {
                    selectedDueDate = false;
                    selectedDate = nullDate;
                }

                var temp = timeSelectModel;
                for(var i=0;i<timeSelectModel.length;i++) {
                    if(i == index) {
                        temp[i] = temp[i].replace(checkMark,""); //it may already have a checkmark
                        temp[i] = checkMark + temp[i] ;
                    }else {
                        temp[i] = temp[i].replace(checkMark,"");
                    }
                }
                timeSelectModel = temp;
            }

        }

    }
}
