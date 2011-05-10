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
#include <QMap>

class TasksTaskItem;

class TasksListItem
{
public:
        TasksListItem(const QString &name, QDateTime createdDateTime = QDateTime());

        static const int defaultListId;
        int id() const {return m_id; }
        QString name() const {return m_name; }
        void setName(const QString &name);

        QDateTime createdDateTime() const {return m_createdDateTime; }

        int incompleted() const {return m_incompleted; }
        int tasks() const;
        int hiddenTasks() const;
        TasksTaskItem *task(int i);
        void addTask(TasksTaskItem *task);
        void insertTask(TasksTaskItem *task, int idx);
        void removeTask(TasksTaskItem *task);
        void removeTask(int idx);
        void removeTasks();
        int indexOfTask(TasksTaskItem *task);
        void swapTasks(int src, int dest);
        void hideTask(int index, int oldIndex);
        void showHiddenTasks(int startIndex);
        void showHiddenTasks();
        QList<TasksTaskItem *> &taskList();
private:
        friend class TasksDatabase;
        friend class TasksDBEngine;
        static int ids;
        int m_id;
        QString m_name;
        QDateTime m_createdDateTime;
        QList<TasksTaskItem *> m_tasks;
        QMap<int, TasksTaskItem *> m_hiddenTasks;
        int m_incompleted;
};

#endif // TASKSLISTITEM_H
