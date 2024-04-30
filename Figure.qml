import QtQuick
import QtCharts
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root

    property real minX: 0
    property real maxX: 1024
    property real minY: -5
    property real maxY: 5
    property real mouseX: 0
    property real mouseY: 0
    enum MouseType {
        Draging,
        Zooming,
        Nothing
    }

    Keys.onPressed: (event)=> {
                        if (event.key === Qt.Key_Left)
                        chartView.scrollLeft(10)
                        if (event.key === Qt.Key_Right)
                        chartView.scrollRight(10)
                        if (event.key === Qt.Key_Up)
                        chartView.scrollUp(10)
                        if (event.key === Qt.Key_Down)
                        chartView.scrollDown(10)
                    }
    RowLayout {
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        Layout.topMargin: 10
        spacing: 1
        Button {
            id: homeBtn
            display: AbstractButton.IconOnly
            hoverEnabled: true
            icon {
                source: "home.png"
                width: 28
                height: 28
            }
            ToolTip.text: "Reset original view"
            ToolTip.visible: hovered
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            background: Rectangle {
                color: homeBtn.hovered ? "white" : "lightgray"
                border.color: "gray"
                border.width: homeBtn.hovered ? 1 : 0
                radius: homeBtn.hovered ? 3 : 0
            }
            width: 32
            height: 32
            onClicked: {
                chartView.zoomReset()
                axisX.min = root.minX
                axisX.max = root.maxX
                axisY.min = root.minY
                axisY.max = root.maxY

            }
        }

        Button {
            id: dragBtn
            display: AbstractButton.IconOnly
            hoverEnabled: true
            icon {
                source: "drag.png"
                width: 28
                height: 28
            }
            background: Rectangle {
                color: dragBtn.hovered ? "white" : dragBtn.checked ? "darkgray" : "lightgray"
                border.color: "gray"
                border.width: dragBtn.hovered || dragBtn.checked ? 1 : 0
                radius: dragBtn.hovered || dragBtn.checked ? 3 : 0
            }
            ToolTip.text: "Left button pans, Right button zooms x/y fixes axis"
            ToolTip.visible: hovered
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval

            checkable: true
            checked: false
            onClicked: {
                if (!checked)
                    chartView.mouseBeh = Figure.MouseType.Nothing
                else {
                    chartView.mouseBeh = Figure.MouseType.Draging
                    if (zoomBtn.checked)
                        zoomBtn.checked = false
                }
            }

            width: 32
            height: 32
        }

        Button {
            id: zoomBtn
            display: AbstractButton.IconOnly
            hoverEnabled: true
            icon {
                source: "zoom.png"
                width: 28
                height: 28
            }
            background: Rectangle {
                color: zoomBtn.hovered ? "white" : zoomBtn.checked ? "darkgray" : "lightgray"
                border.color: "gray"
                border.width: zoomBtn.hovered || zoomBtn.checked? 1 : 0
                radius: zoomBtn.hovered || zoomBtn.checked ? 3 : 0
            }
            ToolTip.text: "Zoom to rectangle"
            ToolTip.visible: hovered
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            checkable: true
            checked: false
            onClicked: {
                if (!checked)
                    chartView.mouseBeh = Figure.MouseType.Nothing
                else {
                    chartView.mouseBeh = Figure.MouseType.Zooming
                    if (dragBtn.checked)
                        dragBtn.checked = false
                }

            }

            width: 32
            height: 32
        }
        Item {
            Layout.fillWidth: true
        }

        Label {
            text: "x: "
            color: "black"
            visible: dragArea.containsMouse
        }

        Label {
            id: xValue
            text: mouseX
            color: "black"
            visible: dragArea.containsMouse
        }


        Label {
            Layout.leftMargin: 10
            text: "y: "
            color: "black"
            visible: dragArea.containsMouse
        }

        Label {
            id: yValue
            text: mouseY
            color: "black"
            visible: dragArea.containsMouse
        }
    }

    ChartView {
        id: chartView
        Layout.fillHeight: true
        Layout.fillWidth: true
        margins.bottom: 0
        margins.top: 0
        margins.left: 0
        margins.right: 0



        property int mouseBeh: Figure.MouseType.Nothing
        property int zoomRatio: 30

        property bool openGL: openGLSupported
        property list<int> pointsX: []
        property list<int> pointsY: []

        signal graphxyChanged(point: var, state: bool)
        animationOptions: ChartView.SeriesAnimations
        theme: ChartView.ChartThemeBlueCerulean


        plotArea: Qt.rect(0, 0, 0, 0)

        onOpenGLChanged: {
            if (openGLSupported) {
                var series1 = series("signal 1")
                if (series1)
                    series1.useOpenGL = openGL;
                var series2 = series("signal 2")
                if (series2)
                    series2.useOpenGL = openGL;
            }
        }
        legend.visible: false

        Rectangle {
            id: rubber
            color: "steelblue"
            opacity: 0.7
            border.color: "blue"
            border.width: 2

        }
        focus: true


        MouseArea {

            id: dragArea
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.fill: parent
            property real oldX: 0
            property real oldY: 0

            cursorShape: chartView.mouseBeh === Figure.MouseType.Nothing ? Qt.ArrowCursor :
                                                                           chartView.mouseBeh === Figure.MouseType.Draging ?
                                                                               Qt.ClosedHandCursor : Qt.CrossCursor
            // onWheel: (w)=>{
            //              if (w.angleDelta.y > 0)
            //              chartView.zoom(1.1)
            //              else
            //              chartView.zoom(0.9)

            //          }
            onReleased: (mouse) => {
                            if (chartView.pointsY.length > 0 | chartView.pointsX > 0)
                            if(mouse.button === Qt.LeftButton)
                            chartView.zoomIn(rubber)
                            else if (mouse.button === Qt.RightButton)
                            chartView.zoom(rubber.width/chartView.width)
                            rubber.visible = false
                        }

            onPressed: (mouse) => {
                           oldX = mouse.x
                           oldY = mouse.y
                           chartView.pointsY = []
                           chartView.pointsX = []
                       }

            hoverEnabled: true

            onPositionChanged: (mouse) => {
                                   var p = chartView.mapToValue(Qt.point(mouse.x, mouse.y), lineSeries)
                                   root.mouseX = p.x
                                   root.mouseY = p.y
                                   if (!pressed)
                                        return
                                   if (chartView.mouseBeh === Figure.MouseType.Zooming) {
                                       rubber.visible = true
                                       chartView.pointsX.push(mouse.x)
                                       chartView.pointsY.push(mouse.y)
                                       rubber.x = Math.min(chartView.pointsX[0], chartView.pointsX[chartView.pointsX.length-1])
                                       rubber.y = Math.min(chartView.pointsY[0], chartView.pointsY[chartView.pointsY.length-1])
                                       rubber.width = Math.abs(Math.max(chartView.pointsX[0], chartView.pointsX[chartView.pointsX.length-1]) - Math.min(chartView.pointsX[0], chartView.pointsX[chartView.pointsX.length-1]))
                                       rubber.height = Math.abs(Math.max(chartView.pointsY[0], chartView.pointsY[chartView.pointsY.length-1]) - Math.min(chartView.pointsY[0], chartView.pointsY[chartView.pointsY.length-1]))
                                   }
                                   else if (chartView.mouseBeh === Figure.MouseType.Draging) {
                                       if (dragArea.pressedButtons === Qt.LeftButton) {
                                            if (mouse.x > oldX)
                                                chartView.scrollLeft(mouse.x - oldX)
                                            else if (mouse.x < oldX)
                                                chartView.scrollRight(oldX - mouse.x)
                                            if (mouse.y > oldY)
                                                chartView.scrollUp(mouse.y - oldY)
                                            else if (mouse.y < oldY)
                                                chartView.scrollDown(oldY - mouse.y)

                                       }
                                       else if (dragArea.pressedButtons === Qt.RightButton) {
                                           if (mouse.y < oldY) {
                                               axisY.min = axisY.min + axisY.tickInterval/chartView.zoomRatio
                                               axisY.max = axisY.max - axisY.tickInterval/chartView.zoomRatio
                                           }
                                           else if (mouse.y > oldY) {
                                               axisY.min = axisY.min - axisY.tickInterval/chartView.zoomRatio
                                               axisY.max = axisY.max + axisY.tickInterval/chartView.zoomRatio
                                           }
                                           if (mouse.x > oldX) {
                                               axisX.min = axisX.min + axisX.tickInterval/chartView.zoomRatio
                                               axisX.max = axisX.max - axisX.tickInterval/chartView.zoomRatio
                                           }
                                           else if (mouse.x < oldX){
                                               axisX.min = axisX.min - axisX.tickInterval/chartView.zoomRatio
                                               axisX.max = axisX.max + axisX.tickInterval/chartView.zoomRatio
                                           }
                                       }
                                       oldX = mouse.x
                                       oldY = mouse.y
                                   }

                               }
        }

        ValuesAxis {
            id: axisY
            min: root.minY
            max: root.maxY
            labelFormat: "%3.0f mv"


            onRangeChanged: {
                var logg = Math.log((axisY.max - axisY.min)/1.7) / Math.LN10
                var dec = Math.floor(logg)
                axisY.labelFormat = "%3." + (dec < 0 ? Math.abs(dec) : 0) + "f mv"
                axisY.tickInterval = Math.pow(10, dec)
            }

            tickAnchor: 0
            tickInterval: 1
            tickType : ValueAxis.TicksDynamic
        }

        ValuesAxis {
            id: axisX
            min: root.minX
            max: root.maxX
            onRangeChanged: {
                var logg = Math.log((axisX.max - axisX.min)/1.7) / Math.LN10
                var dec = Math.floor(logg)
                axisX.labelFormat = "%3." + (dec < 0 ? Math.abs(dec) : 0) + "f"
                axisX.tickInterval = Math.pow(10, dec)
            }
            tickAnchor: 0
            tickInterval: 100
            tickType : ValueAxis.TicksDynamic
        }

        LineSeries {
            id: lineSeries
            axisX: axisX
            axisY: axisY
            onHovered: (point, state) =>{
                           chartView.graphxyChanged(point, state)
                       }

            useOpenGL: chartView.openGL
        }

        Timer {
            id: refreshTimer
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                dataSource.update(lineSeries)

            }
        }
    }
}
