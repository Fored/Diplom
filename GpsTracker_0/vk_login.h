#ifndef VK_LOGIN_H
#define VK_LOGIN_H
#include <QObject>
#include <QDesktopServices>
#include <QUrl>
#include <QUrlQuery>

class vk_login : public QObject
{
    Q_OBJECT
public:
    explicit vk_login(QObject *parent = 0);

public slots:
    void tie(int u); //привязать в странице ВК
};

#endif // VK_LOGIN_H
