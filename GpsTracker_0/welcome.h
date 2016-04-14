#ifndef WELCOME_H
#define WELCOME_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QUrl>
#include <QUrlQuery>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

class welcome : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int user READ getUser /*NOTIFY loginOk*/)
public:
    explicit welcome(QObject *parent = 0);
    QNetworkAccessManager *networkManager;
    QNetworkAccessManager *network_signup;
    QTimer *timer;
    int user;
    int getUser();


signals:
    void loginOk();
    void offline();
    void notlogin();
    void loginExist();

public slots:
    void login(QString log, QString pass);
    void loginRes(QNetworkReply *reply);
    void timeout();
    void signup(QString log, QString pass);
    void signupRes(QNetworkReply *reply);

private:
    QUrl mainUrl;
};

#endif // WELCOME_H
