#ifndef CARTMODEL_H
#define CARTMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QAbstractListModel>
#include "types.h"

class CartModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(double subTotal READ subTotal NOTIFY totalsChanged)
    Q_PROPERTY(double discountAmount READ discountAmount WRITE setDiscountAmount NOTIFY totalsChanged)
    Q_PROPERTY(double taxAmount READ taxAmount NOTIFY totalsChanged)
    Q_PROPERTY(double grandTotal READ grandTotal NOTIFY totalsChanged)
public:

    enum Roles{
        NameRole = Qt::UserRole + 1,
        PriceRole,
        ImagePathRole,
        CategoryRole,
        QuantityRole,
        TotalRole
    };

    explicit CartModel(QObject *parent = nullptr)
        : QAbstractListModel{parent}, m_discountAmount(0.0)
    {}

    // --- READ-ONLY GETTER for BillGenerator ---
    const std::vector<Cart>& items() const { return m_cart; }

    double subTotal() const {
        double sum = 0.0;
        for(const auto &item : m_cart){
            sum += item.total;
        }
        return sum;
    }

    double discountAmount() const {
        return m_discountAmount;
    }

    double taxAmount() const {
        // Example: 9% tax on (Subtotal - Discount)
        double taxableAmount = subTotal() - m_discountAmount;
        if(taxableAmount < 0) taxableAmount = 0;
        return taxableAmount * 0.09;
    }

    double grandTotal() const {
        return subTotal() - m_discountAmount + taxAmount();
    }

    // --- SETTER FOR DISCOUNT ---
    void setDiscountAmount(double amount) {
        if (m_discountAmount == amount) return;
        m_discountAmount = amount;
        emit totalsChanged(); // Recalculate everything
    }

    // Model
    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void addToCart(const QString &name, const double &price, const QString &imagePath){
        for(int i=0; i<m_cart.size();i++){
            if(m_cart[i].product.name == name){
                m_cart[i].quantity++;
                m_cart[i].total = m_cart[i].quantity * price;

                QModelIndex idx = createIndex(i, 0);
                emit dataChanged(idx, idx, {QuantityRole, TotalRole});
                emit totalsChanged();
                return;
            }
        }
        beginInsertRows(QModelIndex(), m_cart.size(), m_cart.size());

        m_cart.push_back({
            .product = {
                .id = static_cast<int>(m_cart.size()),
                .name = name,
                .price = price,
                .imagePath = imagePath
            },
            .quantity = 1,
            .total = price
        });

        endInsertRows();
        emit totalsChanged();
    }

    Q_INVOKABLE void subtract(int index){
        if(index < 0 || index >= m_cart.size()) return;

        if(m_cart[index].quantity > 1){
            m_cart[index].quantity--;
            m_cart[index].total = m_cart[index].quantity * m_cart[index].product.price;

            QModelIndex idx = createIndex(index, 0);
            emit dataChanged(idx, idx, {QuantityRole, TotalRole});
            emit totalsChanged();
            return;
        }
    }

    Q_INVOKABLE void increase(int index){
        if(index < 0 || index >= m_cart.size()) return;

        m_cart[index].quantity++;
        m_cart[index].total = m_cart[index].quantity * m_cart[index].product.price;

        QModelIndex idx = createIndex(index, 0);
        emit dataChanged(idx, idx, {QuantityRole, TotalRole});
        emit totalsChanged();
        return;
    }

    Q_INVOKABLE void removeFromCart(int index){
        if(index < 0 || index >= m_cart.size()) return;

        beginRemoveRows(QModelIndex(), index, index);
        m_cart.erase(m_cart.begin() + index);
        endRemoveRows();
        emit totalsChanged();
    }

    Q_INVOKABLE void resetOrder(){
        if (m_cart.empty()) {
            return;
        }
        beginRemoveRows(QModelIndex(), 0, m_cart.size() - 1);
        m_cart.clear();
        endRemoveRows();
        setDiscountAmount(0.0);
        emit totalsChanged();
    }

signals:
    void totalsChanged();

private:
    std::vector<Cart> m_cart;
    double m_discountAmount;
};

#endif // CARTMODEL_H
