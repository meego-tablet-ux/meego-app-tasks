/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: container
    width: 200
    height: 40
    property date date
    date: new Date()

    Rectangle {
        id: dateBt
        height: parent.height
        width: parent.width/5
        color: "gray"
        Rectangle {
            width: parent.width
            height:parent.height/2
            anchors.bottom:parent.bottom
            color:"Silver"
        }
        anchors.left: parent.left
        Text {
            id: day
            text: date.getDate()
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseY < parent.height/2) {
                    var d = date;
                    d.setDate(d.getDate() + 1);
                    date = d;
                }else {
                    var d = date;
                    d.setDate(d.getDate() - 1);
                    date = d;
                }
            }
        }
    }
    Rectangle {
        id: monthBt
        height: parent.height
        color: "gray"
        anchors.left: dateBt.right
        anchors.right: yearBt.left
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        Rectangle {
            width: parent.width
            height:parent.height/2
            anchors.bottom:parent.bottom
            color:"Silver"
        }
        Text {
            id: month
            text: Qt.formatDate(date, "MMMM")
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseY < parent.height/2) {
                    var d = date;
                    d.setMonth(d.getMonth() + 1);
                    date = d;
                }else {
                    var d = date;
                    d.setMonth(d.getMonth() - 1);
                    date = d;
                }
            }
        }
    }
    Rectangle {
        id: yearBt
        height: parent.height
        width: parent.width/4
        color: "gray"
        anchors.right: parent.right
        Rectangle {
            width: parent.width
            height:parent.height/2
            anchors.bottom:parent.bottom
            color:"Silver"
        }
        Text {
            id: year
            text: Qt.formatDate(date, qsTr("yyyy"))
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (mouseY < parent.height/2) {
                    var d = date;
                    d.setFullYear(d.getFullYear() + 1);
                    date = d;
                }else {
                    var d = date;
                    d.setFullYear(d.getFullYear() - 1);
                    date = d;
                }
            }
        }
    }

}
