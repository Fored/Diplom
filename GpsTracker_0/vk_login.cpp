#include "vk_login.h"

vk_login::vk_login(QObject *parent) :
    QObject(parent)
{

}

void vk_login::tie(int u)
{
    QUrl url1("http://fored.esy.es/gps.php");
    QUrlQuery urlq1;
    urlq1.addQueryItem("user", QString::number(u));
    url1.setQuery(urlq1);
    QUrl url("https://oauth.vk.com/authorize");
    QUrlQuery urlq;
    urlq.addQueryItem("client_id", "5399798");
    urlq.addQueryItem("redirect_uri", url1.toString());
    urlq.addQueryItem("display", "page");
    urlq.addQueryItem("scope", "friends,offline");
    urlq.addQueryItem("v", "5.50");
    url.setQuery(urlq);
    QDesktopServices::openUrl(url);
}

