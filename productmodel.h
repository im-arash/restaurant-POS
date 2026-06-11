#ifndef PRODUCTMODEL_H
#define PRODUCTMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>
#include "types.h"
#include "databasemanager.h"
#include "imagestorage.h"

class ProductModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QStringList categoryView READ categoryView CONSTANT)
public:

    enum Roles{
        IdRole = Qt::UserRole + 1,
        NameRole,
        PriceRole,
        ImagePathRole,
        CategoryRole
    };
    Q_ENUM(Roles);

    explicit ProductModel(QObject *parent = nullptr)
        : QAbstractListModel{parent}
    {
        // 1. Init Database
        DatabaseManager::init();

        // 2. Load Data from SQL
        m_products = DatabaseManager::getAllProducts();

        // 3. (Optional) If DB is empty, add dummy data for testing
        // if (m_products.empty()) {
        //     addProduct("Capochino", 3.50, "Coffee", "file:///C:/Users/user/Desktop/coffee/capochino.webp");
        //     addProduct("Latte", 4.00, "Coffee", "file:///C:/Users/user/Desktop/coffee/latte.webp");
        // }
    }

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;


    QStringList categoryView() const{
        QStringList list;
        for (const Category &c : m_categories)
            list.append(c.title);

        return list;
    }

    Q_INVOKABLE void addProduct(const QString &name, double price, const QString &category, const QUrl &imageUrl){
        for (const auto &p : m_products) {
            if (p.name == name || name == "")
                return;
        }

        Product newProduct;
        newProduct.name = name;
        newProduct.price = price;
        newProduct.category = category;

        // ✅ import image here
        newProduct.imagePath = ImageStorage::importImage(imageUrl);

        const int newId = DatabaseManager::addProduct(newProduct);
        if (newId == -1)
            return;

        newProduct.id = newId;

        beginInsertRows(QModelIndex(), m_products.size(), m_products.size());
        m_products.push_back(newProduct);
        endInsertRows();
    }

    Q_INVOKABLE void updateProduct(int row, const QVariant &value, int role)
    {
        if (row < 0 || row >= static_cast<int>(m_products.size()))
            return;

        // Validate uniqueness BEFORE modifying
        if (role == NameRole) {
            const QString newName = value.toString();
            for (int i = 0; i < m_products.size(); ++i) {
                if (i == row) continue;
                if (m_products[i].name == newName)
                    return;
            }
        }

        Product &p = m_products[row];

        switch (role) {
        case NameRole:      p.name = value.toString(); break;
        case PriceRole:     p.price = value.toDouble(); break;
        case ImagePathRole: p.imagePath = ImageStorage::importImage(value.toUrl());
        case CategoryRole:  p.category = value.toString(); break;
        default: return;
        }

        DatabaseManager::updateProduct(p);

        const QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx, { role });

    }


    Q_INVOKABLE void removeProduct(int row)
    {
        if (row < 0 || row >= static_cast<int>(m_products.size())) {
            qWarning() << "Attempted to remove product at invalid row:" << row;
            return;
        }

        int idToRemove = m_products.at(row).id;

        if (DatabaseManager::removeProduct(idToRemove)) {
            beginRemoveRows(QModelIndex(), row, row);
            m_products.erase(m_products.begin() + row);
            endRemoveRows();
        } else {
            qWarning() << "Failed to remove product with id" << idToRemove << "from the database.";
        }
    }

signals:

private:
    std::vector<Product> m_products;
    QVector<Category> m_categories = {
        {"Coffee"},
        {"Pastry"},
        {"Merch"}
    };
};

#endif // PRODUCTMODEL_H
