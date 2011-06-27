/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSTASKITEM_P_H
#define TASKSTASKITEM_P_H

#include <QSharedData>
#include <QDate>
#include "taskslistmodel.h"

class TasksListItem;

class TasksTaskItemData : public QSharedData {
private:
        static int ids;
public:
        TasksTaskItemData(const TasksListItem &list): list(list), id(ids++),
          complete(false), hasDueDate(false), reminderType(TasksListModel::NoReminder) {}

        TasksListItem list;
        int id;
        QString task;
        QString notes;
        bool complete;
        bool hasDueDate;
        QDate dueDate;
        TasksListModel::ReminderType reminderType;
        QDate reminderDate;
        QDateTime createdDateTime;
        QStringList urls;
        QStringList attachments;
};

int TasksTaskItemData::ids = 0;

#endif // TASKSTASKITEM_P_H
