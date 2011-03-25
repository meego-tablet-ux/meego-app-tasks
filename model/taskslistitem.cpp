/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "taskslistitem.h"

#include "taskstaskitem.h"

const int TasksListItem::defaultListId = 0;
int TasksListItem::ids = TasksListItem::defaultListId;

TasksListItem::TasksListItem(const QString &name, QDateTime createdDateTime)
        : m_name(name)
        , m_incompleted(0)
        , m_createdDateTime(createdDateTime)
{
        m_id = ids;
        ids++;
        if (m_createdDateTime.isNull())
                m_createdDateTime = QDateTime::currentDateTime();
}

void TasksListItem::setName(const QString &name)
{
        m_name = name;
}

int TasksListItem::tasks() const
{
        return m_tasks.count();
}

int TasksListItem::hiddenTasks() const
{
    return m_hiddenTasks.count();
}

TasksTaskItem *TasksListItem::task(int i)
{
        if (i < 0 || i >= m_tasks.count())
                return 0;
        return m_tasks[i];
}

void TasksListItem::addTask(TasksTaskItem *task)
{
        m_tasks << task;
        if (!task->isComplete())
                m_incompleted++;
}

void TasksListItem::insertTask(TasksTaskItem *task, int idx)
{
        m_tasks.insert(idx, task);
        if (!task->isComplete())
                m_incompleted++;
}

void TasksListItem::removeTask(TasksTaskItem *task)
{
        int idx = m_tasks.indexOf(task);
        if (idx == -1)
                return;
        if (!task->isComplete())
                m_incompleted--;
        m_tasks.removeAt(idx);
}

void TasksListItem::removeTask(int idx)
{
        if (idx < 0 || idx >= m_tasks.count())
                return;
        if (!m_tasks[idx]->isComplete())
                m_incompleted--;
        m_tasks.removeAt(idx);
}

void TasksListItem::removeTasks()
{
        while (!m_tasks.isEmpty()) {
                TasksTaskItem * task = m_tasks.takeLast();
                if (!task->isComplete())
                        m_incompleted--;
                delete task;
        }
}

int TasksListItem::indexOfTask(TasksTaskItem *task)
{
        return m_tasks.indexOf(task);
}

void TasksListItem::swapTasks(int src, int dest)
{
     m_tasks.swap(src, dest);
}

void TasksListItem::hideTask(int index, int oldIndex)
{
    m_hiddenTasks[oldIndex] = m_tasks.takeAt(index);
}

void TasksListItem::showHiddenTasks(int startIndex)
{
    const int count = m_hiddenTasks.count();
    QList<TasksTaskItem *> values = m_hiddenTasks.values();

    for (int i=count-1; i>=0; --i) {
        m_tasks.insert(startIndex, values.at(i));
    }

    m_hiddenTasks.clear();
}

void TasksListItem::showHiddenTasks()
{
    QMapIterator<int, TasksTaskItem *> i(m_hiddenTasks);
     while (i.hasNext()) {
         i.next();
         m_tasks.insert(i.key(), i.value());
     }

     m_hiddenTasks.clear();
}

QList<TasksTaskItem *> TasksListItem::taskList()
{
    return m_tasks;
}
