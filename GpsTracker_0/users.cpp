#include "users.h"

Users::Users(QObject *parent) : QObject(parent)
{
    mainUrl.setUrl("http://rhombic-subordinate.000webhostapp.com/gps.php");
    network_get_friend = new QNetworkAccessManager(this);
    connect(network_get_friend, SIGNAL(finished(QNetworkReply*)), this, SLOT(getFriendRes(QNetworkReply*)));
    network_find_user = new QNetworkAccessManager(this);
    connect(network_find_user, SIGNAL(finished(QNetworkReply*)), this, SLOT(findUserRes(QNetworkReply*)));
    network_request = new QNetworkAccessManager(this);
    connect(network_request, SIGNAL(finished(QNetworkReply*)), this, SLOT(requestRes(QNetworkReply*)));
    network_get_request = new QNetworkAccessManager(this);
    connect(network_get_request, SIGNAL(finished(QNetworkReply*)), this, SLOT(getRequestRes(QNetworkReply*)));

}

QString Users::getLogin()
{
    return us.login;
}

void Users::getFriend(int u)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "getfriend");
    urlq.addQueryItem("user", QString::number(u));
    url.setQuery(urlq);
    qDebug() << url;
    network_get_friend->get(QNetworkRequest(url));
    users.clear();
    //us.id = u;
    //us.login = "Это я";
    //users.append(us);

}

void Users::getFriendRes(QNetworkReply *reply)
{
    //emit editLogin();
    if(!reply->error()){
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            us.id = subtree.value("id").toString().toInt();
            us.login = subtree.value("login").toString();
            users.append(us);
            emit editLogin();
        }
    }
    reply->deleteLater();
}

void Users::findUser(QString log, int fol)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "finduser");
    urlq.addQueryItem("login", log);
    urlq.addQueryItem("follower", QString::number(fol));
    url.setQuery(urlq);
    qDebug() << url;
    network_find_user->get(QNetworkRequest(url));
}

void Users::findUserRes(QNetworkReply *reply)
{
    if(!reply->error()){
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();     
        QJsonObject subtree = ja.at(0).toObject();
        foundUser = subtree.value(subtree.keys().at(0)).toString().toInt();
        switch (foundUser) {
        case 0:
            emit notUser();
            break;
        case -1:
            emit yesFollower();
            break;
        case -2:
            emit yesRequest();
            break;
        case -3:
            emit thisYou();
            break;
        default:
            emit yesUser();
            break;
        }
    }
    reply->deleteLater();
}

void Users::request(int f)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "request");
    urlq.addQueryItem("user", QString::number(foundUser));
    urlq.addQueryItem("follower", QString::number(f));
    urlq.addQueryItem("datetime", QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));
    url.setQuery(urlq);
    qDebug() << url;
    network_request->get(QNetworkRequest(url));
}

void Users::requestRes(QNetworkReply *reply)
{
    emit giveAccessyesno();
    reply->deleteLater();
}

void Users::getRequest(int u)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "getrequest");
    urlq.addQueryItem("user", QString::number(u));
    url.setQuery(urlq);
    qDebug() << url;
    network_get_request->get(QNetworkRequest(url));
    users.clear();
}

void Users::getRequestRes(QNetworkReply *reply)
{
    if(!reply->error()){
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            us.id = subtree.value("id").toString().toInt();
            us.login = subtree.value("login").toString();
            users.append(us);
            emit editReq();
        }
    }
    reply->deleteLater();
}

void Users::giveAccess(bool yn, int u, int fol)
{
    if (yn)
    {
        QUrl url(mainUrl);
        QUrlQuery urlq;
        urlq.addQueryItem("action", "giveaccessyes");
        urlq.addQueryItem("user", QString::number(u));
        urlq.addQueryItem("follower", QString::number(fol));
        urlq.addQueryItem("datetime", QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));
        url.setQuery(urlq);
        qDebug() << url;
        network_request->get(QNetworkRequest(url));
        qDebug() << url;
    }
    else
    {
        QUrl url(mainUrl);
        QUrlQuery urlq;
        urlq.addQueryItem("action", "giveaccessno");
        urlq.addQueryItem("user", QString::number(u));
        urlq.addQueryItem("follower", QString::number(fol));
        //urlq.addQueryItem("datetime", QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss"));
        url.setQuery(urlq);
        qDebug() << url;
        network_request->get(QNetworkRequest(url));
    }
}

int Users::getUserId(int index)
{
    if (users.length() > index)
    {
        return users.at(index).id;
    }
    else return 0;
}

