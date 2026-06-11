import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import guide

Item {
    property Window editProductInstance: null
    implicitWidth: 640

    property int activeCategoryIndex: -1

    ProductFilterProxyModel {
        id: productProxyModel
        sourceModel: productModel
    }

    // 1. Header (Fixed at Top)
    Rectangle {
        id: menuHeader
        width: parent.width
        height: 80
        color: "#f6f4f2"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 5

        Column {
            anchors.left: parent.left
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Item{
                height: 40
                width: parent.width

                RowLayout{
                    spacing: 0
                    anchors.fill: parent
                    anchors.rightMargin: 20

                    Image{
                        id: menuicon
                        source: "../Resources/bookmark.svg"
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                    }

                    ToolButton {
                        id: menuButton
                        text: "Menu ▾"
                        font.bold: true
                        font.pixelSize: 14
                        onClicked: menuPopup.popup(menuButton)
                        leftPadding: 0
                        rightPadding: 0
                    }

                    Item {
                            Layout.fillWidth: true
                        }

                    Rectangle{
                        id: searchbox
                        width: 200
                        height: 20
                        radius: 10
                        visible: false
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        color: "white"
                        clip: true
                        TextEdit {
                            id: searchinput
                            anchors.fill: parent
                            visible: false
                            text: ""
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            onTextChanged: {
                                productProxyModel.searchText = text
                            }
                        }
                    }
                    Text{
                        id: txt
                        width: 20
                        text: "⌕"
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        transform: Scale {
                                origin.x: txt.width / 2
                                origin.y: txt.height / 2
                                xScale: -1
                                yScale: 1
                            }
                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                    searchbox.visible = !searchbox.visible
                                    searchinput.visible = searchbox.visible
                                    if (searchbox.visible)
                                        searchinput.forceActiveFocus()
                                }
                        }
                    }
                }



                Menu {
                    id: menuPopup

                    MenuItem {
                        text: "ADD / EDIT"
                        onTriggered: {
                            if (!editProductInstance) {
                                editProductInstance =
                                    editProductComponent.createObject(null)

                                editProductInstance.onClosing.connect(function () {
                                    editProductInstance = null
                                })
                            } else {
                                editProductInstance.raise()
                                editProductInstance.requestActivate()
                            }
                        }
                    }
                }
                Component {
                    id: editProductComponent
                    EditProductWindow{}
                }
            }


            Row {
                id: categoryRow
                spacing: 10
                // Manually add an "All" button
                Text {
                    text: "All"
                    font.pixelSize: 14
                    color: activeCategoryIndex === -1 ? "#5D4037" : "black"
                    font.underline: activeCategoryIndex === -1 ? true : false
                    padding: 8

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            productProxyModel.filterCategory = ""
                            activeCategoryIndex = -1
                        }
                    }
                }

                Repeater {
                    model: productModel.categoryView
                    delegate: Text {
                        text: modelData
                        font.pixelSize: 14
                        color: activeCategoryIndex === index ? "#5D4037" : "black"
                        font.underline: activeCategoryIndex === index ? true : false
                        padding: 8

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                productProxyModel.filterCategory = modelData
                                activeCategoryIndex = index
                            }
                        }
                    }
                }
            }
        }
    }

    // 2. Product Grid
    GridView {
        id: productGrid

        model: productProxyModel

        anchors.top: menuHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        cellWidth: 160
        cellHeight: 180
        clip: true

        delegate: Item {
            width: productGrid.cellWidth - 5
            height: productGrid.cellHeight - 5

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: "white"
                border.color: "#BCAAA4"
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    width: parent.width - 20
                    spacing: 5

                    Image {
                        source: model.imagePath
                        width: 100
                        height: 100
                        anchors.horizontalCenter: parent.horizontalCenter
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        MouseArea{
                            anchors.fill: parent
                            onDoubleClicked: Qt.openUrlExternally(model.imagePath)
                        }
                    }

                    Text {
                        text: model.name
                        font.pixelSize: 14
                        color: "#333333"
                        elide: Text.ElideRight
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Row {
                        width: parent.width

                        Text {
                            text: "$" + model.price.toFixed(2)
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Item {
                            width: parent.width - 24 - parent.children[0].width
                            height: 1
                        }

                        Image {
                            width: 28
                            height: 28
                            source: "../Resources/add_box_color.svg"
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                anchors.fill: parent
                                onClicked: cartModel.addToCart(model.name, model.price, model.imagePath)
                            }
                        }
                    }
                }
            }
        }
    }
}
