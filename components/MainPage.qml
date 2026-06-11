import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtGraphs
import guide

Item {
    id: root
    property double totalRevenue: 0.0

    // 1. New function: ONLY updates the UI summaries (Graph & Total Sales)
    function updateSummaries() {
        if (typeof graphsView !== "undefined") graphsView.refreshGraph()
        if (typeof barGraphsView !== "undefined") barGraphsView.refreshGraph()
        if (typeof dbManager !== "undefined") root.totalRevenue = dbManager.getTotalSales()
    }

    // 2. Initial load
    Component.onCompleted: {
        updateSummaries()
    }

    // 3. When page is shown, refresh the sales list.
    onVisibleChanged: {
        if (visible && typeof salesModel !== "undefined") {
            salesModel.refresh()
        }
    }

    // 4. Safe connections
    Connections {
        target: salesModel

        function onModelReset() {
            updateSummaries()
        }

        function onRowsInserted() {
            updateSummaries()
        }
    }


    RowLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        // ----------------------------------------------------
        // 1. LEFT PANEL (INVOICES)
        // ----------------------------------------------------
        // Wrapped in a styling Rectangle so the whole panel matches the right side
        Rectangle {
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            color: "white"
            radius: 10
            border.color: "#e0e0e0"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Added a title to match the right-side charts
                Text {
                    text: "Recent Invoices"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1d3d53"
                    Layout.fillWidth: true
                }

                ListView {
                    id: invoiceListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 15
                    clip: true
                    model: salesModel

                    delegate: Rectangle {
                        // The listview now has margins from the parent ColumnLayout,
                        // so we can just use the full width without complex math.
                        width: invoiceListView.width
                        height: itemColumn.implicitHeight + 30

                        // Slightly off-white to pop against the white panel
                        color: "#fafafa"
                        radius: 8
                        border.color: "#e0e0e0"

                        ColumnLayout {
                            id: itemColumn
                            anchors.fill: parent
                            anchors.margins: 15

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: "Invoice #" + invoiceNumber; font.bold: true; font.pixelSize: 16 }
                                Item { Layout.fillWidth: true }
                                Text { text: date; color: "gray" }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#eee" }

                            Text { text: "Items:"; font.bold: true; color: "#555" }

                            Column {
                                Layout.fillWidth: true
                                spacing: 5

                                Repeater {
                                    model: items
                                    RowLayout {
                                        width: parent.width
                                        Text { text: modelData.name; Layout.fillWidth: true }
                                        Text { text: "x" + modelData.quantity; color: "gray" }
                                        Text { text: "$" + modelData.lineTotal.toFixed(2); font.bold: true }
                                    }
                                }
                            }

                            Rectangle { Layout.fillWidth: true; height: 1; color: "#eee" }

                            RowLayout {
                                Layout.fillWidth: true
                                Item { Layout.fillWidth: true }
                                Text { text: "Total: $" + total.toFixed(2); font.bold: true; font.pixelSize: 18; color: "#2E7D32" }
                            }
                        }
                    }
                }
            }
        }

        // ----------------------------------------------------
        // 2. RIGHT PANEL (ANALYTICS)
        // ----------------------------------------------------
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 15

            // --- TOP SUMMARY CARDS ---
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                spacing: 15

                // Card 1: Total Sales
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#e0e0e0"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Total Sales"
                            color: "gray"
                            font.pixelSize: 14
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 22
                            font.bold: true
                            color: "#1d3d53"
                            text: "$" + Number(root.totalRevenue).toFixed(2)
                        }
                    }
                }

                // Card 2: Total Orders
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "white"
                    radius: 10
                    border.color: "#e0e0e0"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Total Orders"
                            color: "gray"
                            font.pixelSize: 14
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            font.pixelSize: 22
                            font.bold: true
                            color: "#1d3d53"
                            text: invoiceListView.count
                        }
                    }
                }
            }

            // --- BAR CHART ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true     // Changed to fillHeight to dynamically scale with the window
                Layout.minimumHeight: 250   // Ensure it never gets too squished
                color: "white"
                radius: 10
                border.color: "#e0e0e0"

                Text {
                    id: chartTitle
                    text: "Weekly Revenue"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#1d3d53"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 30
                    anchors.topMargin: 20
                }

                GraphsView {
                    id: barGraphsView
                    anchors.top: chartTitle.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.leftMargin: 0
                    anchors.rightMargin: 30

                    theme: GraphsTheme {
                        colorScheme: GraphsTheme.ColorScheme.Light
                        theme: GraphsTheme.Theme.MixSeries
                        backgroundColor: "transparent"
                        plotAreaBackgroundColor: "transparent"
                        seriesColors: ["#1d3d53"]
                    }

                    axisX: BarCategoryAxis {
                        categories: ["Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"]
                        gridVisible: false
                        subGridVisible: false
                    }

                    axisY: ValueAxis {
                        id: barAxisY
                        min: 0
                        max: 100
                        tickInterval: 20
                        subTickCount: 0
                        labelFormat: "$%.0f"
                    }

                    BarSeries {
                        barWidth: 0.5

                        BarSet {
                            id: weeklySalesSet
                            borderColor: "#1d3d53"
                            label: "Daily Revenue"
                            values: [0, 0, 0, 0, 0, 0, 0]
                        }
                    }

                    function refreshGraph() {
                        if (typeof dbManager === "undefined") return

                        let weeklyData = dbManager.getWeeklySales()

                        if (weeklyData && weeklyData.length === 7) {
                            weeklySalesSet.values = weeklyData
                            let maxVal = Math.max(...weeklyData)

                            if (maxVal > 0) {
                                barAxisY.max = Math.ceil(maxVal / 100) * 100
                                barAxisY.tickInterval = barAxisY.max / 5
                            } else {
                                barAxisY.max = 100
                                barAxisY.tickInterval = 20
                            }
                        }
                    }
                }
            }

            // --- BOTTOM PIE CHART ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true      // Changed to fillHeight to dynamically scale with the window
                Layout.minimumHeight: 250    // Ensure it never gets too squished
                color: "white"
                radius: 10
                border.color: "#e0e0e0"

                RowLayout {
                    anchors.fill: parent
                    spacing: 20

                    // --- CUSTOM LEGEND UI ---
                    Column {
                        Layout.leftMargin: 30
                        spacing: 10

                        Text {
                            text: "Top 5 Products"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#1d3d53"
                            bottomPadding: 10
                        }

                        Repeater {
                            model: ListModel { id: legendModel }

                            delegate: Row {
                                spacing: 12

                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 4
                                    color: model.colorCode
                                    border.color: "#4b270f"
                                    border.width: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: `${model.name} (${model.quantity})`
                                    font.pixelSize: 14
                                    color: "#333333"
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }

                    GraphsView {
                        id: graphsView
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        theme: GraphsTheme {
                            colorScheme: GraphsTheme.ColorScheme.Light
                            theme: GraphsTheme.Theme.MixSeries
                            backgroundColor: "transparent"
                            plotAreaBackgroundColor: "transparent"
                            seriesColors: ["#ffc0c5","#955e3e","#eee5de","#1d3d53","#4b270f"]
                            borderColors: ["#4b270f"]
                        }

                        PieSeries {
                            id: topProductsSeries
                            pieSize: 0.8
                        }

                        function refreshGraph() {
                            topProductsSeries.clear()
                            legendModel.clear()

                            let topItems = dbManager.getTopProducts()
                            let colors = ["#ffc0c5","#1d3d53","#eee5de","#955e3e","#4b270f"]

                            if (topItems.length === 0) {
                                topProductsSeries.append("No Sales Yet", 1)
                                return
                            }

                            for (let i = 0; i < topItems.length; i++) {
                                let product = topItems[i]

                                let slice = topProductsSeries.append(product.name, product.quantity)
                                slice.labelVisible = false

                                legendModel.append({
                                    "name": product.name,
                                    "quantity": product.quantity,
                                    "colorCode": colors[i % colors.length]
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
