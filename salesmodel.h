#ifndef SALESMODEL_H
#define SALESMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QQmlEngine>
#include <QVariantMap> // Needed for the nested data
#include "types.h"
#include "DatabaseManager.h"

class SalesModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
public:

    enum Roles {
        IdRole = Qt::UserRole + 1,
        InvoiceNumberRole,
        DateRole,
        SubtotalRole,
        TaxRole,
        TotalRole,
        ItemsRole // <--- NEW ROLE
    };

    explicit SalesModel(QObject *parent = nullptr)
        : QAbstractListModel{parent}
    {
        DatabaseManager::init();
        m_sales = DatabaseManager::getAllInvoices();
    }

    int rowCount(const QModelIndex &parent) const override {
        if (parent.isValid()) return 0;
        return static_cast<int>(m_sales.size());
    }

    QVariant data(const QModelIndex &index, int role) const override {
        if (!index.isValid() || index.row() >= m_sales.size()) return QVariant();

        const Invoice &invoice = m_sales[index.row()];
        switch (role) {
        case IdRole: return invoice.id;
        case InvoiceNumberRole: return invoice.invoiceNumber;
        case DateRole: return invoice.date;
        case SubtotalRole: return invoice.subtotal;
        case TaxRole: return invoice.tax;
        case TotalRole: return invoice.total;

        case ItemsRole: {
            // Convert std::vector<InvoiceItem> to QVariantList (Array of objects)
            QVariantList itemsList;
            for (const auto &item : invoice.items) {
                QVariantMap map;
                map["name"] = item.name;
                map["quantity"] = item.quantity;
                map["unitPrice"] = item.unitPrice;
                map["lineTotal"] = item.lineTotal;
                itemsList.append(map);
            }
            return itemsList;
        }
        }
        return QVariant();
    }

    QHash<int, QByteArray> roleNames() const override {
        return {
            {IdRole, "id"},
            {InvoiceNumberRole, "invoiceNumber"},
            {DateRole, "date"},
            {SubtotalRole, "subtotal"},
            {TaxRole, "tax"},
            {TotalRole, "total"},
            {ItemsRole, "items"} // Expose to QML as 'items'
        };
    }

    // Optional: Function to refresh data from QML
    Q_INVOKABLE void refresh() {
        beginResetModel();
        m_sales = DatabaseManager::getAllInvoices();
        endResetModel();
    }

private:
    std::vector<Invoice> m_sales;
};

#endif // SALESMODEL_H
