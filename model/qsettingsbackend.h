/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef QSETTINGSBACKEND_H
#define QSETTINGSBACKEND_H

#include <QtDeclarative/QDeclarativeItem>
#include <QtCore/QVariant>
#include <QtCore/QSettings>

class QmlSetting : public QDeclarativeItem
{
    Q_OBJECT
    Q_DISABLE_COPY(QmlSetting)

    Q_PROPERTY(QString organization READ organization CONSTANT)
    Q_PROPERTY(QString application READ application CONSTANT)
    Q_PROPERTY(bool isRunningFirstTime READ isRunningFirstTime WRITE setRunningFirstTime NOTIFY isRunningFirstTimeChanged)

public:

    QmlSetting(QDeclarativeItem *parent = 0);
    ~QmlSetting();

    QString organization();
    QString application();

    void setRunningFirstTime(bool first);
    bool isRunningFirstTime() const;

signals:
    void valueChanged(const QString& key, const QVariant &value);
    void isRunningFirstTimeChanged();

public slots:
    QVariant get(const QString& key) const;
    void set(const QString& key, const QVariant &value);

private slots:
    void saveSettings();

private:
    QSettings m_settings;
};

QML_DECLARE_TYPE(QmlSetting)

#endif // QSETTINGSBACKEND_H
