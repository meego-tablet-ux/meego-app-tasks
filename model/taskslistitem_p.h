/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSLISTITEM_P_H
#define TASKSLISTITEM_P_H

#include <QSharedData>
#include <QDateTime>
#include <QMap>

class TasksTaskItem;

class TasksListItemData: public QSharedData {
private:
        static int ids;

public:
        TasksListItemData(const QString &name = QString()): id(ids++), name(name),
          incompleted(0) {}

        int id;
        QString name;
        QDateTime createdDateTime;
        QList<TasksTaskItem> tasks;
        QMap<int, TasksTaskItem> hiddenTasks;
        int incompleted;
};

int TasksListItemData::ids = 0;

#endif // TASKSLISTITEM_P_H
