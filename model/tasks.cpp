/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "tasks.h"
#include "taskstaskitem.h"
#include "taskslistmodel.h"
#include "qsettingsbackend.h"

void tasks::registerTypes(const char *uri)
{
    qmlRegisterType<TasksListModel>(uri, 0, 0, "TasksListModel");
    qmlRegisterType<QmlSetting>(uri, 0, 0, "QmlSetting");
}

void tasks::initializeEngine(QDeclarativeEngine *engine, const char *uri)
{
    Q_UNUSED(uri);
    Q_UNUSED(engine);
}

Q_EXPORT_PLUGIN(tasks);
