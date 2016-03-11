#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QGeoPositionInfo>
#include "my_bd.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<my_bd>("ModuleBD", 1, 0, "MyBd");
    qmlRegisterType<QGeoCoordinate>();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

