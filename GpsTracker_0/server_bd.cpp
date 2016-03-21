#include "server_bd.h"

server_bd::server_bd(QObject *parent) : my_bd(parent)
{
    q_sync = QSqlQuery("", db_route);
    networkManager = new QNetworkAccessManager(this);
    // Подключаем networkManager к обработчику ответа
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(insertDotRes(QNetworkReply*)));
    net_max_serv = new QNetworkAccessManager(this);
    connect(net_max_serv, SIGNAL(finished(QNetworkReply*)), this, SLOT(get_max_on_serverRes(QNetworkReply*)));
    online = false;
    max_on_server = "null";
    server_ready = true;
}

void server_bd::sync(QString datetime)
{
    q_sync.prepare(QString("SELECT COUNT(*) FROM coordinate WHERE "
                            "Id = %1 AND datatime > '%2'").arg(1).arg(datetime));
    q_sync.exec();
    q_sync.next();
    left_sync = q_sync.value(0).toInt();
    emit editLeft_sync();
    q_sync.prepare(QString("SELECT datatime, latitude, longitude FROM coordinate WHERE "
                            "Id = %1 AND datatime > '%2' ORDER BY datatime").arg(1).arg(datetime));
    q_sync.exec();
    qDebug() << left_sync;

    if (q_sync.next())
    {
        insertDot(1, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
    }
}

int server_bd::test()
{
    //QUrl url("https://www.instagram.com");
       //QDesktopServices::openUrl(url);
    q_sync.prepare("SELECT COUNT(*) FROM coordinate");
    q_sync.exec();
    q_sync.next();
    return q_sync.value(0).toInt();
}

void server_bd::server_sync()
{
    if (online == false and max_on_server == "null" and server_ready == true)
    {
        get_max_on_server(1);
    }
    else if (online == true and left_sync > 0)
    {

    }
    else if (online == true and left_sync < 1 and server_ready == true)
    {
        get_max_on_server(1);
    }
}

void server_bd::insertDot(int user, QString cur_time, QString latitude, QString longitude)
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

void server_bd::insertDotRes(QNetworkReply *reply)
{
    if(!reply->error()){
        //max_on_server = q_sync.value(0).toString();
//        QByteArray answer = reply->readAll();
//        reply->deleteLater();
//        qDebug() << answer;
        left_sync--;
        emit editLeft_sync();
        //qDebug() << left_sync;
        if (q_sync.next())
        {
            insertDot(1, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
        }
    }
    else {
        //qDebug() << reply->error();
        online = false;
        max_on_server = "null";
        left_sync = 0;
        emit editLeft_sync();
    }
}

void server_bd::get_max_on_server(int u)
{
    server_ready = false;
    QUrl url("http://foredev.heliohost.org/gps.php");
    QUrlQuery urlq;
    urlq.addQueryItem("action", "max");
    urlq.addQueryItem("user", QString::number(u));
    url.setQuery(urlq);
    net_max_serv->get(QNetworkRequest(url));
}

void server_bd::get_max_on_serverRes(QNetworkReply *reply)
{
    server_ready = true;
    // Если ошибки отсутсвуют
    if(!reply->error()){
        online = true;
        // То создаём объект Json Document, считав в него все данные из ответа
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        QJsonObject r = ja.at(0).toObject();
        max_on_server = r.value(r.keys().at(0)).toString();
        sync(max_on_server);
    }
//    else
//    {
//        online = false;
//    }
}


