import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls 1.4

Item{
    Rectangle{
        color: "white"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 0.02 * app.width
        anchors.bottom: sendBar.top
        clip: true

        //ListView not working for now
        ScrollView{
            id: scroll
            anchors.fill: parent
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn
            horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

            Column{
                id: mainCol
                width: parent.width - 15
                Repeater{
                    model: chatModel

                    delegate:
                        Item{
                        height: subCol.height + 10
                        width: mainCol.width

                        Column{
                            id: subCol
                            width: parent.width
                            spacing: 5

                            property bool printUser: index <= 0 || (chatModel.get(index-1).userLogin !== chatModel.get(index).userLogin)

                            Text{
                                visible: parent.printUser
                                text: userLogin + " :"
                            }
                            Rectangle{
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                height: textItem.height * 1.3
                                width: textItem.width * 1.1
                                radius: 5
                                color: userID === app.currentUserID ? "yellow" : "lightgray"
                                Text{
                                    id: textItem
                                    text: content
                                    font.pointSize: 18
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item{
        id: sendBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0.02 * app.width
        anchors.rightMargin: 0.02 * app.width
        anchors.bottomMargin: 35

        //RowLayout are not yet implemented in qmlweb
        Row{
            width: parent.width
            Rectangle{
                id: userRect
                height: input.height
                width: userText.width * 1.5
                color: "lightgray"

                Text{
                    id: userText
                    anchors.centerIn: parent
                    text: app.currentUserLogin
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        console.debug("TEST")
                        scroll.flickableItem.contentY = 0
                    }
                }
            }

            TextField{
                id: input
                width: parent.width - userRect.width - sendButton.width
                onAccepted:{
                    ws.send( input.text )
                    input.text = ""
                }
            }

            Connections{
                target: input
                onAccepted:{
                    ws.send( input.text )
                    input.text = ""
                }
            }

            BasicButton{
                id: sendButton
                text: "Send"
                enabled: input.text !== ""
                height: input.height

                onClicked:{
                    ws.send( input.text )
                    input.text = ""
                }
            }
        }
    }
}
