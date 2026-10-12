import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root
    objectName: "controlsPopup"
    required property var barWindow
    screen: barWindow.screen
    anchors { top: true; right: true }
    margins { top: barWindow.height + Settings.outerMargin; right: Settings.outerMargin }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 36
    color: "transparent"
    visible: false

    HyprlandFocusGrab {
        windows: [root, root.barWindow]
        active: root.visible
        onCleared: root.visible = false
    }
    Rectangle {
        anchors.fill: parent
        radius: 20
        topLeftRadius: 0
        topRightRadius: 0
        color: Theme.panel
        border.color: Theme.border
        border.width: 1
        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
            spacing: 18
            RowLayout {
                Layout.fillWidth: true
                Text { text: "Quick controls"; color: Theme.text; font.family: Theme.font; font.pixelSize: 15; font.bold: true; Layout.fillWidth: true }
                Chip { objectName: "closeControls"; icon: "󰅖"; interactive: true; tooltip: "Close"; onClicked: root.visible = false }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    objectName: "appearanceLabel"
                    text: "Appearance · " + (Theme.darkMode ? "Dark" : "Light")
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }
                RowLayout {
                    spacing: 6
                    Repeater {
                        model: ["system", "light", "dark"]
                        Chip {
                            required property string modelData
                            objectName: "theme-" + modelData
                            label: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                            icon: modelData === "system" ? "󰌢" : (modelData === "light" ? "󰃠" : "󰖔")
                            background: Theme.mode === modelData ? Theme.hover : Theme.surface
                            accent: Theme.mode === modelData ? Theme.accent : Theme.muted
                            tooltip: modelData === "system" ? "Follow the system light/dark preference automatically" : "Always use " + modelData + " mode"
                            interactive: true
                            onClicked: Theme.setMode(modelData)
                        }
                    }
                }
            }
            ControlSlider {
                objectName: "volumeSlider"
                Layout.fillWidth: true
                title: SystemState.data.muted ? "Volume · muted" : "Volume"
                icon: SystemState.data.muted ? "󰝟" : "󰕾"
                available: SystemState.data.volume !== null && SystemState.data.volume !== undefined
                level: SystemState.data.volume || 0
                onMoved: value => SystemState.control("volume-set", Math.round(value))
            }
            Chip {
                label: SystemState.data.muted ? "Unmute" : "Mute output"
                icon: SystemState.data.muted ? "󰕾" : "󰝟"
                interactive: true
                onClicked: SystemState.control("volume-mute")
            }
            ControlSlider {
                objectName: "brightnessSlider"
                Layout.fillWidth: true
                title: "Brightness"
                icon: "󰃠"
                available: SystemState.data.brightness !== null && SystemState.data.brightness !== undefined
                level: SystemState.data.brightness || 0
                onMoved: value => SystemState.control("brightness-set", Math.max(1, Math.round(value)))
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                Text {
                    text: (SystemState.data.networkOnline ? "Connected · " : "Offline · ") + (SystemState.data.networkInterface || "No default route")
                    color: SystemState.data.networkOnline ? Theme.green : Theme.muted
                    font.family: Theme.font; font.pixelSize: 12
                    Layout.fillWidth: true; elide: Text.ElideRight
                }
                Text { text: SystemState.data.networkAddress || "No IP address"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 12 }
                Text {
                    text: "↓ " + SystemState.rate(SystemState.data.networkRx) + "    ↑ " + SystemState.rate(SystemState.data.networkTx)
                    color: Theme.text; font.family: Theme.font; font.pixelSize: 12
                }
            }
            Text {
                visible: SystemState.error !== ""
                text: SystemState.error
                color: Theme.red
                font.family: Theme.font; font.pixelSize: 11
                Layout.fillWidth: true; wrapMode: Text.WordWrap
            }
        }
    }
}
