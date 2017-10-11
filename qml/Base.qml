/****************************************

  Due to limitation in QmlWeb 0.2.0 some QML component/functions/signals can't be use

****************************************/

import QtQuick 2.0
import QtQuick.Controls 2.1
import QtWebSockets 1.1

Rectangle {
    id: app
    color: "#333"

    anchors.fill: parent

    property bool web: true
    property bool connected: ws.status === 1
    property int currentUserID: -1
    property string currentUserLogin: ""
    property bool logged: false
    property int loginError: 0
    property bool newUser: true

    onConnectedChanged: {
        if(!app.connected){
            console.debug("Auto disconnect", ws.status)
            logged = false
        }
    }


    WebSocket{
        id: ws
        active: true
        url: "ws://127.0.0.1:8081"
        onStatusChanged: {
            if( status === WebSocket.Closed || status === WebSocket.Error )
                reconnectionTimer.start()
            if( status === WebSocket.Open)
                reconnectionTimer.stop()
        }
        onTextMessageReceived:{
            console.debug( message )
            var data = JSON.parse( message )
            if( "connect" in data ){
                app.loginError = data.connect
                if(data.connect === 0){
                    //No error
                    app.currentUserLogin = data.userLogin
                    app.currentUserID = data.userID
                    app.logged = true
                }
                return
            }
            if( "newUser" in data){
                app.newUser = data.newUser
                return
            }

            chatModel.append( {content: data.message, userID: data.userID, userLogin: data.userLogin } )
        }
        function send( message ){
            var d = {
                message: message,
                userID: app.currentUserID,
                userLogin: app.currentUserLogin
            }
            ws.sendTextMessage( JSON.stringify(d) )
        }
    }


    Timer{
        id: reconnectionTimer
        repeat: false
        interval: 2000
        onTriggered: {
            ws.active = false
            ws.active = true
        }
    }

    Column{
        id: githubCol
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 15
        Image{
            source: app.web ? "images/github.png" : "qrc:/images/github"
            width: 32
            height: 32
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Text{
            text: "Github"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea{
        anchors.fill: githubCol
        onClicked: {
            Qt.openUrlExternally("http://github.com/lbaudouin/qmlweb-chat-demo");
        }
        cursorShape: Qt.PointingHandCursor
    }

    Row{
        id: infoRow
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 0.02 * app.width
        spacing: 15

        Text{

            text: "QML chat demo"
            color: "white"
            font.pointSize: 20
        }

        Rectangle{
            anchors.verticalCenter: parent.verticalCenter
            height: infoRow.height * 0.5
            width: height
            radius: height

            color: app.connected ? "green" : "red"
        }
    }

    ListModel{
        id: chatModel
        ListElement{ //need to init the model first
            date: 0
            content: "test"
            userID: 0
            userLogin: ""
        }
        Component.onCompleted:{
            clear()
        }
    }

    //StackView not available
    Item{
        id: container

        anchors.top: infoRow.bottom
        anchors.topMargin: 0.02 * app.height
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        Login{
            visible: !app.logged
            anchors.centerIn: parent
            width: 500
        }

        Chat{
            visible: app.logged
            anchors.fill: parent
        }
    }
}

