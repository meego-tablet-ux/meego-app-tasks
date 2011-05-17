/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "qsettingsbackend.h"

#include <QtDeclarative/qdeclarative.h>
#include <QApplication>

static const QString generalGroup = "General/";
static const QString isRunningFirstTimeKey = "isRunningFirstTime";

QmlSetting::QmlSetting(QDeclarativeItem *parent):
        QDeclarativeItem(parent),
    m_settings("MeeGo", "meego-app-tasks")
{
    // By default, QDeclarativeItem does not draw anything. If you subclass
    // QDeclarativeItem to create a visual item, you will need to uncomment the
    // following line:

    // setFlag(ItemHasNoContents, false);

    connect(qApp, SIGNAL(aboutToQuit()), SLOT(saveSettings()));
}

QmlSetting::~QmlSetting()//WARNING: dtor is never called
{
}

QString QmlSetting::organization()
{
    return m_settings.organizationName();
}

QString QmlSetting::application()
{
    return m_settings.applicationName();
}

QVariant QmlSetting::get(const QString& key) const
{
    return m_settings.value(generalGroup + key);
}

void QmlSetting::set(const QString& key, const QVariant &value)
{
    m_settings.setValue(generalGroup + key, value);
    emit valueChanged(key, value);
}

bool QmlSetting::isRunningFirstTime() const
{
    return m_settings.value(generalGroup + isRunningFirstTimeKey, true).toBool();
}

void QmlSetting::saveSettings()
{
    if (isRunningFirstTime())
        m_settings.setValue(generalGroup + isRunningFirstTimeKey, false);
    m_settings.sync();
}
