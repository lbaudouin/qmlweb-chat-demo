import QtQuick 2.0
import QtQuick.Controls 2.1

Rectangle{
    id: loginPage

    color: "white"
    height: col.height * 1.2

    border.color: "black"
    border.width: 2

    function log(){
        ws.sendTextMessage( JSON.stringify( {"connect":{"login": inputLogin.text, "password": inputPassword.text}} ) )
        inputPassword.text = ""
    }

    Column{
        id: col
        width: parent.width * 0.8
        anchors.centerIn: parent
        spacing: 5
        Text{
            text: "Login"
        }
        TextField{
            id: inputLogin
            width: parent.width
            //text: app.web ? "Web" : "Ordi"

            onTextChanged: {
                ws.sendTextMessage( JSON.stringify( {"login": inputLogin.text } ) )
            }
        }
        Item{
            width: 5
        }
        Text{
            text: "Password"
        }
        TextField{
            id: inputPassword
            width: parent.width
            echoMode: app.web ? 1 :TextField.Password
            onAccepted: {
                loginPage.log()
            }
        }
        Text{
            visible: app.loginError === 1
            color: "red"
            text: "Wrong password"
        }

        BasicButton{
            anchors.right: parent.right
            enabled: app.connected && inputLogin.text != "" && inputPassword.text != ""
            text: app.newUser ? "Create" : "Login"

            onClicked: {
                loginPage.log()
            }
        }
    }
}
