/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSDATABASE_H
#define TASKSDATABASE_H

#include <QObject>
#include <QMap>
#include <QDate>
#include <QMutex>
#include "taskstaskitem.h"

class TasksListModel;
class TasksListItem;
class TasksDBEngine;

class TasksDatabase : public QObject
{
        Q_OBJECT
public:
        static TasksDatabase *instance();
        TasksDatabase(QObject *parent = 0);
        ~TasksDatabase();

        void renameList(int listId, const QString &name);
        void addList(const QString &name);
        void removeList(int listId);

        void addTask(int listId, const QString &task, const QString &notes, bool complete,
                     bool hasDueDate, const QDate &dueDate,
                     TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                     const QStringList &urls, const QStringList &attachments);
        void editTask(int taskId, int listId, const QString &task, const QString &notes,
                      bool hasDueDate, const QDate &dueDate,
                      TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                      const QStringList &urls, const QStringList &attachments);
        void removeCompletedTasksInList(int listId);
        void removeAllCompletedTasks();
        void setCompleted(int taskId, bool completed);
        void removeTask(int taskId, bool store = true);
        void removeTasks(const QStringList &staskIds);
        void reorderTask(int taskId, int destidx);
        void hideTasks(const QStringList &taskIds);
        void showHiddenTasks(int listId, int startIndex);
        void showHiddenTasksOldPositions(int listId);
        void saveReorder(int listId);
        void moveTasksToList(const QStringList &staskIds, int destListId);
        void commitAddedTasks();
        void rollbackAddedTasks();

signals:
        void listAdded(TasksListItem *list);
        void beginInsertRow(int r);
        void endInsertRow();
        void beginRemoveRow(int r);
        void endRemoveRow();
        void updateRow(int r);

protected:
        void timerEvent(QTimerEvent *event);

private:
        int findList(int listId);
        void setTaskComplited(TasksTaskItem *task);
        void setTaskUncomplited(TasksTaskItem *task);
        void load();
        void createList(const QString &name);
        TasksTaskItem *createTask(TasksListItem *list, const QString &task, const QString &notes, bool complete,
                                  bool hasDueDate, const QDate &dueDate,
                                  TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                                  const QStringList &urls, const QStringList &attachments, const QDateTime &createdDateTime);
        int findIndexForUpcoming(TasksTaskItem *t);
        int findIndexForOverdue(TasksTaskItem *t);
        int findIndexForSomeday(TasksTaskItem *t);
        void insertTaskToAll(TasksTaskItem *t);
        void insertTasks(const QList<TasksTaskItem *> &tasks);
        void updateDueTasks(bool topast = false);

private:
        static TasksDatabase *tasksDatabaseInstance;
        friend class TasksListModel;
        friend class TasksDBEngine;
        TasksDBEngine *m_dbEngine;
        int m_timerId;
        QDate m_currentDate;
        QMutex m_lock;
        QList <TasksListModel *> m_models;
        // List of lists objects
        // First is "Default List"
        // Others sorted by datetime of creation
        QList<TasksListItem *> m_lists;
        // List of all tasks with due date
        // Sorted from earliest to latest due date
        //QList<TasksTaskItem *> m_dueTasks;
        QList<TasksTaskItem *> m_overdueTasks;
        QList<TasksTaskItem *> m_upcomingTasks;
        // List of all tasks without due date
        // Sorted by datetime of creation
        QList<TasksTaskItem *> m_somedayTasks;
        // New tasks list. First add tasks to list
        // and save after.
        QList<TasksTaskItem *> m_newTasks;
        // Id maps
        QMap<int, TasksListItem *> m_listsMap;
        QMap<int, TasksTaskItem *> m_tasksMap;
        // All tasks
        QList<TasksTaskItem *> m_allTasks;
};

#define Database TasksDatabase::instance()

#endif // TASKSDATABASE_H
