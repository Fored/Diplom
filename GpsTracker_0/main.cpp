#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQmlComponent>
#include <QGeoPositionInfo>
#include <QSqlQuery>
#include "my_bd.h"
#include "server_bd.h"
#include "welcome.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    //qmlRegisterType<my_bd>("ModuleBD", 1, 0, "MyBd");
    qmlRegisterType<server_bd>("ServerBD", 1, 0, "ServBd");
    qmlRegisterType<welcome>("Welcome", 1, 0, "Welcome");
    qmlRegisterType<QGeoCoordinate>();
    //qmlRegisterType<QSqlQuery>();
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

