#include "server_bd.h"

server_bd::server_bd(QObject *parent) : my_bd(parent)
{
    q_sync = QSqlQuery("", db_route);
    networkManager = new QNetworkAccessManager(this);
    // Подключаем networkManager к обработчику ответа
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(insertDotRes(QNetworkReply*)));
    net_max_serv = new QNetworkAccessManager(this);
    connect(net_max_serv, SIGNAL(finished(QNetworkReply*)), this, SLOT(get_max_on_serverRes(QNetworkReply*)));
    network_online = new QNetworkAccessManager(this);
    connect(network_online, SIGNAL(finished(QNetworkReply*)), this, SLOT(onlineRes(QNetworkReply*)));
    network_select = new QNetworkAccessManager(this);
    connect(network_select, SIGNAL(finished(QNetworkReply*)), this, SLOT(routeServRes(QNetworkReply*)));
    online = false;
    max_on_server = "null";
    server_ready = true;
    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(onlineRes()));
    timer_sync = new QTimer(this);
    connect(timer_sync, SIGNAL(timeout()), this, SLOT(server_sync()));
    q_route.exec("SELECT COUNT(*) FROM profile");
    q_route.next();
    if (q_route.value(0).toInt() == 1)
    {
        q_route.exec("SELECT id FROM profile");
        q_route.next();
        user = q_route.value(0).toInt();
        qDebug() << user;
    }
    else
    {
        user = 0;
    }
    mainUrl.setUrl("http://rhombic-subordinate.000webhostapp.com/gps.php");
    timer_sync->start(10000);
    current_user = 0;

    //q_route.exec("INSERT INTO sync (datetime) VALUES ('45')");
    //sync("2016-03-07 02:17:34");

}

void server_bd::sync()
{
    server_ready = false;
    q_sync.exec("SELECT MAX(datetime) FROM sync");
    q_sync.next();
    max_on_my_bd = q_sync.value(0).toString();
    //qDebug() << max_on_my_bd;
    if (max_on_my_bd == "")
    {
        server_ready = true;
    }
    else
    {    
    q_sync.prepare(QString("SELECT COUNT(*) FROM sync WHERE "
                            "datetime <= '%2'").arg(max_on_my_bd));
    q_sync.exec();
    q_sync.next();
    left_sync = q_sync.value(0).toInt();
    emit editLeft_sync();
    q_sync.prepare(QString("SELECT datetime, latitude, longitude FROM sync WHERE "
                            "datetime <= '%2'").arg(max_on_my_bd));
    q_sync.exec();
    q_sync.next();
    insertDot(user, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
    }
}

int server_bd::test()
{
    //QUrl url("https://www.instagram.com");
       //QDesktopServices::openUrl(url);
    q_route.exec("SELECT COUNT(*) FROM sync");
    q_route.next();
    return q_route.value(0).toInt();

}

void server_bd::server_sync()
{
    //qDebug() << "online" << online;
    //qDebug() << "server_ready" << server_ready;
    if (server_ready == true)
    {
        if (online == false)
        {
            server_ready = false;
            QUrl url(mainUrl);
            network_online->get(QNetworkRequest(url));
            timer->start(10000);
        }
        else
        {
            if (max_on_server == "null")
            {
                get_max_on_server(user);
            }
            else
            {
                sync();
            }
        }
    }
}

void server_bd::onlineRes(QNetworkReply *reply)
{
    if(!reply->error()){
        online = true;
        //qDebug() << "online";
    }
    else
    {
        //qDebug() << "offline";
    }
    reply->deleteLater();
    timer->stop();
    server_ready = true;
}

void server_bd::onlineRes()
{
    timer->stop();
    server_ready = true;
    qDebug() << "offline->timeout";
}

void server_bd::routeServ(int u, QString min, QString max)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "select");
    urlq.addQueryItem("user", QString::number(u));
    urlq.addQueryItem("min", min);
    urlq.addQueryItem("max", max);
    url.setQuery(urlq);
    qDebug() << url;
    network_select->get(QNetworkRequest(url));
    dateDots.clear();
}

void server_bd::routeServRes(QNetworkReply *reply)
{
    if(!reply->error()){
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            dot = QGeoCoordinate(subtree.value("latitude").toString().toDouble(), subtree.value("longitude").toString().toDouble());
            emit editDot();
            dateDots.append(subtree.value("datetime").toString());
        }
    }
    reply->deleteLater();
    emit routeServResEnd();
}

QString server_bd::getDateDot(int i)
{
    return dateDots.at(i);
}

int server_bd::getCurrent_user()
{
    return current_user;
}

void server_bd::setCurrent_user(int u)
{
    current_user = u;
}

void server_bd::insertDot(int user, QString cur_time, QString latitude, QString longitude)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    //Составляем запрос серверу на вставку точки
    urlq.addQueryItem("action", "insert");
    urlq.addQueryItem("user", QString::number(user));
    urlq.addQueryItem("datetime", cur_time);
    urlq.addQueryItem("latitude", latitude);
    urlq.addQueryItem("longitude", longitude);
    //Собираем все в один Url
    url.setQuery(urlq);
    qDebug() << url;
    networkManager->get(QNetworkRequest(url));
}

int server_bd::getUser()
{
    return user;
}

void server_bd::setUser(int u)
{
    user = u;
}

void server_bd::insertDotRes(QNetworkReply *reply)
{
    if(!reply->error()){
        left_sync--;
        emit editLeft_sync();
        if (q_sync.next())
        {
            insertDot(user, q_sync.value(0).toString(), q_sync.value(1).toString(),q_sync.value(2).toString());
        }
        else
        {
            q_sync.prepare(QString("DELETE FROM sync WHERE datetime <= '%1'").arg(max_on_my_bd));
            q_sync.exec();
            server_ready = true;
        }
    }
    else {
        //qDebug() << reply->error();
        online = false;
        server_ready = true;
        QString str = q_sync.value(0).toString();
        q_sync.prepare(QString("DELETE FROM sync WHERE datetime < '%1'").arg(str));
        q_sync.exec();
        //max_on_server = "null";
        //left_sync = 0;
        //emit editLeft_sync();
    }
    reply->deleteLater();
}

void server_bd::get_max_on_server(int u)
{
    server_ready = false;
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "max");
    urlq.addQueryItem("user", QString::number(u));
    url.setQuery(urlq);
    qDebug() << url;
    net_max_serv->get(QNetworkRequest(url));
}

void server_bd::get_max_on_serverRes(QNetworkReply *reply)
{
    // Если ошибки отсутсвуют
    if(!reply->error()){
        // То создаём объект Json Document, считав в него все данные из ответа
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        QJsonObject r = ja.at(0).toObject();
        max_on_server = r.value(r.keys().at(0)).toString();
        qDebug() << max_on_server;
        /* Если во время синхронизации приложение отключили, то максимальное
        datetime на сервере не совпадает с минимальным datetime в таблице sync.
        Поэтому очистим, то что успели синхронизировать из sync*/
        q_sync.prepare(QString("DELETE FROM sync WHERE datetime <= '%1'").arg(max_on_server));
        q_sync.exec();
    }
    else
    {
        online = false;
    }
    server_ready = true;
    reply->deleteLater();
}


