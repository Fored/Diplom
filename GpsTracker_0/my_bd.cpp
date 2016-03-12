#include "my_bd.h"
#include <QDebug>

my_bd::my_bd(QObject *parent) :
    QObject(parent)
{
    left_sync = 0;
    db_record = QSqlDatabase::addDatabase("QSQLITE","OTHER");
    db_record.setDatabaseName("/storage/emulated/0/Download/my_bd.db");
    //db_record.setDatabaseName("D:\my_bd.db");
    db_record.open();
    db_route = QSqlDatabase::database("OTHER");
    q_record = QSqlQuery("", db_record);
    q_record.prepare("CREATE TABLE IF NOT EXISTS coordinate (id INTEGER, datatime TEXT, latitude REAL, longitude REAL)");
    q_record.exec();
    q_route = QSqlQuery("", db_route);
    q_sync = QSqlQuery("", db_route);
    networkManager = new QNetworkAccessManager(this);
    // Подключаем networkManager к обработчику ответа
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(insertDotRes(QNetworkReply*)));
    //sync("2016-03-07 02:17:34");

}

QGeoCoordinate my_bd::getDot()
{
    return dot;
}

void my_bd::setDot(const QGeoCoordinate tck)
{

}

int my_bd::getLeft_sync()
{
    return left_sync;
}

void my_bd::setLeft_sync(const int l_s)
{

}

//QQmlListProperty<QGeoCoordinate> my_bd::path()
//{
//    return QQmlListProperty<QGeoCoordinate> (this, dots);
//}

void my_bd::insertDot(int user, QString cur_time, QString latitude, QString longitude)
{
    QUrl url("http://foredev.heliohost.org/gps.php");
    QUrlQuery urlq;
    //Составляем запрос серверу на вставку точки
    urlq.addQueryItem("action", "insert");
    urlq.addQueryItem("user", QString::number(user));
    urlq.addQueryItem("datetime", cur_time);
    urlq.addQueryItem("latitude", latitude);
    urlq.addQueryItem("longitude", longitude);
    //Собираем все в один Url
    url.setQuery(urlq);
    networkManager->get(QNetworkRequest(url));
}

void my_bd::sync(QString datetime)
{
    q_sync.prepare(QString("SELECT COUNT(*) FROM coordinate WHERE "
                            "Id = %1 AND datatime > '%2' AND datatime < '%3'").arg(1).arg(datetime).arg("2016-03-07 03:28:21"));
    q_sync.exec();
    q_sync.next();
    left_sync = q_sync.value(0).toInt();
    emit editLeft_sync();
    q_sync.prepare(QString("SELECT datatime, latitude, longitude FROM coordinate WHERE "
                            "Id = %1 AND datatime > '%2' AND datatime < '%3'").arg(1).arg(datetime).arg("2016-03-07 03:28:21"));
    q_sync.exec();
    qDebug() << left_sync;
    if (q_sync.next())
    {
        insertDot(1, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
    }
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

void my_bd::insertDotRes(QNetworkReply *reply)
{
    if(!reply->error()){
        QByteArray answer = reply->readAll();
        reply->deleteLater();
        qDebug() << answer;
        left_sync--;
        emit editLeft_sync();
        qDebug() << left_sync;
        if (q_sync.next())
        {
            insertDot(1, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
        }
    }
    else {
        qDebug() << reply->error();
    }
}

void my_bd::test()
{
    qDebug() << "Есть сигнал";
}

