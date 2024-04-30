cmake_minimum_required(VERSION 3.16)

project(PlotQML VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
find_package(Qt6 REQUIRED COMPONENTS Charts Core Gui Qml Quick)

set(CMAKE_CXX_EXTENSIONS ON)
qt_standard_project_setup(REQUIRES 6.5)

add_executable(PlotQML
    main.cpp
    datasource.h datasource.cpp
)
set_target_properties(PlotQML PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)

target_link_libraries(PlotQML PUBLIC
    Qt::Charts
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
)

# Resources:
set(resources_resource_files
    "Figure.qml"
    "Main.qml"
    "drag.png"
    "zoom.png"
    "home.png"
)

qt6_add_resources(PlotQML "resources"
    PREFIX
        "/"
    FILES
        ${resources_resource_files}
)

install(TARGETS PlotQML
    RUNTIME DESTINATION "${INSTALL_EXAMPLEDIR}"
    BUNDLE DESTINATION "${INSTALL_EXAMPLEDIR}"
    LIBRARY DESTINATION "${INSTALL_EXAMPLEDIR}"
)
