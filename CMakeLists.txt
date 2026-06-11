cmake_minimum_required(VERSION 3.16)

project(guide VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Core)
find_package(Qt6 REQUIRED COMPONENTS Sql)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appguide
    main.cpp
)

qt_add_qml_module(appguide
    URI guide
    QML_FILES
        Main.qml
        components/CartPanel.qml
        components/HeaderBar.qml
        components/MenuPanel.qml
        components/EditProductWindow.qml
    SOURCES
        types.h
        productmodel.h productmodel.cpp
        cartmodel.h cartmodel.cpp
        SOURCES productfilterproxymodel.h productfilterproxymodel.cpp
        SOURCES databasemanager.h databasemanager.cpp
        SOURCES billgenerator.h billgenerator.cpp

        RESOURCES
            templates/invoice_template.html
            Resources/user-template-profile-picture.png
            Resources/home.svg
            Resources/bookmark.svg
            Resources/profile.svg
            Resources/delete.svg
            Resources/dine.svg
            Resources/order.svg
            Resources/delete_white.svg
            Resources/add.svg
            Resources/add_box.svg
            Resources/add_box_color.svg
            Resources/calendar.svg
            Resources/home.svg
            Resources/home_app_logo.svg
            Resources/home_app_logo_white.svg
            Resources/storefront.svg
            SOURCES imagestorage.h
            QML_FILES components/MainPage.qml
            QML_FILES components/PosPage.qml
            SOURCES salesmodel.h salesmodel.cpp
)

target_compile_definitions(appguide
    PRIVATE PROJECT_ROOT_DIR="${CMAKE_SOURCE_DIR}"
)

set_target_properties(appguide PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appguide
    PRIVATE Qt6::Quick Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appguide
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
