#pragma once

#include <QString>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QUuid>
#include <QUrl>

class ImageStorage {
public:
    static QString imagesDir()
    {
        const QString base =
            QString(PROJECT_ROOT_DIR) + "/Resources/Images";

        QDir().mkpath(base);
        return base;
    }

    static QString importImage(const QUrl &sourceUrl)
    {
        if (!sourceUrl.isLocalFile())
            return {};

        const QString srcPath = sourceUrl.toLocalFile();
        const QString ext = QFileInfo(srcPath).suffix();

        const QString fileName =
            QUuid::createUuid().toString(QUuid::WithoutBraces)
            + "." + ext;

        const QString dstPath = imagesDir() + "/" + fileName;

        if (!QFile::copy(srcPath, dstPath))
            return {};

        return fileName; // store ONLY this in DB
    }

    static QString imageUrl(const QString &fileName)
    {
        if (fileName.isEmpty())
            return {};

        const QString fullPath = imagesDir() + "/" + fileName;
        return QUrl::fromLocalFile(fullPath).toString();
    }
};
