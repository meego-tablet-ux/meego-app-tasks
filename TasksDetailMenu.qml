import QtQuick 1.0
import MeeGo.Components 0.1
import MeeGo.App.Tasks 0.1

Column {
    id: detailMenu

    property bool editing: false
    property variant  task
    property variant listNames

    signal close()
    signal save(variant taskToSave)
    signal deleteTask(variant taskId)

    property int hSpacing: 5
    property int vSpacing: 10

    spacing: vSpacing

    onTaskChanged: {
        compCheckbox.isChecked = task.mCompleted; //For whatever stupid reason, the checkbox doesn't get updated
        //along with the other fields, so I have to manually do this!
    }

    function saveTaskFromInput() {
        task.mTask = taskName.text;
        if( task.mHasDueDate = duedateSelector.on) { //the single = is on purpose
            task.mDueDate = datePicker.selectedDate;
        }
        task.mCompleted = compCheckbox.isChecked;
        task.mNotes = notesData.text;
    }

    Row {
        id: nameRow
        spacing: hSpacing
        CheckBox {
            id: compCheckbox
            anchors.verticalCenter: nameRow.verticalCenter
            onClicked: {
                editorList.setCompleted(task.mTaskId, isChecked);
            }
            isChecked: task.mCompleted
        }
        TextEntry {
            id: taskName
            readOnly: !detailMenu.editing
            defaultText: qsTr("Insert task name")
            font.strikeout: compCheckbox.isChecked
            text: task.mTask;
            font.pixelSize: theme_fontPixelSizeLarge
        }
    }
    Row {
        id: listRow
        spacing: hSpacing
        Text {
            id: listLabel
            text: qsTr("List:")
            color: theme_fontColorHighlight
            font.pixelSize: theme_fontPixelSizeLarge
        }
        ListView {
            height: 200
            width: detailMenu.width - listLabel.width
            visible: editing
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
                    if(listId != detailMenu.task.mListId) {
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
                    font.pixelSize: theme_fontPixelSizeLarge
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        detailMenu.task.mListId = listId
                    }
                }
            }
        }
        Text {
            id: listText
            text: listNames[task.mListId]
            visible: !editing
            font.pixelSize: theme_fontPixelSizeLarge
        }
    }

    Row {
        id: dueDateRow
        spacing: hSpacing
        Text {
            id: dueDateLabel
            text: qsTr("Due date:")
            color: theme_fontColorHighlight
            font.pixelSize: theme_fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: duedateText
            text: getFormattedDateYear(task.mDueDate)
            font.pixelSize: theme_fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        ToggleButton {
            id: duedateSelector
            onLabel: qsTr("Date")
            offLabel: qsTr("Someday")
            visible: editing
            on:task.mHasDueDate;
            anchors.verticalCenter: parent.verticalCenter
        }
        Button {
            id: dateButton
            text: qsTr("Set due date")
            visible: editing && duedateSelector.on
            DatePicker {
                id:datePicker
                selectedDate: task.mDueDate
                onDateSelected: {
                    task.mDueDate = datePicker.selectedDate;
                }
            }
            onClicked: {
                datePicker.show();
            }
        }
    }

    Row {
        id: notesRow
        spacing: hSpacing
        Text {
            id: notesLabel
            text: qsTr("Notes")
            color: theme_fontColorHighlight
            font.pixelSize: theme_fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        TextEntry {
            id: notesData
            readOnly: !detailMenu.editing
            defaultText: detailMenu.editing ?  qsTr("Add a note here")  : ""
            text:  task.mNotes;
            font.pixelSize: theme_fontPixelSizeLarge
        }
    }
    Button {
        id: deleteButton
        text: qsTr("Delete task")
        anchors.horizontalCenter: parent.horizontalCenter
        bgSourceUp:"image://theme/btn_red_up"
        bgSourceDn:"image://theme/btn_red_dn"
        onClicked: {
            detailMenu.deleteTask(task.mTaskId);
        }
    }

    Image {
        id: divider
        source: "image://theme/tasks/frm_dropdown_divider"
        width: parent.width
    }

    Row {
        id: editSaveCloseRow
        spacing: hSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            id: editButton
            text: qsTr("Edit")
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            visible: !editing
            onClicked: {
                detailMenu.editing = true;
            }

        }
        Button {
            id: saveButton
            active: taskName.text != ""
            text: qsTr("Save")
            bgSourceUp:"image://theme/btn_blue_up"
            bgSourceDn:"image://theme/btn_blue_dn"
            visible: editing
            onClicked: {
                saveTaskFromInput();
                detailMenu.save(task);
                detailMenu.editing = false;
            }
        }
        Button {
            id: closeButton
            text: qsTr("Close")
            onClicked: {
                detailMenu.close();
            }
        }
    }

}
