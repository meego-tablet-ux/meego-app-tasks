TEMPLATE = subdirs 
SUBDIRS += model
qmlfiles.files += *.qml
qmlfiles.path += $$INSTALL_ROOT/usr/share/$$TARGET

desktopfiles.files += *.desktop
desktopfiles.path += $$INSTALL_ROOT/usr/share/applications

INSTALLS += qmlfiles desktopfiles

QML_FILES = *.qml
LIB_SOURCES += model/*.cpp
LIB_HEADERS += model/*.h
VERSION = 0.2.16
PROJECT_NAME = meego-app-tasks

TRANSLATIONS += $${QML_FILES} $${LIB_SOURCES} $${LIB_HEADERS}

dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += git clone . $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION}/.git &&
dist.commands += rm -f $${PROJECT_NAME}-$${VERSION}/.gitignore &&
dist.commands += mkdir -p $${PROJECT_NAME}-$${VERSION}/ts &&
dist.commands += lupdate $${TRANSLATIONS} -ts $${PROJECT_NAME}-$${VERSION}/ts/$${PROJECT_NAME}.ts &&
dist.commands += tar jcpf $${PROJECT_NAME}-$${VERSION}.tar.bz2 $${PROJECT_NAME}-$${VERSION} &&
dist.commands += rm -fR $${PROJECT_NAME}-$${VERSION} &&
dist.commands += echo; echo Created $${PROJECT_NAME}-$${VERSION}.tar.bz2
QMAKE_EXTRA_TARGETS += dist

OTHER_FILES += $${QML_FILES}
