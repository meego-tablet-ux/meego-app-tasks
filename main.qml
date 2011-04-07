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

Window {
    id: scene
    property string labelTasks: qsTr("Tasks")
    property string labelAllDueTasks: qsTr("All due tasks")
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
    property string labelDeleteListDialog: qsTr("Do you want to delete this list\n and all of its tasks?")
    property string labelDelete: qsTr("Delete")
    property string labelDeleteSingleTask: qsTr("Are you sure you want to delete this task?")

    property int rowHeight: theme_listBackgroundPixelHeightOne
    property int horizontalMargin: 20
    property int verticalMargin: 10
    property int titleHeight: 50

    QmlSetting {
        id: qmlSettings
        organization: "Intel"
        application: "Tasks"
    }

    //    orientation:1
    title: labelTasks
    Component.onCompleted: {
        applicationPage = landingScreenPageComponent
    }
    function getFormattedDate(date) {
        if (!date.getDate()) {
            return labelSomeday;
        }
        var now = new Date();
        if (now.getDate() == date.getDate() &&
                now.getMonth() == date.getMonth() &&
                now.getYear() == date.getYear() )
            return labelToday

        return qsTr("%1 %2").arg(Qt.formatDate(date,"d") + "").arg(Qt.formatDate(date,"MMM") + "");
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
    function showTaskDetailWindow(item,x, y, payload) {
        saveChanges();
        // makeTaskItem(payload);
        if (!taskDetailLoader.item) {
            taskDetailLoader.sourceComponent = taskDetailComponent;
        }
        var map = item.mapToItem(scene, x, y);
        //taskDetailLoader.item.x = getTaskDetailWindowX();
        taskDetailLoader.item.x = map.x;
        var ty = map.y;
        if ( ty + taskDetailLoader.item.height > scene.height) {
            ty = scene.height - taskDetailLoader.item.height;
            taskDetailLoader.item.moveY = map.y - ty;
        }

        taskDetailLoader.item.y = ty;
        taskDetailLoader.item.task = payload;
        taskDetailLoader.item.listNames = listsGroupItem.getAllListsNames();
        taskDetailLoader.item.updateValues();
    }
    function saveChanges(){
        if (taskDetailLoader.item && taskDetailLoader.item.editing)
        {
            taskDetailLoader.item.retrieveData(taskDetailToSave);
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
            taskDetailLoader.item.editing = false;
            console.log("================end save changes =================");
        }
    }

    function getTaskDetailWindowX() {
        return content.width - 350
    }

    function addNewTask(listId, taskName) {
        if (taskName){
            // editorList.addTask(listId, taskName, "new added task comment",
            //                    false,duedateData.hasDuedate, duedateData.dueDate,
            //                    0, new Date(), [], []);
            editorList.addTaskAlt(listId, taskName, false, duedateData.hasDuedate, duedateData.dueDate);
        }
    }
    function closeDetailWindowWithId(taskId) {
        if ( taskDetailLoader.item && taskDetailLoader.item.taskId == taskId) {
            saveChanges();
            taskDetailLoader.sourceComponent = undefined;
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
            var t = [];
            for (var i = 0; i< listsGroupItem.children.length -1 ; i++) {
                t = t.concat([listsGroupItem.children[i].list]);
            }
            return t;
        }

        Repeater {
            id: listsRepeater
            model:allListsModel

            delegate:Item {
                property string list :listName

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

    Loader {
        id :taskDetailLoader
    }
    Loader {
        id: dialogLoader
        onStatusChanged :{
            if (status == Loader.Ready){
                item.parent = scene
                item.textinput.forceActiveFocus();
            }
        }
    }

    Component {
        id: taskDetailComponent
        TasksDetailWindow {
            maxHeight: content.height
            onHeightChanged: {
                if (!taskDetailLoader.item)
                    return;
                var ty = taskDetailLoader.item.y;
                if ( ty + taskDetailLoader.item.height > content.height)
                    ty = scene.height - taskDetailLoader.item.height
                taskDetailLoader.item.y = ty;
            }

            onClose: {
                taskDetailLoader.sourceComponent = undefined;
            }
            onSave: {
                saveChanges();
            }
            onDeleteTask: {
                editorList.removeTask(taskId);
                taskDetailLoader.sourceComponent = undefined;
            }
        }
    }

    Component {
        id: newListModalDialogComponent
        ModalDialog{
            id: newListDialog
            leftButtonText: (textinput.text.length > 0) ? labelOk : "" //this is done because there is no way in the ModalDialog to disable the OK button if the user didn't enter text
            rightButtonText:labelCancel
            dialogTitle: labelNewList
            bgSourceUpLeft:"image://theme/btn_blue_up"
            bgSourceDnLeft:"image://theme/btn_blue_dn"
            property alias textinput: textinput.textInput
            dialogWidth: 300
            dialogHeight: 175

            TextEntry {
                id: textinput
                width: newListDialog.dialogWidth
                height: 50
                defaultText: qsTr("List name")
                parent: dialog
                anchors.centerIn: parent
            }

            onDialogClicked: {
                if (button == 1 && textinput.text){

                    allListsModel.addList(textinput.text)
                }
                dialogLoader.sourceComponent = undefined;
            }
        }
    }
    Component {
        id: landingScreenPageComponent
        ApplicationPage {
            id: landingScreenPage
            anchors.fill:parent
            title: labelTasks;

            onSearch: {
                allListsModel.filter = needle;
            }


            menuContent: ActionMenu {
                id: actions
                model: [labelAddNewList]
                onTriggered: {
                    if(index == 0) {
                        scene.showModalDialog(newListModalDialogComponent);
                        dialogLoader.item.parent = landingScreenPage.content
                    } else if(index == 1) {

                    }
                    landingScreenPage.closeMenu();
                }//ontriggered
            }//action menu


            ListView {
                id: listview
                parent: landingScreenPage.content
                anchors.fill:  landingScreenPage.content
                model: allListsModel
                clip:true
                interactive: (contentHeight + rowHeight) > listview.height
                delegate: Item{
                    id: dinstance
                    width: parent.width
                    height: rowHeight
                    //                    text: listName
                    property string mListId: listId
                    property string mListName: listName

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

                    Image {
                        id: icon
                        source: listId == 0? "image://theme/tasks/icn_defaultlist":""
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
                        font.pixelSize: theme_fontPixelSizeLarge
                        elide: Text.ElideRight
                        color: theme_fontColorNormal
                    }

                    Image {
                        id: separator_top
                        width: parent.width
                        anchors.top: parent.bottom
                        source: "image://theme/tasks/ln_grey_l"
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
                            font.pixelSize: theme_fontPixelSizeSmall
                        }

                    }
                    Image {
                        id: goArrow
                        anchors.right:parent.right
                        anchors.rightMargin: horizontalMargin
                        anchors.verticalCenter:parent.verticalCenter
                        source: "image://theme/icn_forward_dn"
                    }
                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            customlistModel.listId = listId;
                            customlistModel.listName = text.text;
                            landingScreenPage.addApplicationPage(customlistPageComponent)
                        }
                        onPressAndHold : {
                            if (listId != 0) {
                                var map = dinstance.mapToItem(landingScreenPage, mouseX, mouseY);
                                landingScreenContextMenu.payload = dinstance;
                                landingScreenContextMenu.displayContextMenu(map.x,map.y)
                            }
                        }
                    }

                }

                header: Item{
                    id: allDueTasksItem
                    //parent: landingScreenPage.content
                    width: parent.width
                    height: rowHeight
                    Image {
                        id: icon
                        source: "image://theme/tasks/icn_header_tasks"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left:parent.left
                        anchors.leftMargin: horizontalMargin
                        height:parent.height - 2* verticalMargin
                        width: height
                        smooth:true
                        fillMode:Image.PreserveAspectFit
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
                        //font.bold: true
                        font.pixelSize: theme_fontPixelSizeLarge
                        elide: Text.ElideRight
                        color: theme_fontColorNormal
                    }

                    Image {
                        id: separator_top
                        width: parent.width
                        anchors.top: parent.bottom
                        source: "image://theme/tasks/ln_grey_l"
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
                            font.pixelSize: theme_fontPixelSizeSmall
                            color: theme_fontColorNormal
                        }

                    }

                    Image {
                        id: goArrow
                        anchors.right:parent.right
                        anchors.rightMargin: horizontalMargin
                        anchors.verticalCenter:parent.verticalCenter
                        source: "image://theme/icn_forward_dn"
                    }
                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            landingScreenPage.addApplicationPage(allDueTasksPageComponent)
                        }
                    }
                }

                //footer
                footer: Text {
                    id: footerText
                    y: listview.count * rowHeight + 15
                    width: listview.width
                    height: paintedHeight
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("You can create a new list using the action menu")
                    visible: listview.count == 1
                    color: theme_fontColorNormal
                    font.pixelSize: theme_fontPixelSizeLarge
                }
            }

            ContextMenu {
                id: landingScreenContextMenu
                model: [labelRenameList, labelDeleteList]
                menuWidth: 400
                onTriggered: {
                    if (index == 0)
                    {
                        // rename
                        /*scene.showModalDialog(renameListModalDialogComponent);
                        dialogLoader.item.parent = landingScreenPage.content
                        dialogLoader.item.listId = payload.mListId;
                        dialogLoader.item.textinput.text = payload.mListName;*/
                        renameDialog.listId = payload.mListId;
                        renameDialog.textinput = payload.mListName;
                        renameDialog.opacity=1;
                    }
                    else if (index == 1)
                    {
                        // delete list
                        //editorList.removeList(payload.mListId);
                        scene.showModalDialog(deleteListModalDialogComponent);
                        dialogLoader.item.parent = landingScreenPage.content
                        dialogLoader.item.listId = payload.mListId;
                    }

                }
            }
        }
    }
    Component {
        id: allDueTasksPageComponent
        ApplicationPage {
            id: allDueTasksPage
            anchors.fill:parent
            title: labelAllDueTasks

            onSearch: {
                overdueModel.filter = needle;
                upcomingModel.filter = needle;
                somedayModel.filter = needle;
            }

            menuContent: ActionMenu {
                id: actions
                model: [labelAllDueTasks, labelOverdue, labelUpComing, labelSomeday]
                onTriggered: {
                    if(index == 0) {
                        alldueTasksList.model = [overdueCItem, upcomingCItem, somedayCItem];
                        alldueTasksList.forceShowTitle = false;
                        allDueTasksPage.closeMenu();
                    } else if(index == 1) {
                        alldueTasksList.model = [overdueCItem];
                        alldueTasksList.forceShowTitle = true;
                        allDueTasksPage.closeMenu();
                    } else if(index == 2) {
                        alldueTasksList.model = [upcomingCItem];
                        alldueTasksList.forceShowTitle = true;
                        allDueTasksPage.closeMenu();
                    } else if(index == 3) {
                        alldueTasksList.model = [somedayCItem];
                        alldueTasksList.forceShowTitle = true;
                        allDueTasksPage.closeMenu();
                    }
                    allDueTasksPage.closeMenu();
                }//ontriggered
            }//action menu

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
                parent: allDueTasksPage.content
                anchors.fill:parent
                model: [overdueCItem, upcomingCItem, somedayCItem]
                titleHeight: scene.titleHeight
                rowHeight: scene.rowHeight

                onClickedAtRow: {
                    showTaskDetailWindow(alldueTasksList,x, y,payload);
                }
                onCheckedAtRow: {
                    editorList.setCompleted(payload.mTaskId,checked);
                }
                onCloseDetailOfTask: {
                    closeDetailWindowWithId(taskId);
                }
                onPressAndHoldAtRow : {
                    var map = alldueTasksList.mapToItem(allDueTasksPage, x, y);
                    allDueTasksPageContextMenu.payload = payload;
                    allDueTasksPageContextMenu.mousePos = map;
                    allDueTasksPageContextMenu.displayContextMenu(map.x,map.y)
                    taskDetailLoader.sourceComponent = undefined;

                }
            }
            ContextMenu {
                id: allDueTasksPageContextMenu
                model: [labelViewDetail, labelEditTask, labelShowInList, labelDeleteTask]
                menuWidth: 400
                property variant mousePos

                onTriggered: {
                    if (index == 0)
                    {
                        // view detail
                        showTaskDetailWindow(alldueTasksList,mousePos.x, mousePos.y,payload);
                    }
                    else if (index == 1)
                    {
                        // edit task
                        showTaskDetailWindow(alldueTasksList,mousePos.x, mousePos.y,payload);
                        taskDetailLoader.item.editing = true;
                    }
                    else if (index == 2) {
                        // view in list
                        customlistModel.listId = payload.mListId;
                        customlistModel.listName = payload.mListName;
                        allDueTasksPage.close();
                        addApplicationPage(customlistPageComponent)
                    }else if (index == 3) {
                        // delete task
                        if(qmlSettings.get("task_auto_delete")){
                            editorList.removeTask(payload.mTaskId);
                        } else {
                            scene.showModalDialog(deleteTaskModalDialogComponent);
                            dialogLoader.item.parent = allDueTasksPage.content
                            dialogLoader.item.taskId = payload.mTaskId
                        }
                    }
                }
            }
        }
    }


    ModalDialog{
        id: renameDialog
        leftButtonText: (userTextInput.text.length > 0) ? labelOk : "" //this is done because there is no way in the ModalDialog to disable the OK button if the user didn't enter text
        rightButtonText:labelCancel
        dialogTitle: labelRenameList
        bgSourceUpLeft:"image://theme/btn_blue_up"
        bgSourceDnLeft:"image://theme/btn_blue_dn"
        property alias textinput: userTextInput.text
        property int listId: -1
        dialogWidth: 300
        dialogHeight: 175
        opacity: 0

        TextEntry {
            id: userTextInput
            width: renameDialog.dialogWidth - 10
            height: 50
            anchors.centerIn: parent
        }

        onDialogClicked: {
            if (button == 1 && userTextInput.text){
                allListsModel.renameList( listId, userTextInput.text);
            }
            renameDialog.opacity =0;
        }
    }

    Component {
        id: deleteListModalDialogComponent
        TasksModalDialog{
            id: newListDialog
            leftButtonText: labelDelete
            rightButtonText:labelCancel
            dialogTitle: labelDeleteListDialog
            property bool pageBack: false
            property int listId: -1



            onDialogClicked: {
                if (button == 1){
                    editorList.removeList(listId);
                    if(pageBack) {
                        scene.previousApplicationPage();
                    }
                }
                dialogLoader.sourceComponent = undefined;
            }
        }
    }

    Component {
        id: deleteTaskModalDialogComponent
        TasksModalDialog{
            id: newTaskDialog
            leftButtonText: labelDelete
            rightButtonText:labelCancel
            dialogTitle: labelDeleteSingleTask
            property int taskId: -1

            checkBoxVisible: true
            checkBoxText: qsTr("Don't ask to confirm deleting tasks.")

            onDialogClicked: {
                if (button == 1){
                    if(checkBoxChecked)
                        qmlSettings.set("task_auto_delete", true);
                    editorList.removeTask(taskId);
                }
                dialogLoader.sourceComponent = undefined;
            }
        }
    }


    Component {
        id: customlistPageComponent
        ApplicationPage {
            id: customlistPage
            title: labelTasks
            onSearch: {
                customlistModel.filter = needle;

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
                return returnMe;
            }

            function addTaskFun() {taskListView.mode =1;}
            function selectMultiFun() {taskListView.mode = 2;}
            function renameListFun() {
                renameDialog.listId = customlistModel.listId;
                renameDialog.textinput = customlistModel.listName;
                renameDialog.opacity=1;
            }
            function deleteListFun() {
                scene.showModalDialog(deleteListModalDialogComponent);
                dialogLoader.item.parent = customlistPage.content;
                dialogLoader.item.listId = customlistModel.listId;
                dialogLoader.item.pageBack = true;
            }
            function deleteCompFun() {confirmDelComTasksDialog.opacity = 1;}

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
                runMe[index]();
            }

            menuContent: ActionMenu {
                id: actions
                model: makeActionMenuModel()

                onTriggered: {
                    onContextMenuClicked(index)
                    customlistPage.closeMenu();
                }//ontriggered
            }//action menu


            ModalDialog {
                id: confirmDelComTasksDialog
                dialogTitle: qsTr("Are you sure you want to delete the completed tasks?")
                leftButtonText: qsTr("Yes")
                rightButtonText: qsTr("No")
                bgSourceUpLeft:"image://theme/btn_blue_up"
                bgSourceDnLeft:"image://theme/btn_blue_dn"
                opacity: 0
                onDialogClicked: {
                    if(button ==1) {
                        customlistModel.removeCompletedTasksInList(customlistModel.listId);
                    }
                    confirmDelComTasksDialog.opacity = 0;
                }
            }

            TaskListView {
                id: taskListView
                parent:customlistPage.content
                anchors.fill:parent
                property alias title: categoryitem.title
                property alias viewModel: categoryitem.viewModel

                // Actions for create new task drop down
                Action {
                    id: dueSomedayAction
                    text:labelSomeday
                    onTriggered : {
                        duedateData.hasDuedate = false;
                        duedateData.dueDate = new Date();
                    }
                    checked: true
                }
                Action {
                    id: dueTodayAction
                    text:labelToday
                    onTriggered : {
                        duedateData.hasDuedate = true;
                        duedateData.dueDate = new Date();
                    }
                }
                Action {
                    id: dueTomorrowAction
                    text:labelTomorrow
                    onTriggered : {
                        duedateData.hasDuedate = true;
                        var date = new Date();
                        date.setDate(date.getDate() +1);
                        duedateData.dueDate = date;
                    }
                }
                Action {
                    id: dueNextWeekAction
                    text:labelNextWeek
                    onTriggered : {
                        duedateData.hasDuedate = true;
                        var date = new Date();
                        date.setDate(date.getDate() +7);
                        duedateData.dueDate = date;
                    }
                }
                Action {
                    id: dueCustomDateAction
                    text:labelSetDueDate
                    onTriggered : {
                        datePicker.show();
                    }
                }

                duedateActions: [dueSomedayAction, dueTodayAction, dueTomorrowAction,
                    dueNextWeekAction, dueCustomDateAction]
                model: CategoryItem {
                    id: categoryitem
                    viewModel:customlistModel
                    title: customlistModel.listName
                    titleColor:"#cbcbcb"
                }
                onModeChanged :{
                    taskDetailLoader.sourceComponent = undefined;
                }

                onClickedAtRow: {
                    if (taskListView.mode == 0)
                        showTaskDetailWindow(taskListView,x, y,payload);
                }
                onCheckedAtRow: {
                    editorList.setCompleted(payload.mTaskId,checked);
                }
                onPressAndHoldAtRow: {
                    var map = taskListView.mapToItem(customlistPage, x, y);
                    customListPageContextMenu.payload = payload;
                    customListPageContextMenu.mousePos = map;
                    customListPageContextMenu.displayContextMenu(map.x,map.y)
                    taskDetailLoader.sourceComponent = undefined;
                }
            }
            ContextMenu {
                id: customListPageContextMenu
                model: {
                    if(customlistModel.count > 1) {
                        return [labelViewDetail,labelEditTask, labelDeleteTask,labelSelectMultiple];
                    } else {
                        return [labelViewDetail,labelEditTask, labelDeleteTask];
                    }
                }

                menuWidth: 400
                property variant mousePos
                onTriggered: {
                    if (index == 0) { // view detail
                        showTaskDetailWindow(taskListView,mousePos.x, mousePos.y,payload);
                    } else if (index == 1) { // edit task
                        showTaskDetailWindow(taskListView,mousePos.x, mousePos.y,payload);
                        taskDetailLoader.item.editing = true;
                    } else if (index ==2) {  // delete task
                        if(qmlSettings.get("task_auto_delete")){
                            editorList.removeTask(payload.mTaskId);
                        } else {
                            scene.showModalDialog(deleteTaskModalDialogComponent);
                            dialogLoader.item.parent = customlistPage.content
                            dialogLoader.item.taskId = payload.mTaskId
                        }
                    } else if (index == 3) { // multiple selection mode
                        taskListView.mode = 2;
                    }
                }
            }
        }
    }
}
