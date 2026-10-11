pragma Singleton
import QtQuick
import QtCore as Core

QtObject {
    property alias mode: preferences.mode
    readonly property bool darkMode: mode === "dark" || (mode !== "light" && SystemAppearance.colorScheme !== Qt.Light)
    readonly property QtObject preferences: Core.Settings {
        id: preferences
        location: Qt.resolvedUrl("appearance.ini")
        category: "Appearance"
        property string mode: "system"
    }

    function setMode(value) {
        if (["system", "light", "dark"].indexOf(value) === -1) return;
        mode = value;
        preferences.setValue("mode", mode);
        preferences.sync();
    }

    // Catppuccin Mocha / Latte. Every widget binds to these shared colors.
    readonly property color background: darkMode ? "#11111b" : "#eff1f5"
    readonly property color panel: darkMode ? "#181825" : "#e6e9ef"
    readonly property color surface: darkMode ? "#1e1e2e" : "#dce0e8"
    readonly property color hover: darkMode ? "#313244" : "#ccd0da"
    readonly property color border: darkMode ? "#45475a" : "#bcc0cc"
    readonly property color text: darkMode ? "#cdd6f4" : "#4c4f69"
    readonly property color muted: darkMode ? "#a6adc8" : "#6c6f85"
    readonly property color accent: darkMode ? "#b4befe" : "#7287fd"
    readonly property color green: darkMode ? "#a6e3a1" : "#40a02b"
    readonly property color yellow: darkMode ? "#f9e2af" : "#df8e1d"
    readonly property color red: darkMode ? "#f38ba8" : "#d20f39"
    readonly property color peach: darkMode ? "#fab387" : "#fe640b"
    readonly property color teal: darkMode ? "#94e2d5" : "#179299"
    readonly property color onAccent: darkMode ? "#11111b" : "#eff1f5"
    readonly property int radius: 14
    readonly property int fontSize: 12
    readonly property string font: "CommitMono Nerd Font"
}
