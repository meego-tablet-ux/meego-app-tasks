/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

import Qt 4.7

Item {
    id: window
    property string text: ""
    property string iconSource: ""
    property string badgeText: ""
    property bool   checked: false
    property variant payload
    signal triggered()
}
