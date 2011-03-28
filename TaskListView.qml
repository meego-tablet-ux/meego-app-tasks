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
    height: 480
    property int titleHeight: 60
    property variant model
    property int rowHeight: theme_listBackgroundPixelHeightOne
    property bool addNewRow: true
    property variant rowDelegate: cellComponent
    property int textHMargin: 20
    property bool listReorderable: true
    property alias duedateActions: newrow.actions


    property variant selectedIds: []


    signal clickedAtRow(int index, int x , int y, variant payload)
    signal checkedAtRow(int index, variant payload,bool checked)
    signal pressAndHoldAtRow(int index, int x, int y, variant payload)

    // 0 normal mode
    // 1 add new row mode
    // 2 multiple selection mode
    property int mode: 0

    function getTitleText(){
        var collapsed = view.collapsed;
        var tt = model.title;
        if (collapsed) {
           tt =  qsTr("%1 (%2)").arg(tt).arg(view.count);
        }
        return tt;
    }


    function  toggleSelected(id) {
        var index = selectedIds.indexOf(id);
        if (index == -1) {
            selectedIds = selectedIds.concat(id);
        }else {
            var temp = selectedIds;
            temp.splice(index, 1);
            selectedIds = temp;
        }
    }

    Flickable {
        id: area
        width: container.width
        height: container.height
        contentWidth: container.width
        contentHeight: view.height + titleHeight + newrow.extraHeight + (container.height /2);
        clip: true
        ListView {
            id: view
            cacheBuffer: container.rowHeight*2//this needed for multiple drag&drop (workaround for strange cases)
            width: container.width
            height:(collapsed ? 0:  viewHeight )
            clip: true
            x: 0
            y:titleHeight
            interactive: false
            property int viewHeight: count * (container.rowHeight + spacing) - spacing
            property bool collapsed: false
            model: container.model.viewModel
            delegate : rowDelegate

        }
        CreateNewTaskRow {
            id: newrow
            width: parent.width
            height: addNewRow?container.rowHeight: 0
            visible: addNewRow
            anchors.top: view.bottom
            onRequestForEditing: {
                container.mode = 1;
            }
        }
    }
    Rectangle {
        id: titleRect
        parent: area
        width: container.width
        height:  container.titleHeight
        x: 0
        y: 0

        color:model.titleColor
        Text {
            id: text
            anchors.fill: parent
            anchors.leftMargin: textHMargin
            text:  getTitleText()
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: theme_fontPixelSizeLarge
            elide: Text.ElideRight
        }
        Image {
            id: separator_top
            width: parent.width
            anchors.bottom: parent.top
            source: "image://theme/tasks/ln_grey_l"
        }
        Image {
            id: separator_bt
            width: parent.width
            anchors.top: parent.bottom
            source: "image://theme/tasks/ln_grey_l"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                 view.collapsed = !view.collapsed;
                 text.text = getTitleText();
                 if (!view.collapsed) {
                   //  ensureShowingList(index);
                 }
            }
            onPressAndHold: {
                // test code, to be delted
                mode = 2;
            }
        }
    }

    QtObject {
        id: privateData
        property int selectedRow: -1
        property bool addNewRowCache:addNewRow

    }

    Loader {
        id: tasksDragLoader
    }

    Component {
        id: dragRectComponent

        Rectangle {
            id: dragRect
            color: "yellowgreen"
            width: container.width
            height: container.rowHeight
            z: 100
        }
    }

    Component {
        id: cellComponent
        Item {
            id: dinstance
            width: container.width
            height: container.rowHeight
            property bool grabbed: false
            opacity: grabbed? 0.2: 1

            // all the properties we need to show in detail
            property string mTask: task
            property date mDueDate: dueDate
            property bool mHasDueDate: hasDueDate
            property bool mCompleted: complete
            property variant mReminderType: reminder
            property variant mReminderDate: reminderDate
            property variant mUrls: urls
            property variant mAttachments: attachments
            property string mNotes: notes
            property int mTaskId: taskId
            property int mListId: listId

            property bool isMultipleDragActive: false

            Text {
                id: titleText
                text: mTask
                width:  (dinstance.width - rowHeight - 6*textHMargin - reorderBt.width - duedateText.width - overdueIcon.width)
                height: dinstance.height
                x: rowHeight + textHMargin
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.strikeout: mCompleted
                font.pixelSize: theme_fontPixelSizeLarge
                visible: !isMultipleDragActive
            }
            Text {
                id: duedateText
                text: getFormattedDate(mDueDate)
                anchors.right: reorderBt.left
                anchors.rightMargin:textHMargin
                font.pixelSize: theme_fontPixelSizeLarge
                height: dinstance.height
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color:theme_fontColorNormal
                visible: mHasDueDate && !isMultipleDragActive
            }

            //showed when dragging several tasks
            Text {
                id: tasksCount
                width: dinstance.width - x
                height: dinstance.height
                x: rowHeight + textHMargin
                text: qsTr("%1 tasks").arg(selectedIds.length)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.strikeout: mCompleted
                font.pixelSize: theme_fontPixelSizeLarge
                visible: isMultipleDragActive
            }


            Image {
                id: reminderIcon
                source: "image://theme/tasks/icn_alarmclock"
                anchors.right: duedateText.left
                anchors.rightMargin:textHMargin
                visible: mHasDueDate && (mReminderType!= TasksListModel.NoReminder)
                anchors.verticalCenter: parent.verticalCenter
            }
            Image {
                id: separator
                width: parent.width
                anchors.bottom: parent.bottom
                source: "image://theme/tasks/ln_grey_l"
            }
            Image {
                id: highlight
                source: "image://theme/tasks/bg_highlightedpanel_l"
                anchors.fill: parent
                visible: (index == privateData.selectedRow)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    privateData.selectedRow = index;
                    if (mode ==0 ) {
                    var map = dinstance.mapToItem(container, mouseX, mouseY);
                    container.clickedAtRow(index, map.x, map.y,dinstance);
                    }else if (mode == 1)
                    {
                        // adding mode, do nothing?
                    }else if (mode == 2){
                        toggleSelected(mTaskId)
                    }
                }
                onPressAndHold: {
                    if (mode == 0) {
                        var map = dinstance.mapToItem(container, mouseX, mouseY);
                        container.pressAndHoldAtRow(index, map.x, map.y, dinstance);
                    }
                }
            }
            Checkbox {
                id: selectBox
                x: (rowHeight - width)/2
                y: (rowHeight - height)/2
                visible: mode == 2
                checked: selectedIds.indexOf(mTaskId)!= -1
                onClicked: {
                    container.toggleSelected(mTaskId);
                  //  container.checkedAtRow(index, dinstance, checked);
                }
            }

            Checkbox {
                id: box
                x: (rowHeight - width)/2
                y: (rowHeight - height)/2
                checked:mCompleted
                visible: mode !=2
                onClicked: {
                    if(mode ==0)
                        container.checkedAtRow(index, dinstance,!checked);
                }
            }
            Image {
                id: overdueIcon
                source: "image://theme/tasks/icn_overdue_red"
                anchors.verticalCenter: parent.verticalCenter
                x: titleText.x + titleText.paintedWidth + 20
                visible: isOverdue(mDueDate) && mHasDueDate
            }


            Image {
                id: reorderBt
                source: "image://theme/tasks/icn_grabhandle"
                anchors.right: parent.right
                anchors.rightMargin: 20
                visible: listReorderable
                y: (rowHeight - height)/2

                MouseArea {
                    property int start: 0
                    property bool isPositionChanged: false

                    anchors.fill: parent
                    onPressed : {
                        area.interactive = false;
                        dinstance.grabbed = true;

                        if (mode == 2 && selectedIds.indexOf(mTaskId) != -1 && selectedIds.length > 1) {//only for multiple drag&drop
                            isMultipleDragActive = true;
                            start = selectedIds.indexOf(mTaskId);
                            var tempArray = new Array();
                            tempArray = tempArray.concat(selectedIds.slice(0, start));

                            if (start != selectedIds.length-1) {
                                tempArray = tempArray.concat(selectedIds.slice(start+1, selectedIds.length));
                            }

//                            selectedIds = tempArray;
                            view.model.hideTasks(tempArray);
                        }
                    }
                    onMousePositionChanged: { 
                        var mapToArea = reorderBt.mapToItem(area, mouseX, mouseY);

                        //scroll up
                        if (area.height - mapToArea.y <= 1 && area.contentY+area.height<=area.contentHeight)
                            area.contentY+=5;

                        //scroll down
                        if ((mapToArea.y+area.contentY <= area.contentY+container.titleHeight) && area.contentY >= 0)
                            area.contentY-=5;

                        var map = reorderBt.mapToItem(view, mouseX, mouseY);
                        var target = view.indexAt(map.x, map.y + view.contentY);
                        if ( target != -1 && target != index) {
                            if (mode == 2) {//only for multiple drag&drop
                                isPositionChanged = true;
                                var diff = target - index;
                                if (diff > 1) {
                                    for (var i=index+1; i<target; ++i) {
                                        start = i;
                                        view.model.reorderTask(mTaskId, i);
                                    }
                                }

                                start = target;
                            }

                            view.model.reorderTask(mTaskId, target);
                            privateData.selectedRow = -1;
                        }
                    }
                    onReleased: {
                        if (mode == 2 && isMultipleDragActive) {//only for multiple drag&drop
                            if (!isPositionChanged)
                                view.model.showHiddenTasksOldPositions(view.model.listId);
                            else
                                view.model.showHiddenTasks(view.model.listId, start+1);

//                            selectedIds = selectedIds.concat(mTaskId);
                            isMultipleDragActive = false;
                            isPositionChanged = false;
                        }
                        view.model.saveReorder(mListId);
                        area.interactive = true;
                        dinstance.grabbed = false;
                    }
                }
            }

        }
    }

    BottomBar {
        id: bottombar
        width: parent.width
        height: 80
        visible: false
        anchors.bottom: parent.bottom
        model: selectedIds
        saveButtonActive: newrow.textinput.text != ""
        onClickedCancel: {
            // clean up the added tasks
            //container.model.viewModel.rollbackAddedTasks();
            container.mode = 0;
            container.selectedIds = [];
        }
        onClickedSave: {
            // actually save the tasks            
            view.model.addTaskAlt(view.model.listId, newrow.textinput.text,
                                  false, newrow.selectedDueDate,newrow.selectedDate);

            newrow.selectedDueDate = false;

            //area.contentHeight = getMaxContentHeight();
            container.model.viewModel.commitAddedTasks();
            container.selectedIds = [];
        }
        onClickedMove: {
           // container.model.viewModel.moveTasksToList(selectedIds, 0);
           // container.selectedIds = [];
           picker.visible = true;
        }
        onClickedDelete: {
             container.model.viewModel.removeTasks(selectedIds);
             container.selectedIds = [];
        }
        onClickedOk: {
            container.model.viewModel.rollbackAddedTasks();
            container.mode = 0;
            container.selectedIds = [];
        }
    }
    TaskListPicker {
        id: picker
        parent: container.parent
        visible:false
        onSelected: {
            if (selectedIds.length > 0) {
                container.model.viewModel.moveTasksToList(selectedIds, listId);
                selectedIds = [];
            }
        }
    }

    states: [
        State {
            name: "normalMode"
            when: mode == 0
            /*PropertyChanges {
                target: area
                height: container.height
                contentHeight: view.height + titleHeight
            }*/
            PropertyChanges {
                target:newrow
                visible: addNewRow
                height: addNewRow?container.rowHeight: 0
                editing: false
            }
            PropertyChanges {
                target: bottombar
                visible: false
            }
            PropertyChanges {
                target: privateData
                selectedRow: -1

            }
        },
        State {
            name: "addNewTaskMode"
            when: mode == 1
            /*PropertyChanges {
                target: area
                height: container.height - bottombar.height
                contentHeight:getMaxContentHeight()
            }*/
            PropertyChanges {
                target: newrow
                visible: true
                height: container.rowHeight
                editing: true
            }
            PropertyChanges {
                target: bottombar
                visible: true
                mode:0
            }
            PropertyChanges {
                target: privateData
                selectedRow: -1

            }
        },
        State {
            name: "multiSelectionMode"
            when: mode == 2
            /*PropertyChanges {
                target: area
                height: container.height - bottombar.height
                contentHeight: view.height + titleHeight;
            }*/
            PropertyChanges {
                target: newrow
                visible: false
                height: 0
            }
            PropertyChanges {
                target: bottombar
                visible: true
                mode: 1
            }
            PropertyChanges {
                target: privateData
                selectedRow: -1

            }
        }
    ]

}
