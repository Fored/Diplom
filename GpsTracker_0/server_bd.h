#ifndef SERVER_BD_H
#define SERVER_BD_H
#include <QtSql>
#include <QSqlQuery>
#include <QDesktopServices>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include "my_bd.h"


class server_bd : public my_bd
{
    Q_OBJECT
    Q_PROPERTY(int user READ getUser WRITE setUser/*NOTIFY loginOk*/)

public:
    explicit server_bd(QObject *parent = 0);

    void insertDot(int user, QString cur_time, QString latitude, QString longitude);
    int getUser();
    void setUser(int u);

//signals:


public slots:
    void insertDotRes(QNetworkReply *reply = 0);
    void sync();//Закачиваем данные из локальной бд на серверную бд
    void get_max_on_server(int u);
    void get_max_on_serverRes(QNetworkReply *reply);
    int test();
    void server_sync();
    void onlineRes(QNetworkReply *reply);
    void onlineRes();


private:
    QSqlQuery q_sync;
    QNetworkAccessManager *networkManager;
    QNetworkAccessManager *net_max_serv;
    //QNetworkAccessManager *network_sync;
    QNetworkAccessManager *network_online;
    QString max_on_server;
    bool online;
    bool server_ready;
    QTimer *timer;
    bool login;
    int user;
};

#endif // SERVER_BD_H
