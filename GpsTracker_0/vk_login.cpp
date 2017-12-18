#include "vk_login.h"

vk_login::vk_login(QObject *parent) :
    QObject(parent)
{
    mainUrl.setUrl("http://rhombic-subordinate.000webhostapp.com/gps.php");
    user = 0;
    mainphoto = "";
    photo = "";
    name = "";
    login="";
    ind = 1;
    latitude = 0;
    longitude = 0;
    datetime = "";
    network_token = new QNetworkAccessManager(this);
    network_getfriend = new QNetworkAccessManager(this);
    connect(network_getfriend, SIGNAL(finished(QNetworkReply*)),this, SLOT(getFriendRes(QNetworkReply*)));
    network_namephoto = new QNetworkAccessManager(this);
    connect(network_namephoto, SIGNAL(finished(QNetworkReply*)),this, SLOT(namephotoRes(QNetworkReply*)));
    network_gettoken = new QNetworkAccessManager(this);
    connect(network_gettoken, SIGNAL(finished(QNetworkReply*)),this, SLOT(gettokenRes(QNetworkReply*)));
    network_enddots = new QNetworkAccessManager(this);
    connect(network_enddots, SIGNAL(finished(QNetworkReply*)),this, SLOT(enddotsRes(QNetworkReply*)));
    network_friendhere = new QNetworkAccessManager(this);
    connect(network_friendhere, SIGNAL(finished(QNetworkReply*)),this, SLOT(friendHereRes(QNetworkReply*)));
    network_vkfriend = new QNetworkAccessManager(this);
    connect(network_vkfriend, SIGNAL(finished(QNetworkReply*)),this, SLOT(vkFriendRes(QNetworkReply*)));
    network_vkfriendnamephoto = new QNetworkAccessManager(this);
    connect(network_vkfriendnamephoto, SIGNAL(finished(QNetworkReply*)),this, SLOT(vkfriendnamephotoRes(QNetworkReply*)));
}

QString vk_login::getmainphoto()
{
    return mainphoto;
}
QString vk_login::getPhoto()
{
    return photo;
}
QString vk_login::getName()
{
    return name;
}
QString vk_login::getLogin()
{
    return login;
}
double vk_login::getlatitude()
{
    return latitude;
}
double vk_login::getlongitude()
{
    return longitude;
}
QString vk_login::getdatetime()
{
    return datetime;
}
QString vk_login::getHerePhoto()
{
    return here_photo;
}
QString vk_login::getHereName()
{
    return here_name;
}
QString vk_login::getHereLogin()
{
    return here_login;
}

void vk_login::enddots()
{
    QUrl url(mainUrl);
    QUrlQuery urlq;
    urlq.addQueryItem("action", "enddots");
    urlq.addQueryItem("user", QString::number(user));
    url.setQuery(urlq);
    qDebug() << url;
    network_enddots->get(QNetworkRequest(url));
}

void vk_login::setAccess_token(QUrl url, int u)
{
    url = url.toString().replace("#", "?");
    QString token = QUrlQuery(url).queryItemValue("access_token");
    int id = QUrlQuery(url).queryItemValue("user_id").toInt();
    QString secret = QUrlQuery(url).queryItemValue("secret");
    if (!token.isEmpty())
    {
        QUrl url(mainUrl);
        QUrlQuery urlq;
        urlq.addQueryItem("action", "settoken");
        urlq.addQueryItem("user", QString::number(u));
        urlq.addQueryItem("access_token", token);
        urlq.addQueryItem("id_vk", QString::number(id));
        urlq.addQueryItem("secret", secret);
        url.setQuery(urlq);
        qDebug() << url;
        network_token->get(QNetworkRequest(url));
        emit yesVk();
    }
}

void vk_login::getFriend(int u)
{
    if (token.isEmpty())
    {
        user = u;
        QUrl url2(mainUrl);
        QUrlQuery urlq2;
        urlq2.addQueryItem("action", "gettoken");
        urlq2.addQueryItem("user", QString::number(u));
        url2.setQuery(urlq2);
        qDebug() << url2;
        network_gettoken->get(QNetworkRequest(url2));
    }
}

void vk_login::friendHere()
{
    if (!token.isEmpty())
    {
        QUrl url("http://api.vk.com/method/friends.get");
        QUrlQuery urlq;
        urlq.addQueryItem("access_token", token);
        QUrl md ("/method/friends.get");
        md.setQuery(urlq);
        QString sig = QString(QCryptographicHash::hash((md.toString()+secret).toLatin1(), QCryptographicHash::Md5).toHex());
        urlq.addQueryItem("sig", sig);
        url.setQuery(urlq);
        network_friendhere->get(QNetworkRequest(url));
    }
}

void vk_login::listfriend()
{
    for(int i = 1; i < vk_users.count(); i++)
    {
        here_name = vk_users.at(i).last_name + " " + vk_users.at(i).first_name;
        here_login = vk_users.at(i).login;
        here_photo = vk_users.at(i).photo;
        emit editlistfriend();
    }
}

void vk_login::gettokenRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonArray ja = document.array();
        QJsonObject subtree = ja.at(0).toObject();
        token = subtree.value("access_token").toString();
        secret = subtree.value("secret").toString();

        QUrl url(mainUrl);
        QUrlQuery urlq;
        urlq.addQueryItem("action", "getfriend");
        urlq.addQueryItem("user", QString::number(user));
        url.setQuery(urlq);
        qDebug() << url;
        network_getfriend->get(QNetworkRequest(url));
    }
    reply->deleteLater();
}

void vk_login::getFriendRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonArray ja = document.array();
        vk_user temp;
        QString user_ids;
        for(int i = 0; i < ja.count(); i++)
        {            
            QJsonObject subtree = ja.at(i).toObject();
            contents.append(subtree.value("id").toString().toInt());
            temp.id = subtree.value("id").toString().toInt();
            temp.login = subtree.value("login").toString();
            temp.id_vk = subtree.value("id_vk").toString().toInt();
            vk_users.append(temp);
            if(subtree.value("id_vk").toString() != "0")
            {
                if(!user_ids.isEmpty())
                {
                    user_ids.append(",");
                }
                user_ids.append(subtree.value("id_vk").toString());
            }
        }
        if (!token.isEmpty())
        {
            QUrl url2("http://api.vk.com/method/users.get");
            QUrlQuery urlq2;
            urlq2.addQueryItem("user_ids", user_ids);
            urlq2.addQueryItem("fields", "photo_200");
            urlq2.addQueryItem("access_token", token);
            QUrl md ("/method/users.get");
            md.setQuery(urlq2);
            QString sig = QString(QCryptographicHash::hash((md.toString()+secret).toLatin1(), QCryptographicHash::Md5).toHex());
            urlq2.addQueryItem("sig", sig);
            url2.setQuery(urlq2);
            qDebug() << url2;
            network_namephoto->get(QNetworkRequest(url2));
        }
        else
        {
            enddots();
        }
    }
    reply->deleteLater();
}

void vk_login::namephotoRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        //qDebug() << reply->readAll();
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        qDebug() << document;
        QJsonObject root = document.object();
        qDebug() << root;
        QJsonArray ja = root.value("response").toArray();
        int j = 0;
        qDebug() << ja;
        qDebug() << ja.count();
        for(int i = 0; i < ja.count(); i++)
        {            
            QJsonObject subtree = ja.at(i).toObject();
            if (i==0)
            {
                mainphoto = subtree.value("photo_200").toString();
                qDebug() << mainphoto;
                emit editmainphoto();
            }
            while (vk_users.at(j).id_vk == 0)
            {
                j++;
            }
            vk_users[j].first_name = subtree.value("first_name").toString();
            vk_users[j].last_name = subtree.value("last_name").toString();
            vk_users[j].photo = subtree.value("photo_200").toString();
            j++;
        }
        if (vk_users.length() > ind)
        {
            photo = vk_users.at(ind).photo;
            name = vk_users.at(ind).last_name + " " + vk_users.at(ind).first_name;
            login = vk_users.at(ind).login;
            emit editphoto();
            emit editname();
            emit editlogin();
            enddots();
        }
//        for(int j = 0; j < vk_users.count(); j++)
//        {
//            qDebug() << vk_users.at(j).id;
//            qDebug() << vk_users.at(j).login;
//            qDebug() << vk_users.at(j).id_vk;
//            qDebug() << vk_users.at(j).first_name;
//            qDebug() << vk_users.at(j).last_name;
//            qDebug() << vk_users.at(j).photo;
//        }
    }
    reply->deleteLater();
}

void vk_login::enddotsRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonArray ja = document.array();
        qDebug() << ja.count();
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            vk_users[i+1].latitude = subtree.value("latitude").toString().toDouble();
            vk_users[i+1].longitude = subtree.value("longitude").toString().toDouble();
            vk_users[i+1].datetime = subtree.value("max").toString();
        }
        if (vk_users.length() > ind)
        {
            latitude = vk_users.at(ind).latitude;
            longitude = vk_users.at(ind).longitude;
            datetime = vk_users.at(ind).datetime;
            emit editlatitude();
            emit editlongitude();
            emit editdatetime();
        }
    }
    reply->deleteLater();
}

void vk_login::friendHereRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonObject root = document.object();
        QJsonArray ja = root.value("response").toArray();
        QString vk_friends;
        vk_friends.append(QString::number(ja.at(0).toInt()));
        for(int i = 1; i < ja.count(); i++)
        {
            vk_friends.append(",");
            vk_friends.append(QString::number(ja.at(i).toInt()));
        }
        QUrl url(mainUrl);
        QUrlQuery urlq;
        urlq.addQueryItem("action", "friendhere");
        urlq.addQueryItem("user", QString::number(user));
        urlq.addQueryItem("vk_friend", vk_friends);
        url.setQuery(urlq);
        qDebug() << url;
        network_vkfriend->get(QNetworkRequest(url));
    }
    reply->deleteLater();
}

void vk_login::vkFriendRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonArray ja = document.array();
        vk_user temp;
        QString user_ids;
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            temp.login = subtree.value("login").toString();
            temp.id_vk = subtree.value("id_vk").toString().toInt();
            frHere.append(temp);
            if(!user_ids.isEmpty())
            {
                user_ids.append(",");
            }
            user_ids.append(subtree.value("id_vk").toString());
        }
            QUrl url2("http://api.vk.com/method/users.get");
            QUrlQuery urlq2;
            urlq2.addQueryItem("user_ids", user_ids);
            urlq2.addQueryItem("fields", "photo_200");
            urlq2.addQueryItem("access_token", token);
            QUrl md ("/method/users.get");
            md.setQuery(urlq2);
            QString sig = QString(QCryptographicHash::hash((md.toString()+secret).toLatin1(), QCryptographicHash::Md5).toHex());
            urlq2.addQueryItem("sig", sig);
            url2.setQuery(urlq2);
            network_vkfriendnamephoto->get(QNetworkRequest(url2));

    }
    reply->deleteLater();
}

void vk_login::vkfriendnamephotoRes(QNetworkReply *reply)
{
    if(!reply->error())
    {
        QJsonDocument document = QJsonDocument::fromJson(reply->readAll());
        QJsonObject root = document.object();
        QJsonArray ja = root.value("response").toArray();
        for(int i = 0; i < ja.count(); i++)
        {
            QJsonObject subtree = ja.at(i).toObject();
            here_name = subtree.value("last_name").toString() + " " + subtree.value("first_name").toString();
            here_photo = subtree.value("photo_200").toString();
            here_login = frHere.at(i).login;
            emit editherefriend();

        }
    }
    reply->deleteLater();
}

//QString vk_login::getphoto(int u)
//{
//    if (u > 0 and !vk_users.isEmpty())
//    {
//    return "";//vk_users.at(contents.indexOf(u)).photo;
//    }
//    else return "";
//}

//QString vk_login::getname(int u)
//{
//    if (u > 0 or !vk_users.isEmpty())
//    {
//    return vk_users.at(contents.indexOf(u)).last_name + " " + vk_users.at(contents.indexOf(u)).first_name;
//    }
//    else return "";
//}

//QString vk_login::getlogin(int u)
//{
//    if (u > 0 or !vk_users.isEmpty())
//    {
//    return vk_users.at(contents.indexOf(u)).login;
//    }
//    else return "";
//}

void vk_login::nextUser()
{
    ind++;
    if(ind == vk_users.count())
    {
        ind = 1;
    }
    photo = vk_users.at(ind).photo;
    name = vk_users.at(ind).last_name + " " + vk_users.at(ind).first_name;
    login = vk_users.at(ind).login;
    latitude = vk_users.at(ind).latitude;
    longitude = vk_users.at(ind).longitude;
    datetime = vk_users.at(ind).datetime;
    emit editphoto();
    emit editname();
    emit editlogin();
    emit editlatitude();
    emit editlongitude();
    emit editdatetime();
}

void vk_login::selectUserPhoto(int i)
{
    ind = i;
    photo = vk_users.at(ind).photo;
    name = vk_users.at(ind).last_name + " " + vk_users.at(ind).first_name;
    login = vk_users.at(ind).login;
    emit editphoto();
    emit editname();
    emit editlogin();
}

void vk_login::selectUser(int i)
{
    ind = i;
    photo = vk_users.at(ind).photo;
    name = vk_users.at(ind).last_name + " " + vk_users.at(ind).first_name;
    login = vk_users.at(ind).login;
    latitude = vk_users.at(ind).latitude;
    longitude = vk_users.at(ind).longitude;
    datetime = vk_users.at(ind).datetime;
    emit editphoto();
    emit editname();
    emit editlogin();
    emit editlatitude();
    emit editlongitude();
    emit editdatetime();
}

void vk_login::previousUser()
{
    ind--;
    if (ind < 1)
    {
        ind = vk_users.count() - 1;
    }
    photo = vk_users.at(ind).photo;
    name = vk_users.at(ind).last_name + " " + vk_users.at(ind).first_name;
    login = vk_users.at(ind).login;
    latitude = vk_users.at(ind).latitude;
    longitude = vk_users.at(ind).longitude;
    datetime = vk_users.at(ind).datetime;
    emit editphoto();
    emit editname();
    emit editlogin();
    emit editlatitude();
    emit editlongitude();
    emit editdatetime();
}



