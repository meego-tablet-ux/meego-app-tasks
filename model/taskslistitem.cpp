/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "taskslistitem.h"
#include "taskslistitem_p.h"
#include "taskstaskitem.h"


TasksListItem::TasksListItem(const QString &name, const QDateTime &createdDateTime):
  d(new TasksListItemData(name))
{
        d->name = name;
        d->createdDateTime = createdDateTime.isNull() ? QDateTime::currentDateTime() : createdDateTime;
}

TasksListItem::TasksListItem(const TasksListItem &other): d(other.d) {}

TasksListItem::~TasksListItem() {}

TasksListItem& TasksListItem::operator=(const TasksListItem& other)
{
  d = other.d;
  return *this;
}

void TasksListItem::setName(const QString &name)
{
        d->name = name;
}

QList<TasksTaskItem> TasksListItem::tasks() const
{
        return d->tasks;
}

/** Returns the number of tasks in the list */
int TasksListItem::count() const
{
  return d->tasks.count();
}

int TasksListItem::hiddenTasks() const
{
    return d->hiddenTasks.count();
}

TasksTaskItem TasksListItem::task(int i) const
{
        if (i < 0 || i >= d->tasks.count())
                return TasksTaskItem();
        return d->tasks[i];
}

void TasksListItem::addTask(const TasksTaskItem& task)
{
        d->tasks << task;
        if (!task.isComplete())
                d->incompleted++;
}

void TasksListItem::insertTask(const TasksTaskItem &task, int idx)
{
        d->tasks.insert(idx, task);
        if (!task.isComplete())
                d->incompleted++;
}

void TasksListItem::removeTask(const TasksTaskItem &task)
{
        int idx = d->tasks.indexOf(task);
        if (idx == -1)
                return;
        if (!task.isComplete())
                d->incompleted--;
        d->tasks.removeAt(idx);
}

void TasksListItem::removeTask(int idx)
{
        if (idx < 0 || idx >= d->tasks.count())
                return;
        if (!d->tasks[idx].isComplete())
                d->incompleted--;
        d->tasks.removeAt(idx);
}

void TasksListItem::removeTasks()
{
        while (!d->tasks.isEmpty()) {
                TasksTaskItem task = d->tasks.takeLast();
                if (!task.isComplete())
                        d->incompleted--;
        }
}

int TasksListItem::indexOfTask(const TasksTaskItem &task) const
{
        return d->tasks.indexOf(task);
}

void TasksListItem::swapTasks(int src, int dest)
{
     d->tasks.swap(src, dest);
}

void TasksListItem::hideTask(int index, int oldIndex)
{
    d->hiddenTasks[oldIndex] = d->tasks.takeAt(index);
}

void TasksListItem::showHiddenTasks(int startIndex)
{
    const int count = d->hiddenTasks.count();
    QList<TasksTaskItem> values = d->hiddenTasks.values();

    for (int i=count-1; i>=0; --i) {
        d->tasks.insert(startIndex, values.at(i));
    }

    d->hiddenTasks.clear();
}

void TasksListItem::showHiddenTasks()
{
    QMapIterator<int, TasksTaskItem> i(d->hiddenTasks);
     while (i.hasNext()) {
         i.next();
         d->tasks.insert(i.key(), i.value());
     }

     d->hiddenTasks.clear();
}

QList<TasksTaskItem> &TasksListItem::taskList() const
{
        return d->tasks;
}

int TasksListItem::incompleted() const
{
        return d->incompleted;
}

int TasksListItem::id() const
{
        return d->id;
}

QDateTime TasksListItem::createdDateTime() const
{
        return d->createdDateTime;
}

QString TasksListItem::name() const
{
        return d->name;
}

void TasksListItem::incrementIncompleted()
{
        ++(d->incompleted);
}

void TasksListItem::decrementIncompleted()
{
        --(d->incompleted);
}

bool TasksListItem::isValid() const
{
        return !d->name.isEmpty();
}

bool TasksListItem::operator ==(const TasksListItem &other) const
{
        return d->id == other.id();
}
