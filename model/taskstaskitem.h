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

class TasksListItem;

class TasksTaskItem
{
public:
        TasksTaskItem(TasksListItem *list);

        TasksListItem *list() const {return m_list; }
        int id() const {return m_id; }
        QString task() const {return m_task; }
        QString notes() const {return m_notes; }
        bool isComplete() const {return m_complete; }
        bool hasDueDate() const {return m_hasDueDate; }
        QDate dueDate() const {return m_dueDate; }
        TasksListModel::ReminderType reminderType() const {return m_reminderType; }
        QDate reminderDate() const {return m_reminderDate; }
        QDateTime createdDateTime() const {return m_createdDateTime; }
        const QStringList &urls() const {return m_urls; }
        const QStringList &attachments() const {return m_attachments; }

        void setList(TasksListItem *list);
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
        static int ids;
        TasksListItem *m_list;
        int m_id;
        QString m_task;
        QString m_notes;
        bool m_complete;
        bool m_hasDueDate;
        QDate m_dueDate;
        TasksListModel::ReminderType m_reminderType;
        QDate m_reminderDate;
        QDateTime m_createdDateTime;
        QStringList m_urls;
        QStringList m_attachments;
};

#endif // TASKITEM_H
