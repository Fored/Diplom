import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtLocation 5.3
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.3
import ModuleBD 1.0


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
                text: qsTr("Exit")
                onTriggered: {
//                    route.addCoordinate({ latitude: 59.9918, longitude: 30.3111 });
//                    route.addCoordinate({ latitude: 59.991, longitude: 30.3188 });
                    //routes.lat1.firstText.text = qsTr("gggggggggggggg")
                }
            }
        }
    }
    Loader {
            id: loader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: map
        }
    MyBd {
        id: mybd
        onEditDot: {
            loader.item.children[1].children[2].addCoordinate(mybd.dot);
        }
    }
    PositionSource {
        id: posit
        active: true
        onPositionChanged: {
            mybd.recordDot(1, Qt.formatDateTime(position.timestamp, "yyyy-MM-dd hh:mm:ss"),
                           position.coordinate.latitude, position.coordinate.longitude);
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
                        }
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
                    mybd.route(1, "2016-03-07 01:00:50", "2016-03-08 01:29:14");
                    loader.item.children[1].center = loader.item.children[1].children[2].path[0];
                }
            }
        }
    }
}

