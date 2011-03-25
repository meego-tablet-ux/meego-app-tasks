/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "taskstaskitem.h"

int TasksTaskItem::ids = 0;

TasksTaskItem::TasksTaskItem(TasksListItem *list)
      : m_list(list)
{
        m_id = ids;
        ids++;
}

void TasksTaskItem::setList(TasksListItem *list)
{
        m_list = list;
}

void TasksTaskItem::setTask(const QString &task)
{
        m_task = task;
}

void TasksTaskItem::setNotes(const QString &notes)
{
        m_notes = notes;
}

void TasksTaskItem::setComplete(bool complete)
{
        m_complete = complete;
}

void TasksTaskItem::setHasDueDate(bool hasDueDate)
{
        m_hasDueDate = hasDueDate;
}

void TasksTaskItem::setDueDate(const QDate &dueDate)
{
        m_dueDate = dueDate;
}

void TasksTaskItem::setReminderType(TasksListModel::ReminderType reminderType)
{
        m_reminderType = reminderType;
}

void TasksTaskItem::setReminderDate(const QDate &reminderDate)
{
        m_reminderDate = reminderDate;
}

void TasksTaskItem::setCreatedDateTime(const QDateTime &createdDateTime)
{
        m_createdDateTime = createdDateTime;
}

void TasksTaskItem::setUrls(const QStringList &urls)
{
        m_urls = urls;
}

void TasksTaskItem::setAttachments(const QStringList &attachments)
{
        m_attachments = attachments;
}
