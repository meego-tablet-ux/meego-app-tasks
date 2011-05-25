/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "qsettingsbackend.h"

#include <QtDeclarative/qdeclarative.h>
#include <QDate>

static const QString generalGroup = "General/";
static const QString isRunningFirstTimeKey = "isRunningFirstTime";

QmlSetting::QmlSetting(QDeclarativeItem *parent):
        QDeclarativeItem(parent),
    m_settings("MeeGo", "meego-app-tasks")
{
    // By default, QDeclarativeItem does not draw anything. If you subclass
    // QDeclarativeItem to create a visual item, you will need to uncomment the
    // following line:

    // setFlag(ItemHasNoContents, false)
}

QmlSetting::~QmlSetting()
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

void QmlSetting::setRunningFirstTime(bool first)
{
    if (first == isRunningFirstTime())
        return;
    m_settings.setValue(generalGroup + isRunningFirstTimeKey, first);
    m_settings.sync();
}

QString QmlSetting::localDate(const QDate &date, int format) const
{
    return date.toString(formatString(format));
}

QString QmlSetting::formatString(int format) const
{
    QString res;
    switch (format) {
    case DateMonthDay:
        res = tr("MMMM d");
        break;
    case DateFullNumShort:
        res = m_locale.dateFormat(QLocale::ShortFormat);
        break;
    default:
        qDebug() << Q_FUNC_INFO << "unknown format" << format;
        break;
    }
    return res;
}
