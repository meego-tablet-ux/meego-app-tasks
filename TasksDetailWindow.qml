/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.Labs.Components 0.1
import MeeGo.App.Tasks 0.1


Item {
    id: container
    width: 640
    height: adjustHeight()
    property int taskId

    property int horizontalMargin: 15
    property int verticalMarginInSection: 10
    property int verticalMarginBetweenSections: 20
    property color labelColor: theme_fontColorHighlight
    property bool editing: false
    property int buttonHeight: 40
    property int checkboxWidth: 20

    property int maxHeight: 900
    property variant  task
    //property alias listNames: listCombobox.dataModel
    property variant listNames

    signal close()
    signal save()
    signal deleteTask()

    function adjustHeight() {
        var h = titleBackground.height + flickarea.contentHeight + 3* verticalMarginBetweenSections
                 + divider.height + editBt.height;
        if (h > container.maxHeight)
            return maxHeight;
        else
           return h;
    }

    function updateValues(){
        title.text = task.mTask;
        //listCombobox.selectedIndex = task.mListId -1;
        duedateSelector.on = task.mHasDueDate;
        duedatePicker.date = (task.mDueDate.getDate()? task.mDueDate: new Date()) ;
        notes.text = task.mNotes;
        taskId = task.mTaskId;
    }
    function retrieveData(task){
        task.mCompleted = checkbox.checked ;
        task.mTask = title.text ;
        //task.mLists = listCombobox.dataModel;
        task.mDueDate = duedatePicker.date;
        task.mHasDueDate = duedateSelector.on   ;
        task.mNotes = notes.text;
        task.mTaskId = taskId;
        task.mListId = container.task.mListId;
    }
    MouseArea {
        anchors.fill: parent
    }

    BorderImage {
        id: top
        source: "image://theme/tasks/frm_dropdown_open_bottom"
        width:container.width
        border.left: 10
        border.top: 0
        border.right: 10
        border.bottom: 0
        anchors.top: container.top
        rotation: 180
    }

    BorderImage {
        id: body
        source: "image://theme/tasks/frm_dropdown_open_middle"
        anchors.fill: centerArea
        border.left: 10
        border.top: 10
        border.right: 10
        border.bottom: 10
    }

    Item {
        id: centerArea
        width:container.width
        height: container.height - top.height - bottom.height
        anchors.top:top.bottom
        clip: true
        Checkbox {
            id: checkbox
            anchors.left: parent.left
            anchors.leftMargin: horizontalMargin
            anchors.top: parent.top
            anchors.topMargin: verticalMarginInSection
            width:checkboxWidth
            height: width
            onClicked: {
                editorList.setCompleted(taskId, !checked);
            }

            checked: task?task.mCompleted:false
        }
        BorderImage {
            id: titleBackground
            source: "image://theme/tasks/frm_textbox_l"
            width: parent.width - checkbox.width - 3* horizontalMargin
            height:   2* verticalMarginInSection + 57
            border.left: 10
            border.top: 10
            border.right: 10
            border.bottom: 10
            anchors.left: checkbox.right
            anchors.leftMargin:horizontalMargin
            anchors.top: parent.top
            clip: true
        }
        Flickable {
            id: titleFlick
            anchors.left: titleBackground.left
            anchors.leftMargin: horizontalMargin
            anchors.top: titleBackground.top
            anchors.topMargin: verticalMarginInSection
            width: titleBackground.width - 2 * horizontalMargin
            height: 57
            flickableDirection: Flickable.VerticalFlick
            contentHeight: title.paintedHeight
            clip: true
            function ensureVisible(r)
            {
                if (contentX >= r.x)
                    contentX = r.x;
                else if (contentX+width <= r.x+r.width)
                    contentX = r.x+r.width-width;
                if (contentY >= r.y)
                    contentY = r.y;
                else if (contentY+height <= r.y+r.height)
                    contentY = r.y+r.height-height;
            }
            TextEdit {
                id: title
                width: titleFlick.width
                height: titleFlick.height
                wrapMode: TextEdit.Wrap
                font.pixelSize: theme_fontPixelSizeMedium
                font.bold: true
                font.strikeout: checkbox.checked
                readOnly: !editing
                onCursorRectangleChanged: titleFlick.ensureVisible(cursorRectangle)
            }
        }
        Flickable {
            id: flickarea
            width: parent.width
            height: centerArea.height - titleBackground.height - 2* verticalMarginBetweenSections - buttonHeight
            anchors.top:titleBackground.bottom
            anchors.topMargin:verticalMarginBetweenSections
            anchors.left:parent.left
            flickableDirection: Flickable.VerticalFlick
            contentHeight: flickItem.height
            interactive: contentHeight > height
            clip: true
            Item {
                id: flickItem
                width: flickarea.width
                height: childrenRect.height

                /*List */
                Text {
                    id: listLabel
                    text: qsTr("List:")
                    color:labelColor
                    anchors.left: parent.left
                    anchors.leftMargin: horizontalMargin
                   // anchors.top: flickItem.top
                    anchors.verticalCenter: listCombobox.verticalCenter
                }
                Text {
                    id: list
                    text: listNames[task.mListId]
                    color:theme_fontColorNormal
                    font.bold: true
                    anchors.left: listLabel.right
                    anchors.leftMargin: 2
                    anchors.verticalCenter: listCombobox.verticalCenter
                }
                ListView {
                    width: parent.width - listLabel.width - 3 * horizontalMargin
                    height: 200
                    anchors.left: listLabel.right
                    anchors.leftMargin: horizontalMargin
                    id: listCombobox
                    model: TasksListModel {
                        id: viewmodel
                        modelType: TasksListModel.AllLists
                    }
                    spacing: 4
                    clip: true
                    delegate: Rectangle {
                        width: parent.width
                        height: 40
                        color: {
                            if(listId != container.task.mListId) {
                                return theme_fontColorNormal;
                            } else {
                                return theme_fontColorHighlight;
                            }
                        }

                        Text {
                            id:  text
                            text: listName
                            anchors.centerIn: parent
                            width: parent.width
                            elide: Text.ElideMiddle
                            horizontalAlignment: Text.AlignHCenter


                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                container.task.mListId = listId
                            }
                        }
                    }
                }

                /*Due Date*/
                Text {
                    id: duedateLabel
                    text: qsTr("Due Date:")
                    color:labelColor
                    anchors.left: parent.left
                    anchors.leftMargin: horizontalMargin
                    anchors.verticalCenter: duedateSelector.verticalCenter
                }
                Text {
                    id: duedate
                    text: duedateSelector.on? getFormattedDate(duedatePicker.date): labelSomeday
                    color:theme_fontColorNormal
                    font.bold: true
                    anchors.left: duedateLabel.right
                    anchors.leftMargin: 2
                    anchors.verticalCenter: duedateSelector.verticalCenter
                }
                TasksToggleButton {
                    id: duedateSelector
                    width: parent.width - duedateLabel.width - 3* horizontalMargin
                    height: 32
                    anchors.left: duedateLabel.right
                    anchors.top: listCombobox.bottom
                    anchors.topMargin: verticalMarginInSection/2
                    lstring: qsTr("Date")
                    rstring: qsTr("Someday")
                }
                TasksDatePicker {
                    id: duedatePicker
                    width: duedateLabel.width + duedateSelector.width
                    anchors.left: duedateLabel.left
                    anchors.top:duedateSelector.bottom
                    anchors.topMargin: verticalMarginInSection/2
                    height: (duedateSelector.on && editing)? 50: 0
                    visible: duedateSelector.on && editing
                }
                Text {
                    id: notesLabel
                    text: qsTr("Notes")
                    color:labelColor
                    anchors.top: duedatePicker.bottom
                    anchors.topMargin:verticalMarginBetweenSections
                    anchors.left:parent.left
                    anchors.leftMargin: horizontalMargin
                }
                BorderImage {
                    id: notesBackground
                    source: "image://theme/tasks/frm_textbox_l"
                    width: parent.width  - 2* horizontalMargin
                    height:   notes.paintedHeight +   verticalMarginInSection
                    border.left: 10
                    border.top: 10
                    border.right: 10
                    border.bottom: 10
                    anchors.top:notesLabel.bottom
                   // anchors.topMargin:verticalMarginInSection/2
                    anchors.left:parent.left
                    anchors.leftMargin: horizontalMargin
                    clip: true
                    visible: editing
                }


                TextEdit {
                    id: notes
                    anchors.top: notesBackground.top
                    anchors.left: notesBackground.left
                    anchors.topMargin: verticalMarginInSection/2
                    anchors.leftMargin: horizontalMargin
                    wrapMode: TextEdit.Wrap
                    width: notesBackground.width - 2* horizontalMargin
                    readOnly: !editing
                }

                TasksButton {
                    id: deleteTaskBt
                    title: qsTr("Delete task")
                    upImageSource: "image://theme/tasks/btn_red"
                    dnImageSource: "image://theme/tasks/btn_red"
                    width: parent.width/2
                    height: editing ? buttonHeight: 0
                    anchors.top:notes.bottom
                    anchors.topMargin:verticalMarginBetweenSections
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        container.deleteTask();
                    }
                }
                states: [
                    State {
                        name: "noduedate"
                        when: !duedateSelector.on
                        AnchorChanges {
                            target: notesLabel
                            anchors.top: duedatePicker.bottom
                        }
                    },
                    State {
                        name: "hasduedate"
                        when: duedateSelector.on
                        AnchorChanges {
                            target: notesLabel
                            anchors.top: reminderCombobox.bottom
                        }
                    }

                ]

            }
        }

        Image {
            id: divider
            source: "image://theme/tasks/frm_dropdown_divider"
            anchors.top: flickarea.bottom
            width: parent.width
        }

        TasksButton {
            id: editBt
            title: qsTr("Edit")
            upImageSource:"image://theme/tasks/btn_blue"
            dnImageSource:"image://theme/tasks/btn_blue"
            width: (parent.width - 3* horizontalMargin)/2
            height: buttonHeight//- 2* verticalMarginInSection
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: horizontalMargin/2
            anchors.top: flickarea.bottom
            anchors.topMargin: verticalMarginInSection
            onClicked: {
                container.editing = true
            }
        }

        TasksButton {
            id: saveBt
            active: title.text != ""
            title: qsTr("Save")
            upImageSource:"image://theme/tasks/btn_blue"
            dnImageSource:"image://theme/tasks/btn_blue"
            width: (parent.width - 3* horizontalMargin)/2
            height: buttonHeight//- 2* verticalMarginInSection
            anchors.right: parent.horizontalCenter
            anchors.rightMargin: horizontalMargin/2
            anchors.top: flickarea.bottom
            anchors.topMargin: verticalMarginInSection
            visible: false
            onClicked: {
                container.save();
            }
        }

        TasksButton {
            id: closeBt
            title: qsTr("Close")
            upImageSource:"image://theme/tasks/btn_grey"
            dnImageSource:"image://theme/tasks/btn_grey"
            width: (parent.width - 3* horizontalMargin)/2
            height: buttonHeight//- 2* verticalMarginInSection
            anchors.left: parent.horizontalCenter
            anchors.leftMargin: horizontalMargin/2
            anchors.top: flickarea.bottom
            anchors.topMargin: verticalMarginInSection
            onClicked: {
                container.close();
            }
        }
        states: [
            State {
                name: "normal"
                when: !editing
                PropertyChanges {
                    target: titleBackground
                    opacity: 0
                    height: title.paintedHeight
                }
                PropertyChanges {
                    target: titleFlick
                    width: titleBackground.width
                    anchors.leftMargin: 0
                }

                PropertyChanges {
                    target: title
                    readOnly: true
                }
                PropertyChanges {
                    target: saveBt
                    visible: false
                }
                PropertyChanges {
                    target: editBt
                    visible: true
                }
                PropertyChanges {
                    target: listCombobox
                    visible: false
                }
                PropertyChanges {
                    target: duedateSelector
                    visible: false
                }
                PropertyChanges {
                    target: deleteTaskBt
                    visible: false
                }

            },
            State {
                name: "edit"
                when: editing
                PropertyChanges {
                    target: titleBackground
                    opacity: 1
                    height: 2* verticalMarginInSection + 57
                }
                PropertyChanges {
                    target: titleFlick
                    width: titleBackground.width - 2* horizontalMargin
                    anchors.leftMargin: horizontalMargin
                }
                PropertyChanges {
                    target: title
                    readOnly: false
                }
                PropertyChanges {
                    target: saveBt
                    visible: true
                }
                PropertyChanges {
                    target: editBt
                    visible: false
                }
                PropertyChanges {
                    target: listCombobox
                    visible: true
                }
                PropertyChanges {
                    target: duedateSelector
                    visible: true
                }
                PropertyChanges {
                    target: deleteTaskBt
                    visible: true
                } PropertyChanges {
                    target: list
                    visible: false
                } PropertyChanges {
                    target: duedate
                    visible: false
                }


            }

        ]

    }

    BorderImage {
        id: bottom
        source: "image://theme/tasks/frm_dropdown_open_bottom"
        width:container.width
        border.left: 10
        border.top: 0
        border.right: 10
        border.bottom: 0
        anchors.top: centerArea.bottom
    }
}
