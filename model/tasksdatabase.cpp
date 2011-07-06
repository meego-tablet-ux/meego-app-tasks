/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "tasksdatabase.h"

#include "taskslistmodel.h"
#include "taskslistitem.h"
#include "tasksdbengine.h"

#include <QDebug>
#include <QTimerEvent>

const int DefaultListId = 0;

TasksDatabase *TasksDatabase::tasksDatabaseInstance = 0;
TasksDatabase *TasksDatabase::instance()
{
    if (!tasksDatabaseInstance)
        tasksDatabaseInstance = new TasksDatabase();
    return tasksDatabaseInstance;
}

static int duedate_comp(const TasksTaskItem &t1, const TasksTaskItem &t2)
{
    if (t1.hasDueDate() && t2.hasDueDate()) {
        if (t1.dueDate() < t2.dueDate())
            return 1;
        else if (t1.dueDate() > t2.dueDate())
            return -1;
        return 0;
    }
    if (t1.hasDueDate())
        return 1;
    if (t2.hasDueDate())
        return -1;
    return 0;
}

static int someday_comp(const TasksTaskItem &t1, const TasksTaskItem &t2)
{
    if (t1.createdDateTime() < t2.createdDateTime())
        return 1;
    else if (t1.createdDateTime() > t2.createdDateTime())
        return -1;
    return 0;
}

static int all_comp(const TasksTaskItem &t1, const TasksTaskItem &t2)
{
    if (t1.hasDueDate() && t2.hasDueDate()) {
        if (t1.dueDate() < t2.dueDate())
            return 1;
        else if (t1.dueDate() > t2.dueDate())
            return -1;
        return 0;
    }
    if (t1.hasDueDate())
        return 1;
    if (t2.hasDueDate())
        return -1;
    if (t1.createdDateTime() < t2.createdDateTime())
        return 1;
    else if (t1.createdDateTime() > t2.createdDateTime())
        return -1;
    return 0;
}

TasksDatabase::TasksDatabase(QObject *parent)
    : QObject(parent)
    , m_timerId(-1)
{
    m_dbEngine = new TasksDBEngine(this);

    m_currentDate = QDate::currentDate();

    // Create default list
    createList(tr("Default List"));

    load();
    //// Create some test data
    m_timerId = startTimer(1000 * 60);
}

TasksDatabase::~TasksDatabase()
{
    if (m_timerId != -1)
        killTimer(m_timerId);
}

void TasksDatabase::renameList(int listId, const QString &name)
{
    if (!m_listsMap.contains(listId))
        return;
    // Cannot rename the default list
    if (listId == DefaultListId)
        return;
    foreach (const TasksListItem &list, m_lists)
        if (list.id() != listId && list.name() == name)
            return;
    TasksListItem &list = m_listsMap[listId];
    list.setName(name);
    // store
    m_dbEngine->saveLists();
    m_dbEngine->updateTasksList(list);

    int idx = -1;
    int currentIndex = 0;
    foreach (const TasksListItem &currentList, m_lists) {
        if (currentList.id() == listId) {
            idx = currentIndex;
            break;
        }
        ++currentIndex;
    }

    if (idx == -1)
        return;
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::AllLists)
            model->onUpdateRow(idx);
}

void TasksDatabase::addList(const QString &name)
{
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::AllLists)
            model->onBeginInsertRow(m_lists.count());
    TasksListItem list(name);
    m_listsMap[list.id()] = list;
    m_lists << list;
    ////
    // store
    m_dbEngine->saveLists();
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::AllLists)
            model->onEndInsertRow();
}

void TasksDatabase::removeList(int listId)
{
    // Cannot remove the default list
    if (listId == DefaultListId)
        return;
    if (!m_listsMap.contains(listId))
        return;
    TasksListItem &list = m_listsMap[listId];
    int idx = m_lists.indexOf(list);
    if (idx == -1)
        return;
    // find rows
    QSet<TasksTaskItem> removeTasks;
    foreach(const TasksTaskItem &task, list.tasks()) {
          removeTasks.insert(task);
    }
    QList<int> removeSomedayRows;
    for (int r = 0; r < m_somedayTasks.count(); r++)
        if (removeTasks.contains(m_somedayTasks[r]))
            removeSomedayRows << r;
    QList<int> removeOverdueRows;
    for (int r = 0; r < m_overdueTasks.count(); r++)
        if (removeTasks.contains(m_overdueTasks[r]))
            removeOverdueRows << r;
    QList<int> removeUpcomingRows;
    for (int r = 0; r < m_upcomingTasks.count(); r++)
        if (removeTasks.contains(m_upcomingTasks[r]))
            removeUpcomingRows << r;

    qDebug() << removeSomedayRows;
    qDebug() << removeOverdueRows;
    qDebug() << removeUpcomingRows;

    QList <TasksListModel *> somedayModels;
    QList <TasksListModel *> overdueModels;
    QList <TasksListModel *> upcomingModels;
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday)
                somedayModels << model;
            else if (model->timeGroups() == TasksListModel::Overdue)
                overdueModels << model;
            else if (model->timeGroups() == TasksListModel::Upcoming)
                upcomingModels << model;
        }
    int iii = 0;
    int c = 0;
    while (iii < removeSomedayRows.count()){
        int k = iii;
        while (k + 1 < removeSomedayRows.count() && removeSomedayRows[k] + 1 == removeSomedayRows[k + 1])
            k++;
        int n = k - iii + 1;

        foreach (TasksListModel *model, somedayModels)
            model->onBeginRemoveRows(removeSomedayRows[iii] - c, n);

        for (int i = 0; i < n; i++) {
            m_somedayTasks.removeAt(removeSomedayRows[iii] - c + i);
            c++;
        }

        foreach (TasksListModel *model, somedayModels)
            model->onEndRemoveRow();

        iii = k + 1;
    }
    iii = 0;
    c = 0;
    while (iii < removeOverdueRows.count()){
        int k = iii;
        while (k + 1 < removeOverdueRows.count() && removeOverdueRows[k] + 1 == removeOverdueRows[k + 1])
            k++;
        int n = k - iii + 1;

        foreach (TasksListModel *model, overdueModels)
            model->onBeginRemoveRows(removeOverdueRows[iii] - c, n);

        for (int i = 0; i < n; i++) {
            m_somedayTasks.removeAt(removeOverdueRows[iii] - c + i);
            c++;
        }

        foreach (TasksListModel *model, overdueModels)
            model->onEndRemoveRow();

        iii = k + 1;
    }
    iii = 0;
    c = 0;
    while (iii < removeUpcomingRows.count()){
        int k = iii;
        while (k + 1 < removeUpcomingRows.count() && removeUpcomingRows[k] + 1 == removeUpcomingRows[k + 1])
            k++;
        int n = k - iii + 1;

        foreach (TasksListModel *model, upcomingModels)
            model->onBeginRemoveRows(removeUpcomingRows[iii] - c, n);

        for (int i = 0; i < n; i++) {
            m_upcomingTasks.removeAt(removeUpcomingRows[iii] - c + i);
            c++;
        }

        foreach (TasksListModel *model, upcomingModels)
            model->onEndRemoveRow();

        iii = k + 1;
    }

    // remove from lists

    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists)
            model->onBeginRemoveRow(idx);
        else if (model->modelType() == TasksListModel::List) {
            if (model->listId() == listId)
                model->onBeginRemoveRows(0, list.count());
        }
    }

    m_dbEngine->removeTasks(removeTasks.toList());
    // remove item and all tasks
    list.removeTasks();
    //foreach (TasksTaskItem *ti, removeTasks)
    //        delete ti;
    // remove list
    m_lists.removeAt(idx);
    m_listsMap.remove(listId);
    // store
    m_dbEngine->saveLists();
    //////////////////
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists)
            model->onEndRemoveRow();
        else if (model->modelType() == TasksListModel::List) {
            if (model->listId() == listId)
                model->onEndRemoveRow();
        }
    }
}

void TasksDatabase::addTask(int listId, const QString &task, const QString &notes, bool complete,
                            bool hasDueDate, const QDate &dueDate,
                            TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                            const QStringList &urls, const QStringList &attachments)
{
    qDebug() << m_listsMap.contains(listId);
    if (!m_listsMap.contains(listId))
        return;
    TasksListItem &list = m_listsMap[listId];
    TasksTaskItem tsk(list);
    m_tasksMap[tsk.id()] = tsk;
    tsk.setTask(task);
    tsk.setNotes(notes);
    tsk.setComplete(complete);
    tsk.setHasDueDate(hasDueDate);
    tsk.setDueDate(dueDate);
    tsk.setReminderType(reminderType);
    tsk.setReminderDate(reminderDate);
    tsk.setUrls(urls);
    tsk.setAttachments(attachments);
    tsk.setCreatedDateTime(QDateTime::currentDateTime());

    TasksListModel::TimeGroups tg = TasksListModel::All; // not at any timeview
    int idx = -1;
    if (!complete) {
        if (!hasDueDate)
            tg = TasksListModel::Someday;
        else if (dueDate < m_currentDate) {
            tg = TasksListModel::Overdue;
            //idx = 0;
            //while (idx < m_overdueTasks.count() && m_overdueTasks.at(idx)->dueDate() < dueDate)
            //        idx++;
            idx = findIndexForOverdue(tsk);
        } else {
            tg = TasksListModel::Upcoming;
            //idx = 0;
            //while (idx < m_upcomingTasks.count() && m_upcomingTasks.at(idx)->dueDate() < dueDate)
            //        idx++;
            idx = findIndexForUpcoming(tsk);
        }
    }
    // Send begin insert row
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists)
            ;//
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                model->onBeginInsertRow(m_somedayTasks.count());
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                model->onBeginInsertRow(idx);
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                model->onBeginInsertRow(idx);
        }
        else if (model->modelType() == TasksListModel::List) {
            if (model->listId() == listId)
                model->onBeginInsertRow(list.count());
        }
    }
    ///////////
    list.addTask(tsk);
    if (tg == TasksListModel::Someday)
        m_somedayTasks << tsk;
    else if (tg == TasksListModel::Overdue)
        m_overdueTasks.insert(idx, tsk);
    else if (tg == TasksListModel::Upcoming)
        m_upcomingTasks.insert(idx, tsk);
    ///////////
    m_newTasks << tsk;
    // Send end insert row
    int lidx = findList(listId);
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists) {
            if (lidx != -1)
                model->onUpdateRow(lidx);
        }
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                model->onEndInsertRow();
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                model->onEndInsertRow();
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                model->onEndInsertRow();
        }
        else if (model->modelType() == TasksListModel::List) {
            if (model->listId() == listId)
                model->onEndInsertRow();
        }
    }
}

void TasksDatabase::editTask(int taskId, int listId, const QString &task, const QString &notes,
                             bool hasDueDate, const QDate &dueDate,
                             TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                             const QStringList &urls, const QStringList &attachments)
{
    Q_UNUSED(reminderType);
    Q_UNUSED(reminderDate);
    Q_UNUSED(urls);
    Q_UNUSED(attachments);
    //qDebug() << "LIST ID " << listId;
    //if (!hasDueDate)
    //        dueDate = QDate();
    if (!m_tasksMap.contains(taskId))
        return;
    TasksTaskItem &tsk = m_tasksMap[taskId];
    bool dueupdated = tsk.hasDueDate() == hasDueDate && tsk.dueDate() == dueDate;
    tsk.setTask(task);
    tsk.setNotes(notes);
    tsk.setHasDueDate(hasDueDate);
    tsk.setDueDate(dueDate);
    //tsk.setReminderType(reminderType);
    //tsk.setReminderDate(reminderDate);
    //tsk.setUrls(urls);
    //tsk.setAttachments(attachments);
    m_dbEngine->updateTask(tsk);
    //////
    int listIndex = tsk.list().indexOfTask(tsk);
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::List && listIndex != -1) {
            if (model->listId() == tsk.list().id())
                model->onUpdateRow(listIndex);
        }
    }
    //////

    if (tsk.list().id() != listId) {
        qDebug("Database: Moving task to a new id");
        QStringList ids(QString::number(tsk.id()));
        moveTasksToList(ids, listId);
        qDebug("Database: Done moving task to a new id");
    }

    int somedayIndex = m_somedayTasks.indexOf(tsk);
    int overdueIndex = m_overdueTasks.indexOf(tsk);
    int upcomingIndex = m_upcomingTasks.indexOf(tsk);
    if (dueupdated) {
        // Update timeviews
        foreach (TasksListModel *model, m_models)
            if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1)
                    model->onUpdateRow(somedayIndex);
                else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1)
                    model->onUpdateRow(overdueIndex);
                else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1)
                    model->onUpdateRow(upcomingIndex);
            }
        return;
    }
    // Update timeview

    //////
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1)
                model->onBeginRemoveRow(somedayIndex);
            else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1)
                model->onBeginRemoveRow(overdueIndex);
            else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1)
                model->onBeginRemoveRow(upcomingIndex);
        }
    // remove from timeview list
    if (somedayIndex != -1)
        m_somedayTasks.removeAt(somedayIndex);
    if (overdueIndex != -1)
        m_overdueTasks.removeAt(overdueIndex);
    if (upcomingIndex != -1)
        m_upcomingTasks.removeAt(upcomingIndex);
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1)
                model->onEndRemoveRow();
            else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1)
                model->onEndRemoveRow();
            else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1)
                model->onEndRemoveRow();
        }
    // add to timeview
    TasksListModel::TimeGroups tg = TasksListModel::All;
    int idx = -1;
    if (!hasDueDate) {
        tg = TasksListModel::Someday;
        //idx = 0;
        //while (idx < m_somedayTasks.count() && m_somedayTasks.at(idx)->createdDateTime() < tsk.createdDateTime())
        //        idx++;
        idx = findIndexForSomeday(tsk);
    }
    else if (dueDate < QDate::currentDate()) {
        tg = TasksListModel::Overdue;
        //idx = 0;
        //while (idx < m_overdueTasks.count() && m_overdueTasks.at(idx)->dueDate() < dueDate)
        //        idx++;
        idx = findIndexForOverdue(tsk);
    } else {
        tg = TasksListModel::Upcoming;
        //idx = 0;
        //while (idx < m_upcomingTasks.count() && m_upcomingTasks.at(idx)->dueDate() < dueDate)
        //        idx++;
        idx = findIndexForUpcoming(tsk);
    }
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                model->onBeginInsertRow(idx);
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                model->onBeginInsertRow(idx);
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                model->onBeginInsertRow(idx);
        }
    }
    ///
    if (tg == TasksListModel::Someday)
        m_somedayTasks.insert(idx, tsk);
    else if (tg == TasksListModel::Overdue)
        m_overdueTasks.insert(idx, tsk);
    else if (tg == TasksListModel::Upcoming)
        m_upcomingTasks.insert(idx, tsk);
    ///
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                model->onEndInsertRow();
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                model->onEndInsertRow();
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                model->onEndInsertRow();
        }
    }
}

void TasksDatabase::removeCompletedTasksInList(int listId)
{
    if (!m_listsMap.contains(listId))
        return;
    TasksListItem &list = m_listsMap[listId];
    QList<int> rows;
    QList<TasksTaskItem> tasks;
    for (int r = 0; r < list.count(); r++)
        if (list.task(r).isComplete()) {
            rows << r;
            tasks << list.task(r);
        }

    QList <TasksListModel *> models;
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == listId)
                models << model;

    int idx = 0;
    int c = 0;
    while (idx < rows.count()){
        int k = idx;
        while (k + 1 < rows.count() && rows[k] + 1 == rows[k + 1])
            k++;
        int n = k - idx + 1;

        foreach (TasksListModel *model, models)
            model->onBeginRemoveRows(rows[idx] - c, n);

        for (int i = 0; i < n; i++) {
            list.removeTask(rows[idx] - c + i);
            c++;
        }

        foreach (TasksListModel *model, models)
            model->onEndRemoveRow();

        idx = k + 1;
    }
    // store
    m_dbEngine->removeTasks(tasks);
    // clear
    tasks.clear();
}

void TasksDatabase::removeAllCompletedTasks()
{
    foreach (const TasksListItem &list, m_lists)
        removeCompletedTasksInList(list.id());
}

void TasksDatabase::setCompleted(int taskId, bool completed)
{
    if (!m_tasksMap.contains(taskId))
        return;
    TasksTaskItem &tsk = m_tasksMap[taskId];
    if (tsk.isComplete() == completed)
        return;
    if (completed)
        setTaskComplited(tsk);
    else
        setTaskUncomplited(tsk);
}

void TasksDatabase::removeTask(int taskId, bool store)
{
    if (!m_tasksMap.contains(taskId))
        return;
    const TasksTaskItem &tsk = m_tasksMap[taskId];
    //bool complete = tsk.isComplete();
    int listIndex = tsk.list().indexOfTask(tsk);
    int somedayIndex = m_somedayTasks.indexOf(tsk);
    int overdueIndex = m_overdueTasks.indexOf(tsk);
    int upcomingIndex = m_upcomingTasks.indexOf(tsk);
    ///////
    QList<TasksListModel *> models;
    QList<TasksListModel *> almodels;
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists) {
            almodels << model;
        }
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1) {
                model->onBeginRemoveRow(somedayIndex);
                models << model;
            }
            else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1) {
                model->onBeginRemoveRow(overdueIndex);
                models << model;
            }
            else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1) {
                model->onBeginRemoveRow(upcomingIndex);
                models << model;
            }
        }
        else if (model->modelType() == TasksListModel::List && listIndex != -1) {
            if (model->listId() == tsk.list().id()) {
                model->onBeginRemoveRow(listIndex);
                models << model;
            }
        }
    }
    ///////
    int lidx = findList(tsk.list().id());
    tsk.list().removeTask(tsk);
    if (store)
        m_dbEngine->removeTask(tsk);
    if (somedayIndex != -1)
        m_somedayTasks.removeAt(somedayIndex);
    if (overdueIndex != -1)
        m_overdueTasks.removeAt(overdueIndex);
    if (upcomingIndex != -1)
        m_upcomingTasks.removeAt(upcomingIndex);
    m_tasksMap.remove(taskId);
    ///////
    foreach (TasksListModel *model, models)
        model->onEndRemoveRow();
    if (lidx != -1)
        foreach (TasksListModel *model, almodels)
            model->onUpdateRow(lidx);
}

void TasksDatabase::removeTasks(const QStringList &staskIds)
{
    foreach (const QString &sid, staskIds) {
        bool ok;
        int id = sid.toInt(&ok);
        if (ok)
            removeTask(id, true);
    }
}

void TasksDatabase::reorderTask(int taskId, int destidx)
{
    if (!m_tasksMap.contains(taskId))
        return;
    const TasksTaskItem &tsk = m_tasksMap[taskId];
    TasksListItem list = tsk.list();
    int listIndex = list.indexOfTask(tsk);
    if (listIndex == -1 || destidx == listIndex)
        return;
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == tsk.list().id()) {
                model->onBeginMoveRow(listIndex, destidx);
            }
    list.swapTasks(listIndex, destidx);
    //m_dbEngine->updateTasksOrder(list);
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == tsk.list().id()) {
                model->onEndMoveRow();
            }
}

void TasksDatabase::hideTasks(const QStringList &taskIds)
{
    QList<TasksTaskItem> tasks;
    QList<int> oldIndexes;
    for (int i=0; i<taskIds.count(); ++i) {
        if (!m_tasksMap.contains(taskIds.at(i).toInt()))
            return;
        const TasksTaskItem &tsk = m_tasksMap[taskIds.at(i).toInt()];
        tasks.append(tsk);
        TasksListItem list = tsk.list();
        oldIndexes.append(list.indexOfTask(tsk));
    }
    for (int i=0; i<taskIds.count(); ++i) {
        //        TasksTaskItem *tsk = m_tasksMap[taskIds.at(i).toInt()];
        TasksListItem list = tasks.at(i).list();
        int listIndex = list.indexOfTask(tasks.at(i));
        if (listIndex == -1)
            return;

        foreach (TasksListModel *model, m_models)
            if (model->modelType() == TasksListModel::List)
                if (model->listId() == tasks.at(i).list().id()) {
                    model->onBeginRemoveRow(listIndex);
                }
        list.hideTask(listIndex, oldIndexes.at(i));
        //m_dbEngine->updateTasksOrder(list);
        foreach (TasksListModel *model, m_models)
            if (model->modelType() == TasksListModel::List)
                if (model->listId() == tasks.at(i).list().id()) {
                    model->onEndRemoveRow();
                }
    }
}

void TasksDatabase::showHiddenTasks(int listId, int startIndex)
{
    TasksListItem &list = m_listsMap[listId];
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == list.id()) {
                model->onBeginInsertRows(startIndex, list.hiddenTasks());
            }
    list.showHiddenTasks(startIndex);
    //m_dbEngine->updateTasksOrder(list);
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == list.id()) {
                model->onEndInsertRow();
            }
}

void TasksDatabase::showHiddenTasksOldPositions(int listId)
{
    TasksListItem &list = m_listsMap[listId];
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == list.id()) {
                model->onBeginReset();
            }
    list.showHiddenTasks();
    //m_dbEngine->updateTasksOrder(list);
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == list.id()) {
                model->onEndReset();
            }
}

void TasksDatabase::saveReorder(int listId)
{
    if (!m_listsMap.contains(listId))
        return;
    const TasksListItem &list = m_listsMap[listId];
    m_dbEngine->updateTasksOrder(list);
}

void TasksDatabase::moveTasksToList(const QStringList &staskIds, int destListId)
{
    if (!m_listsMap.contains(destListId))
        return;
    TasksListItem &list = m_listsMap[destListId];
    QSet<int> idsSet;
    foreach (const QString &sid, staskIds) {
        bool ok;
        int id = sid.toInt(&ok);
        if (ok)
            idsSet << id;
    }
    QList<TasksTaskItem> tsks;
    foreach (int taskId, idsSet)
        if (m_tasksMap.contains(taskId))
            tsks << m_tasksMap[taskId];
    if (tsks.isEmpty())
        return;
    TasksListItem slist = tsks.first().list();
    int srcListId = slist.id();
    int lidx1 = findList(srcListId);
    int lidx2 = findList(destListId);
    QList<int> rows;
    for (int i = 0; i < slist.count(); i++)
        if (idsSet.contains(slist.task(i).id())) {
            rows << i;
        }
    QList <TasksListModel *> models;
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == srcListId)
                models << model;
    int idx = 0;
    int c = 0;
    while (idx < rows.count()){
        int k = idx;
        while (k + 1 < rows.count() && rows[k] + 1 == rows[k + 1])
            k++;
        int n = k - idx + 1;

        foreach (TasksListModel *model, models)
            model->onBeginRemoveRows(rows[idx] - c, n);

        for (int i = 0; i < n; i++) {
            slist.removeTask(rows[idx] - c + i);
            c++;
        }

        foreach (TasksListModel *model, models)
            model->onEndRemoveRow();

        idx = k + 1;
    }

    ////
    // Append
    ////
    foreach (TasksListModel *model, m_models)
        if (model->modelType() == TasksListModel::List)
            if (model->listId() == destListId)
                model->onBeginInsertRows(list.count(), tsks.count());
    ////
    foreach (TasksTaskItem tsk, tsks) {
        tsk.setList(list);
        list.addTask(tsk);
    }
    ////
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists) {
            if (lidx1 != -1)
                model->onUpdateRow(lidx1);
            if (lidx2 != -1)
                model->onUpdateRow(lidx2);
        }
        else if (model->modelType() == TasksListModel::List)
            if (model->listId() == destListId)
                model->onEndInsertRow();
    }
    m_dbEngine->updateTasksList(tsks);
}

void TasksDatabase::commitAddedTasks()
{
    qDebug() << "commit " << m_newTasks.count();
    m_dbEngine->addTasks(m_newTasks);
    m_newTasks.clear();
}

void TasksDatabase::rollbackAddedTasks()
{
    foreach (const TasksTaskItem &task, m_newTasks)
        removeTask(task.id(), false);
    m_newTasks.clear();
}

int TasksDatabase::taskIdByUid(const QString &uid)
{
    return m_dbEngine->taskIdByUid(uid);
}

QVariant TasksDatabase::taskValue(int taskId, const QString &valueName)
{
    TasksTaskItem task = m_tasksMap.value(taskId);

    if (!task.isValid())
        return QVariant();

    if (valueName == "Task")
        return QVariant(task.task());
    else if (valueName == "Notes")
        return QVariant(task.notes());
    else if (valueName == "Complete")
        return QVariant(task.isComplete());
    else if (valueName == "HasDueDate")
        return QVariant(task.hasDueDate());
    else if (valueName == "DueDate")
        return QVariant(task.dueDate());
    else if (valueName == "Reminder")
        return QVariant(task.reminderType());
    else if (valueName == "ReminderDate")
        return QVariant(task.reminderDate());
    else if (valueName == "Urls")
        return QVariant(task.urls());
    else if (valueName == "Attachments")
        return QVariant(task.attachments());
    else if (valueName == "ListName")
        return QVariant(task.list().name());
    else if (valueName == "ListID")
        return QVariant(task.list().id());

    return QVariant();
}

void TasksDatabase::timerEvent(QTimerEvent *event)
{
    QObject::timerEvent(event);
    if (event->timerId() != m_timerId)
        return;
    qDebug() << QDate::currentDate();
    if (QDate::currentDate() == m_currentDate)
        return;
    m_currentDate = QDate::currentDate();
    qDebug() << "current date changed";
    updateDueTasks();
}

int TasksDatabase::findList(int listId)
{
    for (int idx = 0; idx < m_lists.count(); idx++)
        if (m_lists[idx].id() == listId)
            return idx;
    return -1;
}

void TasksDatabase::setTaskComplited(TasksTaskItem &task)
{
    int listIndex = task.list().indexOfTask(task);
    int somedayIndex = m_somedayTasks.indexOf(task);
    int overdueIndex = m_overdueTasks.indexOf(task);
    int upcomingIndex = m_upcomingTasks.indexOf(task);
    int lidx = findList(task.list().id());
    ////
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists)
            ;//
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1)
                model->onBeginRemoveRow(somedayIndex);
            else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1)
                model->onBeginRemoveRow(overdueIndex);
            else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1)
                model->onBeginRemoveRow(upcomingIndex);
        }
    }
    ////
    task.setComplete(true);
    task.list().decrementIncompleted();
    m_dbEngine->updateTask(task);
    // remove from timeview list
    if (somedayIndex != -1)
        m_somedayTasks.removeAt(somedayIndex);
    if (overdueIndex != -1)
        m_overdueTasks.removeAt(overdueIndex);
    if (upcomingIndex != -1)
        m_upcomingTasks.removeAt(upcomingIndex);
    ///////
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists) {
            if (lidx != -1)
                model->onUpdateRow(lidx);
        }
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && somedayIndex != -1) {
                model->onEndRemoveRow();
                model->onIcountChanged();
            }
            else if (model->timeGroups() == TasksListModel::Overdue && overdueIndex != -1) {
                model->onEndRemoveRow();
                model->onIcountChanged();
            }
            else if (model->timeGroups() == TasksListModel::Upcoming && upcomingIndex != -1) {
                model->onEndRemoveRow();
                model->onIcountChanged();
            }
        }
        else if (model->modelType() == TasksListModel::List && listIndex != -1) {
            if (model->listId() == task.list().id()){
                model->onUpdateRow(listIndex);
                model->onIcountChanged();
            }
        }
    }
}

void TasksDatabase::setTaskUncomplited(TasksTaskItem &task)
{
    int lidx = findList(task.list().id());
    // Find positions
    int listIndex = task.list().indexOfTask(task);
    TasksListModel::TimeGroups tg = TasksListModel::All;
    int idx = -1;
    if (!task.hasDueDate()) {
        tg = TasksListModel::Someday;
        //idx = 0;
        //while (idx < m_somedayTasks.count() && m_somedayTasks.at(idx)->createdDateTime() < task.createdDateTime())
        //        idx++;
        idx = findIndexForSomeday(task);
    }
    else if (task.dueDate() < m_currentDate) {
        tg = TasksListModel::Overdue;
        //idx = 0;
        //while (idx < m_overdueTasks.count() && m_overdueTasks.at(idx)->dueDate() < task.dueDate())
        //        idx++;
        idx = findIndexForOverdue(task);
    } else {
        tg = TasksListModel::Upcoming;
        //idx = 0;
        //while (idx < m_upcomingTasks.count() && m_upcomingTasks.at(idx)->dueDate() < task.dueDate())
        //        idx++;
        idx = findIndexForUpcoming(task);
    }
    //
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists)
            ;
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                model->onBeginInsertRow(idx);
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                model->onBeginInsertRow(idx);
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                model->onBeginInsertRow(idx);
        }
    }
    task.setComplete(false);
    task.list().incrementIncompleted();
    m_dbEngine->updateTask(task);
    // Add to timeview
    if (tg == TasksListModel::Someday)
        m_somedayTasks.insert(idx, task);
    else if (tg == TasksListModel::Overdue)
        m_overdueTasks.insert(idx, task);
    else if (tg == TasksListModel::Upcoming)
        m_upcomingTasks.insert(idx, task);
    //
    foreach (TasksListModel *model, m_models) {
        if (model->modelType() == TasksListModel::AllLists) {
            if (lidx != -1)
                model->onUpdateRow(lidx);
        }
        else if (model->modelType() == TasksListModel::Timeview) {
            if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday) {
                model->onEndInsertRow();
                model->onIcountChanged();
            }
            else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue) {
                model->onEndInsertRow();
                model->onIcountChanged();
            }
            else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming) {
                model->onEndInsertRow();
                model->onIcountChanged();
            }
        }
        else if (model->modelType() == TasksListModel::List && listIndex != -1) {
            if (model->listId() == task.list().id()) {
                model->onUpdateRow(listIndex);
                model->onIcountChanged();
            }
        }
    }
}

void TasksDatabase::load()
{
    m_dbEngine->loadLists();
    m_dbEngine->startLoadingTasks();
}

void TasksDatabase::createList(const QString &name)
{
    TasksListItem list(name);
    m_listsMap[list.id()] = list;
    m_lists << list;
}

TasksTaskItem TasksDatabase::createTask(const TasksListItem &list, const QString &task, const QString &notes, bool complete,
                                         bool hasDueDate, const QDate &dueDate,
                                         TasksListModel::ReminderType reminderType, const QDate &reminderDate,
                                         const QStringList &urls, const QStringList &attachments, const QDateTime &createdDateTime)
{
    TasksTaskItem tsk(list);
    m_tasksMap[tsk.id()] = tsk;
    tsk.setTask(task);
    tsk.setNotes(notes);
    tsk.setComplete(complete);
    tsk.setHasDueDate(hasDueDate);
    tsk.setDueDate(dueDate);
    tsk.setReminderType(reminderType);
    tsk.setReminderDate(reminderDate);
    tsk.setUrls(urls);
    tsk.setAttachments(attachments);
    tsk.setCreatedDateTime(createdDateTime);
    return tsk;
}


int TasksDatabase::findIndexForUpcoming(const TasksTaskItem &t) const
{
    int b = -1;
    int e = m_upcomingTasks.count();
    while (e - b > 1) {
        int m = (b + e) / 2;
        if (duedate_comp(t, m_upcomingTasks[m]) == 1)
            e = m;
        else
            b = m;
    }
    int r = 0;
    if (e > b)
        r = b + 1;
    return r;
}

int TasksDatabase::findIndexForOverdue(const TasksTaskItem &t) const
{
    int b = -1;
    int e = m_overdueTasks.count();
    while (e - b > 1) {
        int m = (b + e) / 2;
        if (duedate_comp(t, m_overdueTasks[m]) == 1)
            e = m;
        else
            b = m;
    }
    int r = 0;
    if (e > b)
        r = b + 1;
    return r;
}

int TasksDatabase::findIndexForSomeday(const TasksTaskItem &t) const
{
    int b = -1;
    int e = m_somedayTasks.count();
    while (e - b > 1) {
        int m = (b + e) / 2;
        if (all_comp(t, m_somedayTasks[m]) == 1)
            e = m;
        else
            b = m;
    }
    int r = 0;
    if (e > b)
        r = b + 1;
    return r;
}

void TasksDatabase::insertTaskToAll(const TasksTaskItem &t)
{
    int b = -1;
    int e = m_allTasks.count();
    while (e - b > 1) {
        int m = (b + e) / 2;
        if (someday_comp(t, m_allTasks[m]) == 1)
            e = m;
        else
            b = m;
    }
    int r = -1;
    if (e > b)
        r = b;
    r++;
    m_allTasks.insert(r, t);
}

void TasksDatabase::insertTasks(const QList<TasksTaskItem> &tasks)
{
    foreach (const TasksTaskItem &task, tasks) {
        task.list().addTask(task);
        if (task.isComplete()) {
            continue;
        }
        int listId = task.list().id();

        //m_allTasks << task;
        insertTaskToAll(task);

        TasksListModel::TimeGroups tg = TasksListModel::All;
        int idx = -1;
        if (!task.hasDueDate()) {
            tg = TasksListModel::Someday;
            idx = findIndexForSomeday(task);
        }
        else if (task.dueDate() < QDate::currentDate()) {
            tg = TasksListModel::Overdue;
            idx = findIndexForOverdue(task);
        } else {
            tg = TasksListModel::Upcoming;
            idx = findIndexForUpcoming(task);
        }

        // Send begin insert row
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::AllLists)
                ;//
            else if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                    model->onBeginInsertRow(m_somedayTasks.count());
                else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                    model->onBeginInsertRow(idx);
                else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                    model->onBeginInsertRow(idx);
            }
            else if (model->modelType() == TasksListModel::List) {
                if (model->listId() == listId)
                    model->onBeginInsertRow(task.list().count());
            }
        }
        // Insert
        if (tg == TasksListModel::Someday)
            m_somedayTasks.insert(idx, task);
        else if (tg == TasksListModel::Overdue)
            m_overdueTasks.insert(idx, task);
        else if (tg == TasksListModel::Upcoming)
            m_upcomingTasks.insert(idx, task);

        // Send end insert row
        int lidx = findList(listId);
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::AllLists) {
                if (lidx != -1)
                    model->onUpdateRow(lidx);
            }
            else if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Someday && tg == TasksListModel::Someday)
                    model->onEndInsertRow();
                else if (model->timeGroups() == TasksListModel::Overdue && tg == TasksListModel::Overdue)
                    model->onEndInsertRow();
                else if (model->timeGroups() == TasksListModel::Upcoming && tg == TasksListModel::Upcoming)
                    model->onEndInsertRow();
            }
            else if (model->modelType() == TasksListModel::List) {
                if (model->listId() == listId)
                    model->onEndInsertRow();
            }
        }
    }
}

void TasksDatabase::updateDueTasks(bool topast)
{
    // update after current date changed
    if (topast) {
        int n = m_overdueTasks.count();
        for (; n > 0; n--)
            if (m_overdueTasks[n - 1].dueDate() < m_currentDate)
                break;
        n = m_overdueTasks.count() - n;
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Overdue) {
                    model->onBeginRemoveRows(m_overdueTasks.count() - n, n);
                }
                else if (model->timeGroups() == TasksListModel::Upcoming) {
                    model->onBeginInsertRows(0, n);
                }
            }
        }
        for (int nn = 0; nn < n; nn++) {
            TasksTaskItem task = m_upcomingTasks.takeLast();
            m_overdueTasks.push_front(task);
        }
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Overdue) {
                    model->onEndRemoveRow();
                }
                else if (model->timeGroups() == TasksListModel::Upcoming) {
                    model->onEndInsertRow();
                }
            }
        }
    } else {
        int n = 0;
        for (; n < m_upcomingTasks.count(); n++)
            if (m_upcomingTasks[n].dueDate() >= m_currentDate)
                break;
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Overdue) {
                    model->onBeginInsertRows(m_overdueTasks.count(), n);
                    //model->onIcountChanged();
                }
                else if (model->timeGroups() == TasksListModel::Upcoming) {
                    model->onBeginRemoveRows(0, n);
                }
            }
        }
        for (int nn = 0; nn < n; nn++) {
            TasksTaskItem task = m_upcomingTasks.takeFirst();
            m_overdueTasks << task;
        }
        foreach (TasksListModel *model, m_models) {
            if (model->modelType() == TasksListModel::Timeview) {
                if (model->timeGroups() == TasksListModel::Overdue) {
                    model->onEndInsertRow();
                }
                else if (model->timeGroups() == TasksListModel::Upcoming) {
                    model->onEndRemoveRow();
                }
            }
        }
    }
}

