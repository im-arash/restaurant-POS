#ifndef TYPES_H
#define TYPES_H

#include <QString>

struct Category{
    QString title;
};

struct Product{
    int id;
    QString name;
    double price;
    QString imagePath;
    QString category;
};

struct Cart {
    Product product;
    int quantity;
    double total;

    void update() { total = quantity * product.price; }
};

struct InvoiceItem {
    QString name;
    int quantity;
    double unitPrice;
    double lineTotal;
};

struct Invoice {
    int id;
    QString invoiceNumber;
    QString date;
    double subtotal;
    double tax;
    double total;

    std::vector<InvoiceItem> items;
};



#endif // TYPES_H
