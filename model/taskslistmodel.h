/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef TASKSLISTMODEL_H
#define TASKSLISTMODEL_H

#include <QAbstractListModel>
#include <QList>
#include "taskslistitem.h"
#include <QStringList>

class TasksDatabase;
class TasksTaskItem;

class TasksListModel : public QAbstractListModel
{
        Q_OBJECT
        Q_ENUMS(ReminderType)
        Q_ENUMS(ModelType)
        Q_ENUMS(TimeGroups)
        Q_ENUMS(TasksTaskItem::ReminderType)
        Q_ENUMS(SortOrder)
        Q_PROPERTY(ModelType modelType READ modelType WRITE setModelType NOTIFY modelTypeChanged);
        Q_PROPERTY(TimeGroups timeGroups READ timeGroups WRITE setTimeGroups NOTIFY timeGroupsChanged);
        Q_PROPERTY(int listId READ listId WRITE setListId NOTIFY listIdChanged);
        Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged);
        Q_PROPERTY(int count READ count NOTIFY countChanged);
        Q_PROPERTY(int icount READ icount NOTIFY icountChanged);
        Q_PROPERTY(SortOrder sortOrder READ sortOrder NOTIFY modelSorted);
        Q_PROPERTY(QStringList nameList READ nameList NOTIFY nameListChanged);
public:
        enum ReminderType {
                NoReminder,
                OnDueDate,
                OneDayBefore,
                TwoDaysBefore,
                OneWeekBefore,
                DateReminder};
        enum TimeGroups {
                All,
                Overdue,
                Upcoming,
                Someday
        };
        enum Role {
                TaskID = Qt::UserRole + 1,
                Task = Qt::UserRole + 2,
                Notes = Qt::UserRole + 3,
                Complete = Qt::UserRole + 4,
                HasDueDate = Qt::UserRole + 5,
                DueDate = Qt::UserRole + 6,
                Reminder = Qt::UserRole + 7,
                ReminderDate = Qt::UserRole + 8,
                Urls = Qt::UserRole + 9,
                Attachments = Qt::UserRole + 10,
                ListName = Qt::UserRole + 11,
                ListID = Qt::UserRole + 12,
                ListCount = Qt::UserRole + 13,
                ListIncompletedCount = Qt::UserRole + 14
        };
        enum ModelType {
                AllLists = 0,
                AllTimeView = 1,
                List = 2,
                Timeview = 3,
                AllTasks = 4
        };
        enum SortOrder { ASC = Qt::AscendingOrder, DESC = Qt::DescendingOrder };
        explicit TasksListModel();
        ~TasksListModel();

        ModelType modelType() const {return m_modelType; }
        void setModelType(ModelType t);

        TimeGroups timeGroups() const {return m_timeGroups; }
        void setTimeGroups(TimeGroups timeGroups);

        int listId() const {return m_listId; }
        void setListId(int listId);

        QString filter() const;
        void setFilter(const QString &filter);

        int count() const { return rowCount(); }
        int icount() const;
        virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
        virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
        virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
        //virtual bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);
        virtual Qt::ItemFlags flags(const QModelIndex &index) const;

        virtual bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex());
        virtual bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex());

        virtual void sort(int column, Qt::SortOrder order);

        SortOrder sortOrder() const { return m_sortOrder; }

        QStringList nameList();

public slots:
        void addList(const QString &name);
        void renameList(int listId, const QString &name);
        void removeList(int listId);
        void addTask(int listId, const QString &task, const QString &notes, bool complete,
                     bool hasDueDate, const QDate &dueDate,
                     ReminderType reminderType, const QDate &reminderDate,
                     const QStringList &urls, const QStringList &attachments);
        void addTaskAlt(int listId, const QString &task, bool complete,
                     bool hasDueDate, const QDate &dueDate);
        void editTask(int taskId, int listId, const QString &task, const QString &notes,
                      bool hasDueDate, const QDate &dueDate,
                      ReminderType reminderType, const QDate &reminderDate,
                      const QStringList &urls, const QStringList &attachments);
        void removeCompletedTasksInList(int listId);
        void removeAllCompletedTasks();
        void setCompleted(int taskId, bool completed);
        void removeTask(int taskId);
        void removeTasks(const QStringList &taskIds);
        void reorderTask(int taskId, int destidx);
        void hideTasks(const QStringList &taskIds);
        void showHiddenTasks(int listId, int startIndex);
        void showHiddenTasksOldPositions(int listId);
        void saveReorder(int listId);
        void moveTasksToList(const QStringList &taskIds, int destListId);
        void commitAddedTasks();
        void rollbackAddedTasks();
        void sort(SortOrder order) { m_sortOrder = order; sort(0, Qt::SortOrder(order)); }

signals:
        void modelTypeChanged(ModelType t);
        void timeGroupsChanged(TimeGroups t);
        void listIdChanged(int id);
        void countChanged();
        void icountChanged();
        void modelSorted();
        void filterChanged();
        void nameListChanged();

private slots:
        void onBeginInsertRow(int r);
        void onBeginInsertRows(int r, int c);
        void onEndInsertRow();
        void onBeginRemoveRow(int r);
        void onBeginRemoveRows(int r, int c);
        void onEndRemoveRow();
        void onBeginMoveRow(int r, int d);
        void onEndMoveRow();
        void onBeginReset();
        void onEndReset();
        void onUpdateRow(int r);
        void onIcountChanged();

private:
        QVariant taskRole(const TasksTaskItem& task, int role) const;
        void doFiltering();

        friend class TasksDatabase;
        ModelType m_modelType;
        TimeGroups m_timeGroups;
        int m_listId;
        QString m_filter;

        QList<TasksListItem> m_taskListsFiltered;
        QList<TasksTaskItem> m_tasksFiltered;

        SortOrder m_sortOrder;
};

#endif // TASKSLISTMODEL_H
