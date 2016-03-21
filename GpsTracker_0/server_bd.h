#ifndef SERVER_BD_H
#define SERVER_BD_H
#include <QtSql>
#include <QSqlQuery>
#include <QDesktopServices>
#include <QNetworkConfigurationManager>
#include <QNetworkSession>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QList>
#include "my_bd.h"


class server_bd : public my_bd
{
    Q_OBJECT

public:
    explicit server_bd(QObject *parent = 0);

    void insertDot(int user, QString cur_time, QString latitude, QString longitude);



//signals:

public slots:
    void insertDotRes(QNetworkReply *reply);
    void sync(QString datetime);//Закачиваем данные из локальной бд на серверную бд
    void get_max_on_server(int u);
    void get_max_on_serverRes(QNetworkReply *reply);
    int test();
    void server_sync();

private:
    QSqlQuery q_sync;
    QNetworkAccessManager *networkManager;
    QNetworkAccessManager *net_max_serv;
    QNetworkAccessManager *network_sync;
    QString max_on_server;
    bool online;
    bool server_ready;
};

#endif // SERVER_BD_H
