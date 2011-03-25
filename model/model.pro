TEMPLATE = lib
TARGET = Tasks
QT += declarative
CONFIG += qt plugin link_pkgconfig

PKGCONFIG += libkcalcoren libmkcal

OBJECTS_DIR = .obj
MOC_DIR = .moc

TARGET = $$qtLibraryTarget($$TARGET)
DESTDIR = $$TARGET

# Input
SOURCES += tasks.cpp \
    taskslistitem.cpp \
    taskstaskitem.cpp \
    tasksdatabase.cpp \
    taskslistmodel.cpp \
    tasksdbengine.cpp \
    qsettingsbackend.cpp
HEADERS += tasks.h \
    taskslistitem.h \
    taskstaskitem.h \
    tasksdatabase.h \
    taskslistmodel.h \
    tasksdbengine.h \
    qsettingsbackend.h

QMAKE_POST_LINK = cp qmldir $$DESTDIR

qmlfiles.files += $$TARGET
qmlfiles.path += $$[QT_INSTALL_IMPORTS]/MeeGo/App
INSTALLS += qmlfiles
