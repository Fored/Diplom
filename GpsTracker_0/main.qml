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
//import QtWebKit 3.0
import QtWebView 1.1
import QtQuick.Extras 1.4



ApplicationWindow {
    id: mainWindow
    visible: true
    title: qsTr("Hello World")
    width: 640
    height: 480
    color: "#EDEFEB"
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
                text: qsTr("Карта")
                onTriggered: {
                    loader.sourceComponent = map;
                }
            }
            MenuItem {
                id: menu2
                text: qsTr("История перемещения")
                onTriggered: {
                    loader.sourceComponent = routes;
                }
            }
            MenuItem {
                id: menu3
                text: qsTr("Найти друга")
                onTriggered: {
                    loader.sourceComponent = friend;
                }
            }
            MenuItem {
                id: menu4
                text: qsTr("Вконтакте")
                onTriggered: {
                    //loader.sourceComponent = vk_view;
                    loader.sourceComponent = vk_access;

                    //vk.getFriend(2);
                    //vk.getFriend(mybd.user)
                }
            }
            MenuItem {
                id: menu5
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
            loader.item.children[1].children[1/*2*/].addCoordinate(mybd.dot);
        }
        onRouteServResEnd: {
            loader.item.children[1].center = loader.item.children[1].children[1/*2*/].path[0];

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
        onYesVk: {
            loader.sourceComponent = map
        }

        onEditherefriend: {
            loader.item.children[3].model.append({"name": vk.here_name, "login": vk.here_login, "photo": vk.here_photo})
        }
        onEditlistfriend: {
            listfriendmodel.append({"name": vk.here_name, "login": vk.here_login, "photo": vk.here_photo})
        }
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
        //updateInterval: 10000
        onPositionChanged: {
            if (mybd.user != 0) {
                mybd.recordDot(mybd.user, Qt.formatDateTime(position.timestamp, "yyyy-MM-dd hh:mm:ss"),
                               position.coordinate.latitude, position.coordinate.longitude);
                //mybd.server_sync();
            }
        }
    }
    Component {
        id: map
        Item {
            anchors.fill: parent
            RowLayout {
                    id: rowLayout
                    anchors.bottom: parent.bottom
                    //anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right

//                    Text {
//                        id: leftsync
//                        text: mybd.left_sync
//                        //width: dp(30)
//                        anchors.left: parent.left
//                    }
                    Rectangle {
                        id: photo
                        color: "#c8fd41"
                        width: dp(100)
                        height: dp(100)
                        Image {
                            //source: vk.getphoto(mybd.current_user)
                            source: vk.photo
                            sourceSize.width: dp(95)
                            sourceSize.height: dp(95)
                            anchors.centerIn: parent
                        }
                        MouseArea {
                              anchors.fill: parent
                              onClicked: karta.center = icon.coordinate//QtPositioning.coordinate (vk.latitude, vk.longitude)
                        }
                    }
                    ColumnLayout {
                        anchors.left: photo.right
                        anchors.leftMargin: dp(30)
                        Text {
                            color: "#99d90a"
                            //text: vk.getname(mybd.current_user)
                            text: vk.name
                            font.bold: true
                            style: Text.Outline
                            font.pointSize: dp(14)
                        }
                        Text {
                            color: "#e03636"
                            //text: vk.getlogin(mybd.current_user)
                            text: vk.login
                            font.italic: true
                            font.pointSize: dp(10)
                        }
                    }

                    Text {
                        id: datedot                      
                        styleColor: "#538403"
                        font.pointSize: dp(11)
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        text: vk.datetime
                    }
            }

            Map {
                id: karta
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: rowLayout.top
                plugin: mapPlugin
                //center: posit.position.coordinate
                zoomLevel: zoomlvl.value
                MapQuickItem {
                    coordinate: posit.position.coordinate
                    sourceItem: Image {
                        id: name
                        width: dp(115); height: dp(165)
                        source: "icon.png"
                    }
                    anchorPoint.x: name.width/2
                    anchorPoint.y: name.height
                }
                MapPolyline {
                    id: puti
                    line.width: 4
                    line.color: 'green'
                }
                MapQuickItem {
                    id: icon
                    coordinate: puti.path.length ? puti.path[placeduring.value] : QtPositioning.coordinate (vk.latitude, vk.longitude)
                    sourceItem: Image {
                        id: name2
                        width: dp(115); height: dp(165)
                        source: "icon.png"
                    }
                    anchorPoint.x: name2.width/2
                    anchorPoint.y: name2.height
                    //zoomLevel: 16
                }
                MapQuickItem {
                    coordinate: puti.path.length ? puti.path[placeduring.value] : QtPositioning.coordinate (vk.latitude, vk.longitude)
                    sourceItem: Image {
                        id: name3
                        //source: vk.getphoto(mybd.current_user)
                        source: vk.photo
                        sourceSize.width: dp(70)
                        sourceSize.height: dp(70)
                    }
                    anchorPoint.x: name3.width/2-dp(3)
                    anchorPoint.y: name3.height+(name2.height*107/300)
                    //zoomLevel: 16

                }
                MapQuickItem {
                    coordinate: posit.position.coordinate
                    sourceItem: Image {
                        id: name1
                        source: vk.mainphoto
                        sourceSize.width: dp(70)
                        sourceSize.height: dp(70)
                    }
                    anchorPoint.x: name1.width/2-dp(3)
                    anchorPoint.y: name1.height+(name.height*107/300)
                    //zoomLevel: 16

                }

                Slider {
                    id: zoomlvl
                    anchors.bottom: centre.top
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
                Slider {
                    id: placeduring
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: dp(30)
                    anchors.left: parent.left
                    anchors.leftMargin: dp(30)
                    anchors.top: parent.top
                    anchors.topMargin: dp(30)
                    minimumValue: 0
                    maximumValue: puti.path.length ? puti.path.length-1 : puti.path.length
                    value: 0
                    stepSize: 1.0
                    onValueChanged: {
                        //karta.center = puti.path[placeduring.value] //центр карты в точке маркера
                        datedot.text = mybd.getDateDot(value)
                    }
                    orientation: Qt.Vertical
                }
                Image {
                    id: centre
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: dp(30)
                    anchors.right: parent.right
                    anchors.rightMargin: dp(30)
                    source: "centre.png"
                    sourceSize.width: dp(60)
                    sourceSize.height: dp(60)
                    MouseArea {
                          anchors.fill: parent
                          onClicked: karta.center = posit.position.coordinate
                    }
                }
                RowLayout {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: dp(30)
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        width: dp(63)
                        height: dp(63)
                        color: "#EDEFEB"
                        Image {
                            source: "left.png"
                            sourceSize.width: dp(63)
                            sourceSize.height: dp(63)
                            MouseArea {
                                  anchors.fill: parent
                                  onClicked: {
                                      vk.previousUser()
                                      karta.center = QtPositioning.coordinate (vk.latitude, vk.longitude)
                                  }
                            }
                        }
                    }
                    Rectangle {
                        width: dp(63)
                        height: dp(63)
                        color: "#EDEFEB"
                        Image {
                            source: "personal.png"
                            sourceSize.width: dp(63)
                            sourceSize.height: dp(63)
                            MouseArea {
                                  anchors.fill: parent
                                  onClicked: {
                                      //listfriend.open()
                                      if (listfriendmodel.count === 0) {
                                          vk.listfriend()
                                      }
                                      if (listfriendmodel.count !== 0) {
                                          listfriend.open()
                                      }
                                  }
                            }
                        }
                    }
                    Rectangle {
                        width: dp(63)
                        height: dp(63)
                        color: "#EDEFEB"
                        Image {
                            source: "right.png"
                            sourceSize.width: dp(63)
                            sourceSize.height: dp(63)
                            MouseArea {
                                  anchors.fill: parent
                                  onClicked: {
                                      vk.nextUser()
                                      karta.center = QtPositioning.coordinate (vk.latitude, vk.longitude)
                                  }
                            }
                        }
                    }
                }
            }
            Plugin {
                 id: mapPlugin
                 name: "osm"
                 PluginParameter {
                     name: "osm.mapping.host";
                     value: "http://a.tile.openstreetmap.org/"
                 }
            }
            Timer {
                interval: 100; running: true; repeat: false
                onTriggered: {
                    for(var i = 0;
                        i < karta.supportedMapTypes.length;
                        ++i){
                        if(karta.supportedMapTypes[i].style
                                === MapType.CustomMap){
                            karta.activeMapType = karta.supportedMapTypes[i];
                        }
                    }
                }
            }
            Component.onCompleted: {
                menu1.visible = true;
                menu2.visible = true;
                menu3.visible = true;
                menu4.visible = true;
                menu5.visible = true;
                vk.getFriend(mybd.user)
                //vk.enddots()
            }
        }        
    }
    Component {
        id: routes
        Item {
            Text {
                id: startDateTime
                anchors.top: routes_text.bottom
                anchors.topMargin: dp(30)
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: dp(35)
                text: Qt.formatDateTime(tempDate, "yyyy-MM-dd hh:mm")
                color: "#99d90a"
                font.bold: true
                style: Text.Outline
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectDateTime.open()

                    }
                }
            }
            Text {
                id: endDateTime
                anchors.top: startDateTime.bottom
                anchors.topMargin: dp(30)
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: dp(35)
                text: Qt.formatDateTime(tempDate, "yyyy-MM-dd hh:mm")
                color: "#99d90a"
                font.bold: true
                style: Text.Outline
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        selectDateTime.open()

                    }
                }
            }

            Button {
                id: construct
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: comboBox1.bottom
                anchors.topMargin: dp(30)
                text: qsTr("Построить")
                onClicked: {                 
                    vk.selectUserPhoto(comboBox1.currentIndex)
                    loader.sourceComponent = map
                    mybd.routeServ(users.getUserId(comboBox1.currentIndex), startDateTime.text, endDateTime.text);

                }
            }
            ComboBox {
                id: comboBox1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: endDateTime.bottom
                anchors.topMargin: dp(30)
                model: model1
                activeFocusOnPress: true

            }
            ListModel {
                id: model1

            }
            Text {
                id: textSingleton
            }
            FontLoader {
                id: openSans
                source: "qrc:/fonts/OpenSans-Regular.ttf"
             }
            Text {
                id: routes_text
                text: "Введите время начала и окончания маршрута либо выберите его из списка"
                anchors.right: parent.right
                anchors.left: parent.left
                font.pixelSize: dp(30)
                wrapMode: Text.Wrap
            }

            Dialog {
                id: selectDateTime
                contentItem: ColumnLayout {
                    spacing: dp(30)
                RowLayout {
                    id: lat2
                    Tumbler {
                        id: tumbler
                        //anchors.centerIn: parent
                        anchors.bottom: parent.bottom
                        //anchors.verticalCenter: parent.verticalCenter
                        // TODO: Use FontMetrics with 5.4
                        Label {
                            id: characterMetrics
                            font.bold: true
                            font.pixelSize: textSingleton.font.pixelSize * 1.25
                            font.family: openSans.name
                            visible: false
                            text: "M"
                        }

                        readonly property real delegateTextMargins: characterMetrics.width * 1.5
                        readonly property var days: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

                        TumblerColumn {
                            width: characterMetrics.width * 4 + tumbler.delegateTextMargins
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 2000; i < 2100; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        TumblerColumn {
                            id: monthColumn
                            width: characterMetrics.width * 3 + tumbler.delegateTextMargins
                            model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                            onCurrentIndexChanged: tumblerDayColumn.updateModel()
                        }
                        TumblerColumn {
                            id: tumblerDayColumn

                            function updateModel() {
                                var previousIndex = tumblerDayColumn.currentIndex;
                                var newDays = tumbler.days[monthColumn.currentIndex];
                                if (!model) {
                                    var array = [];
                                    for (var i = 0; i < newDays; ++i) {
                                        array.push(i + 1);
                                    }
                                    model = array;
                                } else {
                                    // If we've already got days in the model, just add or remove
                                    // the minimum amount necessary to make spinning the month column fast.
                                    var difference = model.length - newDays;
                                    if (model.length > newDays) {
                                        model.splice(model.length - 1, difference);
                                    } else {
                                        var lastDay = model[model.length - 1];
                                        for (i = lastDay; i < lastDay + difference; ++i) {
                                            model.push(i + 1);
                                        }
                                    }
                                }

                                tumbler.setCurrentIndexAt(0, Math.min(newDays - 1, previousIndex));
                            }
                        }
                        Component.onCompleted: {

                            tumbler.setCurrentIndexAt(1,Qt.formatDateTime(tempDate, "MM") - 1 )
                            tumbler.setCurrentIndexAt(2,Qt.formatDateTime(tempDate, "d") - 1 )
                            tumbler.setCurrentIndexAt(0,Qt.formatDateTime(tempDate, "yy"))

                        }
                    }
                    Tumbler {
                        id: tumblerTime
                        TumblerColumn {
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 0; i < 24; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        TumblerColumn {
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 0; i < 60; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        Component.onCompleted: {
                            tumblerTime.setCurrentIndexAt(0,Qt.formatDateTime(tempDate, "hh"))
                            tumblerTime.setCurrentIndexAt(1,Qt.formatDateTime(tempDate, "mm"))
                        }
                    }
                }
                RowLayout {

                    Tumbler {
                        id: tumbler2
                        anchors.bottom: parent.bottom

                        readonly property real delegateTextMargins: characterMetrics.width * 1.5
                        readonly property var days: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

                        TumblerColumn {
                            width: characterMetrics.width * 4 + tumbler2.delegateTextMargins
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 2000; i < 2100; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        TumblerColumn {
                            id: monthColumn2
                            width: characterMetrics.width * 3 + tumbler2.delegateTextMargins
                            model: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
                            onCurrentIndexChanged: tumblerDayColumn2.updateModel()
                        }
                        TumblerColumn {
                            id: tumblerDayColumn2

                            function updateModel() {
                                var previousIndex = tumblerDayColumn2.currentIndex;
                                var newDays = tumbler2.days[monthColumn2.currentIndex];
                                if (!model) {
                                    var array = [];
                                    for (var i = 0; i < newDays; ++i) {
                                        array.push(i + 1);
                                    }
                                    model = array;
                                } else {
                                    // If we've already got days in the model, just add or remove
                                    // the minimum amount necessary to make spinning the month column fast.
                                    var difference = model.length - newDays;
                                    if (model.length > newDays) {
                                        model.splice(model.length - 1, difference);
                                    } else {
                                        var lastDay = model[model.length - 1];
                                        for (i = lastDay; i < lastDay + difference; ++i) {
                                            model.push(i + 1);
                                        }
                                    }
                                }

                                tumbler2.setCurrentIndexAt(0, Math.min(newDays - 1, previousIndex));
                            }
                        }
                        Component.onCompleted: {

                            tumbler2.setCurrentIndexAt(1,Qt.formatDateTime(tempDate, "MM") - 1 )
                            tumbler2.setCurrentIndexAt(2,Qt.formatDateTime(tempDate, "d") - 1 )
                            tumbler2.setCurrentIndexAt(0,Qt.formatDateTime(tempDate, "yy"))

                        }

                    }
                    Tumbler {
                        id: tumblerTime2
                        TumblerColumn {
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 0; i < 24; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        TumblerColumn {
                            model: ListModel {
                                Component.onCompleted: {
                                    for (var i = 0; i < 60; ++i) {
                                        append({value: i.toString()});
                                    }
                                }
                            }
                        }
                        Component.onCompleted: {
                            tumblerTime2.setCurrentIndexAt(0,Qt.formatDateTime(tempDate, "hh"))
                            tumblerTime2.setCurrentIndexAt(1,Qt.formatDateTime(tempDate, "mm"))
                        }
                    }
                }
                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Ok"
                    onClicked: {
                        var txt = tumbler.currentIndexAt(0) + 2000 + "-"
                        if ((tumbler.currentIndexAt(1) + 1) < 10) {
                            txt = txt + "0" + (tumbler.currentIndexAt(1) + 1) + "-"
                        }
                        else {
                            txt = txt + (tumbler.currentIndexAt(1) + 1) + "-"
                        }
                        if ((tumbler.currentIndexAt(2) + 1) < 10) {
                            txt = txt + "0" + (tumbler.currentIndexAt(2) + 1) + " "
                        }
                        else {
                            txt = txt + (tumbler.currentIndexAt(2) + 1) + " "
                        }
                        if ((tumblerTime.currentIndexAt(0)) < 10) {
                            txt = txt + "0" + (tumblerTime.currentIndexAt(0)) + ":"
                        }
                        else {
                            txt = txt + (tumblerTime.currentIndexAt(0)) + ":"
                        }
                        if ((tumblerTime.currentIndexAt(1)) < 10) {
                            txt = txt + "0" + (tumblerTime.currentIndexAt(1))
                        }
                        else {
                            txt = txt + (tumblerTime.currentIndexAt(1))
                        }
                        startDateTime.text = txt

                        var txt2 = tumbler2.currentIndexAt(0) + 2000 + "-"
                        if ((tumbler2.currentIndexAt(1) + 1) < 10) {
                            txt2 = txt2 + "0" + (tumbler2.currentIndexAt(1) + 1) + "-"
                        }
                        else {
                            txt2 = txt2 + (tumbler2.currentIndexAt(1) + 1) + "-"
                        }
                        if ((tumbler2.currentIndexAt(2) + 1) < 10) {
                            txt2 = txt2 + "0" + (tumbler2.currentIndexAt(2) + 1) + " "
                        }
                        else {
                            txt2 = txt2 + (tumbler2.currentIndexAt(2) + 1) + " "
                        }
                        if ((tumblerTime2.currentIndexAt(0)) < 10) {
                            txt2 = txt2 + "0" + (tumblerTime2.currentIndexAt(0)) + ":"
                        }
                        else {
                            txt2 = txt2 + (tumblerTime2.currentIndexAt(0)) + ":"
                        }
                        if ((tumblerTime2.currentIndexAt(1)) < 10) {
                            txt2 = txt2 + "0" + (tumblerTime2.currentIndexAt(1))
                        }
                        else {
                            txt2 = txt2 + (tumblerTime2.currentIndexAt(1))
                        }
                        endDateTime.text = txt2

                        //startDateTime.text = tumbler.currentIndexAt(0) + 2000 + "." + (tumbler.currentIndexAt(1) + 1) + "." + (tumbler.currentIndexAt(2) + 1) + " " + tumblerTime.currentIndexAt(0) + ":" + tumblerTime.currentIndexAt(1)
                        selectDateTime.close()
                    }
                }
                }
            }
                        Component.onCompleted: {
                users.getFriend(mybd.user);
            }
            ListModel {
                id: move
                ListElement {
                       start: "2016-05-25 12:55:06"
                       end: "2016-05-25 13:09:59"
                   }
                ListElement {
                       start: "2016-05-25 01:37:50"
                       end: "2016-05-25 01:37:50"
                   }
                ListElement {
                       start: "2016-05-25 00:23:58"
                       end: "2016-05-25 00:23:58"
                   }
                ListElement {
                       start: "2016-05-24 02:28:35"
                       end: "2016-05-24 04:17:00"
                   }
                ListElement {
                       start: "2016-05-23 22:03:18"
                       end: "2016-05-23 22:05:15"
                   }
            }
            ListView {
                id: viewmove
                anchors.top: construct.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                model: move
                spacing: dp(20)
                delegate: Rectangle {
                    width: viewmove.width- dp(30)
                    height: dp(30)
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: 'white'
                    border {
                        color: 'lightgray'
                        width: dp(2)
                    }
                    radius: dp(10)
                    Text {

                    anchors.centerIn: parent
                    elide: Text.AlignHCenter
                    text: start + " - " + end
                    font.pointSize: dp(10)
                    }
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
                        font.pixelSize: Screen.width/11
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
                        font.pixelSize: Screen.width/12
                        echoMode: TextInput.Password
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
                menu4.visible = false;
                menu5.visible = false;
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
    Component {
        id: vk_access
        Item {
                Text {
                    id: vk_text
                    text: "Чтобы видеть друзей использующих это приложение привяжите свою странницу Вконтакте"
                    anchors.right: parent.right
                    anchors.left: parent.left
                    font.pointSize: dp(20)
                    wrapMode: Text.Wrap
                    visible: vk.mainphoto === ""
                }
                Image {
                    anchors.top: vk_text.bottom
                    anchors.topMargin: dp(30)
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "vk.png"
                    sourceSize.width: Screen.width/5
                    sourceSize.height: Screen.width/5
                    visible: vk.mainphoto === ""
                    MouseArea {
                          anchors.fill: parent
                          onClicked: {
                              loader.sourceComponent = vk_view
                          }
                    }
                }
                ListModel {
                    id: contactModel

                }
                Text {
                    id: vk_text2
                    text: "Список ваших друзей, у которых вы еще не попросили доступ"
                    anchors.right: parent.right
                    anchors.left: parent.left
                    font.pointSize: dp(12)
                    wrapMode: Text.Wrap
                    visible: contactModel.count
                }

                ListView {
                    id: view
                    anchors.top: vk_text2.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: dp(10)
                    //anchors.fill: parent
                    model: contactModel
                    spacing: dp(10)
                    visible: vk.mainphoto !== ""
                    delegate: Rectangle {
                        width: view.width
                        height: image.height + dp(20)
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: 'white'
                        border {
                            color: 'lightgray'
                            width: dp(2)
                        }
                        radius: dp(10)

                        Row {
                            anchors.margins: dp(10)
                            anchors.fill: parent
                            spacing: dp(10)

                            Image {
                                id: image
                                width: (view.height/4)-dp(30)
                                height: (view.height/4)-dp(30)

                                //height: parent.height
                                //fillMode: Image.PreserveAspectFit
                                source: model['photo']
                            }
                            Column {
                                width: parent.width - image.width - parent.spacing
                                anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    //width: parent.width - image.width - parent.spacing
                                    //anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                    text: model['name']
                                    wrapMode: Text.Wrap
                                    font.pointSize: dp(14)
                                }
                                Text {
                                    //width: parent.width - image.width - parent.spacing
                                    //anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    renderType: Text.NativeRendering
                                    //text: "%1 %2".arg(model['first_name']).arg(model['last_name'])
                                    text: model['login']
                                    wrapMode: Text.Wrap
                                    font.pointSize: dp(10)
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                users.findUser(model.login, mybd.user)
                            }
                        }
                    }
                }
                Component.onCompleted: {
                    vk.friendHere()
                }
        }

    }
    Component {
        id: vk_view
        Item {
            WebView {
                id: webView
                anchors.fill: parent
                url: "http://oauth.vk.com/authorize?client_id=5464103&display=mobile&redirect_uri=http://oauth.vk.com/blank.html&scope=friends,offline,nohttps&response_type=token&v=5.52"
                onLoadingChanged: {
                    vk.setAccess_token(loadRequest.url, mybd.user);
                }
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
    Dialog {
        id: listfriend
        //width: mainWindow.width/2
        //height: mainWindow.height/2

        contentItem: ListView {
            id: viewlistfr
            width: mainWindow.width*(2/3)
            height: mainWindow.height*(2/3)
            //anchors.top: parent.top
            //anchors.left: parent.left
            //anchors.right: parent.right
            //anchors.bottom: parent.bottom
            anchors.margins: dp(10)
            //anchors.fill: parent
            model: listfriendmodel
            spacing: dp(10)

            delegate: Rectangle {
                width: viewlistfr.width
                height: image.height + dp(20)
                anchors.horizontalCenter: parent.horizontalCenter
                color: 'white'
                border {
                    color: 'lightgray'
                    width: dp(2)
                }
                radius: dp(10)

                Row {
                    anchors.margins: dp(10)
                    anchors.fill: parent
                    spacing: dp(10)

                    Image {
                        id: image
                        width: (viewlistfr.height/4)-dp(30)
                        height: (viewlistfr.height/4)-dp(30)

                        //height: parent.height
                        //fillMode: Image.PreserveAspectFit
                        source: model['photo']
                    }
                    Column {
                        width: parent.width - image.width - parent.spacing
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            //width: parent.width - image.width - parent.spacing
                            //anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                            text: model['name']
                            wrapMode: Text.WrapAnywhere
                            font.pointSize: dp(12)
                        }
                        Text {
                            //width: parent.width - image.width - parent.spacing
                            //anchors.verticalCenter: parent.verticalCenter
                            elide: Text.ElideRight
                            renderType: Text.NativeRendering
                            //text: "%1 %2".arg(model['first_name']).arg(model['last_name'])
                            text: model['login']
                            wrapMode: Text.Wrap
                            font.pointSize: dp(8)
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listfriend.close()
                        vk.selectUser(model.index+1)
                    }
                }
            }
        }
    }
    ListModel {
        id: listfriendmodel
    }
}

