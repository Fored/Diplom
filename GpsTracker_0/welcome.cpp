#include "welcome.h"

welcome::welcome(QObject *parent) : QObject(parent)
{
    networkManager = new QNetworkAccessManager(this);
    connect(networkManager, SIGNAL(finished(QNetworkReply*)), this, SLOT(loginRes(QNetworkReply*)));
    timer = new QTimer(this);
    connect(timer, SIGNAL(timeout()), this, SLOT(timeout()));
    network_signup = new QNetworkAccessManager(this);
    connect(network_signup, SIGNAL(finished(QNetworkReply*)), this, SLOT(signupRes(QNetworkReply*)));
    mainUrl.setUrl("http://rhombic-subordinate.000webhostapp.com/gps.php");
}

void welcome::loginRes(QNetworkReply *reply)
{
    // Если ошибки отсутсвуют
    if(!reply->error()){
        // То создаём объект Json Document, считав в него все данные из ответа
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        QJsonObject obj = ja.at(0).toObject();
        qDebug() << "(qDeb)=> welcome::loginRes " << obj.keys().at(0);
        qDebug() << "(qDeb)=> welcome::loginRes " << obj.value(obj.keys().at(0)).toString().toInt();

        if (obj.value(obj.keys().at(0)).toString().toInt() == 1)
        {
            user = obj.value("id").toString().toInt();
            qDebug() << "(qDeb)=> welcome::loginRes " << user;
            emit loginOk();
        }
        else
        {
            emit notlogin();
        }
    }
    else
    {
        emit offline();
    }
    reply->deleteLater();
    timer->stop();
}

void welcome::timeout()
{
    timer->stop();
    emit offline();
}

void welcome::signup(QString log, QString pass)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "signup");
    urlq.addQueryItem("login", log);
    urlq.addQueryItem("password", pass);
    url.setQuery(urlq);
    qDebug() << "(qDeb)=> welcome::signup " << url;
    network_signup->get(QNetworkRequest(url));
    timer->start(10000);
}

void welcome::signupRes(QNetworkReply *reply)
{
    // Если ошибки отсутсвуют
    if(!reply->error()){
        // То создаём объект Json Document, считав в него все данные из ответа
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        // Преобразуем документ в массив
        QJsonArray ja = document.array();
        QJsonObject obj = ja.at(0).toObject();
        qDebug() << "(qDeb)=> welcome::signupRes " << obj.value(obj.keys().at(0)).toString().toInt();

        if (obj.value(obj.keys().at(0)).toString().toInt() > 0)
        {
            user = obj.value(obj.keys().at(0)).toString().toInt();
            qDebug() << "(qDeb)=> welcome::signupRes " << user;
            emit loginOk();
        }
        else
        {
            emit loginExist();
        }
    }
    else
    {
        emit offline();
    }
    reply->deleteLater();
    timer->stop();
}

int welcome::getUser()
{
    return user;
}

void welcome::login(QString log, QString pass)
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "login");
    urlq.addQueryItem("login", log);
    urlq.addQueryItem("password", pass);
    url.setQuery(urlq);    
    qDebug() << "(qDeb)=> welcome::login " << url;
    networkManager->get(QNetworkRequest(url));
    timer->start(10000);
}

