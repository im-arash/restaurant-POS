#include "cartmodel.h"





int CartModel::rowCount(const QModelIndex &parent) const{
    if(parent.isValid()) return 0;
    return static_cast<int>(m_cart.size());
}

QVariant CartModel::data(const QModelIndex &index, int role) const{
    if(!index.isValid() || index.row() >= m_cart.size()) return QVariant();
    const Cart &cart = m_cart[index.row()];
    switch (role) {
    case NameRole: return cart.product.name;
    case PriceRole: return cart.product.price;
    case ImagePathRole: return cart.product.imagePath;
    case CategoryRole: return cart.product.category;
    case QuantityRole: return cart.quantity;
    case TotalRole: return cart.total;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> CartModel::roleNames() const{
    return {
        {NameRole, "name"},
        {PriceRole, "price"},
        {ImagePathRole, "imagePath"},
        {CategoryRole, "category"},
        {QuantityRole, "quantity"},
        {TotalRole, "total"}
    };
}
