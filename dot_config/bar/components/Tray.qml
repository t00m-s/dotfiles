import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import ".."

Row {
    id: root
    required property var barWindow
    spacing: 3
    Repeater {
        model: SystemTray.items
        Rectangle {
            id: trayItem
            required property SystemTrayItem modelData
            width: 28
            height: 30
            radius: 10
            color: Settings.hoverEnabled && mouse.containsMouse ? Theme.hover : "transparent"
            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: trayItem.modelData.icon
                fillMode: Image.PreserveAspectFit
            }
            QsMenuAnchor {
                id: menu
                menu: trayItem.modelData.menu
                anchor.item: trayItem
                anchor.edges: Edges.Bottom | Edges.Left
                anchor.gravity: Edges.Bottom | Edges.Right
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: Settings.hoverEnabled
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    if (event.button === Qt.RightButton || trayItem.modelData.onlyMenu) {
                        if (trayItem.modelData.hasMenu) menu.open();
                    } else if (event.button === Qt.MiddleButton) trayItem.modelData.secondaryActivate();
                    else trayItem.modelData.activate();
                }
                onWheel: event => trayItem.modelData.scroll(event.angleDelta.y, false)
            }
            ToolTip.visible: Settings.hoverEnabled && mouse.containsMouse
            ToolTip.text: modelData.tooltipTitle || modelData.title || modelData.id
            ToolTip.delay: 500
        }
    }
}
