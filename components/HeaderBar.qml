import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root
    signal homeRequested()
    width: parent.width - 10
    height: 40
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var date = new Date()
            timeText.text = Qt.formatDateTime(date, "ddd, dd MMM hh:mm AP")
        }
    }

    Rectangle{
        color: "#f6f4f2"
        width: parent.width - 10
        height: 40

        // --- Main Button ---
        Rectangle{
            id: mainbtn
            width: 100
            height: 30
            radius: 10
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            // color: "#8a7067" /*"black"*/
            Row{
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Image {
                    source: "../Resources/home_app_logo.svg"
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text{
                    // color: "white"
                    text: "Viuna Café"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                    font.bold: true
                }
            }
            MouseArea{
                id: mainbtnMouse
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    salesModel.refresh()
                    root.homeRequested()
                }
            }
        }

        // --- Profile ---
        Rectangle{
            id: profile
            width: 100
            height: 30
            radius: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    source: "../Resources/profile.svg"
                    width: 18
                    height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    text: "Admin"
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }
            }
        }

        // --- Time&Date ---
        Rectangle{
            anchors.right: profile.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            width: 180
            height: 30
            color: "white"
            radius: 10
            Row{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    source: "../Resources/calendar.svg"
                    width: 18
                    height: 18
                }
                Text{
                    id: timeText
                    text: ""
                    color: "#999999"
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14
                }
            }
        }


    }
}
