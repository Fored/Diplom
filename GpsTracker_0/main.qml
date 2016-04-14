import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtLocation 5.3
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.3
//import ModuleBD 1.0
import ServerBD 1.0
import Welcome 1.0
import Vk_login 1.0
import Users 1.0


ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Hello World")
    width: 640
    height: 480
    property int dpi: Screen.pixelDensity * 25.4
    property var tempDate: new Date()

    function dp(x){
            if(dpi < 120) {
                return x; // Для обычного монитора компьютера
            } else {
                return x*(dpi/160);
            }
        }

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                id: menu1
                text: qsTr("История перемещения")
                onTriggered: {
                    loader.sourceComponent = routes;
                }
            }
            MenuItem {
                id: menu2
                text: qsTr("Найти друга")
                onTriggered: {
                    loader.sourceComponent = friend;
                }
            }
            MenuItem {
                id: menu3
                text: qsTr("Выход из профиля")
                onTriggered: {
                    mybd.exit();
                    mybd.user = 0;
                    loader.sourceComponent = login;
                }
            }
        }
    }

    ServBd {
        id: mybd
        onEditDot: {
            loader.item.children[1].children[2].addCoordinate(mybd.dot);
        }
        onRouteServResEnd: {
            loader.item.children[1].center = loader.item.children[1].children[2].path[0];
        }

    }

    Welcome {
        id: welcome
        onLoginOk: {
            mybd.setProfile(user, loader.item.children[0].children[0].children[0].text, loader.item.children[0].children[1].children[0].text);
            mybd.user = user;
            loader.sourceComponent = map;
        }
        onOffline: {
            notnetwork.open();
            loader.item.children[1].running = false;
            loader.item.children[1].currentFrame = 0;
        }
        onNotlogin: {
            notcorect.open();
            loader.item.children[1].running = false;
            loader.item.children[1].currentFrame = 0;
        }
        onLoginExist: {
            loginExist.open();
            loader.item.children[1].running = false;
            loader.item.children[1].currentFrame = 0;
        }

    }

    Vk_login {
        id: vk
    }
    Users {
        id: users
        onEditLogin: {
            loader.item.children[3].model.append({text: users.login});
        }
        onNotUser: {
            notcorect.open();
        }
        onYesUser: {
            yesuser.open();
        }
        onYesFollower: {
            yesFollower.open();
        }
        onYesRequest: {
            yesRequest.open();
        }
        onThisYou: {
            thisYou.open();
        }
        onEditReq: {
            loader.item.children[0].children[2].model.append({text: users.login});
        }
        onGiveAccessyesno: {
            loader.item.children[0].children[2].model.clear();
            loader.item.children[0].children[2].model.append({text: "Запросы от пользователей"});
            users.getRequest(mybd.user);
        }
    }

    Loader {
            id: loader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: mybd.user ? map : login
        }

    PositionSource {
        id: posit
        active: true
        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
        onPositionChanged: {
            if (mybd.user != 0) {
                mybd.recordDot(mybd.user, Qt.formatDateTime(position.timestamp, "yyyy-MM-dd hh:mm:ss"),
                               position.coordinate.latitude, position.coordinate.longitude);
                mybd.server_sync();
            }
        }
    }
    Component {
        id: map
        Item {
            anchors.fill: parent
            RowLayout {
                    id: rowLayout
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Button {
                        text: qsTr("Если маршрут плохо вывелся")
                        onClicked: {
                            //puti.addCoordinate(puti.path[puti.path.length-1]);
                            //mybd.sync("2015-03-07 02:17:34");
                            //console.log(mybd.test());
                            //mybd.get_max_on_server(1);
                            //vk.tie(mybd.user);
                            users.request(3,3);
                        }
                    }
                    Text {
                        text: mybd.left_sync
                    }
            }

            Map {
                id: karta
                anchors.top: rowLayout.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                plugin: Plugin {name: "osm" }
                center: posit.position.coordinate
                zoomLevel: zoomlvl.value
                MapQuickItem {
                    coordinate: posit.position.coordinate
                    sourceItem: Image {
                        id: name
                        source: "marker.png"
                    }
                }
                MapPolyline {
                    id: puti
                    line.width: 4
                    line.color: 'green'
                }
            }
            Slider {
                id: zoomlvl
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dp(30)
                anchors.right: parent.right
                anchors.rightMargin: dp(30)
                anchors.top: parent.top
                anchors.topMargin: dp(30)
                minimumValue: karta.minimumZoomLevel + 5
                maximumValue: karta.maximumZoomLevel
                value: 17
                orientation: Qt.Vertical
            }
        Component.onCompleted: {
            menu1.visible = true;
            menu2.visible = true;
            menu3.visible = true;
        }
        }

    }
    Component {
        id: routes
        Item {

            RowLayout {
                id: lat1
                anchors.top: parent.top
                Button {
                    id: less1
                    style: ButtonStyle {
                        label: Text {
                                   text: "<"
                                   style: Text.Normal
                                   font.bold: true
                                   font.pixelSize: dp(50)
                              }
                          }
                    onClicked: {
                        tempDate.setDate(tempDate.getDate()-1)
                        firstText.text = Qt.formatDate(tempDate, "yyyy.MM.dd")
                    }
                }
                Text {
                    id: firstText
                    font.pixelSize: dp(20)
                    text: Qt.formatDate(tempDate, "yyyy.MM.dd")
                }
                Button {
                    id: more1
                    style: ButtonStyle {
                        label: Text {
                                   text: ">"
                                   style: Text.Normal
                                   font.bold: true
                                   font.pixelSize: dp(50)
                              }
                          }
                    onClicked: {
                        tempDate.setDate(tempDate.getDate()+1)
                        firstText.text = Qt.formatDate(tempDate, "yyyy.MM.dd")
                    }
                }               
                TextInput {
                    id: hour1
                    text: qsTr("00:00")
                    color: "#aaf44b"
                    font.pixelSize: dp(25)
                    inputMask: "00:00"
                }

            }
            RowLayout {
                anchors.top: lat1.bottom
                Button {
                    id: less2
                    style: ButtonStyle {
                        label: Text {
                                   text: "<"
                                   style: Text.Normal
                                   font.bold: true
                                   font.pixelSize: dp(50)
                              }
                          }
                    onClicked: {
                        tempDate.setDate(tempDate.getDate()-1)
                        secondText.text = Qt.formatDate(tempDate, "yyyy.MM.dd")
                    }
                }
                Text {
                    id: secondText
                    font.pixelSize: dp(20)
                    text: Qt.formatDate(tempDate, "yyyy.MM.dd")
                }
                Button {
                    id: more2
                    style: ButtonStyle {
                        label: Text {
                                   text: ">"
                                   style: Text.Normal
                                   font.bold: true
                                   font.pixelSize: dp(50)
                              }
                          }
                    onClicked: {
                        tempDate.setDate(tempDate.getDate()+1)
                        secondText.text = Qt.formatDate(tempDate, "yyyy.MM.dd")
                    }
                }
                TextInput {
                    id: hour2
                    text: qsTr("00:00")
                    color: "#aaf44b"
                    font.pixelSize: dp(25)
                    inputMask: "00:00"
                }

            }
            Button {
                id: construct
                anchors.centerIn: parent
                text: qsTr("Построить")
                onClicked: {
                    loader.sourceComponent = map;
                    mybd.routeServ(users.getUserId(comboBox1.currentIndex), firstText.text + " " + hour1.text, secondText.text + " " + hour2.text);
                }
            }
            ComboBox {
                id: comboBox1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: construct.top
                model: model
                activeFocusOnPress: true

            }
            ListModel {
                id: model

            }
            Component.onCompleted: {
                model.append({text: "Моя хронология"});
                users.getFriend(mybd.user);
            }
        }


    }
    Component {
        id: login
        Item {
            ColumnLayout {
                id: columnLayout1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                //width: 100
                //height: 100
                spacing: 15

                Rectangle {
                    color: "#f4af58"
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: Screen.width/2
                    Layout.preferredHeight: Screen.width/10
                    TextInput {
                        id: log
                        width: parent.width
                        height: parent.height
                        text: qsTr("fored")
                        font.pixelSize: Screen.width/10
                    }
                }
                Rectangle {
                    color: "#f4af58"
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: Screen.width/2
                    Layout.preferredHeight: Screen.width/10
                    TextInput {
                        id: pass
                        width: parent.width
                        height: parent.height
                        text: qsTr("fored")
                        font.pixelSize: Screen.width/10
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignCenter

                    Button {
                        id: enter
                        text: qsTr("Войти")
                        onClicked: {
                            welcome.login(log.text, pass.text);
                            animatedSprite.restart();
                        }
                    }

                    Button {
                        id: signup
                        text: qsTr("Зарегистрироваться")
                        onClicked: {
                            welcome.signup(log.text, pass.text);
                            animatedSprite.restart();
                        }

                    }
                }
            }
            AnimatedSprite {
                        id: animatedSprite
                        width: dp(30)  // Ширина области под спрайт
                        height: dp(30)  // Высота области под спрайт
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: columnLayout1.bottom
                        anchors.topMargin: dp(100)

                        // Источник, спрайтовая картинка
                        source: "sprite_sheet.png"
                        frameCount: 16  // Количество кадров
                        frameWidth: 20  // Ширина фрейма
                        frameHeight: 20 // Высота фрейма
                        //frameSync: true // Синхронизация
                        running: false
                    }
            Component.onCompleted: {
                menu1.visible = false;
                menu2.visible = false;
                menu3.visible = false;
            }
        }
    }
    Component {
        id: friend
        Item {
            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 15
                Rectangle {
                    color: "#f4af58"
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: Screen.width/2
                    Layout.preferredHeight: Screen.width/10
                    TextInput {
                        id: text1
                        width: parent.width
                        height: parent.height
                        text: qsTr("fored")
                        font.pixelSize: Screen.width/10
                    }
                }
                Button {
                    text: qsTr("Найти")
                    onClicked: {
                        users.findUser(text1.text, mybd.user);
                    }
                }
                ComboBox {
                    id: comboBox2
                    model: model2
                    onActivated:
                        if (index > 0) {
                            giveaccess.open();
                        }
                }
            }
            ListModel {
                id: model2

            }
            Component.onCompleted: {
                model2.append({text: "Запросы от пользователей"});
                users.getRequest(mybd.user);
            }
        }
    }

    MessageDialog {
        id: notnetwork
        title: "Нет связи"
        text: "Отсутствует интернет соединение или сервер не отвечает"
    }
    MessageDialog {
        id: notcorect
        title: "Ошибка"
        text: "Неверный логин или пароль"
    }
    MessageDialog {
        id: loginExist
        title: "Ошибка"
        text: "Такой логин уже существует"
    }
    MessageDialog {
        id: yesFollower
        title: "Ошибка"
        text: "Вы уже подписаны"
    }
    MessageDialog {
        id: yesRequest
        title: "Ошибка"
        text: "Вы уже подали запрос. Пользователь еще не подтвердил."
    }
    MessageDialog {
        id: thisYou
        title: "Ошибка"
        text: "Ты лайки тоже сам себе ставишь?"
    }
    MessageDialog {
        id: yesuser
        title: "Пользователь найден"
        text: "Подписаться?"
        standardButtons: StandardButton.Yes |StandardButton.No
        onYes: users.request(mybd.user)
        //onNo: console.log("didn't copy")
    }
    MessageDialog {
        id: giveaccess
        title: "Пользователь хочет подписаться"
        text: "Предоставить доступ?"
        standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Close
        onYes: {
            users.giveAccess(true, mybd.user, users.getUserId(loader.item.children[0].children[2].currentIndex-1));
            loader.item.children[0].children[2].currentIndex = 0

        }
        onNo: {
            users.giveAccess(false, mybd.user, users.getUserId(loader.item.children[0].children[2].currentIndex-1));
            loader.item.children[0].children[2].currentIndex = 0

        }
        onRejected: loader.item.children[0].children[2].currentIndex = 0
    }
}

