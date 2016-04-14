#ifndef MY_BD_H
#define MY_BD_H

#include <QObject>
#include <QtSql>
#include <QGeoPositionInfo>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>

class my_bd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QGeoCoordinate dot READ getDot NOTIFY editDot)
    Q_PROPERTY(int left_sync READ getLeft_sync NOTIFY editLeft_sync)
public:
    explicit my_bd(QObject *parent = 0);
    QGeoCoordinate getDot();
    double shirota;
    double dolgota;
    QSqlDatabase db_route;
    int left_sync;
    int getLeft_sync();
    QString max_on_my_bd;
    QSqlQuery q_record;
    QSqlQuery q_route;
    QGeoCoordinate dot;


signals:
    void editDot();
    void editLeft_sync();

public slots:
    void setProfile(int id, QString log, QString pass);
    void recordDot(int user, QString cur_time, double latitude, double longitude);
    void route (int user, QString start, QString end);
    void exit();

private:

    QSqlDatabase db_record;


};

#endif // MY_BD_H
