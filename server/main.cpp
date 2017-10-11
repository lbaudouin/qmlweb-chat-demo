#include <QCoreApplication>
#include <QWebSocketServer>
#include <QWebSocket>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCryptographicHash>
#include <QDebug>

struct User{
    int id;
    QString login;
    QByteArray password;
};

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    a.setApplicationName("ChatServer");
    a.setApplicationVersion("1.0");
    QMap<QString, User> users;
    QWebSocketServer m_server("chat",QWebSocketServer::NonSecureMode,&a);
    if( !m_server.listen(QHostAddress::Any,8081) ){
        qDebug() << "Failed to open WebSocketServer";
    }
    QList<QWebSocket*> m_connections;
    QObject::connect(&m_server, &QWebSocketServer::newConnection, [&users, &m_server, &m_connections](){
        qDebug() << "New connection";
        QWebSocket *socket = m_server.nextPendingConnection();
        QObject::connect(socket, &QWebSocket::textMessageReceived, [&users, socket, &m_connections](const QString &message){
            qDebug() << "New data " << message;
            QJsonDocument doc = QJsonDocument::fromJson(message.toLocal8Bit());
            if(!doc.isObject()){
                return;
            }
            QJsonObject obj = doc.object();
            if( obj.contains("login") ){
                QJsonObject out;
                out.insert("newUser", !users.contains(obj.value("login").toString()));
                socket->sendTextMessage( QJsonDocument(out).toJson() );
                return;
            }
            if( obj.contains("connect") ){
                QJsonObject connectionInfo = obj.value("connect").toObject();
                QJsonObject out;
                if( connectionInfo.contains("login") && connectionInfo.contains("password")){
                    QString login = connectionInfo.value("login").toString();
                    QCryptographicHash hash(QCryptographicHash::Md5);
                    hash.addData(connectionInfo.value("password").toString().toLocal8Bit());
                    QByteArray password = hash.result();
                    if(users.contains(login)){
                        out.insert("connect",  (users.value(login).password == password) ? 0 : 1);
                    }else{
                        out.insert("connect", 0);
                        User u;
                        u.login = login;
                        u.password = password;
                        u.id = 0;
                        foreach (const auto &user, users) {
                            if( u.id <= user.id ) u.id = user.id + 1;
                        }
                        users.insert( login, u );
                    }
                    out.insert("userID", users.value(login).id);
                    out.insert("userLogin", login);
                }else{
                    out.insert("connect", -1);
                }
                socket->sendTextMessage( QJsonDocument(out).toJson() );
                return;
            }
            foreach (auto ws, m_connections) {
                ws->sendTextMessage( message );
            }
        });
        QObject::connect(socket, &QWebSocket::disconnected, [&socket, &m_connections](){
            m_connections.removeAll(socket);
        });
        m_connections << socket;
    });
    return a.exec();
}
