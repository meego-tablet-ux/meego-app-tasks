/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSLISTITEM_H
#define TASKSLISTITEM_H

#include <QString>
#include <QDateTime>
#include <QList>
#include <QExplicitlySharedDataPointer>

class TasksListItemData;
class TasksTaskItem;

class TasksListItem
{
public:
        TasksListItem(const QString &name = QString(), const QDateTime &createdDateTime = QDateTime());
        TasksListItem(const TasksListItem &other);
        ~TasksListItem();
        TasksListItem& operator=(const TasksListItem& other);
        bool operator==(const TasksTaskItem& other) const;

        bool isValid() const;
        int id() const;
        QString name() const;
        void setName(const QString &name);
        QDateTime createdDateTime() const;
        void incrementIncompleted();
        void decrementIncompleted();
        int incompleted() const;
        QList<TasksTaskItem> tasks() const;
        int count() const;
        int hiddenTasks() const;
        TasksTaskItem task(int i) const;
        void addTask(const TasksTaskItem &task);
        void insertTask(const TasksTaskItem &task, int idx);
        void removeTask(const TasksTaskItem &task);
        void removeTask(int idx);
        void removeTasks();
        int indexOfTask(const TasksTaskItem &task) const;
        void swapTasks(int src, int dest);
        void hideTask(int index, int oldIndex);
        void showHiddenTasks(int startIndex);
        void showHiddenTasks();
        QList<TasksTaskItem> &taskList() const;
private:
        QExplicitlySharedDataPointer<TasksListItemData> d;
};

#endif // TASKSLISTITEM_H
