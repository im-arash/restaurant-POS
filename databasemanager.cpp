#include <databasemanager.h>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {
    init();
}

void DatabaseManager::init() {
    QSqlDatabase db;

    // Check connection to prevent duplicates
    if (QSqlDatabase::contains(QSqlDatabase::defaultConnection)) {
        db = QSqlDatabase::database(QSqlDatabase::defaultConnection);
    } else {
        db = QSqlDatabase::addDatabase("QSQLITE");
    }

    QString dbPath = QFileInfo(__FILE__).absolutePath() + "/products.db";
    db.setDatabaseName(dbPath);

    if (!db.isOpen() && !db.open()) {
        qCritical() << "Database Error:" << db.lastError().text();
        return;
    }

    db.exec("PRAGMA foreign_keys = ON;");

    QSqlQuery query(db);

    // Create Tables
    if (!query.exec("CREATE TABLE IF NOT EXISTS products ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "name TEXT, "
                    "price REAL, "
                    "image_path TEXT, "
                    "category TEXT)")) {
        qWarning() << "Create Products Table Error:" << query.lastError().text();
    }

    if (!query.exec("CREATE TABLE IF NOT EXISTS invoices ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "invoice_number TEXT, "
                    "date TEXT, "
                    "subtotal REAL, "
                    "tax REAL, "
                    "total REAL)")) {
        qWarning() << "Create Invoices Table Error:" << query.lastError().text();
    }

    if (!query.exec("CREATE TABLE IF NOT EXISTS invoice_items ("
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
                    "invoice_id INTEGER, "
                    "name TEXT, "
                    "quantity INTEGER, "
                    "unit_price REAL, "
                    "line_total REAL, "
                    "FOREIGN KEY(invoice_id) REFERENCES invoices(id) ON DELETE CASCADE)")) {
        qWarning() << "Create Invoice Items Table Error:" << query.lastError().text();
    }
}

std::vector<Product> DatabaseManager::getAllProducts() {
    std::vector<Product> list;
    QSqlQuery query("SELECT * FROM products");

    while (query.next()) {
        Product p;
        p.id = query.value("id").toInt();
        p.name = query.value("name").toString();
        p.price = query.value("price").toDouble();
        p.imagePath = query.value("image_path").toString();
        p.category = query.value("category").toString();
        list.push_back(p);
    }
    return list;
}

int DatabaseManager::addProduct(const Product &p) {
    QSqlQuery query;
    query.prepare("INSERT INTO products (name, price, image_path, category) "
                  "VALUES (?, ?, ?, ?)");
    query.addBindValue(p.name);
    query.addBindValue(p.price);
    query.addBindValue(p.imagePath);
    query.addBindValue(p.category);

    if (query.exec()) {
        return query.lastInsertId().toInt();
    }
    qWarning() << "Insert Product Error:" << query.lastError().text();
    return -1;
}

bool DatabaseManager::updateProduct(const Product &p) {
    QSqlQuery query;
    query.prepare("UPDATE products SET name=?, price=?, image_path=?, category=? WHERE id=?");
    query.addBindValue(p.name);
    query.addBindValue(p.price);
    query.addBindValue(p.imagePath);
    query.addBindValue(p.category);
    query.addBindValue(p.id);

    return query.exec();
}

bool DatabaseManager::removeProduct(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM products WHERE id = ?");
    query.addBindValue(id);

    if (!query.exec()) {
        qWarning() << "Delete Product Error:" << query.lastError().text();
        return false;
    }
    return true;
}

int DatabaseManager::saveInvoice(const Invoice &inv, const std::vector<InvoiceItem> &items) {
    QSqlDatabase db = QSqlDatabase::database();

    if (!db.transaction()) {
        qWarning() << "Failed to start database transaction!";
        return -1;
    }

    QSqlQuery query(db);

    // 1. Insert Invoice Header
    if (!query.prepare("INSERT INTO invoices (invoice_number, date, subtotal, tax, total) "
                       "VALUES (?, ?, ?, ?, ?)")) {
        qWarning() << "Prepare Invoice Error:" << query.lastError().text();
        db.rollback();
        return -1;
    }

    query.addBindValue(inv.invoiceNumber);
    query.addBindValue(inv.date);
    query.addBindValue(inv.subtotal);
    query.addBindValue(inv.tax);
    query.addBindValue(inv.total);

    if (!query.exec()) {
        qWarning() << "Insert Invoice Error:" << query.lastError().text();
        db.rollback();
        return -1;
    }

    int invoiceId = query.lastInsertId().toInt();

    // 2. Insert Invoice Items
    if (!query.prepare("INSERT INTO invoice_items (invoice_id, name, quantity, unit_price, line_total) "
                       "VALUES (?, ?, ?, ?, ?)")) {
        qWarning() << "Prepare Invoice Items Error:" << query.lastError().text();
        db.rollback();
        return -1;
    }

    for (const auto &item : items) {
        query.addBindValue(invoiceId);
        query.addBindValue(item.name);
        query.addBindValue(item.quantity);
        query.addBindValue(item.unitPrice);
        query.addBindValue(item.lineTotal);

        if (!query.exec()) {
            qWarning() << "Insert Invoice Item Error:" << query.lastError().text();
            db.rollback();
            return -1;
        }
    }

    db.commit();
    qDebug() << "Successfully saved invoice to database with ID:" << invoiceId;
    return invoiceId;
}

std::vector<InvoiceItem> DatabaseManager::getInvoiceItems(int invoiceId) {
    std::vector<InvoiceItem> items;
    QSqlQuery query;
    query.prepare("SELECT name, quantity, unit_price, line_total FROM invoice_items WHERE invoice_id = ?");
    query.addBindValue(invoiceId);

    if (query.exec()) {
        while (query.next()) {
            InvoiceItem item;
            item.name = query.value("name").toString();
            item.quantity = query.value("quantity").toInt();
            item.unitPrice = query.value("unit_price").toDouble();
            item.lineTotal = query.value("line_total").toDouble();
            items.push_back(item);
        }
    }
    return items;
}

std::vector<Invoice> DatabaseManager::getAllInvoices() {
    std::vector<Invoice> list;
    QSqlQuery query("SELECT * FROM invoices ORDER BY id DESC"); // Newest first

    while (query.next()) {
        Invoice invoice;
        invoice.id = query.value("id").toInt();
        invoice.invoiceNumber = query.value("invoice_number").toString();
        invoice.date = query.value("date").toString();
        invoice.subtotal = query.value("subtotal").toDouble();
        invoice.tax = query.value("tax").toDouble();
        invoice.total = query.value("total").toDouble();

        // Populate the items vector inside the invoice
        invoice.items = getInvoiceItems(invoice.id);

        list.push_back(invoice);
    }
    return list;
}

QVariantList DatabaseManager::getTopProducts() {
    QVariantList topList;
    QSqlQuery query;

    // Group by product name, sum the total quantity sold, sort highest to lowest, take top 5
    query.prepare("SELECT name, SUM(quantity) as total_qty "
                  "FROM invoice_items "
                  "GROUP BY name "
                  "ORDER BY total_qty DESC "
                  "LIMIT 5");

    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["name"] = query.value("name").toString();
            map["quantity"] = query.value("total_qty").toInt();
            topList.append(map);
        }
    } else {
        qWarning() << "Error fetching top products:" << query.lastError().text();
    }

    return topList;
}

double DatabaseManager::getTotalSales() {
    QSqlQuery query("SELECT SUM(total) FROM invoices");

    if (query.next()) {
        return query.value(0).toDouble();
    }

    qWarning() << "Failed to calculate total sales:" << query.lastError().text();
    return 0.0;
}
