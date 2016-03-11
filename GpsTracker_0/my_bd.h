#ifndef MY_BD_H
#define MY_BD_H

#include <QObject>
#include <QtSql>
#include <QGeoPositionInfo>
#include <QQmlListProperty>

class my_bd : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QGeoCoordinate dot READ getDot WRITE setDot NOTIFY editDot)
    Q_PROPERTY(QQmlListProperty<QGeoCoordinate> path READ path/* NOTIFY editDots*/)
public:
    explicit my_bd(QObject *parent = 0);
    QGeoCoordinate getDot();
    void setDot (const QGeoCoordinate tck);
    QQmlListProperty<QGeoCoordinate> path();
    double shirota;
    double dolgota;
signals:
    void editDot();
    void editDots();
public slots:
    void recordDot(int user, QString cur_time, double latitude, double longitude);
    void route (int user, QString start, QString end);
private:
    QGeoCoordinate dot;
    QSqlDatabase db_record;
    QSqlDatabase db_route;
    QSqlQuery q_record;
    QSqlQuery q_route;
    QList<QGeoCoordinate> d;
    QList<QGeoCoordinate *> dots;

};

#endif // MY_BD_H
