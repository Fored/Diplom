#ifndef USERS_H
#define USERS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QVector>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

struct s_user
{
    int id;
    QString login;
};

class Users : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString login READ getLogin/*NOTIFY loginOk*/)
public:
    explicit Users(QObject *parent = 0);
    QNetworkAccessManager *network_get_friend;
    QNetworkAccessManager *network_find_user;
    QNetworkAccessManager *network_request;
    QNetworkAccessManager *network_get_request;
    QUrl mainUrl;
    s_user us;
    QVector <s_user> users;
    s_user req;
    QVector <s_user> requests;
    int foundUser;
    QString getLogin();

signals:
    void editLogin();
    void notUser();
    void yesUser();
    void yesFollower();
    void yesRequest();
    void thisYou();
    void editReq();
    void giveAccessyesno();

public slots:
    void getFriend(int u);
    void getFriendRes(QNetworkReply *reply);
    void findUser(QString log, int fol);
    void findUserRes(QNetworkReply *reply);
    void request(int f);
    void requestRes(QNetworkReply *reply);
    void getRequest(int u);
    void getRequestRes(QNetworkReply *reply);
    void giveAccess(bool yn, int u, int fol);

    int getUserId(int index);
};

#endif // USERS_H
