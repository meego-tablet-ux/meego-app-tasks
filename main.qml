/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Tasks 0.1
import MeeGo.Components 0.1
import MeeGo.Ux.Gestures 0.1

Window {
    id: window
    property string labelTasks: qsTr("Tasks")
    property string labelAllDueTasks: qsTr("All due tasks")
    //:Up arrow for the Ascending order
    property string labelAllDureTasksASCOrder: qsTr("Order: %1").arg("↑")
    //:Down arrow for the decending order
    property string labelAllDureTasksDESCOrder: qsTr("Order: %1").arg("↓")
    property string labelOverdue: qsTr("Overdue")
    property string labelUpComing: qsTr("Upcoming")
    property string labelSomeday: qsTr("Someday")
    property string labelDefaultList: qsTr("Default list")
    property string labelToday: qsTr("Today")
    property string labelTomorrow: qsTr("Tomorrow")
    property string labelNextWeek: qsTr("Next week")
    property string labelSetDueDate: qsTr("Set due date...")
    property string labelAddNewList: qsTr("Add new list...")
    property string labelSelectMultipleLists: qsTr("Select multiple lists...")
    property string labelOk: qsTr("OK")
    property string labelCancel: qsTr("Cancel")
    property string labelNewList: qsTr("New list")
    property string labelRenameList: qsTr("Rename list")
    property string labelSelectMultiple: qsTr("Select multiple tasks...")
    property string labelDeleteCompletedTask: qsTr("Delete completed tasks")
    property string labelDeleteList: qsTr("Delete list")
    property string labelAddTask: qsTr("Add task")
    property string labelViewDetail: qsTr("View detail")
    property string labelEditTask: qsTr("Edit task")
    property string labelShowInList: qsTr("Show in list")
    property string labelDeleteTask: qsTr("Delete task")
    property string labelDeleteListDialog: qsTr("Do you want to delete this list and all of its tasks?")
    property string labelDelete: qsTr("Delete")
    property string labelDeleteSingleTask: qsTr("Are you sure you want to delete this task?")

    Theme {
        id: theme
    }

    property int rowHeight: theme.listBackgroundPixelHeightOne
    property int horizontalMargin: 20
    property int verticalMargin: 10
    property int titleHeight: 50

    QmlSetting {
        id: qmlSettings
        //        isRunningFirstTime: saveRestore.value("isRunningFirstTime")
    }

    SaveRestoreState {
        id: saveRestore

        onSaveRequired: internal.save()

        Component.onCompleted: {
            if (!restoreRequired)
                return;
            internal.restore();
        }
    }

    TopItem{ id: topItem }

    Connections {
        target: mainWindow
        onCall: {
            console.log("cmd call");
            var cmd = parameters[0];
            var cdata = parameters[1];
            if (cmd == "openTasks") {
                console.log("opentasks");
                var uid = cdata;
                var taskId = tasksDatabase.taskIdByUid(uid);
                dueTaskObject.mTaskId = taskId;
                dueTaskObject.mTask = tasksDatabase.taskValue(taskId, "Task");
                dueTaskObject.mNotes = tasksDatabase.taskValue(taskId, "Notes");
                dueTaskObject.mCompleted = tasksDatabase.taskValue(taskId, "Complete");
                dueTaskObject.mHasDueDate =  tasksDatabase.taskValue(taskId, "HasDueDate");
                dueTaskObject.mDueDate = tasksDatabase.taskValue(taskId, "DueDate");
                dueTaskObject.mReminderType = tasksDatabase.taskValue(taskId, "Reminder");
                dueTaskObject.mReminderDate = tasksDatabase.taskValue(taskId, "ReminderDate");
                dueTaskObject.mUrls = tasksDatabase.taskValue(taskId, "Urls");
                dueTaskObject.mAttachments = tasksDatabase.taskValue(taskId, "Attachments");
                dueTaskObject.mListId = tasksDatabase.taskValue(taskId, "ListID");

                dueTaskDetail.task = dueTaskObject;
                dueTaskDetail.listNames = listsGroupItem.getAllListsNames();
                dueTaskDetail.editing = false;
                dueTaskDetail.visible = true;
            }
        }
    }

    QtObject {
        id: dueTaskObject
        property string mTask
        property date mDueDate
        property bool mHasDueDate
        property bool mCompleted
        property variant mReminderType
        property variant mReminderDate
        property variant mUrls
        property variant mAttachments
        property string mNotes
        property int mTaskId
        property int mListId
    }

    TasksDetailMenu {
        id: dueTaskDetail
        z: 10
        anchors.centerIn: parent
        task: taskDetailMenu.setTask;
        listNames: taskDetailMenu.setListnames;
        editing:taskDetailMenu.setEditing;
        deleteButtonVisible: false
        editButtonVisible: false
        saveButtonVisible: false
        visible: false

        onClose: {
            visible = false;
        }
    }

    QtObject {
        id: internal

        property string isRunningFirstTime: "isRunningFirstTime"
        property string currentPage: "currentPage"

        function save()
        {
            saveRestore.setValue(isRunningFirstTime, false);
            saveRestore.setValue(currentPage, window.pageStack.currentPage.objectName);
            window.pageStack.currentPage.save(saveRestore);
            saveRestore.sync();
        }

        function restore()
        {
            qmlSettings.isRunningFirstTime = saveRestore.value(isRunningFirstTime);
            restoreCurrentPage();
        }

        function restoreCurrentPage()
        {
            var cp = saveRestore.value(internal.currentPage);
            if (cp == "landingScreenPage") {
                window.addPage(landingScreenPageComponent)
            } else if (cp == "allDueTasksPage") {
                window.addPage(allDueTasksPageComponent)
            } else if (cp == "customlistPage") {
                window.addPage(customlistPageComponent)
            }
            window.pageStack.currentPage.restore(saveRestore);
        }
    }

    //    Labs.LocaleHelper {
    //        id: localeHelper
    //    }

    toolBarTitle: labelTasks

    Component.onCompleted: switchBook(landingScreenPageComponent)

    function getFormattedDate(date) {
        if (!date.getDate()) {
            return labelSomeday;
        }
        var now = new Date();
        if (now.getDate() == date.getDate() &&
                now.getMonth() == date.getMonth() &&
                now.getYear() == date.getYear() )
            return labelToday

        return qmlSettings.localDate(date, now.getYear() == date.getYear() ? QmlSetting.DateMonthDay : QmlSetting.DateFullNumShort);
    }

    function isOverdue(date) {
        if (!date.getDate)
            return false;
        var now = new Date();
        if(date.getYear() < now.getYear())
            return true;
        if (date.getYear() > now.getYear())
            return false;
        if (date.getMonth() < now.getMonth())
            return true;
        if (date.getMonth() > now.getMonth())
            return false;
        if (date.getDate() < now.getDate())
            return true;
        return false;
    }

    function saveChanges(saveMe){
        var taskDetailToSave = saveMe;
        console.log("==================save information==============");
        console.log("id: " +taskDetailToSave.mTaskId);
        console.log("name: " +taskDetailToSave.mTask);
        console.log("notes: " +taskDetailToSave.mNotes);
        console.log("hasDueDate: " +taskDetailToSave.mHasDueDate);
        console.log("dueDate: " +taskDetailToSave.mDueDate);
        console.log("reminderType: " +taskDetailToSave.mReminderType);
        console.log("reminderDate: " +taskDetailToSave.mReminderDate);
        console.log("listId: "+ taskDetailToSave.mListId);
        console.log("================end save information=================");

        // add the taskDetailToSave.mListId at the expected place.
        editorList.editTask(taskDetailToSave.mTaskId,
                            taskDetailToSave.mListId,
                            taskDetailToSave.mTask,
                            taskDetailToSave.mNotes,
                            taskDetailToSave.mHasDueDate,
                            taskDetailToSave.mDueDate,
                            taskDetailToSave.mReminderType,
                            taskDetailToSave.mReminderDate,
                            taskDetailToSave.mUrls,
                            taskDetailToSave.mAttachments);
        console.log("================end save changes =================");
    }


    function addNewTask(listId, taskName) {
        if (taskName){
            editorList.addTaskAlt(listId, taskName, false, duedateData.hasDuedate, duedateData.dueDate);
        }
    }

    QtObject {
        id: duedateData
        property bool hasDuedate: false
        property date dueDate
    }

    QtObject {
        id:taskDetailToSave
        property string mTask
        property date mDueDate
        property bool mHasDueDate
        property bool mCompleted
        property variant mReminderType
        property variant mUrls
        property variant mAttachments
        property string mNotes
        property variant mLists
        property int mTaskId
        property date mReminderDate
        property int mListId

    }
    Item {
        id: listsGroupItem
        function getAllListsNames() {
            var listNames = new Array();
            for (var i = 0; i < listsGroupItem.children.length - 1; ++i) {
                listNames[listsGroupItem.children[i].idList] = listsGroupItem.children[i].list;
            }
            return listNames;
        }

        Repeater {
            id: listsRepeater
            model:allListsModel

            delegate:Item {
                property string list :listName
                property int idList :listId
            }
        }
    }
    TasksListModel {
        id: overdueModel
        modelType: TasksListModel.Timeview
        timeGroups: TasksListModel.Overdue
    }
    TasksListModel {
        id: upcomingModel
        modelType: TasksListModel.Timeview
        timeGroups: TasksListModel.Upcoming
    }
    TasksListModel {
        id: somedayModel
        modelType: TasksListModel.Timeview
        timeGroups: TasksListModel.Someday
    }
    TasksListModel {
        id: customlistModel
        property string listName
        modelType: TasksListModel.List
    }
    TasksListModel {
        id: allListsModel
        modelType: TasksListModel.AllLists
    }

    TasksListModel {
        id: editorList
    }

    function currentSortOrderText(model)
    {
        return model.sortOrder == TasksListModel.ASC ? labelAllDureTasksASCOrder : labelAllDureTasksDESCOrder
    }

    function swapSortOrder(model)
    {
        return model.sortOrder == TasksListModel.ASC ? TasksListModel.DESC : TasksListModel.ASC;
    }

    bookMenuPayload: [ landingScreenPageComponent ]

    onSearch: {
        var currentPage = window.pageStack.currentPage.objectName;
        if (currentPage == "landingScreenPage") {
            allListsModel.filter = needle;
        } else if (currentPage == "allDueTasksPage") {
            overdueModel.filter = needle;
            upcomingModel.filter = needle;
            somedayModel.filter = needle;
        } else if (currentPage == "customlistPage") {
            customlistModel.filter = needle;
        }
    }

    Component {
        id: landingScreenPageComponent
        AppPage {
            id: landingScreenPage
            anchors.fill:parent
            pageTitle: labelTasks
            objectName: "landingScreenPage"

            actionMenuModel: [ labelAddNewList ]
            actionMenuPayload: [ 0 ]

            onActionMenuTriggered: {
                if (!selectedItem)
                    newListDialog.show();
            }

            onDeactivated: {
                if (allListsModel.filter != "")
                    allListsModel.filter = "";
            }
            function save(saveRestore)
            {
                //newListDialog
                saveRestore.setValue("landingNewListDialogVisible", newListDialog.visible);
                saveRestore.setValue("landingNewListDialogText", textinput.text);

                //renameDialog
                saveRestore.setValue("landingRenameDialogVisible", renameDialog.visible);
                saveRestore.setValue("landingRenameDialogText", renameTextInput.text);
                saveRestore.setValue("landingRenameDialogListId", renameDialog.listId);

                //deleteListDialog
                saveRestore.setValue("landingDeleteListDialogVisible", deleteListDialog.visible);
                saveRestore.setValue("landingDeleteListDialogListId", deleteListDialog.listId);
            }

            function restore(saveRestore)
            {
                //newListDialog
                if (saveRestore.value("landingNewListDialogVisible") == "true") {
                    newListDialog.show();
                    textinput.forceActiveFocus();
                    textinput.focus = true;
                } else {
                    newListDialog.hide();
                }
                textinput.text = saveRestore.value("landingNewListDialogText");

                //renameDialog
                if (saveRestore.value("landingRenameDialogVisible") == "true") {
                    renameDialog.show();
                    renameTextInput.forceActiveFocus();
                    renameTextInput.focus = true;
                } else {
                    renameDialog.hide();
                }
                renameTextInput.text = saveRestore.value("landingRenameDialogText");
                renameDialog.listId = saveRestore.value("landingRenameDialogListId");

                //deleteListDialog
                if (saveRestore.value("landingDeleteListDialogVisible") == "true") {
                    deleteListDialog.show();
                } else {
                    deleteListDialog.hide();
                }
                deleteListDialog.listId = saveRestore.value("landingDeleteListDialogListId");
            }

            function hasDupeTaskListName(checkName) {
                for(var i=0;i< allListsModel.nameList.length; i++) {
                    if(allListsModel.nameList[i] == checkName) {
                        return true;
                    }
                }
                return false;
            }

            ModalDialog {
                id: newListDialog
                content: TextEntry {
                    id: textinput;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.rightMargin: anchors.leftMargin
                    defaultText: qsTr("List name")
                }
                title: labelNewList
                cancelButtonText: labelCancel
                acceptButtonText: labelOk
                showAcceptButton: (textinput.text.length > 0) && (hasDupeTaskListName(textinput.text) != true)
                //this is done because there is no way in the ModalDialog to disable the OK button if the user didn't enter text
                onAccepted: {
                    allListsModel.addList(textinput.text);
                    textinput.text = "";
                    listsViewBlankSlate.visible = false;
                    qmlSettings.isRunningFirstTime = false;
                }
                onRejected: {
                    textinput.text = "";
                }

            }

            ModalDialog{
                id: deleteListDialog
                acceptButtonImage:"image://themedimage/widgets/common/button/button-negative"
                acceptButtonImagePressed:"image://themedimage/widgets/common/button/button-negative-pressed"
                title: labelDeleteListDialog
                acceptButtonText: labelDelete
                cancelButtonText:labelCancel
                property int listId: -1
                onAccepted: {
                    editorList.removeList(listId);
                }
            }

            ModalDialog{
                id: renameDialog
                acceptButtonText: labelOk
                cancelButtonText:labelCancel
                title: labelRenameList
                showAcceptButton: (renameTextInput.text.length > 0) && (hasDupeTaskListName(renameTextInput.text) != true)
                //this is done because there is no way in the ModalDialog to disable the OK button if the user didn't enter text
                property int listId: -1
                property alias originalText: renameTextInput.text;
                content: TextEntry {
                    id: renameTextInput;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.rightMargin: anchors.leftMargin
                    defaultText: qsTr("List name")
                }
                onAccepted: {
                    allListsModel.renameList( listId, renameTextInput.text);
                    customlistModel.listName = renameTextInput.text;
                }
            }

            ContextMenu {
                id: landingScreenContextMenu
                property variant payload
                content: ActionMenu {
                    model: [labelRenameList, labelDeleteList]
                    onTriggered: {
                        if (index == 0)
                        {
                            // rename
                            renameDialog.listId =landingScreenContextMenu.payload.mListId;
                            renameDialog.originalText = landingScreenContextMenu.payload.mListName;
                            renameDialog.show();
                        }
                        else if (index == 1)
                        {
                            // delete list
                            deleteListDialog.listId = landingScreenContextMenu.payload.mListId;
                            deleteListDialog.show();
                        }
                        landingScreenContextMenu.hide();
                    }
                }
            }

            Column {
                anchors.fill: parent
                spacing: 20

                ListView {
                    id: listview

                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: listsViewBlankSlate.visible ? 150 : parent.height   //TODO: calculate 150 properly

                    model: allListsModel
                    clip:true
                    interactive: (contentHeight + rowHeight) > listview.height
                    delegate: Item{
                        id: dinstance
                        width: parent.width
                        height: rowHeight
                        property string mListId: listId
                        property string mListName: listName
                        property bool   mPressed: false

                        Image {
                            source: mPressed ? "image://themedimage/widgets/common/list/list-active"
                                             : "image://themedimage/widgets/common/list/list"
                            anchors.fill: parent
                        }

                        Image {
                            id: separator
                            width: parent.width
                            anchors.bottom: parent.bottom
                            source: "image://themedimage/widgets/common/dividers/divider-horizontal-single"
                        }

                        Image {
                            id: icon
                            source: listId == 0 ? "image://themedimage/icons/internal/tasks-group-default"
                                                : "image://themedimage/icons/internal/tasks-group-generic"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:parent.left
                            anchors.leftMargin: horizontalMargin
                            height:parent.height - 2* verticalMargin
                            width: height
                            smooth:true
                            fillMode:Image.PreserveAspectFit
                        }

                        Text {
                            id: text
                            anchors.left: parent.left
                            anchors.leftMargin: 2*horizontalMargin + parent.height - 2* verticalMargin
                            height: parent.height
                            anchors.right: icompletedCount.left
                            anchors.rightMargin:horizontalMargin
                            text:  listName
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            //font.bold: true
                            font.pixelSize: theme.fontPixelSizeLarge
                            elide: Text.ElideRight
                            color: theme.fontColorNormal
                        }

                        Image {
                            id: separator_top
                            width: parent.width
                            anchors.top: parent.bottom
                            source: "image://themedimage/widgets/common/dividers/divider-horizontal-single"
                        }
                        Rectangle {
                            id: icompletedCount
                            width: height
                            height: parent.height - 2* verticalMargin
                            radius: width/4
                            color:"lightgray"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: goArrow.left
                            anchors.rightMargin: horizontalMargin
                            visible: !(icountText.text=="")
                            Text {
                                id: icountText
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text:listIncompletedCount
                                font.pixelSize: theme.fontPixelSizeSmall
                            }

                        }
                        Image {
                            id: goArrow
                            anchors.right:parent.right
                            anchors.rightMargin: horizontalMargin
                            anchors.verticalCenter:parent.verticalCenter
                            source: mPressed ? "image://themedimage/icons/internal/arrow-default-right-active"
                                             : "image://themedimage/icons/internal/arrow-default-right"
                        }

                        TopItem{ id: top }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
				//Hitting a task list multiple times will cause
				// the task to be added to the page stack multiple times 
                                if (window.pageStack.busy)
                                    return;

                                customlistModel.listId = listId;
                                customlistModel.listName = text.text;
                                window.addPage(customlistPageComponent);
                            }
                            onPressAndHold: {
                                if (listId != 0) {
                                    top.calcTopParent();
                                    landingScreenContextMenu.payload = dinstance;
                                    var map = mapToItem(top.topItem, mouseX, mouseY);
                                    landingScreenContextMenu.setPosition(map.x, map.y);
                                    landingScreenContextMenu.show();
                                }
                            }
                            onPressed: { mPressed = true; }
                            onReleased: { mPressed = false; }
                            onCanceled: { mPressed = false; }
                        }
                    }

                    header: Item{
                        id: allDueTasksItem
                        //parent: landingScreenPage.content
                        width: parent.width
                        height: rowHeight
                        property bool mPressed: false

                        Image {
                            source: mPressed ? "image://themedimage/widgets/common/list/list-active"
                                             : "image://themedimage/widgets/common/list/list"
                            anchors.fill: parent
                        }

                        Image {
                            id: separator
                            width: parent.width
                            anchors.bottom: parent.bottom
                            source: "image://themedimage/widgets/common/dividers/divider-horizontal-single"
                        }

                        Image {
                            id: icon
                            source: "image://themedimage/icons/internal/tasks-group-alldue"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left:parent.left
                            anchors.leftMargin: horizontalMargin
                            height:parent.height - 2* verticalMargin
                            width: height
                            smooth:true
                            fillMode:Image.PreserveAspectFit
                        }

                        Text {
                            id: text
                            anchors.left: parent.left
                            anchors.leftMargin: 2*horizontalMargin + parent.height - 2* verticalMargin
                            height: parent.height
                            anchors.right: icompletedCount.left
                            anchors.rightMargin:horizontalMargin
                            text:  labelAllDueTasks
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: theme.fontPixelSizeLarge
                            elide: Text.ElideRight
                            color: theme.fontColorNormal
                        }

                        Image {
                            id: separator_top
                            width: parent.width
                            anchors.top: parent.bottom
                            source: "image://themedimage/widgets/common/dividers/divider-horizontal-single"
                        }
                        Rectangle {
                            id: icompletedCount
                            width: height
                            height: parent.height - 2* verticalMargin
                            radius: width/4
                            color:"lightgray"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: goArrow.left
                            anchors.rightMargin: horizontalMargin
                            visible: !(icountText.text=="")
                            Text {
                                id: icountText
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                text:overdueModel.icount + upcomingModel.icount + somedayModel.icount
                                font.pixelSize: theme.fontPixelSizeSmall
                                color: theme.fontColorNormal
                            }

                        }

                        Image {
                            id: goArrow
                            anchors.right:parent.right
                            anchors.rightMargin: horizontalMargin
                            anchors.verticalCenter:parent.verticalCenter
                            source: mPressed ? "image://themedimage/icons/internal/arrow-default-right-active"
                                             : "image://themedimage/icons/internal/arrow-default-right"
                        }

                        GestureArea {
                            anchors.fill: parent
                            acceptUnhandledEvents: true
                            Tap {
                                onStarted: { mPressed = true; }

                                onFinished: {
                                    mPressed = false;
                                    // Prevent adding extra pages
                                    if (window.pageStack.busy)
                                        return;
                                    window.addPage(allDueTasksPageComponent);
                                }

                                onCanceled: { mPressed = false; }
                            }
                        }

                        //                        MouseArea {
                        //                            anchors.fill: parent
                        //                            onClicked: window.addPage(allDueTasksPageComponent)
                        //                        }
                    }
                }

                BlankSlate {
                    id: listsViewBlankSlate
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.height - listview.height

                    visible: qmlSettings.isRunningFirstTime

                    title: qsTr("Use the default task list, or make a new one")
                    buttonText: qsTr("Create a new task list")

                    viewModel: ListModel {

                    }

                    Component.onCompleted: {
                        viewModel.append({"title" : qsTr("What's a task list?"),
                                         "source" : "",
                                         "buttonText" : "",
                                         "subTitle" : qsTr("A task list is a collection of tasks. Use the default task list we have created for you, or make a new one.")});
                        viewModel.append({"title" : qsTr("How do I create tasks?"),
                                         "source" : "",
                                         "buttonText" : "",
                                         "subTitle" : qsTr("To create a task, start by selecting a task list. Then tap on the new task line.")});
                        viewModel.append({"title" : qsTr("How do I check completed tasks?"),
                                         "source" : "",
                                         "buttonText" : "",
                                         "subTitle" : qsTr("To mark a task as completed, tap the check box.")});
                    }

                    onButtonClicked: newListDialog.show()
                }
            }
        }
    }

    Component {
        id: allDueTasksPageComponent
        AppPage {
            id: allDueTasksPage
            anchors.fill:parent
            objectName: "allDueTasksPage"
            pageTitle: labelAllDueTasks

            onDeactivated: {
                if (overdueModel.filter != "")
                    overdueModel.filter = "";
                if (upcomingModel.filter != "")
                    upcomingModel.filter = "";
                if (somedayModel.filter != "")
                    somedayModel.filter = "";
            }

            function save(saveRestore)
            {
                saveRestore.setValue("alldueTasksListSortOrder", overdueModel.sortOrder);
                for (var i = 0; i < 3; ++i)
                    saveRestore.setValue("alldueTasksListCollapsed" + i, alldueTasksList.itemCollapsed(i));
                saveRestore.setValue("alldueTasksListContentX", alldueTasksList.contentX);
                saveRestore.setValue("alldueTasksListContentY", alldueTasksList.contentY);
            }

            function restore(saveRestore)
            {
                overdueModel.sort(saveRestore.value("customSortOrder"));
                upcomingModel.sort(saveRestore.value("customSortOrder"));
                for (var i = 0; i < 3; ++i)
                    alldueTasksList.collapseItem(i, saveRestore.value("alldueTasksListCollapsed" + i));
                alldueTasksList.contentX = saveRestore.value("alldueTasksListContentX");
                alldueTasksList.contentY = saveRestore.value("alldueTasksListContentY");
            }

            Connections {
                target: window.pageStack
                onCurrentPageChanged: {
                    if (window.pageStack.currentPage != allDueTasksPage)
                        return;
                    overdueModel.sort(TasksListModel.DESC);
                    upcomingModel.sort(TasksListModel.DESC);
                    tryShowBlankOrNoContentSlate(0);
                }
            }

            actionMenuModel: [ labelAllDueTasks,
                labelOverdue,
                labelUpComing,
                labelSomeday,
                currentSortOrderText(overdueModel) ]
            actionMenuPayload: [ 0, 1, 2, 3, 4 ]

            property int prevSelectedItem: 0

            function tryShowBlankOrNoContentSlate(index)
            {
                allDueBlankSlates.model.setProperty(prevSelectedItem, "visible", false);
                if (index > 3)
                    return;

                if (!index && (overdueModel.count > 0 || upcomingModel.count > 0 || somedayModel.count > 0)) {
                    alldueTasksList.visible = true;
                    return;
                } else if ((index == 1 && overdueModel.count > 0)
                           || (index == 2 && upcomingModel.count > 0)
                           || (index == 3 && somedayModel.count > 0)) {
                    alldueTasksList.visible = true;
                    return;
                }

                alldueTasksList.visible = false;

                prevSelectedItem = index;
                allDueBlankSlates.model.setProperty(index, "visible", true);
            }

            onActionMenuTriggered: {
                tryShowBlankOrNoContentSlate(selectedItem);

                if(selectedItem == 0) {
                    alldueTasksList.model = [overdueCItem, upcomingCItem, somedayCItem];
                    alldueTasksList.forceShowTitle = false;
                } else if(selectedItem == 1) {
                    alldueTasksList.model = [overdueCItem];
                    alldueTasksList.forceShowTitle = true;
                } else if(selectedItem == 2) {
                    alldueTasksList.model = [upcomingCItem];
                    alldueTasksList.forceShowTitle = true;
                } else if(selectedItem == 3) {
                    alldueTasksList.model = [somedayCItem];
                    alldueTasksList.forceShowTitle = true;
                } else if (selectedItem == 4) {
                    var order = swapSortOrder(overdueModel);
                    overdueModel.sort(order);
                    upcomingModel.sort(order);
                }
            }

            // Category Items
            CategoryItem {
                id: overdueCItem
                viewModel: overdueModel
                title: labelOverdue
                titleColor:"#cbcbcb"
            }
            CategoryItem {
                id: upcomingCItem
                viewModel: upcomingModel
                title:labelUpComing
                titleColor:"#cbcbcb"
            }
            CategoryItem {
                id: somedayCItem
                viewModel: somedayModel
                title: labelSomeday
                titleColor:"#cbcbcb"
            }
            CategoryView {
                id: alldueTasksList
                parent: allDueTasksPage
                anchors.fill:parent
                model: [overdueCItem, upcomingCItem, somedayCItem]
                titleHeight: window.titleHeight
                rowHeight: window.rowHeight

                onClickedAtRow: {
                    taskDetailContextMenu.displayContextMenu(x,y,payload,false);
                }
                onCheckedAtRow: {
                    editorList.setCompleted(payload.mTaskId,checked);
                }
                onCloseDetailOfTask: {
                    closeDetailWindowWithId(taskId);
                }
                onPressAndHoldAtRow : {
                    var mouse = mapToItem(top, x, y)
                    allDueTasksPageContextMenu.mousePos = mouse
                    allDueTasksPageContextMenu.payload = payload;
                    allDueTasksPageContextMenu.setPosition(x, y)
                    allDueTasksPageContextMenu.show();
                }
            }

            Repeater {
                id: allDueBlankSlates

                model: ListModel {
                    id: blankSlatesModel
                }

                Component.onCompleted: {
                    model.append({"title" : qsTr("You have no due tasks"),
                                 "visible" : false});
                    model.append({"title" : qsTr("You have no overdue tasks"),
                                 "visible" : false});
                    model.append({"title" : qsTr("You have no upcoming tasks"),
                                 "visible" : false});
                    model.append({"title" : qsTr("You have no someday tasks"),
                                 "visible" : false});
                }

                delegate: BlankSlate {
                    id: allDueTasksBlankSlate
                    anchors.topMargin: 20
                    anchors.fill: parent

                    title: model.title
                    subTitle: !qmlSettings.isRunningFirstTime ? qsTr("To create a task, start by selecting a task list.") : ""
                    buttonVisible:true 
//!qmlSettings.isRunningFirstTime
                    buttonText: qsTr("Select a task list")

                    visible: model.visible

                    viewVisible: qmlSettings.isRunningFirstTime
                    viewModel: ListModel {

                    }

                    Component.onCompleted: {
                        viewModel.append({"title" : qsTr("How do I create tasks?"),
                                         "source" : "",
                                         "buttonText" : qsTr("Select a task list"),
                                         "subTitle" : qsTr("To create a task, start by selecting a task list. Then tap on the new task line.")});
                    }

                    onViewItemButtonClicked: picker.show()
                    onButtonClicked: picker.show()
                }
            }

            TaskListPicker {
                id: picker
                visible:false
                onSelected: {
                    visible = false;
                    customlistModel.listId = listId;
                    switchBook(landingScreenPageComponent);
                    window.addPage(customlistPageComponent);
                }
            }

            ModalDialog {
                id: deleteTaskDialog
                acceptButtonText: labelDelete
                cancelButtonText:labelCancel
                title: labelDeleteSingleTask
                acceptButtonImage:"image://themedimage/widgets/common/button/button-negative"
                acceptButtonImagePressed:"image://themedimage/widgets/common/button/button-negative-pressed"
                property int taskId: -1

                content: Row {
                    anchors.fill: parent
                    spacing: 10
                    CheckBox {
                        id:checkBox
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: checkboxTextArea
                        text: qsTr("Don't ask to confirm deleting tasks.")
                        wrapMode: Text.WordWrap
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - checkBox.width
                        font.pixelSize: theme.fontPixelSizeLarge
                    }
                }
                onAccepted: {
                    if(checkBox.isChecked)
                        qmlSettings.set("task_auto_delete", true);
                    editorList.removeTask(taskId);
                }
            }

            ContextMenu {
                id: taskDetailContextMenu
                property alias setTask: theDetailMenu.task
                property alias setListnames: theDetailMenu.listNames
                property alias setEditing: theDetailMenu.editing

                content: TasksDetailMenu {
                    id: theDetailMenu
                    anchors.margins: 10
                    onClose: {
                        taskDetailContextMenu.hide();
                        theDetailMenu.editing = false;
                    }
                    onSave: {
                        taskDetailContextMenu.setTask = taskToSave;
                        saveChanges(taskDetailContextMenu.setTask);
                        taskDetailContextMenu.hide();
                    }
                    onDeleteTask:  {
                        // delete task
                        if(qmlSettings.get("task_auto_delete")){
                            editorList.removeTask(taskId);
                        } else {
                            deleteTaskDialog.taskId = taskId
                            deleteTaskDialog.show();
                        }
                        taskDetailContextMenu.hide();
                    }
                }

                function displayContextMenu (mouseX, mouseY, taskData, edit) {
                    taskDetailContextMenu.setPosition(mouseX,mouseY);
                    theDetailMenu.task = taskData;
                    theDetailMenu.listNames = listsGroupItem.getAllListsNames();
                    theDetailMenu.editing = edit;

                    taskDetailContextMenu.show();
                }
            }

            TopItem {id: top}

            ContextMenu {
                id: allDueTasksPageContextMenu
                property variant payload
                property variant mousePos
                content: ActionMenu {
                    model: [labelViewDetail, labelEditTask, labelShowInList, labelDeleteTask]
                    onTriggered: {
                        if (index == 0)
                        {
                            // view detail
                            taskDetailContextMenu.displayContextMenu(allDueTasksPageContextMenu.mousePos.x,
                                                                     allDueTasksPageContextMenu.mousePos.y,
                                                                     allDueTasksPageContextMenu.payload,false);
                        }
                        else if (index == 1)
                        {
                            // edit task
                            taskDetailContextMenu.displayContextMenu(allDueTasksPageContextMenu.mousePos.x,
                                                                     allDueTasksPageContextMenu.mousePos.y,
                                                                     allDueTasksPageContextMenu.payload,true);
                        }
                        else if (index == 2) {
                            // view in list
                            customlistModel.listId = allDueTasksPageContextMenu.payload.mListId;
                            customlistModel.listName = allDueTasksPageContextMenu.payload.mListName;
                            window.replacePage(customlistPageComponent)
                        }else if (index == 3) {
                            // delete task
                            if(qmlSettings.get("task_auto_delete")){
                                editorList.removeTask(allDueTasksPageContextMenu.payload.mTaskId);
                            } else {
                                deleteTaskDialog.taskId = allDueTasksPageContextMenu.payload.mTaskId;
                                deleteTaskDialog.show();
                            }
                        }
                        allDueTasksPageContextMenu.hide();
                    }
                }
            }
        }
    }


    Component {
        id: customlistPageComponent
        AppPage {
            id: customlistPage
            objectName: "customlistPage"
            pageTitle: labelTasks

            onDeactivated: {
                if (customlistModel.filter != "")
                    customlistModel.filter = "";
            }

            function save(saveRestore)
            {
                //customlistModel
                saveRestore.setValue("customCustomlistModelListId", customlistModel.listId);
                saveRestore.setValue("customCustomlistModelListName", customlistModel.listName);

                //confirmDelComTasksDialog
                saveRestore.setValue("customConfirmDelComTasksDialogVisible", confirmDelComTasksDialog.visible);

                //renameDialog
                saveRestore.setValue("customRenameDialogVisible", renameDialog.visible);
                saveRestore.setValue("customRenameDialogText", renameTextInput.text);

                //deleteTaskDialog
                saveRestore.setValue("customDeleteTaskDialogVisible", deleteTaskDialog.visible);

                //deleteListDialog
                saveRestore.setValue("customDeleteListDialogVisible", deleteListDialog.visible);

                //taskListView
                saveRestore.setValue("customTaskListViewMode", taskListView.mode);
                saveRestore.setValue("customSortOrder", customlistModel.sortOrder);
                saveRestore.setValue("customTaskListViewCollapsed", taskListView.collapsed);
                saveRestore.setValue("customTaskListViewContentX", taskListView.contentX);
                saveRestore.setValue("customTaskListViewContentY", taskListView.contentY);
            }

            function restore(saveRestore)
            {
                //customlistModel
                customlistModel.listId = saveRestore.value("customCustomlistModelListId");
                customlistModel.listName = saveRestore.value("customCustomlistModelListName");

                //confirmDelComTasksDialog
                if (saveRestore.value("customConfirmDelComTasksDialogVisible") == "true") {
                    confirmDelComTasksDialog.show();
                } else {
                    confirmDelComTasksDialog.hide();
                }

                //renameDialog
                if (saveRestore.value("customRenameDialogVisible") == "true") {
                    renameTextInput.forceActiveFocus();
                    renameTextInput.focus = true;
                    renameDialog.show();
                } else {
                    renameDialog.hide();
                }
                renameTextInput.text = saveRestore.value("customRenameDialogText");

                //deleteTaskDialog
                if (saveRestore.value("customDeleteTaskDialogVisible") == "true") {
                    deleteTaskDialog.show();
                } else {
                    deleteTaskDialog.hide();
                }

                //deleteListDialog
                if (saveRestore.value("customDeleteListDialogVisible") == "true") {
                    deleteListDialog.show();
                } else {
                    deleteListDialog.hide();
                }

                //taskListView
                taskListView.mode = saveRestore.value("customTaskListViewMode");
                customlistModel.sort(saveRestore.value("customSortOrder"));
                customlistPage.actionMenuModel = makeActionMenuModel();
                taskListView.collapsed = saveRestore.value("customTaskListViewCollapsed");
                taskListView.contentX = saveRestore.value("customTaskListViewContentX");
                taskListView.contentY = saveRestore.value("customTaskListViewContentY");
            }

            ContextMenu {
                id: taskDetailContextMenu
                property alias setTask: theDetailMenu.task
                property alias setListnames: theDetailMenu.listNames
                property alias setEditing: theDetailMenu.editing

                content: TasksDetailMenu {
                    id: theDetailMenu
                    anchors.margins: 10
                    onClose: {
                        taskDetailContextMenu.hide();
                        editing = false;
                    }
                    onSave: {
                        taskDetailContextMenu.setTask = taskToSave;
                        saveChanges(taskDetailContextMenu.setTask);
                        taskDetailContextMenu.hide();
                    }
                    onDeleteTask:  {
                        // delete task
                        if(qmlSettings.get("task_auto_delete")){
                            editorList.removeTask(taskId);
                        } else {
                            deleteTaskDialog.taskId = taskId
                            deleteTaskDialog.show();
                        }
                        taskDetailContextMenu.hide();
                    }
                }

                function displayContextMenu (mouseX, mouseY, taskData, edit) {
                    taskDetailContextMenu.setPosition(mouseX,mouseY);
                    theDetailMenu.task = taskData;
                    theDetailMenu.listNames = listsGroupItem.getAllListsNames();
                    theDetailMenu.editing = edit;

                    taskDetailContextMenu.show();
                }
            }

            function makeActionMenuModel() {
                var returnMe = [labelAddTask];
                if(customlistModel.count > 1 ) {
                    returnMe.push(labelSelectMultiple);
                }
                if(customlistModel.listId > 0) {
                    returnMe.push(labelRenameList);
                    returnMe.push(labelDeleteList);
                }
                if(customlistModel.count != customlistModel.icount) { //implying there are completed tasks
                    returnMe.push(labelDeleteCompletedTask);
                }
                returnMe.push(currentSortOrderText(customlistModel));
                return returnMe;
            }

            function makeActionMenuPayload()
            {
                var list = makeActionMenuModel();
                var res = [];
                for (var i = 0; i < list.length; ++i)
                    res[i] = i;

		customlistPage.actionMenuModel=list

                return res;
            }

            function addTaskFun() {taskListView.mode =1;}
            function selectMultiFun() {taskListView.mode = 2;}
            function renameListFun() {
                renameDialog.listId = customlistModel.listId;
                renameDialog.originalText = customlistModel.listName;
                renameDialog.show();
            }
            function deleteListFun() {
                deleteListDialog.listId = customlistModel.listId;
                deleteListDialog.show();
            }
            function deleteCompFun() {confirmDelComTasksDialog.show();}

            function onContextMenuClicked(index) {
                var runMe = [addTaskFun];
                if(customlistModel.count > 1 ) {
                    runMe.push(selectMultiFun);
                }
                if(customlistModel.listId > 0) {
                    runMe.push(renameListFun);
                    runMe.push(deleteListFun);
                }
                if(customlistModel.count != customlistModel.icount) { //implying there are completed tasks
                    runMe.push(deleteCompFun);
                }
                runMe.push(swapSortOrderForCustomModel);
                runMe[index]();
            }

            function swapSortOrderForCustomModel()
            {
                customlistModel.sort(swapSortOrder(customlistModel));
                customlistPage.actionMenuModel = makeActionMenuModel();
            }

            function hasDupeTaskListName(checkName) {
                for(var i=0;i< allListsModel.nameList.length; i++) {
                    if(allListsModel.nameList[i] == checkName) {
                        return true;
                    }
                }
                return false;
            }

            actionMenuModel: makeActionMenuModel()
            actionMenuPayload: makeActionMenuPayload()

            onActionMenuTriggered: onContextMenuClicked(selectedItem)

            ModalDialog {
                id: confirmDelComTasksDialog
                title: qsTr("Are you sure you want to delete the completed tasks?")
                acceptButtonText: qsTr("Yes")
                cancelButtonText: qsTr("No")
                onAccepted: {
                    customlistModel.removeCompletedTasksInList(customlistModel.listId);
                }
            }

            TaskListView {
                id: taskListView
                parent:customlistPage
                anchors.fill:parent
                property alias title: categoryitem.title
                property alias viewModel: categoryitem.viewModel

                model: CategoryItem {
                    id: categoryitem
                    viewModel:customlistModel
                    title: customlistModel.listName
                    titleColor:"#cbcbcb"
                }
                onModeChanged :{
                    taskDetailContextMenu.hide();
                }

                onClickedAtRow: {
                    if (taskListView.mode == 0) {
                        taskDetailContextMenu.displayContextMenu(x, y,payload,false);
                    }

                }
                onCheckedAtRow: {
                    editorList.setCompleted(payload.mTaskId,checked);
                }
                onPressAndHoldAtRow: {
                    var mouse = mapToItem(top, x, y)
                    customListPageContextMenu.mousePos = mouse
                    customListPageContextMenu.payload = payload;
                    customListPageContextMenu.setPosition(x, y)
                    customListPageContextMenu.show();
                }
            }

            TopItem {id: top}

            ModalDialog{
                id: renameDialog
                acceptButtonText: labelOk
                cancelButtonText:labelCancel
                title: labelRenameList
                showAcceptButton: (renameTextInput.text.length > 0) && (hasDupeTaskListName(renameTextInput.text) != true)
                //this is done because there is no way in the ModalDialog to disable the OK button if the user didn't enter text
                property int listId: -1
                property alias originalText: renameTextInput.text;
                content: TextEntry {
                    id: renameTextInput;
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.rightMargin: anchors.leftMargin
                    defaultText: qsTr("List name")
                }
                onAccepted: {
                    allListsModel.renameList( listId, renameTextInput.text);
                    customlistModel.listName = renameTextInput.text;
                }
            }

            ModalDialog {
                id: deleteTaskDialog
                acceptButtonText: labelDelete
                cancelButtonText:labelCancel
                title: labelDeleteSingleTask
                acceptButtonImage:"image://themedimage/widgets/common/button/button-negative"
                acceptButtonImagePressed:"image://themedimage/widgets/common/button/button-negative-pressed"
                property int taskId: -1

                content: Row {
                    anchors.fill: parent
                    spacing: 10
                    CheckBox {
                        id:checkBox
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: checkboxTextArea
                        text: qsTr("Don't ask to confirm deleting tasks.")
                        wrapMode: Text.WordWrap
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - checkBox.width
                        font.pixelSize: theme.fontPixelSizeLarge
                    }
                }
                onAccepted: {
                    if(checkBox.isChecked)
                        qmlSettings.set("task_auto_delete", true);
                    editorList.removeTask(taskId);
                }
            }

            ModalDialog{
                id: deleteListDialog
                acceptButtonImage:"image://themedimage/widgets/common/button/button-negative"
                acceptButtonImagePressed:"image://themedimage/widgets/common/button/button-negative-pressed"
                title: labelDeleteListDialog
                acceptButtonText: labelDelete
                cancelButtonText:labelCancel
                property int listId: -1
                onAccepted: {
                    editorList.removeList(listId);
                    if (window.pageStack.currentPage == customlistPage)
                        window.pageStack.pop();
                }
            }

            ContextMenu {
                id: customListPageContextMenu
                property variant mousePos
                property variant payload
                content: ActionMenu {
                    model: {
                        if(customlistModel.count > 1) {
                            return [labelViewDetail,labelEditTask, labelDeleteTask,labelSelectMultiple];
                        } else {
                            return [labelViewDetail,labelEditTask, labelDeleteTask];
                        }
                    }
                    onTriggered: {
                        if (index == 0) { // view detail
                            taskDetailContextMenu.displayContextMenu(customListPageContextMenu.mousePos.x,
                                                                     customListPageContextMenu.mousePos.y,
                                                                     customListPageContextMenu.payload,false);
                        } else if (index == 1) { // edit task
                            taskDetailContextMenu.displayContextMenu(customListPageContextMenu.mousePos.x,
                                                                     customListPageContextMenu.mousePos.y,
                                                                     customListPageContextMenu.payload,true);
                        } else if (index ==2) {  // delete task
                            if(qmlSettings.get("task_auto_delete")){
                                editorList.removeTask(customListPageContextMenu.payload.mTaskId);
                            } else {
                                deleteTaskDialog.taskId = customListPageContextMenu.payload.mTaskId;
                                deleteTaskDialog.show();
                            }
                        } else if (index == 3) { // multiple selection mode
                            taskListView.mode = 2;
                        }
                        customListPageContextMenu.hide();
                    }
                }
            }
        }
    }
}
