import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 700
    height: 600
    title: "Edit Menu"
    visible: true

    Material.theme: Material.Light
    Material.accent: Material.Brown
    color: "#f6f4f2"

    property int colPriceWidth: 90
    property int colCategoryWidth: 130
    property int colImageWidth: 80
    property int colDeleteWidth: 70

    property string imageSrc: ""

    FileDialog {
        id: fileDialog
        title: "Please choose an image"
        nameFilters: ["Image files (*.jpg *.png *.jpeg *.webp)", "All files (*)"]

        property int activeRow: -1

        onAccepted: {
            if (activeRow >= 0) {
                productModel.updateProduct(activeRow, selectedFile, ProductModel.ImagePathRole)
                activeRow = -1
            } else {
                imageSrc = selectedFile
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // --- ADD NEW PRODUCT PANEL ---
        Pane {
            Layout.fillWidth: true
            Material.elevation: 2
            padding: 12

            RowLayout {
                anchors.fill: parent
                spacing: 12

                TextField {
                    id: nameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 40
                    topPadding: 4
                    bottomPadding: 4
                    placeholderText: "New Product Name"
                }

                TextField {
                    id: priceInput
                    Layout.preferredWidth: root.colPriceWidth
                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 40
                    topPadding: 4
                    bottomPadding: 4
                    placeholderText: "Price"
                    validator: RegularExpressionValidator { regularExpression: /^[0-9]+(\.[0-9]{1,2})?$/ }
                }

                ComboBox {
                    id: categoryInput
                    Layout.preferredWidth: root.colCategoryWidth
                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 40
                    topPadding: 4
                    bottomPadding: 4
                    model: productModel.categoryView
                }

                Button {
                    Layout.preferredWidth: root.colImageWidth
                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 40
                    text: root.imageSrc === "" ? "Image" : "Selected ✓"
                    Material.foreground: root.imageSrc === "" ? Material.primaryTextColor : "green"
                    onClicked: {
                        fileDialog.activeRow = -1
                        fileDialog.open()
                    }
                }

                Button {
                    Layout.preferredWidth: root.colDeleteWidth
                    Layout.preferredHeight: 40
                    Layout.maximumHeight: 40
                    text: "Add"
                    Material.background: Material.accent
                    Material.foreground: "white"
                    enabled: nameInput.text.length > 0 && priceInput.text.length > 0

                    onClicked: {
                        productModel.addProduct(nameInput.text, priceInput.text, categoryInput.currentText, imageSrc)
                        nameInput.clear()
                        priceInput.clear()
                        imageSrc = ""
                    }
                }
            }
        }

        // --- DATA GRID / LIST VIEW ---
        ListView {
            id: listview
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: productModel
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            spacing: 2

            headerPositioning: ListView.OverlayHeader
            header: Rectangle {
                width: listview.width
                height: 40
                color: "#e0e0e0"
                z: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Label { Layout.fillWidth: true; text: "Name"; font.bold: true }
                    Label { Layout.preferredWidth: root.colPriceWidth; text: "Price"; font.bold: true }
                    Label { Layout.preferredWidth: root.colCategoryWidth; text: "Category"; font.bold: true }
                    Label { Layout.preferredWidth: root.colImageWidth; text: "Image"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                    Label { Layout.preferredWidth: root.colDeleteWidth; text: "Action"; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                }
            }

            delegate: Rectangle {
                id: delegateItem
                width: listview.width
                height: 60
                color: index % 2 === 0 ? "#ffffff" : "#f9f9f9"

                required property int index
                required property string name
                required property string price
                required property string category
                required property string imagePath

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    TextField {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        Layout.maximumHeight: 40
                        topPadding: 4
                        bottomPadding: 4
                        text: delegateItem.name
                        onEditingFinished: productModel.updateProduct(delegateItem.index, text, ProductModel.NameRole)
                    }

                    TextField {
                        Layout.preferredWidth: root.colPriceWidth
                        Layout.preferredHeight: 40
                        Layout.maximumHeight: 40
                        topPadding: 4
                        bottomPadding: 4
                        text: delegateItem.price
                        onEditingFinished: productModel.updateProduct(delegateItem.index, text, ProductModel.PriceRole)
                    }

                    ComboBox {
                        Layout.preferredWidth: root.colCategoryWidth
                        Layout.preferredHeight: 40
                        Layout.maximumHeight: 40
                        topPadding: 4
                        bottomPadding: 4
                        model: productModel.categoryView

                        // FIX: Changed indexOfValue to find() to correctly locate the string in the model
                        currentIndex: find(delegateItem.category)

                        onActivated: function(cbIndex) {
                            productModel.updateProduct(delegateItem.index, currentText, ProductModel.CategoryRole)
                        }
                    }

                    Item {
                        Layout.preferredWidth: root.colImageWidth
                        Layout.fillHeight: true

                        Image {
                            anchors.centerIn: parent
                            width: 40
                            height: 40
                            source: delegateItem.imagePath ? delegateItem.imagePath : ""
                            fillMode: Image.PreserveAspectCrop
                            mipmap: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#dddddd"
                                border.width: 1
                                z: -1
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    fileDialog.activeRow = delegateItem.index
                                    fileDialog.open()
                                }
                            }
                        }
                    }

                    Button {
                        Layout.preferredWidth: root.colDeleteWidth
                        Layout.preferredHeight: 40
                        Layout.maximumHeight: 40
                        topPadding: 0
                        bottomPadding: 0

                        text: "✕"
                        font.pixelSize: 16
                        font.bold: true

                        Material.background: "#ff4c4c"
                        Material.foreground: "white"

                        onClicked: productModel.removeProduct(delegateItem.index)
                    }
                }
            }
        }
    }
}
