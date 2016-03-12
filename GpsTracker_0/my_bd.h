#ifndef MY_BD_H
#define MY_BD_H

#include <QObject>
#include <QtSql>
#include <QGeoPositionInfo>
#include <QQmlListProperty>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>

class my_bd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QGeoCoordinate dot READ getDot WRITE setDot NOTIFY editDot)
    Q_PROPERTY(int left_sync READ getLeft_sync WRITE setLeft_sync NOTIFY editLeft_sync)
    //Q_PROPERTY(QQmlListProperty<QGeoCoordinate> path READ path/* NOTIFY editDots*/)
public:
    explicit my_bd(QObject *parent = 0);
    QGeoCoordinate getDot();
    void setDot (const QGeoCoordinate tck);
    //QQmlListProperty<QGeoCoordinate> path();
    double shirota;
    double dolgota;
    int left_sync;
    int getLeft_sync();
    void setLeft_sync(const int l_s);
    void insertDot(int user, QString cur_time, QString latitude, QString longitude);

signals:
    void editDot();
    //void editDots();
    void editLeft_sync();
public slots:
    void recordDot(int user, QString cur_time, double latitude, double longitude);
    void route (int user, QString start, QString end);
    void insertDotRes(QNetworkReply *reply);
    void test();
    void sync(QString datetime);//Закачиваем данные из локальной бд на серверную бд
private:
    QGeoCoordinate dot;
    QSqlDatabase db_record;
    QSqlDatabase db_route;
    QSqlQuery q_record;
    QSqlQuery q_route;
    QSqlQuery q_sync;
    //QList<QGeoCoordinate> d;
    //QList<QGeoCoordinate *> dots;
    QNetworkAccessManager *networkManager;

};

#endif // MY_BD_H
