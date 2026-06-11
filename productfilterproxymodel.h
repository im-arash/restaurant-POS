#ifndef PRODUCTFILTERPROXYMODEL_H
#define PRODUCTFILTERPROXYMODEL_H

#include <QObject>
#include <QQmlEngine>
#include <QSortFilterProxyModel>
#include "productmodel.h"

class ProductFilterProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString filterCategory READ filterCategory WRITE setFilterCategory NOTIFY filterCategoryChanged)
    Q_PROPERTY(QString searchText READ searchText WRITE setSearchText NOTIFY searchTextChanged)
public:
    explicit ProductFilterProxyModel(QObject *parent = nullptr)
        : QSortFilterProxyModel{parent}
    {}

    QString searchText() const { return m_searchText; }
    void setSearchText(const QString &text)
    {
        if (m_searchText == text)
            return;

        beginFilterChange();
        m_searchText = text;
        endFilterChange();
        emit searchTextChanged();
    }

    QString filterCategory() const
    {
        return m_filterCategory;
    }

    void setFilterCategory(const QString &newCategory)
    {
        if (m_filterCategory == newCategory)
            return;


        beginFilterChange();
        m_filterCategory = newCategory;
        endFilterChange();
        emit filterCategoryChanged();
    }

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override
    {
        QModelIndex idx = sourceModel()->index(source_row, 0, source_parent);
        if (!idx.isValid())
            return false;

        // Category filter
        if (!m_filterCategory.isEmpty()) {
            const QString category =
                sourceModel()->data(idx, ProductModel::CategoryRole).toString();

            if (category != m_filterCategory)
                return false;
        }

        // Search filter
        if (!m_searchText.isEmpty()) {
            const QString name = sourceModel()->data(idx, ProductModel::NameRole).toString();

            if (!name.contains(m_searchText, Qt::CaseInsensitive))
                return false;
        }

        return true;
    }

signals:
    void filterCategoryChanged();
    void searchTextChanged();

private:
    QString m_filterCategory;
    QString m_searchText;
};

#endif // PRODUCTFILTERPROXYMODEL_H
