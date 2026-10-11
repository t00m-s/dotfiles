pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    // Portal values: 0 = no preference, 1 = dark, 2 = light.
    property int portalScheme: -1
    readonly property int colorScheme: portalScheme === 1 ? Qt.Dark
                                           : portalScheme === 2 ? Qt.Light
                                           : Qt.styleHints.colorScheme

    function readScheme(text) {
        const match = text.match(/uint32\s+([012])\b/);
        if (match) portalScheme = Number(match[1]);
    }
    function refresh() {
        if (!reader.running) reader.running = true;
    }

    // Read the freedesktop preference directly: this also works when a custom
    // Qt platform theme does not forward portal updates to Qt.styleHints.
    Process {
        id: reader
        command: ["gdbus", "call", "--session", "--dest", "org.freedesktop.portal.Desktop",
                  "--object-path", "/org/freedesktop/portal/desktop", "--method",
                  "org.freedesktop.portal.Settings.Read", "org.freedesktop.appearance", "color-scheme"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.readScheme(text) }
        onExited: (code, status) => { if (code !== 0) root.portalScheme = -1; }
    }
    Process {
        id: watcher
        command: ["gdbus", "monitor", "--session", "--dest", "org.freedesktop.portal.Desktop",
                  "--object-path", "/org/freedesktop/portal/desktop"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (line.includes("org.freedesktop.portal.Settings.SettingChanged")
                    && line.includes("org.freedesktop.appearance") && line.includes("color-scheme"))
                    root.readScheme(line);
                else if (line.includes("does not have an owner")) root.portalScheme = -1;
                else if (line.includes("is owned by")) root.refresh();
            }
        }
        onExited: (code, status) => {
            root.portalScheme = -1;
            retry.start();
        }
    }
    Timer {
        id: retry
        interval: 5000
        onTriggered: { watcher.running = true; root.refresh(); }
    }
}
