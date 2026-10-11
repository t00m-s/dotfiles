import QtQuick
import QtTest
import Quickshell
import "."
import "components"

ShellRoot {
    id: root
    property var app
    function locate(item, name) {
        if (item.objectName === name) return item;
        for (let i = 0; i < item.children.length; i++) {
            const found = locate(item.children[i], name);
            if (found) return found;
        }
        return null;
    }
    PanelWindow {
        anchors { top: true; left: true; right: true }
        implicitHeight: 1
        TestCase {
            name: "BarInteraction"
            when: true
            function dragSlider(popup, name, action, field) {
                const control = root.locate(popup.contentItem, name);
                const input = root.locate(control, "sliderInput");
                verify(input.enabled, "Slider is disabled");
                verify(input.height >= 32, "Slider hit area is too small");
                verify(input.handle.implicitWidth > 0 && input.handle.implicitHeight > 0);
                compare(input.background.height, 6);
                compare(input.handle.width, 16);
                compare(input.handle.height, 16);
                const expectedX = input.leftPadding + input.visualPosition * (input.availableWidth - input.handle.width);
                verify(Math.abs(input.handle.x - expectedX) < 0.01, "Thumb position does not match its value");
                const x = input.leftPadding + input.position * (input.availableWidth - input.handle.width) + input.handle.width / 2;
                const y = input.height / 2;
                mousePress(input, x, y);
                mouseMove(input, input.width * 0.8, y, 30);
                verify(input.pressed);
                verify(control.displayedLevel > 70, "Dragging did not move the thumb");
                const draggedValue = control.displayedLevel;
                // A stale polling update must not interrupt a gesture.
                const update = Object.assign({}, SystemState.data);
                update[field] = 10;
                SystemState.data = update;
                compare(control.displayedLevel, draggedValue);
                mouseRelease(input, input.width * 0.8, y);
                compare(SystemState.lastAction, action);
                compare(SystemState.lastValue, Math.round(draggedValue));
                compare(control.displayedLevel, draggedValue);
                wait(100);
                compare(control.displayedLevel, draggedValue);
                // Clicking away from the thumb must work across the whole track.
                mouseClick(input, input.width * 0.2, y);
                verify(control.displayedLevel < 30, "Track click did not move the thumb");
                compare(SystemState.lastAction, action);
                compare(SystemState.lastValue, Math.round(control.displayedLevel));
                const confirmed = Object.assign({}, SystemState.data);
                confirmed[field] = 42;
                SystemState.data = confirmed;
                wait(550);
                compare(control.displayedLevel, 42);
            }
            function test_controls() {
                try {
                    const component = Qt.createComponent("app.qml");
                    if (component.status === Component.Error) console.error("APP_LOAD_ERROR", component.errorString());
                    tryCompare(component, "status", Component.Ready, 3000);
                    root.app = component.createObject(root);
                    verify(root.app !== null, component.errorString());
                    wait(300);
                    const bar = root.app.barWindows[0];
                    const left = root.locate(bar.contentItem, "leftGroup");
                    const right = root.locate(bar.contentItem, "rightGroup");
                    const center = root.locate(bar.contentItem, "centerGroup");
                    compare(left.x, 0);
                    compare(right.x + right.width, bar.width);
                    verify(Math.abs(center.x + center.width / 2 - bar.width / 2) <= 0.5, "Center group is not centered");
                    verify(left.leftEdge && !right.leftEdge, "Edge groups are facing the wrong way");
                    const chip = root.locate(bar.contentItem, "networkControl");
                    const popup = bar.controlsWindow;
                    verify(chip.width > 0 && chip.height > 0);
                    mouseClick(chip, chip.width / 2, chip.height / 2);
                    wait(150);
                    verify(popup.visible, "Click did not open controls");
                    const dark = root.locate(popup.contentItem, "theme-dark");
                    verify(dark.width > 0 && dark.height > 0);
                    mouseClick(dark, dark.width / 2, dark.height / 2);
                    compare(Theme.mode, "dark");
                    verify(Theme.darkMode);
                    compare(root.locate(popup.contentItem, "appearanceLabel").text, "Appearance · Dark");
                    const light = root.locate(popup.contentItem, "theme-light");
                    mouseClick(light, light.width / 2, light.height / 2);
                    compare(Theme.mode, "light");
                    verify(!Theme.darkMode);
                    compare(root.locate(popup.contentItem, "appearanceLabel").text, "Appearance · Light");
                    Theme.setMode("system");
                    compare(root.locate(popup.contentItem, "appearanceLabel").text, "Appearance · " + (Theme.darkMode ? "Dark" : "Light"));
                    Settings.pollSeconds = 0; // Shorten telemetry settling in this isolated test.
                    SystemState.data = Object.assign({}, SystemState.data, {volume: 0, brightness: 100});
                    dragSlider(popup, "volumeSlider", "volume-set", "volume");
                    dragSlider(popup, "brightnessSlider", "brightness-set", "brightness");
                    const close = root.locate(popup.contentItem, "closeControls");
                    mouseClick(close, close.width / 2, close.height / 2);
                    verify(!popup.visible, "Close button did not dismiss controls");
                    verify(!Settings.hoverEnabled, "Hover is not disabled by default");
                    compare(Settings.outerMargin, 0);
                    console.log("INTERACTION_OK");
                } catch (error) {
                    console.error("INTERACTION_FAILED", error);
                }
                Qt.quit();
            }
        }
    }
}
