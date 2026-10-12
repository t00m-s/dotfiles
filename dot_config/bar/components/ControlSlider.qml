import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    property string title: ""
    property string icon: ""
    property real level: 0
    property bool available: true
    property real pendingValue: 0
    property int lastSentValue: -1
    readonly property real displayedLevel: slider.value
    signal moved(real value)
    spacing: 8

    function syncLevel() {
        if (!slider.pressed && settle.running && Math.abs(root.level - pendingValue) <= 1)
            settle.stop();
        if (!slider.pressed && !settle.running) slider.value = root.level;
    }
    function sendPending() {
        const rounded = Math.round(pendingValue);
        if (rounded === lastSentValue) return;
        lastSentValue = rounded;
        root.moved(pendingValue);
    }
    onLevelChanged: syncLevel()
    Component.onCompleted: syncLevel()
    RowLayout {
        Layout.fillWidth: true
        Text { text: root.icon; color: Theme.accent; font.family: Theme.font; font.pixelSize: 18 }
        Text { text: root.title; color: Theme.text; font.family: Theme.font; font.pixelSize: 13; Layout.fillWidth: true }
        Text { text: root.available ? Math.round(root.displayedLevel) + "%" : "Unavailable"; color: Theme.muted; font.family: Theme.font; font.pixelSize: 12 }
    }
    Slider {
        id: slider
        objectName: "sliderInput"
        Layout.fillWidth: true
        Layout.preferredHeight: 32
        implicitHeight: 32
        leftPadding: 8
        rightPadding: 8
        enabled: root.available
        from: 0
        to: 100
        stepSize: 0
        // Keep user input independent of telemetry. Wait for the next sample
        // after releasing, rather than restoring an old value immediately.
        onMoved: {
            root.pendingValue = value;
            settle.restart();
            if (!throttle.running) {
                root.sendPending();
                throttle.start();
            }
        }
        onPressedChanged: {
            if (pressed) { settle.stop(); root.pendingValue = value; root.lastSentValue = -1; }
            else if (enabled) {
                throttle.stop();
                settle.restart();
                root.sendPending();
            }
        }
        background: Rectangle {
            objectName: "sliderTrack"
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            implicitHeight: 6
            height: 6
            radius: 3
            color: Theme.hover
            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: slider.enabled ? Theme.accent : Theme.muted
                Behavior on width {
                    enabled: !slider.pressed && !settle.running
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }
            }
        }
        handle: Rectangle {
            objectName: "sliderHandle"
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 16
            implicitHeight: 16
            width: 16
            height: 16
            radius: 8
            color: slider.pressed ? Theme.text : Theme.accent
            Behavior on x {
                enabled: !slider.pressed && !settle.running
                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
            }
            Behavior on color { ColorAnimation { duration: 100 } }
        }
    }
    Timer {
        id: throttle
        interval: 50
        repeat: true
        onTriggered: {
            root.sendPending();
            if (!slider.pressed) stop();
        }
    }
    Timer {
        id: settle
        interval: Math.max(500, Settings.pollSeconds * 1000 + 250)
        onTriggered: root.syncLevel()
    }
}
