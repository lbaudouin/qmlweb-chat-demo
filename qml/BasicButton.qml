/***********************

  No Material with QmlWeb 0.2.0
  No Styles with QmlWeb 0.2.0

***********************/

import QtQuick 2.0

Rectangle{
    id: button

    property alias text: textItem.text
    property bool enabled: true

    color: enabled ? (buttonMouseArea.pressed ? "#FF8F00" : "#FFC107") : "lightgray"

    width: textItem.width * 2
    height: textItem.height * 2
    implicitHeight: height

    signal clicked()

    Text{
        id: textItem
        anchors.centerIn: parent
        color: button.enabled ? "black" : "white"
    }

    MouseArea{
        id: buttonMouseArea
        enabled: app.connected
        anchors.fill: parent
        onClicked:{
            button.clicked()
        }
    }
}
