/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "taskstaskitem.h"
#include "taskstaskitem_p.h"

TasksTaskItem::TasksTaskItem(const TasksListItem &list): d(new TasksTaskItemData(list))
{
}

TasksTaskItem::TasksTaskItem(const TasksTaskItem &other): d(other.d) {}

TasksTaskItem::~TasksTaskItem() {}

TasksTaskItem& TasksTaskItem::operator=(const TasksTaskItem& other)
{
        d = other.d;
        return *this;
}

void TasksTaskItem::setList(const TasksListItem &list)
{
        d->list = list;
}

void TasksTaskItem::setTask(const QString &task)
{
        d->task = task;
}

void TasksTaskItem::setNotes(const QString &notes)
{
        d->notes = notes;
}

void TasksTaskItem::setComplete(bool complete)
{
        d->complete = complete;
}

void TasksTaskItem::setHasDueDate(bool hasDueDate)
{
        d->hasDueDate = hasDueDate;
}

void TasksTaskItem::setDueDate(const QDate &dueDate)
{
        d->dueDate = dueDate;
}

void TasksTaskItem::setReminderType(TasksListModel::ReminderType reminderType)
{
        d->reminderType = reminderType;
}

void TasksTaskItem::setReminderDate(const QDate &reminderDate)
{
        d->reminderDate = reminderDate;
}

void TasksTaskItem::setCreatedDateTime(const QDateTime &createdDateTime)
{
        d->createdDateTime = createdDateTime;
}

void TasksTaskItem::setUrls(const QStringList &urls)
{
        d->urls = urls;
}

void TasksTaskItem::setAttachments(const QStringList &attachments)
{
        d->attachments = attachments;
}

int TasksTaskItem::id() const
{
        return d->id;
}

QString TasksTaskItem::task() const
{
        return d->task;
}

QString TasksTaskItem::notes() const
{
        return d->notes;
}

bool TasksTaskItem::isComplete() const
{
        return d->complete;
}

bool TasksTaskItem::hasDueDate() const
{
        return d->hasDueDate;
}

QDate TasksTaskItem::dueDate() const
{
        return d->dueDate;
}

TasksListModel::ReminderType TasksTaskItem::reminderType() const
{
        return d->reminderType;
}

QDate TasksTaskItem::reminderDate() const
{
        return d->reminderDate;
}

QDateTime TasksTaskItem::createdDateTime() const
{
        return d->createdDateTime;
}

const QStringList & TasksTaskItem::urls() const
{
        return d->urls;
}

const QStringList & TasksTaskItem::attachments() const
{
        return d->attachments;
}

TasksListItem TasksTaskItem::list() const
{
        return d->list;
}

bool TasksTaskItem::isValid() const
{
        return d->list.isValid();
}

bool TasksTaskItem::operator ==(const TasksTaskItem &other) const
{
        return d->id == other.d->id;
}

uint qHash(const TasksTaskItem &key)
{
  return qHash(key.id());
}
