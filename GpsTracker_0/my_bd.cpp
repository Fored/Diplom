#include "my_bd.h"
#include <QDebug>

my_bd::my_bd(QObject *parent) :
    QObject(parent)
{
    db_record = QSqlDatabase::addDatabase("QSQLITE","OTHER");
    //db_record.setDatabaseName("/storage/emulated/0/Download/my_bd.db");
    db_record.setDatabaseName("D:\my_bd.db");
    db_record.open();
    db_route = QSqlDatabase::database("OTHER");
    q_record = QSqlQuery("", db_record);
    q_record.prepare("CREATE TABLE IF NOT EXISTS coordinate (id INTEGER, datatime TEXT, latitude REAL, longitude REAL)");
    q_record.exec();
    q_route = QSqlQuery("", db_route);
}

QGeoCoordinate my_bd::getDot()
{
    return dot;
}

void my_bd::setDot(const QGeoCoordinate tck)
{

}

QQmlListProperty<QGeoCoordinate> my_bd::path()
{
    return QQmlListProperty<QGeoCoordinate> (this, dots);
}

void my_bd::recordDot(int user, QString cur_time, double latitude, double longitude)
{
    if (fabs(latitude - shirota) >= 0.0002 or fabs(longitude - dolgota) >= 0.0002)
    {
        shirota = latitude;
        dolgota = longitude;
        q_record.prepare(QString("INSERT INTO coordinate (id, datatime, latitude, longitude) "
                  "VALUES (%1, '%2', %3, %4)").arg(user).arg(cur_time).arg(latitude).arg(longitude));
        q_record.exec();
    }
}

void my_bd::route(int user, QString start, QString end)
{
    q_route.prepare(QString("SELECT latitude, longitude FROM coordinate WHERE "
                            "Id = %1 AND datatime > '%2' AND datatime < '%3'").arg(user).arg(start).arg(end));
    q_route.exec();
    while (q_route.next())
    {
        dot = QGeoCoordinate(q_route.value(0).toDouble(), q_route.value(1).toDouble());
        emit editDot();
        //d.append(QGeoCoordinate(q_route.value(0).toDouble(), q_route.value(1).toDouble()));
        //dots.append(&d.last());
    }

    //emit editDots();
}

