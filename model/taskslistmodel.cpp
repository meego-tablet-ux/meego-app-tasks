/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "taskslistmodel.h"

#include "tasksdatabase.h"
#include "taskslistitem.h"
#include <QDebug>
TasksListModel::TasksListModel()
    : QAbstractListModel()
    , m_modelType(AllLists)
    , m_timeGroups(Someday)
    , m_listId(-1)
    , m_sortOrder(ASC)
{
    QHash<int, QByteArray> roles;
    roles.insert(TaskID, "taskId");
    roles.insert(Task, "task");
    roles.insert(Notes, "notes");
    roles.insert(Complete, "complete");
    roles.insert(HasDueDate, "hasDueDate");
    roles.insert(DueDate, "dueDate");
    roles.insert(Reminder, "reminder");
    roles.insert(ReminderDate, "reminderDate");
    roles.insert(Urls, "urls");
    roles.insert(Attachments, "attachments");
    roles.insert(ListName, "listName");
    roles.insert(ListID, "listId");
    roles.insert(ListCount, "listCount");
    roles.insert(ListIncompletedCount, "listIncompletedCount");
    setRoleNames(roles);
    Database->m_models << this;
    m_filter = "";
}

TasksListModel::~TasksListModel()
{
    Database->m_models.removeAll(this);
}

void TasksListModel::setModelType(ModelType t)
{
    m_modelType = t;
    emit modelTypeChanged(t);
    reset();
}

void TasksListModel::setTimeGroups(TimeGroups timeGroups)
{
    if (timeGroups == All)
        return;
    m_timeGroups = timeGroups;
    emit timeGroupsChanged(timeGroups);
    reset();
}

void TasksListModel::setListId(int listId)
{
    m_listId = listId;
    emit listIdChanged(listId);
    reset();
}

QString TasksListModel::filter() const
{
    return m_filter;
}

void TasksListModel::setFilter(const QString &filter)
{
    m_filter = filter;
    beginResetModel();
    doFiltering();
    endResetModel();
    emit filterChanged();
}

void TasksListModel::doFiltering()
{
    if(m_filter.isEmpty()) {
        return;
    }

    if (m_modelType == AllLists)  { //list of task lists
        m_taskListsFiltered.clear();
        foreach(TasksListItem *item,Database->m_lists) {
            if(item->name().contains(m_filter,Qt::CaseInsensitive)) {
                m_taskListsFiltered.append(item);
            }
        }
    } else { //a list of tasks of some kind...
        QList<TasksTaskItem *> filterMe;

        if (m_modelType == List) {
            TasksListItem *list = Database->m_listsMap[m_listId];
            filterMe= list->taskList();
        }
        else if (m_modelType == Timeview) {
            if (m_timeGroups == Someday)
                filterMe = Database->m_somedayTasks;
            else if (m_timeGroups == Overdue)
                filterMe =Database->m_overdueTasks;
            else if (m_timeGroups == Upcoming)
                filterMe =  Database->m_upcomingTasks;
        }
        else if (m_modelType == AllTasks) {
            filterMe = Database->m_allTasks;
        }

        m_tasksFiltered.clear();
        foreach(TasksTaskItem *item, filterMe) {
            if(item->task().contains(m_filter,Qt::CaseInsensitive)) {
                m_tasksFiltered.append(item);
            }
        }

    }
}

int TasksListModel::icount() const
{
    if (m_modelType == List) {
        if (!Database->m_listsMap.contains(m_listId))
            return 0;
        TasksListItem *list = Database->m_listsMap[m_listId];
        return list->incompleted();
    } else if (m_modelType == Timeview) {
        return count();
    }
    return 0;
}

int TasksListModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    if (m_modelType == AllLists) {
        if(m_filter.isEmpty()) {
            return Database->m_lists.count();
        }
        else {
            return m_taskListsFiltered.count();
        }
    }
    else if(!m_filter.isEmpty()) {
        return m_tasksFiltered.count();
    }
    else if (m_modelType == AllTimeView) {

    }
    else if (m_modelType == List) {
        if (!Database->m_listsMap.contains(m_listId))
            return 0;
        TasksListItem *list = Database->m_listsMap[m_listId];
        return list->tasks();
    }
    else if (m_modelType == Timeview) {
        if (m_timeGroups == Someday)
            return Database->m_somedayTasks.count();
        else if (m_timeGroups == Overdue)
            return Database->m_overdueTasks.count();
        else if (m_timeGroups == Upcoming)
            return Database->m_upcomingTasks.count();
    }
    else if (m_modelType == AllTasks) {
        return Database->m_allTasks.count();
    }
    return 0;
}

int TasksListModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 1;
}

QVariant TasksListModel::data(const QModelIndex &index, int role) const
{
    if (m_modelType == AllLists) {
        QList<TasksListItem *> lookAtMe= Database->m_lists;
        if(!m_filter.isEmpty()) {
            lookAtMe = m_taskListsFiltered;
        }
        if (index.row() < 0 || index.row() >= lookAtMe.count())
            return QVariant();
        if (role == ListName) {
            return QVariant(lookAtMe[index.row()]->name());
        }

        else if (role == ListID)
            return QVariant(lookAtMe[index.row()]->id());
        else if (role == ListIncompletedCount)
            return QVariant(lookAtMe[index.row()]->incompleted());
    }
    else if (m_modelType == AllTimeView) {
        //
    }
    else if(!m_filter.isEmpty()) {
        return taskRole(m_tasksFiltered[index.row()],role);
    }
    else if (m_modelType == List) {
        if (!Database->m_listsMap.contains(m_listId))
            return QVariant();
        TasksListItem *list = Database->m_listsMap[m_listId];
        TasksTaskItem *task = list->task(index.row());
        return taskRole(task, role);
    }
    else if (m_modelType == Timeview) {
        if (index.row() < 0)
            return QVariant();
        TasksTaskItem *task = 0;
        if (m_timeGroups == Someday && index.row() < Database->m_somedayTasks.count())
            task = Database->m_somedayTasks[index.row()];
        else if (m_timeGroups == Overdue && index.row() < Database->m_overdueTasks.count())
            task = Database->m_overdueTasks[index.row()];
        else if (m_timeGroups == Upcoming && index.row() < Database->m_upcomingTasks.count())
            task = Database->m_upcomingTasks[index.row()];
        else
            return QVariant();
        return taskRole(task, role);
    }
    else if (m_modelType == AllTasks) {
        if (index.row() < 0)
            return QVariant();
        TasksTaskItem *task = 0;
        /*if (Database->isFiltered() && index.row() < Database->m_allTasksFiltered.count())
                        task = Database->m_allTasksFiltered[index.row()];
                else*/ if(index.row() < Database->m_allTasks.count())
            task = Database->m_allTasks[index.row()];
        if (!task)
            return QVariant();
        return taskRole(task, role);
    }
    return QVariant();
}



Qt::ItemFlags TasksListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return QAbstractListModel::flags(index);
    return QAbstractListModel::flags(index) | Qt::ItemIsEditable;
}

bool TasksListModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if (count < 1 || row < 0 || row > rowCount(parent))
        return false;
    beginInsertRows(QModelIndex(), row, row + count - 1);
    endInsertRows();
    return true;
}

bool TasksListModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (count <= 0 || row < 0 || (row + count) > rowCount(parent))
        return false;
    beginRemoveRows(QModelIndex(), row, row + count - 1);

    endRemoveRows();
    return true;
}

void TasksListModel::addList(const QString &name)
{
    Database->addList(name);
}

void TasksListModel::renameList(int listId, const QString &name)
{
    Database->renameList(listId, name);
}

void TasksListModel::removeList(int listId)
{
    Database->removeList(listId);
}

void TasksListModel::addTask(int listId, const QString &task, const QString &notes, bool complete,
                             bool hasDueDate, const QDate &dueDate,
                             ReminderType reminderType, const QDate &reminderDate,
                             const QStringList &urls, const QStringList &attachments)
{
    Database->addTask(listId, task, notes, complete, hasDueDate, dueDate,
                      reminderType, reminderDate, urls, attachments);
}

void TasksListModel::addTaskAlt(int listId, const QString &task, bool complete,
                                bool hasDueDate, const QDate &dueDate)
{
    Database->addTask(listId, task, "", complete, hasDueDate, dueDate,
                      NoReminder, QDate(), QStringList(), QStringList());
}

void TasksListModel::editTask(int taskId, int listId, const QString &task, const QString &notes,
                              bool hasDueDate, const QDate &dueDate,
                              ReminderType reminderType, const QDate &reminderDate,
                              const QStringList &urls, const QStringList &attachments)
{
    Database->editTask(taskId, listId, task, notes, hasDueDate, dueDate,
                       reminderType, reminderDate, urls, attachments);
}

void TasksListModel::removeCompletedTasksInList(int listId)
{
    Database->removeCompletedTasksInList(listId);
}

void TasksListModel::removeAllCompletedTasks()
{
    Database->removeAllCompletedTasks();
}

void TasksListModel::setCompleted(int taskId, bool completed)
{
    Database->setCompleted(taskId, completed);
}

void TasksListModel::removeTask(int taskId)
{
    Database->removeTask(taskId);
}

void TasksListModel::removeTasks(const QStringList &taskIds)
{
    Database->removeTasks(taskIds);
}

void TasksListModel::reorderTask(int taskId, int destidx)
{
    Database->reorderTask(taskId, destidx);
}

void TasksListModel::hideTasks(const QStringList &taskIds)
{
    Database->hideTasks(taskIds);
}

void TasksListModel::showHiddenTasks(int listId, int startIndex)
{
    Database->showHiddenTasks(listId, startIndex);
}

void TasksListModel::showHiddenTasksOldPositions(int listId)
{
    Database->showHiddenTasksOldPositions(listId);
}

void TasksListModel::saveReorder(int listId)
{
    Database->saveReorder(listId);
}

void TasksListModel::moveTasksToList(const QStringList &taskIds, int destListId)
{
    Database->moveTasksToList(taskIds, destListId);
}

void TasksListModel::commitAddedTasks()
{
    Database->commitAddedTasks();
}

void TasksListModel::rollbackAddedTasks()
{
    Database->rollbackAddedTasks();
}

void TasksListModel::onBeginInsertRow(int r)
{
    beginInsertRows(QModelIndex(), r, r);
}

void TasksListModel::onBeginInsertRows(int r, int c)
{
    beginInsertRows(QModelIndex(), r, r + c - 1);
}

void TasksListModel::onEndInsertRow()
{
    endInsertRows();
    emit countChanged();
    emit icountChanged();
}

void TasksListModel::onBeginRemoveRow(int r)
{
    beginRemoveRows(QModelIndex(), r, r);
}

void TasksListModel::onBeginRemoveRows(int r, int c)
{
    qDebug() << "begin remove " << r << " -- " << r + c - 1;
    beginRemoveRows(QModelIndex(), r, r + c - 1);
}

void TasksListModel::onEndRemoveRow()
{
    endRemoveRows();
    emit countChanged();
    emit icountChanged();
}

void TasksListModel::onBeginMoveRow(int r, int d)
{
    if (r == d)
        return;
    QModelIndex index;
    if (r < d) {
        beginMoveRows(index, r+1,d, index, r);
    } else {
        beginMoveRows(index, r, r , index, d);
    }
}

void TasksListModel::onEndMoveRow()
{
    endMoveRows();
}

void TasksListModel::onBeginReset()
{
    beginResetModel();
}

void TasksListModel::onEndReset()
{
    endResetModel();
}

void TasksListModel::onUpdateRow(int r)
{
    QModelIndex idx = index(r, 0, QModelIndex());
    emit dataChanged(idx, idx);
}

void TasksListModel::onIcountChanged()
{
    emit icountChanged();
}

QVariant TasksListModel::taskRole(TasksTaskItem *task, int role) const
{
    if (!task)
        return QVariant();
    if (role == TaskID)
        return QVariant(task->id());
    else if (role == Task)
        return QVariant(task->task());
    else if (role == Notes)
        return QVariant(task->notes());
    else if (role == Complete)
        return QVariant(task->isComplete());
    else if (role == HasDueDate)
        return QVariant(task->hasDueDate());
    else if (role == DueDate)
        return QVariant(task->dueDate());
    else if (role == Reminder)
        return QVariant(task->reminderType());
    else if (role == ReminderDate)
        return QVariant(task->reminderDate());
    else if (role == Urls)
        return QVariant(task->urls());
    else if (role == Attachments)
        return QVariant(task->attachments());
    else if (role == ListName)
        return QVariant(task->list()->name());
    else if (role == ListID)
        return QVariant(task->list()->id());
    return QVariant();
}

static bool lessThen(const QPair<TasksTaskItem *, int> &a, const QPair<TasksTaskItem *, int> &b)
{
    return a.first->dueDate() < b.first->dueDate();
}

static bool greaterThen(const QPair<TasksTaskItem *, int> &a, const QPair<TasksTaskItem *, int> &b)
{
    return a.first->dueDate() > b.first->dueDate();
}

void TasksListModel::sort(int column, Qt::SortOrder order)
{
    Q_UNUSED(column);

    QList<TasksTaskItem *> *tasks = 0;
    if (m_modelType == Timeview) {
        if (m_timeGroups == Someday)
            tasks = &Database->m_somedayTasks;
        else if (m_timeGroups == Overdue)
            tasks = &Database->m_overdueTasks;
        else if (m_timeGroups == Upcoming)
           tasks = &Database->m_upcomingTasks;
    } else if (m_modelType == List && Database->m_listsMap.contains(m_listId)) {
        TasksListItem *list = Database->m_listsMap[m_listId];
        tasks = &list->taskList();
    }

    if (!tasks)
        return;

    emit layoutAboutToBeChanged();

    QList<QPair<TasksTaskItem *, int> > list;
    for (int i = 0; i < tasks->count(); ++i)
        list << qMakePair(tasks->at(i), i);

    if (order == Qt::AscendingOrder) {
        qSort(list.begin(), list.end(), lessThen);
    } else {
        qSort(list.begin(), list.end(), greaterThen);
    }

    tasks->clear();
    QVector<int> forwarding(list.count());
    for (int i = 0; i < list.count(); ++i) {
        tasks->append(list[i].first);
        forwarding[list[i].second] = i;
    }

    QModelIndexList oldIndexes = persistentIndexList();
    QModelIndexList newIndexes;
    for (int i = 0; i < oldIndexes.count(); ++i)
        newIndexes << index(forwarding[oldIndexes[i].row()], 0);
    changePersistentIndexList(oldIndexes, newIndexes);

    emit layoutChanged();
    emit modelSorted();
}
