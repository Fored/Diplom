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
                text: qsTr("История перемещения")
                onTriggered: {
                    loader.sourceComponent = routes;
                }
            }
            MenuItem {
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
        onPositionChanged: {
            if (mybd.user != 0) {
                mybd.recordDot(mybd.user, Qt.formatDateTime(position.timestamp, "yyyy-MM-dd hh:mm:ss"),
                               position.coordinate.latitude, position.coordinate.longitude);
                mybd.server_sync();
            }
            //loader.item.children[1].children[2].addCoordinate(mybd.dot)
            //loader.item.children[1].children[2].addCoordinate(loader.item.children[1].children[2].path[loader.item.children[1].children[2].path.length-1]);
            //karta.center = position.coordinate;
            //bd_ent.record(position.coordinate.latitude, position.coordinate.longitude, Qt.formatDateTime(position.timestamp, "yyyy-MM-dd hh:mm:ss"), bd_ent.acc);
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
                            puti.addCoordinate(puti.path[puti.path.length-1]);
                            //mybd.sync("2015-03-07 02:17:34");
                            console.log(mybd.test());                            
                            //mybd.get_max_on_server(1);
                            //mybd.sync();
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
                        firstText.text = Qt.formatDate(tempDate, "dd.MM.yyyy")
                    }
                }
                Text {
                    id: firstText
                    font.pixelSize: dp(20)
                    text: Qt.formatDate(tempDate, "dd.MM.yyyy")
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
                        firstText.text = Qt.formatDate(tempDate, "dd.MM.yyyy")
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
                        secondText.text = Qt.formatDate(tempDate, "dd.MM.yyyy")
                    }
                }
                Text {
                    id: secondText
                    font.pixelSize: dp(20)
                    text: Qt.formatDate(tempDate, "dd.MM.yyyy")
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
                        secondText.text = Qt.formatDate(tempDate, "dd.MM.yyyy")
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
                anchors.centerIn: parent
                text: qsTr("Построить")
                onClicked: {
                    loader.sourceComponent = map;
                    mybd.route(1, "2016-03-07 01:00:50", "2016-04-08 01:29:14");
                    loader.item.children[1].center = loader.item.children[1].children[2].path[0];
                }
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
}

