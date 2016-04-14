TEMPLATE = app

QT += qml quick widgets positioning sql

SOURCES += main.cpp \
    my_bd.cpp \
    server_bd.cpp \
    welcome.cpp \
    vk_login.cpp \
    users.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES +=

HEADERS += \
    my_bd.h \
    server_bd.h \
    welcome.h \
    vk_login.h \
    users.h

