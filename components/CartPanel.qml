import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import guide

Item {

    BillGenerator{id: billGenerator}
    DatabaseManager{}


    Rectangle {
        id: cartContainer
        anchors.fill: parent
        color: "white"
        radius: 10

        // Cart Header
        RowLayout {
            id: cartHeader

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 6
            spacing: 10

            // Item 1: Title
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                color: "transparent"

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6 // Adds a nice small gap between your icon and text

                    Image {
                        source: "../Resources/order.svg"
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Order Details"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // Item 2: Reset Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                border.color: "#e0e0e0"
                radius: 8

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6 // Adds a nice small gap between your icon and text

                    Image {
                        source: "../Resources/delete.svg"
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Reset Order"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: cartModel.resetOrder()
                }
            }

            // Item 3: Dine In Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                border.color: "#e0e0e0"
                radius: 8

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6 // Added spacing here too

                    Image {
                        source: "../Resources/dine.svg"
                        width: 18
                        height: 18
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Dine In"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        ListView {
            id: cartListView
            anchors.top: cartHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: footerItem.top // Anchor to footer
            anchors.margins: 6
            anchors.topMargin: 14

            clip: true
            spacing: 5
            model: cartModel

            Text {
                id: cartContainerStatus
                text: "Select Product"
                anchors.centerIn: parent
                visible: cartListView.count === 0
            }

            delegate: Rectangle {
                width: cartListView.width
                height: 98
                radius: 12
                color: "white"
                border.color: "#BCAAA4"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.rightMargin: 5
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    anchors.leftMargin: 5

                    spacing: 5

                    // --- 1. Product Image (Left) ---
                    Rectangle {
                        Layout.preferredWidth: 86
                        Layout.preferredHeight: 86
                        radius: 12

                        Image {
                            source: model.imagePath
                            anchors.centerIn: parent
                            width: 80
                            height: 80
                            asynchronous: true
                            mipmap: true
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    // --- 2. Product Info (Middle) ---
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4

                        Text {
                            text: model.name
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Row {
                            spacing: 5
                            Repeater {
                                model: ["Size: Small", "Sugar: Normal"]
                                delegate: Rectangle {
                                    width: tagText.implicitWidth + 12
                                    height: 20
                                    radius: 4
                                    border.color: "#BCAAA4"
                                    Text {
                                        id: tagText
                                        text: modelData
                                        anchors.centerIn: parent
                                        font.pixelSize: 10
                                        color: "gray"
                                    }
                                }
                            }
                            Rectangle {
                                width: 20
                                height: 20
                                radius: 8
                                Text { text: "📋️️"; anchors.centerIn: parent; font.pixelSize: 18 }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: cartModel.subtract(index)
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        Text {
                            text: "$" + model.total.toFixed(2)
                            font.pixelSize: 18
                        }
                    }

                    // --- 3. Actions (Right) ---
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight
                        spacing: 0

                        Rectangle {
                            width: 28
                            height: 28
                            Layout.alignment: Qt.AlignRight
                            color: "#f75555"
                            radius: 8
                            // Text{
                            //     text: "🗑️"
                            //     anchors.centerIn: parent
                            // }
                            Image {
                                source: "../Resources/delete_white.svg"
                                width: 18
                                height: 18
                                anchors.centerIn: parent
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    cartModel.removeFromCart(index)
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }

                        RowLayout {
                            spacing: 5

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 8
                                border.color: "#e0e0e0"
                                Text { text: "−"; anchors.centerIn: parent; font.pixelSize: 18 }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: cartModel.subtract(index)
                                }
                            }

                            Text {
                                text: model.quantity
                                font.pixelSize: 16
                                Layout.minimumWidth: 15
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 8
                                border.color: "#e0e0e0"
                                Text { text: "+"; anchors.centerIn: parent; font.pixelSize: 18 }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: cartModel.increase(index)
                                }
                            }
                        }
                    }
                }
            }
        }

        // Cart Bottom (total)
        Item{
            id: footerItem
            width: parent.width
            height: 200
            anchors.bottom: parent.bottom

            Rectangle{
                anchors.fill: parent
                border.color: "#BCAAA4"
                radius: 10
                anchors.margins: 6
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Subtotal"; color: "gray" }
                        Item { Layout.fillWidth: true }
                        Text { text: "$" + cartModel.subTotal.toFixed(2); font.bold: true }
                    }

                    RowLayout {
                        visible: cartModel.discountAmount > 0
                        Layout.fillWidth: true
                        Text { text: "Discount"; color: "red" }
                        Item { Layout.fillWidth: true }
                        Text { text: "-$" + cartModel.discountAmount.toFixed(2); color: "red" }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Tax (9%)"; color: "gray" }
                        Item { Layout.fillWidth: true }
                        Text { text: "$" + cartModel.taxAmount.toFixed(2) }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#ccc"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Total Amount"
                            font.pixelSize: 18
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "$" + cartModel.grandTotal.toFixed(2)
                            font.pixelSize: 22
                            font.bold: true
                            color: "#2c3e50"
                        }
                    }
                    // SEATS
                    RowLayout {
                        width: parent.width

                        Text {
                            text: "Select Table"
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                        }

                        Item { Layout.fillWidth: true } // spacer

                        ComboBox {
                            Layout.preferredHeight: 30
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                            model: ListModel {
                                ListElement { text: "Table_One" }
                                ListElement { text: "Table_Two" }
                                ListElement { text: "Table_Three" }
                            }
                        }
                    }
                    RowLayout {
                        width: parent.width
                        RoundButton{
                            radius: 10
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true
                            text: "Pay Now"
                            highlighted: true
                            Material.accent: Material.Orange
                        }
                        RoundButton{
                            radius: 10
                            Layout.preferredHeight: 40
                            Layout.fillWidth: true
                            text: "Open Bill"
                            highlighted: true
                            Material.accent: Material.Grey
                            onClicked: {
                                const path = billGenerator.generatePdf(cartModel)
                                if (path !== "")
                                    Qt.openUrlExternally(path)
                            }
                        }
                    }
                }
            }
        }
    }
}
