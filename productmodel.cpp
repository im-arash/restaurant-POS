#include "productmodel.h"



int ProductModel::rowCount(const QModelIndex &parent) const{
    if(parent.isValid()) return 0;
    return static_cast<int>(m_products.size());
}

QVariant ProductModel::data(const QModelIndex &index, int role) const{
    if (!index.isValid() || index.row() >= m_products.size()) return QVariant();

    const Product &product = m_products[index.row()];
    switch (role) {
    case IdRole:        return product.id;
    case NameRole:      return product.name;
    case PriceRole:     return product.price;
    case ImagePathRole: return ImageStorage::imageUrl(product.imagePath);
    case CategoryRole:  return product.category;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> ProductModel::roleNames() const{
    return{
        {IdRole, "id"},
        {NameRole, "name"},
        {PriceRole, "price"},
        {ImagePathRole, "imagePath"},
        {CategoryRole, "category"}
    };
}
