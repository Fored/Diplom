#ifndef VK_LOGIN_H
#define VK_LOGIN_H
#include <QObject>
#include <QDesktopServices>
#include <QUrl>
#include <QUrlQuery>
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QCryptographicHash>

struct vk_user
{
    int id;
    QString login;
    int id_vk;
    QString first_name;
    QString last_name;
    QString photo;
    double latitude;
    double longitude;
    QString datetime;
};

class vk_login : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString mainphoto READ getmainphoto NOTIFY editmainphoto)
    Q_PROPERTY(QString photo READ getPhoto NOTIFY editphoto)
    Q_PROPERTY(QString name READ getName NOTIFY editname)
    Q_PROPERTY(QString login READ getLogin NOTIFY editlogin)
    Q_PROPERTY(double latitude READ getlatitude NOTIFY editlatitude)
    Q_PROPERTY(double longitude READ getlongitude NOTIFY editlongitude)
    Q_PROPERTY(QString datetime READ getdatetime NOTIFY editdatetime)
    Q_PROPERTY(QString here_photo READ getHerePhoto)
    Q_PROPERTY(QString here_name READ getHereName)
    Q_PROPERTY(QString here_login READ getHereLogin)

public:
    explicit vk_login(QObject *parent = 0);
    QString getmainphoto();
    QString getPhoto();
    QString getName();
    QString getLogin();
    double getlatitude();
    double getlongitude();
    QString getdatetime();
    QString getHerePhoto();
    QString getHereName();
    QString getHereLogin();
    void enddots();



signals:
    void editmainphoto();
    void editphoto();
    void editname();
    void editlogin();
    void editlatitude();
    void editlongitude();
    void editdatetime();
    void yesVk();
    void editherefriend();
    void editlistfriend();


public slots:    
    void setAccess_token(QUrl url, int u);
    void getFriend(int u);
    void friendHere();
    void listfriend();
    void getFriendRes(QNetworkReply *reply);
    void namephotoRes(QNetworkReply *reply);
    void gettokenRes(QNetworkReply *reply);
    void enddotsRes(QNetworkReply *reply);
    void friendHereRes(QNetworkReply *reply);
    void vkFriendRes(QNetworkReply *reply);
    void vkfriendnamephotoRes(QNetworkReply *reply);
    //QString getphoto(int u);
    //QString getname(int u);
    //QString getlogin(int u);
    void nextUser();
    void selectUserPhoto(int i);
    void selectUser(int i);
    void previousUser();

private:    
    int user;
    QUrl mainUrl;
    QNetworkAccessManager *network_token;
    QNetworkAccessManager *network_getfriend;
    QNetworkAccessManager *network_namephoto;
    QNetworkAccessManager *network_gettoken;
    QNetworkAccessManager *network_enddots;
    QNetworkAccessManager *network_friendhere;
    QNetworkAccessManager *network_vkfriend;
    QNetworkAccessManager *network_vkfriendnamephoto;
    QVector<vk_user> vk_users;
    QVector<int> contents;
    QString token;
    QString secret;
    QString mainphoto;
    QString photo;
    QString name;
    QString login;
    double latitude;
    double longitude;
    QString datetime;
    int ind;
    QVector<vk_user> frHere;
    QString here_login;
    QString here_name;
    QString here_photo;
};

#endif // VK_LOGIN_H
