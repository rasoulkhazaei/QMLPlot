#include <QApplication>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include <QQmlContext>
#include "datasource.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine mQmlEngine;

    bool openGLSupported = QQuickWindow::graphicsApi() == QSGRendererInterface::OpenGLRhi;
    mQmlEngine.rootContext()->setContextProperty("openGLSupported", openGLSupported);
    QObject::connect(
        &mQmlEngine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    DataSource d;
    mQmlEngine.rootContext()->setContextProperty("dataSource", &d);
    mQmlEngine.load(QUrl("qrc:/Main.qml"));

    return app.exec();
}
