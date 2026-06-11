import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import guide
import "components"

ApplicationWindow {
    width: 1024
    height: 768
    minimumWidth: 1024
    maximumWidth: 1024
    minimumHeight: 768
    maximumHeight: 768
    visible: true
    title: qsTr("POS System")

    Material.theme: Material.Light
    Material.accent: Material.Brown
    color: "#f6f4f2"

    ProductModel { id: productModel }
    CartModel { id: cartModel }
    SalesModel {id: salesModel}
    DatabaseManager { id: dbManager }

    Column {
        anchors.fill: parent
        padding: 5
        spacing: 0

        HeaderBar {
            id: headerBar
            onHomeRequested: {
                if (stack.depth > 1)
                    stack.pop()
                else
                    stack.push(Qt.resolvedUrl("components/PosPage.qml"))
            }
        }

        StackView {
            id: stack
            width: parent.width
            height: parent.height - headerBar.height
            initialItem: MainPage {}
        }
    }
}
