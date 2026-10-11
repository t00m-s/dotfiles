import QtQuick
import Quickshell.Hyprland
import ".."

Rectangle {
    id: root
    property var monitor: null
    property color background: Theme.panel
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : 0
    readonly property var workspaceIds: {
        let ids = [];
        for (const ws of Hyprland.workspaces.values) {
            if (!ws.name.startsWith("special:") && ids.indexOf(ws.id) === -1) ids.push(ws.id);
        }
        return ids.sort((a, b) => a - b);
    }
    implicitWidth: row.implicitWidth + 10
    implicitHeight: 30
    radius: Theme.radius
    color: background

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
        Repeater {
            model: root.workspaceIds
            Rectangle {
                id: workspace
                required property int modelData
                readonly property var workspaceObject: Hyprland.workspaces.values.find(ws => ws.id === modelData) || null
                readonly property bool active: root.activeId === modelData
                width: active ? 32 : 26
                height: 24
                radius: 12
                color: active ? Theme.accent : (Settings.hoverEnabled && mouse.containsMouse ? Theme.hover : "transparent")
                Behavior on width { NumberAnimation { duration: 160 } }
                Behavior on color { ColorAnimation { duration: 160 } }
                Text {
                    anchors.centerIn: parent
                    text: workspace.modelData > 0 ? workspace.modelData : (workspace.workspaceObject ? workspace.workspaceObject.name : "?")
                    color: workspace.active ? Theme.onAccent : (workspace.workspaceObject ? Theme.text : Theme.muted)
                    font.family: Theme.font
                    font.pixelSize: 12
                    font.bold: workspace.active
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: Settings.hoverEnabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("focusmonitor " + root.monitor.name);
                        Hyprland.dispatch("workspace " + (workspace.modelData > 0 ? workspace.modelData : "name:" + workspace.workspaceObject.name));
                    }
                    onWheel: event => {
                        if (!event.angleDelta.y) return;
                        Hyprland.dispatch("focusmonitor " + root.monitor.name);
                        Hyprland.dispatch("workspace " + (event.angleDelta.y > 0 ? "e-1" : "e+1"));
                    }
                }
            }
        }
    }
}
