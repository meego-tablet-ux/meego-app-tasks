/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSTASKITEM_H
#define TASKSTASKITEM_H

#include "taskslistmodel.h"
#include <QStringList>
#include <QExplicitlySharedDataPointer>

class TasksListItem;
class TasksTaskItemData;

class TasksTaskItem
{
public:
        TasksTaskItem(const TasksListItem &list = TasksListItem());
        TasksTaskItem(const TasksTaskItem &other);
        ~TasksTaskItem();
        TasksTaskItem& operator=(const TasksTaskItem& other);
        bool operator==(const TasksTaskItem& other) const;

        bool isValid() const;
        TasksListItem list() const;
        int id() const;
        QString task() const;
        QString notes() const;
        bool isComplete() const;
        bool hasDueDate() const;
        QDate dueDate() const;
        TasksListModel::ReminderType reminderType() const;
        QDate reminderDate() const;
        QDateTime createdDateTime() const;
        const QStringList &urls() const;
        const QStringList &attachments() const;

        void setList(const TasksListItem &list);
        void setTask(const QString &task);
        void setNotes(const QString &notes);
        void setComplete(bool complete);
        void setHasDueDate(bool hasDueDate);
        void setDueDate(const QDate &dueDate);
        void setReminderType(TasksListModel::ReminderType reminderType);
        void setReminderDate(const QDate &reminderDate);
        void setCreatedDateTime(const QDateTime &createdDateTime);
        void setUrls(const QStringList &urls);
        void setAttachments(const QStringList &attachments);
private:
        QExplicitlySharedDataPointer<TasksTaskItemData> d;
};

uint qHash(const TasksTaskItem &key);

#endif // TASKITEM_H
