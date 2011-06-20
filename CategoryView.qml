/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7
import MeeGo.App.Tasks 0.1
import MeeGo.Ux.Components.Common 0.1
import MeeGo.Ux.Gestures 0.1

Item {
    id: container
    width: 640
    height: 480
    property int titleHeight: 60
    property variant model
    property int rowHeight: 70
    property int textHMargin: 20
    property bool forceShowTitle: false
    property alias contentX: area.contentX
    property alias contentY: area.contentY

   // signal clickedAtRow(int category, int row, bool repeat)
    signal clickedAtRow(int index, int x , int y, variant payload)
    signal checkedAtRow(int index, variant payload,bool checked)
    signal pressAndHoldAtRow(int index, int x, int y, variant payload)
    signal closeDetailOfTask(int taskId)
    function getYValue(index) {
        if (index >= viewsRepeater.count)
            return 0;
        var ty = titles.children[index].height;
        for (var i = 0 ; i< index; i++) {
            ty = ty + titles.children[i].height + allViews.children[i].height;
        }
        return ty;
    }
    function getTitleMinValue(index)
    {
        var min = 0;
        for (var i = 0; i< index; i++){
            min += titles.children[i].height;
        }
        return min;
    }
    function getTitleMaxValue(index)
    {
        var max = area.height;
        for (var i = index; i< model.length; i++) {
            max -= titles.children[i].height;
        }
        return max;
    }
    function getTitleYValue(index) {
        // list.y is the height of the previous lists
        var top = -area.contentY;
        if (!allViews.children[index])
            return top;
        var list = allViews.children[index].y;
        var title = titles.children[index]
        if (list == undefined || title == undefined)
            return 0
        var min = getTitleMinValue(index);
        var max = getTitleMaxValue(index);

        if (top + list   < min) {
            return min;
        }
        if (top + list  > max){
            return max;
        }
        return top + list  ;
    }
    function titleText(index){
        //console.log()
        if (!allViews.children.length)
            return "";
        var collapsed = allViews.children[index].collapsed;
        var title = model[index].title;
        if (collapsed) {
           //: This line is used for indication amount of tasks when a category is collapsed.
           title =  qsTr("%1 (%2)").arg(title).arg(model[index].viewModel.count);
        }
        return title;
    }

    function titleCollapsedText(index, collapsed) {
        var title = model[index].title;
        if (collapsed)
            //: This line is used for indication amount of tasks when a category is collapsed.
           title =  qsTr("%1 (%2)").arg(title).arg(model[index].viewModel.count);
        return title;
    }

    function isZeroModel(index) {
        if (index >= model.length)
            return true;
        return model[index].viewModel.count == 0;
    }

    function ensureShowingList(index) {
        var y = -allViews.children[index].y // - getTitleMinValue(index)  //- titles.children[index].height;
        var maxY = area.contentHeight - area.height
        var minY = 0;
        y =  Math.min(maxY, y)
        y =  Math.max(minY, y);
        console.log(y);

        area.contentY = y;
    }
    function updateTitles()
    {
        for (var i = 0; i < container.model.length; ++i)
            titles.children[i].updateTitleText();
    }
    function collapseItem(index, collapse)
    {
        allViews.children[index].collapsed = collapse;
    }
    function itemCollapsed(index)
    {
        return allViews.children[index].collapsed;
    }

    onVisibleChanged: {
        if (visible)
            updateTitles();
    }

    QtObject {
        id: privateData
        property int selectedCategory: -1
        property int selectedRow: -1
    }

    Flickable {
        id: area
        width: container.width
        height: container.height
        contentWidth: container.width
        contentHeight: views.height
        interactive: contentHeight > height
        clip: true
        Item {
            id: views
            width: container.width
            height:childrenRect.height
            Column {
                id: allViews
                Repeater {
                    id: viewsRepeater
                    model: container.model
                    delegate:viewComponent
                }
            }
        }

        property bool movementEnded: true

        onMovementStarted: movementEnded = false
        onMovementEnded: movementEnded = true
    }
    Item {
        id: titles
        anchors.fill: parent

        Repeater {
            id: titleRepeater
            model: container.model
            delegate: titleComponent
        }
    }

    Theme {
        id: theme
    }

    Component {
        id: titleComponent
        Rectangle {
            property alias text: text.text

            id: titleRect
            width: container.width
            height: visible? container.titleHeight:0
            x: 0
            y: getTitleYValue(index)
            visible:  forceShowTitle || (container.model[index].viewModel.count != 0)
            Connections {
                target: container.model[index].viewModel
                onCountChanged: {
                    titleRect.visible =  forceShowTitle ||(container.model[index].viewModel.count != 0)
                }
            }

            function updateTitleText()
            {
                var prevIndex = index - 1;
                var nextIndex = index + 1;
                if (prevIndex < 0 || nextIndex >= titles.children.length)
                    return;

                var prevIndexY = titles.children[prevIndex].y + titles.children[prevIndex].height;
                var nextIndexY = titles.children[nextIndex].y

                if (y == prevIndexY) {
                    titles.children[prevIndex].text = titleCollapsedText(prevIndex, true);
                } else if (y > prevIndexY && titles.children[prevIndex].text == titleCollapsedText(prevIndex, true)) {
                    titles.children[prevIndex].text = titleCollapsedText(prevIndex, false);
                }
                if (y + height == nextIndexY || (y + height == container.height && titles.children[index].children.length)) {
                    titles.children[index].text = titleCollapsedText(index, true);
                } else {
                    titles.children[index].text = titleCollapsedText(index, false);
                }
            }

            onYChanged: {
                if (area.movementEnded)
                    return;

                updateTitleText();
            }

            color:modelData.titleColor
            Text {
                id: text
                anchors.fill: parent
                anchors.leftMargin: textHMargin
                text: titleText(index)
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                //font.bold: true
                font.pixelSize: theme.fontPixelSizeLarge
                elide: Text.ElideRight
            }
            Image {
                id: separator_top
                width: parent.width
                anchors.bottom: parent.top
                source: "image://themedimage/images/tasks/ln_grey_l"
            }
            Image {
                id: separator_bt
                width: parent.width
                anchors.top: parent.bottom
                source: "image://themedimage/images/tasks/ln_grey_l"
            }
            GestureArea {
                anchors.fill: parent
                Tap {
                    onFinished: {
                         allViews.children[index].collapsed = !allViews.children[index].collapsed;

                         text.text = titleText(index);
                         if (!allViews.children[index].collapsed) {
                             ensureShowingList(index);
                         }
                    }
                }
            }

            Connections {
                target: allViews.children[index]
                onCollapsedChanged: {
                    text.text = titleText(index);
                    if (!allViews.children[index].collapsed) {
                        ensureShowingList(index);
                    }
                }
            }

//            MouseArea {
//                anchors.fill: parent

//                onClicked: {
//                    allViews.children[index].collapsed = !allViews.children[index].collapsed;

//                    text.text = titleText(index);
//                    if (!allViews.children[index].collapsed) {
//                        ensureShowingList(index);
//                    }
//                }
//            }
        }
    }

    Component {
        id: viewComponent
        Item {
            id: viewItem
            width: container.width
            height:  (( modelData.viewModel.count > 0 ||forceShowTitle)? titleHeight:0) + (collapsed? 0: view.viewHeight)

            property bool collapsed: false

            Connections {
                target: modelData.viewModel
                onFilterChanged: {
                    viewItem.visible = !isZeroModel(index);
                    titles.children[index].visible = viewItem.visible;
                    container.updateTitles();
                }
            }

            ListView {
                id: view
                width: container.width
                height:viewItem.collapsed ? 0:  viewHeight
                clip: true
                x: 0
                y: titleHeight

                interactive: false
                property int viewHeight: count * (container.rowHeight )
                property int categoryIndex: index

                model: modelData.viewModel
                delegate : cellComponent
            }
        }
    }

    Component {
        id: cellComponent
        Item {
            id: dinstance
            width: container.width
            height: container.rowHeight

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
            property string mListName: listName;

            Rectangle {
                color: "white"
                anchors.fill: parent
            }

            Text {
                id: titleText
                text: mTask
                width: (dinstance.width - rowHeight - 6*textHMargin - duedateText.width - overdueIcon.width)
                height: dinstance.height
                x: rowHeight + textHMargin
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                font.strikeout: mCompleted
                font.pixelSize: theme.fontPixelSizeLarge
            }

            Text {
                id: duedateText
                text:   getFormattedDate(mDueDate)
                anchors.right: parent.right
                anchors.rightMargin:textHMargin
                font.pixelSize: theme.fontPixelSizeLarge
                height: dinstance.height
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                color: theme.fontColorNormal
                visible: mHasDueDate
            }

            Image {
                id: reminderIcon
                source: "image://themedimage/images/tasks/icn_alarmclock"
                anchors.right: duedateText.left
                anchors.rightMargin:textHMargin
                visible: mHasDueDate && (mReminderType!= TasksListModel.NoReminder)
                anchors.verticalCenter: parent.verticalCenter
            }

            Image {
                id: separator
                width: parent.width
                anchors.bottom: parent.bottom
                source: "image://themedimage/images/tasks/ln_grey_l"
            }
            Image {
                id: highlight
                source: "image://themedimage/images/tasks/bg_highlightedpanel_l"
                anchors.fill: parent
                visible: (view.categoryIndex == privateData.selectedCategory ) &&
                         (index == privateData.selectedRow)
            }

            GestureArea {
                anchors.fill: parent
                Tap {
                    onFinished: {
                        privateData.selectedCategory = view.categoryIndex;
                        privateData.selectedRow = index;
                        var map = mapToItem(null, gesture.position.x, gesture.position.y);
                        container.clickedAtRow(index, map.x, map.y,dinstance);
                    }
                }
                TapAndHold {
                    onFinished: {
                        var map = mapToItem(null, gesture.position.x, gesture.position.y);
                        container.pressAndHoldAtRow(index, map.x, map.y, dinstance);
                    }
                }
            }

//            MouseArea {
//                anchors.fill: parent
//                onClicked:  {
//                    privateData.selectedCategory = view.categoryIndex;
//                    privateData.selectedRow = index;
//                    var map = mapToItem(null, mouseX, mouseY);
//                    container.clickedAtRow(index, map.x, map.y,dinstance);
//                }
//                onPressAndHold: {
//                    var map = mapToItem(null, mouseX, mouseY);
//                    container.pressAndHoldAtRow(index, map.x, map.y,dinstance);
//                }
//            }

            Checkbox {
                id: box
                x: (rowHeight - width)/2
                y: (rowHeight - height)/2
                checked: mCompleted
                onClicked: {
                    box.checked = !box.checked
                     container.closeDetailOfTask(mTaskId)
                }
                Binding {
                    target: box
                    property: "checked"
                    value: mCompleted
                }

                onCheckedChanged: PropertyAnimation {
                    target: dinstance
                    property: "opacity"
                    duration: 200
                    to: 0
                }
            }

            Image {
                id: vDivider
                source: "image://themedimage/images/tasks/ln_grey_p"
                height: parent.height
                width: 1
                anchors.left: box.right
                anchors.leftMargin: 20
            }

            Image {
                id: overdueIcon
                source: "image://themedimage/images/tasks/icn_overdue_red"
                anchors.verticalCenter: parent.verticalCenter
                x: titleText.x + titleText.paintedWidth + 20
                visible: isOverdue(mDueDate) && mHasDueDate
            }
            states: [
                State {
                    name: "hide"
                    when: box.checked
                    PropertyChanges {
                        target: dinstance
                        opacity: 0
                    }
                },
                State {
                    name: "show"
                    when: !box.checked
                    PropertyChanges {
                        target: dinstance
                        opacity: 1

                    }
                }
            ]
            transitions: [
                Transition {
                    reversible: true
                     SequentialAnimation {
                        PropertyAnimation {
                            property :"opacity"
                            duration: 700
                        }
                        ScriptAction {
                            script: {
                                if (state == "hide") {
                                    container.checkedAtRow(index, dinstance, box.checked);
                                }
                            }
                        }
                     }
                }
            ]

        }
    }
}
