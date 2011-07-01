/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSDBENGINE_H
#define TASKSDBENGINE_H

#include <ekcal/ekcal-storage.h>
#include <QObject>
#include <QMap>

class TasksDatabase;
class QSettings;
class TasksTaskItem;
class TasksListItem;

class TasksDBEngine: public eKCal::StorageObserver
{

public:
        TasksDBEngine(TasksDatabase *db);
        ~TasksDBEngine();

        void loadLists();
        void saveLists();
        void startLoadingTasks();
        void addTasks(const QList<TasksTaskItem> &tasks);
        void updateTask(const TasksTaskItem &task);
        void removeTask(const TasksTaskItem &task);
        void removeTasks(const QList<TasksTaskItem> &tasks);
        void updateTasksOrder(const TasksListItem &list);
        void updateTasksList(const TasksListItem &list);
        void updateTasksList(const QList<TasksTaskItem> &tasks);
        int taskIdByUid(const QString &uid);

protected:
        virtual void loadingComplete(bool success, const QString &error);
        virtual void savingComplete(bool success, const QString &error);

private:
        void setTaskValues(const TasksTaskItem &task, const KCalCore::Todo::Ptr &todo);
        void loadTasks();

private:
        static const QString tasksNotebook;
        TasksDatabase *m_db;
        QSettings *m_settings;
        eKCal::EStorage::Ptr m_storage;
        KCalCore::Calendar::Ptr m_calendar;
        QMap<int, QString> m_uids;
};

#endif // TASKSDBENGINE_H
