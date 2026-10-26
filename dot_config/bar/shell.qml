import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "components"

ShellRoot {
    readonly property var barWindows: bars.instances
    readonly property var dateLocale: Qt.locale("it_IT")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Variants {
        id: bars
        model: Quickshell.screens

        PanelWindow {
            id: bar
            objectName: "bar"
            required property var modelData

            screen: modelData
            anchors { top: true; left: true; right: true }
            margins {
                top: Settings.outerMargin
                left: Settings.outerMargin
                right: Settings.outerMargin
            }

            implicitHeight: Settings.barHeight
            color: "transparent"

            readonly property var hyprMonitor: Hyprland.monitorFor(screen)
            readonly property bool compact: width < 1350
            readonly property var stats: SystemState.data
            readonly property var controlsWindow: controls
            readonly property var calendarWindow: calendar

            function toggleControls() {
                calendar.visible = false;
                controls.visible = !controls.visible;
            }

            function toggleCalendar() {
                controls.visible = false;
                calendar.visible = !calendar.visible;
            }

            Rectangle {
                anchors.fill: parent
                color: Theme.background
                radius: 0

                Item {
                    anchors.fill: parent

                    EdgeGroup {
                        id: leftGroup
                        objectName: "leftGroup"
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: leftContent.implicitWidth
                        leftEdge: true

                        Row {
                            id: leftContent
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Workspaces {
                                monitor: bar.hyprMonitor
                                background: "transparent"
                            }

                            Text {
                                width: Math.min(
                                    implicitWidth,
                                    bar.compact ? 130 : 230
                                )
                                height: 30
                                leftPadding: 8
                                rightPadding: 8
                                verticalAlignment: Text.AlignVCenter
                                text: Hyprland.activeToplevel
                                    ? Hyprland.activeToplevel.title
                                    : "Desktop"
                                elide: Text.ElideRight
                                color: Theme.muted
                                font.family: Theme.font
                                font.pixelSize: Theme.fontSize

                                MouseArea {
                                    id: titleMouse
                                    anchors.fill: parent
                                    hoverEnabled: Settings.hoverEnabled
                                    acceptedButtons: Qt.NoButton
                                }

                                ToolTip.visible: Settings.hoverEnabled
                                    && titleMouse.containsMouse
                                ToolTip.text: text
                                ToolTip.delay: 600
                            }
                        }
                    }

                    Rectangle {
                        objectName: "centerGroup"
                        anchors.centerIn: parent
                        width: centerContent.implicitWidth
                        height: 30
                        radius: Theme.radius
                        color: Theme.surface

                        RowLayout {
                            id: centerContent
                            anchors.centerIn: parent
                            spacing: 0

                            Chip {
                                icon: ""
                                label: SystemState.temperature(bar.stats.cpuTemp)
                                accent: bar.stats.cpuTemp >= 85
                                    ? Theme.red : Theme.peach
                                tooltip: "CPU temperature" +
                                    (bar.stats.cpuSensor
                                        ? " · " + bar.stats.cpuSensor
                                        : " · sensor unavailable")
                                background: "transparent"
                            }

                            Chip {
                                icon: "󰢮"
                                label: SystemState.temperature(bar.stats.gpuTemp)
                                accent: bar.stats.gpuTemp >= 85
                                    ? Theme.red : Theme.teal
                                tooltip: "GPU temperature" +
                                    (bar.stats.gpuSensor
                                        ? " · " + bar.stats.gpuSensor
                                        : " · sensor unavailable")
                                background: "transparent"
                            }

                            Chip {
                                background: "transparent"
                                icon: "󰥔"
                                objectName: "timeControl"
                                label: dateLocale.toString(
                                    clock.date, Settings.timeFormat
                                )
                                accent: Theme.accent
                                tooltip: dateLocale.toString(
                                    clock.date,
                                    "dddd, dd MMMM yyyy · HH:mm:ss"
                                )
                                interactive: true
                                onClicked: bar.toggleCalendar()
                            }

                            Chip {
                                id: dateChip
                                objectName: "dateControl"
                                visible: !bar.compact
                                label: dateLocale.toString(
                                    clock.date, Settings.dateFormat
                                )
                                background: "transparent"
                                tooltip: dateLocale.toString(
                                    clock.date, "dddd, dd MMMM yyyy"
                                )
                                interactive: true
                                onClicked: bar.toggleCalendar()
                            }

                            Chip {
                                background: "transparent"
                                icon: ""
                                label: SystemState.percent(bar.stats.cpu)
                                accent: bar.stats.cpu >= 90
                                    ? Theme.yellow : Theme.accent
                                tooltip: "CPU usage · sampled every " +
                                    Settings.pollSeconds + " seconds"
                            }

                            Chip {
                                background: "transparent"
                                icon: "󰍛"
                                label: SystemState.percent(bar.stats.memory)
                                accent: bar.stats.memory >= 90
                                    ? Theme.yellow : Theme.accent
                                tooltip: "Memory · " +
                                    (bar.stats.memoryUsedGiB || 0).toFixed(1) +
                                    " / " +
                                    (bar.stats.memoryTotalGiB || 0).toFixed(1) +
                                    " GiB"
                            }
                        }
                    }

                    EdgeGroup {
                        objectName: "rightGroup"
                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: rightContent.implicitWidth
                        leftEdge: false

                        Row {
                            id: rightContent
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Tray {
                                barWindow: bar
                            }

                            Chip {
                                background: "transparent"
                                objectName: "networkControl"
                                icon: bar.stats.networkOnline
                                    ? (bar.stats.networkWireless
                                        ? "󰤨" : "󰈀")
                                    : "󰤭"
                                label: bar.compact
                                    ? ""
                                    : (bar.stats.networkInterface || "Offline")
                                accent: bar.stats.networkOnline
                                    ? Theme.green : Theme.muted
                                tooltip: (bar.stats.networkAddress ||
                                    "No network connection") +
                                    "\n↓ " +
                                    SystemState.rate(bar.stats.networkRx) +
                                    "  ↑ " +
                                    SystemState.rate(bar.stats.networkTx) +
                                    "\nClick: quick controls"
                                interactive: true
                                onClicked: bar.toggleControls()
                                onRightClicked: {
                                    if (Settings.networkCommand.length)
                                        Quickshell.execDetached(
                                            Settings.networkCommand
                                        );
                                }
                            }

                            Chip {
                                background: "transparent"
                                icon: bar.stats.muted ? "󰝟" : "󰕾"
                                label: SystemState.percent(bar.stats.volume)
                                accent: bar.stats.muted
                                    ? Theme.red : Theme.accent
                                tooltip: "Volume · click: controls · right/middle-click: mute · scroll: ±5%"
                                interactive: true
                                onClicked: bar.toggleControls()
                                onRightClicked: SystemState.control("volume-mute")
                                onMiddleClicked: SystemState.control("volume-mute")
                                onScrolled: delta => {
                                    if (delta)
                                        SystemState.control(
                                            "volume-step",
                                            delta > 0 ? 5 : -5
                                        );
                                }
                            }

                            Chip {
                                background: "transparent"
                                icon: "󰃠"
                                visible: bar.stats.brightness !== null
                                    && bar.stats.brightness !== undefined
                                label: SystemState.percent(bar.stats.brightness)
                                accent: Theme.yellow
                                tooltip: "Brightness · click: controls · scroll: ±5%"
                                interactive: true
                                onClicked: bar.toggleControls()
                                onScrolled: delta => {
                                    if (delta)
                                        SystemState.control(
                                            "brightness-step",
                                            delta > 0 ? 5 : -5
                                        );
                                }
                            }

                            Chip {
                                background: "transparent"
                                visible: bar.stats.batteryPresent === true
                                icon: bar.stats.batteryCharging
                                    ? "󰂄"
                                    : (bar.stats.batteryOnAC
                                        ? "󰚥"
                                        : (bar.stats.battery <= 20
                                            ? "󰂃" : "󰁹"))
                                label: SystemState.percent(bar.stats.battery)
                                accent: bar.stats.batteryCharging
                                    ? Theme.green
                                    : (bar.stats.battery <= 20
                                        ? Theme.red : Theme.muted)
                                tooltip: "Battery · " +
                                    (bar.stats.batteryStatus || "Unknown") +
                                    (bar.stats.batteryOnAC
                                        ? " · plugged in" : "")
                            }
                        }
                    }
                }
            }

            ControlsPopup {
                id: controls
                barWindow: bar
            }

            CalendarPopup {
                id: calendar
                barWindow: bar
                anchorItem: dateChip.visible ? dateChip : centerContent
                today: clock.date
            }
        }
    }
}
