/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSDBENGINE_H
#define TASKSDBENGINE_H

#include <extendedcalendar.h>
#include <sqlitestorage.h>
class TasksDatabase;
class QSettings;
class TasksTaskItem;
class TasksListItem;
using namespace mKCal;

class TasksDBEngine
{
public:
        TasksDBEngine(TasksDatabase *db);
        ~TasksDBEngine();

        void loadLists();
        void saveLists();
        void loadTasks();
        void addTask(TasksTaskItem *task);
        void updateTask(TasksTaskItem *task);
        void removeTask(TasksTaskItem *task);
        void removeTasks(QList<TasksTaskItem *> tasks);
        void updateTasksOrder(TasksListItem *list);
        void updateTasksList(TasksListItem *list);
        void updateTasksList(QList<TasksTaskItem *> tasks);
        void commitTasks();

private:
        void setTaskValues(TasksTaskItem *task, const KCalCore::Todo::Ptr &todo);

private:
        static const QString tasksNotebook;
        TasksDatabase *m_db;
        QSettings *m_settings;
        ExtendedCalendar *m_calendar;
        ExtendedCalendar::Ptr m_calendarPtr;
        //SqliteStorage *m_storage;
        ExtendedStorage::Ptr m_storage;
        Notebook *m_notebook;
        QString m_nuid;
        QMap<int, KCalCore::Todo::Ptr> m_tasks;
        QMap<int, QString> m_uids;
};

#endif // TASKSDBENGINE_H
