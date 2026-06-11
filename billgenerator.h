#ifndef BILLGENERATOR_H
#define BILLGENERATOR_H

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QObject>
#include <QPainter>
#include <QPdfWriter>
#include <QQmlEngine>
#include <QStandardPaths>
#include <QTextDocument>
#include <QRandomGenerator>
#include <vector>
#include "cartmodel.h"
#include "databasemanager.h"

class BillGenerator : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit BillGenerator(QObject *parent = nullptr) : QObject(parent) {}

    Q_INVOKABLE QString generatePdf(const CartModel *cart)
    {
        // --- Project root path ---
        QString projectRoot = QCoreApplication::applicationDirPath();

        // Create "invoices" folder if it doesn't exist
        QDir dir(projectRoot);
        if (!dir.exists("invoices"))
            dir.mkdir("invoices");

        QString shortDate = QDate::currentDate().toString("yyMM");
        int randomSuffix = QRandomGenerator::global()->bounded(1000, 9999);
        QString invoiceNumber = QString("%1-%2").arg(shortDate).arg(randomSuffix);

        QString invoiceDate = QDate::currentDate().toString(Qt::ISODate);

        QString filePath = dir.filePath("invoices/Invoice_" +
                                        QDateTime::currentDateTime().toString("yyyyMMdd_HHmmss") +
                                        ".pdf");

        // --- Load external HTML template ---
        QFile file("C:/Users/user/Desktop/qt-guide/guide/templates/invoice_template.html");
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "Cannot open template file!";
            return {};
        }
        QString htmlTemplate = file.readAll();
        file.close();

        const QLocale locale(QLocale::English, QLocale::UnitedStates);

        QString itemRows;
        std::vector<InvoiceItem> dbItems; // Store items for the database

        for (const auto &it : cart->items()) {
            // Populate Database Struct
            InvoiceItem dbItem;
            dbItem.name = it.product.name;
            dbItem.quantity = it.quantity;
            dbItem.unitPrice = it.product.price;
            dbItem.lineTotal = it.total;
            dbItems.push_back(dbItem);

            // Populate PDF Template Row
            itemRows += QString("<tr>"
                                "<td style='border-bottom:1px solid #ccc;'>%1</td>"
                                "<td style='text-align:center; border-bottom:1px solid #ccc;'>%2</td>"
                                "<td style='text-align:center; border-bottom:1px solid #ccc;'>%3</td>"
                                "<td style='text-align:center; border-bottom:1px solid #ccc;'>%4</td>"
                                "</tr>"
                                ).arg(it.product.name.toHtmlEscaped())
                            .arg(it.quantity)
                            .arg(locale.toCurrencyString(it.product.price))
                            .arg(locale.toCurrencyString(it.total));
        }

        if (itemRows.isEmpty()) {
            itemRows = "<tr><td colspan='4' style='text-align:center;'>No items in cart</td></tr>";
        }

        // --- Save to Database ---
        Invoice dbInvoice;
        dbInvoice.invoiceNumber = invoiceNumber;
        dbInvoice.date = invoiceDate;
        dbInvoice.subtotal = cart->subTotal();
        dbInvoice.tax = cart->taxAmount();
        dbInvoice.total = cart->grandTotal();

        // Calls static database method
        DatabaseManager::saveInvoice(dbInvoice, dbItems);

        // --- Prepare HTML template ---
        htmlTemplate.replace("{{DATE}}", invoiceDate);
        htmlTemplate.replace("{{INVOICE_NUMBER}}", invoiceNumber);
        htmlTemplate.replace("{{ITEM_ROWS}}", itemRows);
        htmlTemplate.replace("{{SUBTOTAL}}", locale.toCurrencyString(dbInvoice.subtotal));
        htmlTemplate.replace("{{TAX}}", locale.toCurrencyString(dbInvoice.tax));
        htmlTemplate.replace("{{GRAND_TOTAL}}", locale.toCurrencyString(dbInvoice.total));

        // --- Generate PDF ---
        QPdfWriter writer(filePath);
        writer.setPageSize(QPageSize(QPageSize::A5));
        writer.setPageOrientation(QPageLayout::Portrait);
        writer.setPageMargins(QMarginsF(15, 15, 15, 15));

        QTextDocument doc;
        doc.setDefaultFont(QFont("Helvetica", 10));
        doc.setHtml(htmlTemplate);
        doc.setPageSize(writer.pageLayout().paintRectPoints().size());
        doc.print(&writer);

        qDebug() << "PDF generated at:" << filePath;
        return QUrl::fromLocalFile(filePath).toString();
    }
};

#endif // BILLGENERATOR_H
