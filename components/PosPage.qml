import QtQuick

Item {
    MenuPanel {
        id:menupanel
        implicitWidth: 640
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    CartPanel {
        anchors.left: menupanel.right
        implicitWidth: parent.width - menupanel.width -10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
