import QtQuick 1.0
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Components.DateTime 0.1
import MeeGo.App.Tasks 0.1
import MeeGo.Ux.Gestures 0.1
import MeeGo.Ux.Kernel 0.1
import MeeGo.Ux.Components 0.1

Column {
    id: detailMenu

    property bool editing: false
    property Item  task: null
    property variant listNames: []
    property alias deleteButtonVisible: deleteButton.visible
    property alias editButtonVisible: editButton.visible
    property alias saveButtonVisible: saveButton.visible

    signal close()
    signal save(variant taskToSave)
    signal deleteTask(variant taskId)

    property int hSpacing: 5
    property int vSpacing: 10

    spacing: vSpacing
    width: 350
    onTaskChanged: {
        if (task != null) {
            compCheckbox.isChecked = task.mCompleted;
            listText.text = listNames[task.mListId].toString()
        }
        //For whatever stupid reason, the checkbox doesn't get updated
        //along with the other fields, so I have to manually do this!
    }

    onListNamesChanged: {
        if (task != null && listNames.length > 0) {
            listText.text = listNames[task.mListId].toString()
        }
    }

    function saveTaskFromInput() {
        task.mTask = taskName.text;
        if( task.mHasDueDate = duedateSelector.on) { //the single = is on purpose
            task.mDueDate = datePicker.selectedDate;
        }
        task.mCompleted = compCheckbox.isChecked;
        task.mNotes = notesData.text;
    }

    Theme {
        id: theme
    }

    Row {
        id: nameRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: hSpacing
        CheckBox {
            id: compCheckbox
            anchors.verticalCenter: nameRow.verticalCenter
            onClicked: {
                editorList.setCompleted(task.mTaskId, isChecked);
            }
            isChecked: task ? task.mCompleted : false
        }
        TextField {
            id: taskName
            width: 250
            readOnly: !detailMenu.editing
            defaultText: qsTr("Insert task name")
            font.strikeout: compCheckbox.isChecked
            text: task ? task.mTask : ""
            font.pixelSize: theme.fontPixelSizeLarge
        }
    }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        id: listRow
        spacing: hSpacing
        Text {
            visible: listText.text != "" || editing
            id: listLabel
            text: qsTr("List:")
            color: theme.fontColorHighlight
            font.pixelSize: theme.fontPixelSizeLarge
        }
        ListView {
            height: 200
            width: detailMenu.width - listLabel.width - 30
            id: listCombobox
            model: TasksListModel {
                id: viewmodel
                modelType: TasksListModel.AllLists
            }
            spacing: 4
            clip: true
            visible: editing
            delegate: Rectangle {
                width: parent.width
                height: 40
                color: {
                    if(detailMenu.task && listId != detailMenu.task.mListId) {
                        return theme.fontColorNormal;
                    } else {
                        return theme.fontColorHighlight;
                    }
                }
                Text {
                    id:  text
                    text: listName
                    anchors.centerIn: parent
                    width: parent.width
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: theme.fontPixelSizeLarge
                }

//                GestureArea {
//                    anchors.fill: parent
//                    Tap {
//                        onFinished: {
//                            detailMenu.task.mListId = listId
//                        }
//                    }
//                }

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
            text: task != null ? detailMenu.listNames[task.mListId] : ""
            visible: !editing
            font.pixelSize: theme.fontPixelSizeLarge
        }
    }

    Row {
        id: dueDateRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: hSpacing
        Text {
            id: dueDateLabel
            text: qsTr("Due date:")
            color: theme.fontColorHighlight
            font.pixelSize: theme.fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            id: duedateText
            text: task ? getFormattedDate(task.mDueDate) : ""
            font.pixelSize: theme.fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        ToggleButton {
            id: duedateSelector
            onLabel: qsTr("Date")
            offLabel: qsTr("Someday")
            visible: editing
            on: task ? task.mHasDueDate : false
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
                    internal.newDate = datePicker.selectedDate;
                }
            }
            onClicked: {
                datePicker.show();
            }
        }
    }

    QtObject {
        id: internal

        property variant newDate: null
    }

    Row {
        id: notesRow
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: hSpacing
        Text {
            id: notesLabel
            text: qsTr("Notes")
            color: theme.fontColorHighlight
            font.pixelSize: theme.fontPixelSizeLarge
            anchors.verticalCenter: parent.verticalCenter
        }
        TextField {
            id: notesData
            width: 250
            readOnly: !detailMenu.editing
            defaultText: detailMenu.editing ?  qsTr("Add a note here")  : ""
            text: task ? task.mNotes : ""
            font.pixelSize: theme.fontPixelSizeLarge
        }
    }
    Button {
        id: deleteButton
        text: qsTr("Delete task")
        anchors.horizontalCenter: parent.horizontalCenter
        bgSourceUp:"image://themedimage/widgets/common/button/button-negative"
        bgSourceDn:"image://themedimage/widgets/common/button/button-negative-pressed"
        onClicked: {
            detailMenu.deleteTask(task.mTaskId);
        }
    }

    Image {
        id: divider
        source: "image://themedimage/images/tasks/frm_dropdown_divider"
        width: parent.width
    }

    Row {
        id: editSaveCloseRow

        spacing: hSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        Button {
            id: editButton
            text: qsTr("Edit")
            bgSourceUp:"image://themedimage/widgets/common/button/button-default"
            bgSourceDn:"image://themedimage/widgets/common/button/button-default-pressed"
            visible: !editing
            onClicked: {
                detailMenu.editing = true;
            }

        }
        Button {
            id: saveButton
            active: taskName.text != ""
            text: qsTr("Save")
            bgSourceUp:"image://themedimage/widgets/common/button/button-default"
            bgSourceDn:"image://themedimage/widgets/common/button/button-default-pressed"
            visible: editing
            onClicked: {
                task.mHasDueDate = duedateSelector.on
                if (internal.newDate != null)
                    task.mDueDate = internal.newDate;
                else
                    task.mHasDueDate = false
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
