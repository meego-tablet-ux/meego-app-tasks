/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7


Item {
    id: draggable
    x:100; y:100
    width:100
    height:100

    property int mouseState:0

    property variant mousePos

    signal clicked(int mouseX, int mouseY)
    signal doubleClicked(int mouseX, int mouseY)
    signal longPressAndHold(int mouseX, int mouseY)
    signal pressedAndMoved(int mouseX, int mouseY)
    signal longlongPressAndHold(int mouseX, int mouseY)
    signal released(int mouseX, int mouseY)

  //  property bool dbClicked
  //  dbClicked: false

    Timer {
        id:longTimer
        interval: 800; running:false; repeat:false
        onTriggered: {
            draggable.mouseState = 2;
            draggable.longlongPressAndHold(draggable.mousePos.x, draggable.mousePos.y);
        }
    }

    Timer {
        id: clickTimer
        interval:160; running: false; repeat: false
        onTriggered: {
          //  if (draggable.dbClicked) {
          //      draggable.dbClicked = !dbClicked;
          //  }else{
                draggable.clicked(draggable.mousePos.x, draggable.mousePos.y);
          //  }
        }
    }

    MouseArea {
        anchors.fill:parent
        onClicked: {
            draggable.mousePos = Qt.point(mouseX,mouseY);
            clickTimer.start();
           // draggable.clicked(mouseX,mouseY);
        }
        onDoubleClicked :{
            draggable.doubleClicked(mouseX,mouseY);
          //  draggable.dbClicked = true;
            clickTimer.stop();
        }

        onPressAndHold: {
            draggable.mouseState = 1;
            draggable.longPressAndHold(mouseX,mouseY);
            longTimer.start();
        }

        onPressed: {
            draggable.mousePos = Qt.point(mouseX,mouseY);
        }
        onPositionChanged: {
            draggable.pressedAndMoved(mouseX,mouseY);
            // we can tolerate the movement in 20x20 rect
            if (Math.abs(mouseX - draggable.mousePos.x) >10 || Math.abs(mouseY - draggable.mousePos.y)> 10) {
                longTimer.stop();
            }
        }

        onReleased :{
            longTimer.stop();
            draggable.mouseState = 0;
            draggable.released(mouseX,mouseY);
        }
    }
}

