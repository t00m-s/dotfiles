import QtQuick
import Quickshell
import "."

ShellRoot {
    function check(condition, message) {
        if (!condition) throw new Error(message);
    }
    Timer {
        interval: 500
        running: true
        onTriggered: {
            try {
                if (Theme.preferences.value("probeComplete", false)) {
                    check(Theme.mode === "light", "Manual choice was not restored");
                    check(!Theme.darkMode, "Restored light mode is dark");
                    console.log("THEME_PERSISTENCE_OK");
                } else {
                    check(Theme.mode === "system", "Default is not System");
                    SystemAppearance.readScheme("(<<uint32 2>>,)");
                    check(!Theme.darkMode && Qt.colorEqual(Theme.background, "#eff1f5"), "System light did not select Latte");
                    SystemAppearance.readScheme("org.freedesktop.portal.Settings.SettingChanged ('org.freedesktop.appearance', 'color-scheme', <uint32 1>)");
                    check(Theme.darkMode && Qt.colorEqual(Theme.background, "#11111b"), "Live system dark did not select Mocha");
                    Theme.setMode("light");
                    check(!Theme.darkMode, "Light override failed");
                    SystemAppearance.portalScheme = 1;
                    check(!Theme.darkMode, "System change overrode manual Light");
                    Theme.setMode("dark");
                    SystemAppearance.portalScheme = 2;
                    check(Theme.darkMode, "System change overrode manual Dark");
                    Theme.setMode("system");
                    check(!Theme.darkMode, "Returning to System did not follow light");
                    Theme.setMode("invalid");
                    check(Theme.mode === "system", "Invalid mode was accepted");
                    SystemAppearance.portalScheme = 0;
                    check(SystemAppearance.colorScheme === Qt.styleHints.colorScheme, "Qt fallback failed");
                    Theme.setMode("light");
                    Theme.preferences.setValue("probeComplete", true);
                    Theme.preferences.sync();
                    console.log("THEME_SWITCHING_OK");
                }
            } catch (error) {
                console.error("THEME_TEST_FAILED", error);
            }
            Qt.quit();
        }
    }
}
