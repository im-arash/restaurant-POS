#ifndef DATABASEMANAGER_H
#define DATABASEMANAGER_H

#include <QString>
#include <qqmlintegration.h>
#include <vector>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include "types.h"

class DatabaseManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit DatabaseManager(QObject *parent = nullptr);

    static void init();


    // ==========================================
    // --- PRODUCT METHODS (RESTORED HERE) ---
    // ==========================================

    static std::vector<Product> getAllProducts();

    static int addProduct(const Product &p);

    static bool updateProduct(const Product &p);

    static bool removeProduct(int id);


    // ==========================================
    // --- INVOICE METHODS ---
    // ==========================================

    static int saveInvoice(const Invoice &inv, const std::vector<InvoiceItem> &items);

    static std::vector<InvoiceItem> getInvoiceItems(int invoiceId);

    static std::vector<Invoice> getAllInvoices();

    Q_INVOKABLE QVariantList getTopProducts();

    Q_INVOKABLE double getTotalSales();

    Q_INVOKABLE QVariantList getWeeklySales() {
        QVariantList weeklyData;

        // C++20 vector to hold 7 days of totals (Index 0 = Sat, ..., Index 6 = Fri)
        std::vector<double> dailyTotals(7, 0.0);

        // 1. Calculate the start of the current week (Most recent Saturday)
        QDate today = QDate::currentDate();
        int dayOfWeek = today.dayOfWeek(); // Qt: 1 = Mon, ..., 6 = Sat, 7 = Sun

        // Math to find out how many days ago Saturday was:
        // Sat(6)->0, Sun(7)->1, Mon(1)->2, Tue(2)->3, Wed(3)->4, Thu(4)->5, Fri(5)->6
        int daysSinceSaturday = (dayOfWeek + 1) % 7;
        QDate startOfWeek = today.addDays(-daysSinceSaturday);

        // 2. Query the database for invoices from Saturday onwards
        QSqlQuery query;
        // Assuming your date column stores data in ISO format (yyyy-MM-dd...)
        query.prepare("SELECT date, total FROM invoices WHERE date >= :startOfWeek");
        query.bindValue(":startOfWeek", startOfWeek.toString("yyyy-MM-dd"));

        if (query.exec()) {
            while (query.next()) {
                QString dateString = query.value(0).toString();
                double invoiceTotal = query.value(1).toDouble();

                // Parse the date (handles both "yyyy-MM-dd" and "yyyy-MM-ddTHH:mm:ss")
                QDateTime dt = QDateTime::fromString(dateString, Qt::ISODate);

                // Fallback in case stored as just Date
                if (!dt.isValid()) {
                    dt.setDate(QDate::fromString(dateString, Qt::ISODate));
                }

                if (dt.isValid()) {
                    QDate invoiceDate = dt.date();

                    // Find out which array index (0-6) this invoice belongs to
                    int dayIndex = startOfWeek.daysTo(invoiceDate);

                    // Safety check to ensure it falls within the 7-day window
                    if (dayIndex >= 0 && dayIndex < 7) {
                        dailyTotals[dayIndex] += invoiceTotal;
                    }
                }
            }
        } else {
            qWarning() << "Failed to fetch weekly sales data:" << query.lastError().text();
        }

        // 3. Convert std::vector to QVariantList for QML
        for (const double& total : dailyTotals) {
            weeklyData.append(total);
        }

        return weeklyData;
    }

};

#endif // DATABASEMANAGER_H
