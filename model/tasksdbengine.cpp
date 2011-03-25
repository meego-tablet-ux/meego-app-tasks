/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "tasksdbengine.h"

#include <QSettings>
#include "tasksdatabase.h"
#include "taskslistitem.h"

#include <event.h>
#include <QDebug>

const QString TasksDBEngine::tasksNotebook = "TasksNotebook";

TasksDBEngine::TasksDBEngine(TasksDatabase *db)
        : m_db(db)
{
        m_settings = new QSettings("MeeGo", "meego-app-tasks");

        m_calendar = new ExtendedCalendar(QLatin1String("UTC"));
        m_calendarPtr = ExtendedCalendar::Ptr(m_calendar);
        m_storage = m_calendar->defaultStorage(m_calendarPtr);
        m_storage->open();


        m_notebook = 0;
        Notebook::List nbList = m_storage->notebooks();
        for (int i = 0; i < nbList.count(); i++) {
                Notebook::Ptr nbPtr = nbList.at(i);
                Notebook *notebook = nbPtr.data();
                if (notebook->name() == tasksNotebook) {
                        m_notebook = notebook;
                        break;
                }
        }
        if (!m_notebook) {
                m_notebook = new Notebook(tasksNotebook, "");
                Notebook::Ptr notebookPtr = Notebook::Ptr(m_notebook);
                m_storage->addNotebook(notebookPtr);
        }
        m_nuid = m_notebook->uid();
}

TasksDBEngine::~TasksDBEngine()
{
        delete m_settings;
}

void TasksDBEngine::loadLists()
{
        m_settings->beginGroup("Lists");
        int count = m_settings->value("count", 0).toInt();
        for (int idx = 1; idx < count; idx++) {
                QString name = m_settings->value(QString("list%1").arg(QString::number(idx)), "").toString();
                qDebug() << name;
                m_db->createList(name);
        }
        m_settings->endGroup();
}

void TasksDBEngine::saveLists()
{
        m_settings->beginGroup("Lists");
        m_settings->remove("");
        m_settings->setValue("count", m_db->m_lists.count());
        int idx = 0;
        foreach (TasksListItem *list, m_db->m_lists) {
                m_settings->setValue(QString("list%1").arg(QString::number(idx)), list->name());
                idx++;
        }
        m_settings->endGroup();

        //m_settings->sync();
}

void TasksDBEngine::loadTasks()
{
        m_storage->loadNotebookIncidences(m_nuid);
        QHash<QString, TasksListItem *> listsHash;
        foreach (TasksListItem *list, m_db->m_lists)
                listsHash[list->name()] = list;

        QList<TasksTaskItem *> tasks;
        QList<TasksTaskItem *> taskswoo;
        QList<int> orders;
        KCalCore::Todo::List todos = m_calendar->rawTodos();
        for (int i = 0; i < todos.count(); i++){
                //KCalCore::Todo *todo = todos.at(i).data();
                KCalCore::Todo::Ptr todo = todos.at(i);
                QString order = todo->customProperty("Tasks", "Order");
                bool ok;
                int orderidx = order.toInt(&ok);
                if (!ok)
                        orderidx = -1;
                QString task = todo->description();
                QString notes = todo->altDescription();
                bool completed = todo->isCompleted();
                bool hasDueDate = todo->hasDueDate();
                QDate dueDate = todo->dtDue().date();
                QDateTime created = todo->created().dateTime();
                TasksListModel::ReminderType reminderType = TasksListModel::NoReminder;
                QDate reminderDate;
                //qDebug() << "parse alarms";
                if (todo->hasEnabledAlarms()) {
                        KCalCore::Alarm::List alarms = todo->alarms();
                        //qDebug() << "count " << alarms.count();
                        if (alarms.count() > 0) {
                                KCalCore::Alarm::Ptr alarm = alarms.at(0);

                                if (alarm->hasStartOffset()) {
                                        if (alarm->startOffset().asSeconds() == 0)
                                                reminderType = TasksListModel::OnDueDate;
                                        else if (alarm->startOffset().asDays() == -1)
                                                reminderType = TasksListModel::OneDayBefore;
                                        else if (alarm->startOffset().asDays() == -2)
                                                reminderType = TasksListModel::TwoDaysBefore;
                                        else if (alarm->startOffset().asDays() == -7)
                                                reminderType = TasksListModel::OneWeekBefore;
                                }
                                else if (alarm->hasTime()) {
                                        reminderType = TasksListModel::DateReminder;
                                        KDateTime alarmTime = alarm->time();
                                        reminderDate = alarmTime.date();
                                }
                        }
                }
                QStringList urls = todo->comments();
                //qDebug() << "comments: " << urls;
                QStringList attachments;
                KCalCore::Attachment::List attlst = todo->attachments();
                for (int j = 0; j < attlst.count(); j++) {
                        KCalCore::Attachment *attch = attlst.at(j).data();
                        if (attch->isUri())
                                attachments << attch->uri();
                }

                QStringList cats = todo->categories();
                TasksListItem *list = 0;
                foreach (const QString &cat, cats) {
                        if (listsHash.contains(cat)) {
                                list = listsHash[cat];
                                break;
                        }
                }
                if (!list)
                        continue;
                TasksTaskItem *tsk = m_db->createTask(list, task, notes, completed, hasDueDate, dueDate,
                                                      reminderType, reminderDate, urls, attachments, created);
                //m_tasks[tsk->id()] = todo;
                m_uids[tsk->id()] = todo->uid();
                if (orderidx == -1){
                        taskswoo << tsk;
                } else {
                        QList<int>::iterator it = qLowerBound(orders.begin(), orders.end(), orderidx);
                        int idx = it - orders.begin();
                        //orders.insert(it, orderidx);
                        //int idx = 0;
                        //while (idx < tasks.count() && orders.at(idx) < orderidx)
                        //        idx++;
                        tasks.insert(idx, tsk);
                        orders.insert(idx, orderidx);
                        //qDebug() << "idx " << idx << "  " << idx1;
                }
        }
        m_db->insertTasks(tasks);
        m_db->insertTasks(taskswoo);
}

void TasksDBEngine::addTask(TasksTaskItem *task)
{
        if (m_uids.contains(task->id()))
                return;
        KCalCore::Todo::Ptr todo = KCalCore::Todo::Ptr(new KCalCore::Todo());
        setTaskValues(task, todo);
        //m_tasks[task->id()] = todo;
        m_calendar->addTodo(todo, m_nuid);
}

void TasksDBEngine::updateTask(TasksTaskItem *task)
{
        //if (!m_tasks.contains(task->id()))
        //        return;
        if (!m_uids.contains(task->id()))
                return;
        m_storage->loadNotebookIncidences(m_nuid);
        KCalCore::Todo::Ptr todo = m_calendar->todo(m_uids[task->id()]);
        setTaskValues(task, todo);
        todo->setRevision(todo->revision() + 1);
        m_storage->save();
}

void TasksDBEngine::removeTask(TasksTaskItem *task)
{
        if (!m_uids.contains(task->id()))
                return;
        m_storage->loadNotebookIncidences(m_nuid);
        KCalCore::Todo::Ptr todo = m_calendar->todo(m_uids[task->id()]);
        m_uids.remove(task->id());
        m_calendar->deleteTodo(todo);
        m_storage->save();
}

void TasksDBEngine::removeTasks(QList<TasksTaskItem *> tasks)
{
        m_storage->loadNotebookIncidences(m_nuid);
        foreach (TasksTaskItem *task, tasks) {
                if (!task)
                        continue;
                if (!m_uids.contains(task->id()))
                        continue;
                KCalCore::Todo::Ptr todo = m_calendar->todo(m_uids[task->id()]);
                m_calendar->deleteTodo(todo);
        }
        m_storage->save();
}

void TasksDBEngine::updateTasksOrder(TasksListItem *list)
{
        m_storage->loadNotebookIncidences(m_nuid);
        for (int idx = 0; idx < list->tasks(); idx++) {
                TasksTaskItem *task = list->task(idx);
                if (!task)
                        continue;
                if (!m_uids.contains(task->id()))
                        continue;
                KCalCore::Todo::Ptr todo = m_calendar->todo(m_uids[task->id()]);
                todo->setCustomProperty("Tasks", "Order", QString::number(idx));
        }
        m_storage->save();
}

void TasksDBEngine::updateTasksList(TasksListItem *list)
{
        /*for (int idx = 0; idx < list->tasks(); idx++) {
                TasksTaskItem *task = list->task(idx);
                if (!task)
                        continue;
                updateTask(task);
        }*/
        updateTasksList(list->m_tasks);
}

void TasksDBEngine::updateTasksList(QList<TasksTaskItem *> tasks)
{
        m_storage->loadNotebookIncidences(m_nuid);
        foreach (TasksTaskItem *task, tasks) {
                if (!task)
                        continue;
                if (!m_uids.contains(task->id()))
                        continue;
                KCalCore::Todo::Ptr todo = m_calendar->todo(m_uids[task->id()]);
                todo->setCategories(QStringList(task->list()->name()));
        }
        m_storage->save();
}

void TasksDBEngine::commitTasks()
{
        m_storage->save();
}

void TasksDBEngine::setTaskValues(TasksTaskItem *task, const KCalCore::Todo::Ptr &todo)
{
        todo->setDescription(task->task());
        todo->setAltDescription(task->notes());
        //todo->setSummary(task->notes());
        todo->setCategories(QStringList(task->list()->name()));
        todo->setCompleted(task->isComplete());
        todo->setHasDueDate(task->hasDueDate());
        if (task->hasDueDate()) {
                KDateTime dueDate(task->dueDate());
                todo->setDtDue(dueDate);
        }
        KDateTime createdDateTime(task->createdDateTime());
        todo->setCreated(createdDateTime);
        todo->clearComments();
        // use attachments with mime?
        foreach (const QString &url, task->urls()) {
                qDebug() << "URL: " << url;
                todo->addComment(url);
        }
        todo->clearAttachments();
        foreach (const QString &auri, task->attachments()) {
                qDebug() << "ATTACH URI: " << auri;
                KCalCore::Attachment *attachment = new KCalCore::Attachment(auri);
                KCalCore::Attachment::Ptr attachmentPtr = KCalCore::Attachment::Ptr(attachment);
                todo->addAttachment(attachmentPtr);
        }
        int ordidx = task->list()->indexOfTask(task);
        todo->setCustomProperty("Tasks", "Order", QString::number(ordidx));
        // Save reminder
        todo->clearAlarms();
        if (task->reminderType() != TasksListModel::NoReminder) {
                KCalCore::Alarm::Ptr alarm(todo->newAlarm());
                alarm->setText("Reminder");
                alarm->setDisplayAlarm("Reminder");
                alarm->setEnabled(true);
                if (task->reminderType() == TasksListModel::OnDueDate) {
                        alarm->setSnoozeTime(KCalCore::Duration(60 * 5));
                        alarm->setRepeatCount(1);
                        alarm->setStartOffset(KCalCore::Duration(0));
                } else if (task->reminderType() == TasksListModel::OneDayBefore) {
                        alarm->setSnoozeTime(KCalCore::Duration(60 * 5));
                        alarm->setRepeatCount(1);
                        alarm->setStartOffset(KCalCore::Duration(-1, KCalCore::Duration::Days));
                } else if (task->reminderType() == TasksListModel::TwoDaysBefore) {
                        alarm->setSnoozeTime(KCalCore::Duration(60 * 5));
                        alarm->setRepeatCount(1);
                        alarm->setStartOffset(KCalCore::Duration(-2, KCalCore::Duration::Days));
                } else if (task->reminderType() == TasksListModel::OneWeekBefore) {
                        alarm->setSnoozeTime(KCalCore::Duration(60 * 5));
                        alarm->setRepeatCount(1);
                        alarm->setStartOffset(KCalCore::Duration(-7, KCalCore::Duration::Days));
                } else if (task->reminderType() == TasksListModel::DateReminder) {
                        alarm->setSnoozeTime(KCalCore::Duration(60 * 5));
                        alarm->setRepeatCount(1);
                        KDateTime alarmTime(task->reminderDate());
                        alarm->setTime(alarmTime);
                }
        }
}
