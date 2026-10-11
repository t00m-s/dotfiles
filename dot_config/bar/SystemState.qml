pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var data: ({})
    property string error: ""
    property var pending: []
    readonly property bool ready: Object.keys(data).length > 0

    function percent(value) {
        return value === null || value === undefined ? "—" : Math.round(value) + "%";
    }
    function temperature(value) {
        return value === null || value === undefined ? "—" : Math.round(value) + "°";
    }
    function rate(value) {
        if (value === null || value === undefined) return "—";
        return value >= 1048576 ? (value / 1048576).toFixed(1) + " MiB/s"
                               : Math.round(value / 1024) + " KiB/s";
    }
    function control(action, value) {
        const args = ["python3", Quickshell.shellPath("scripts/monitor.py"), action];
        if (value !== undefined) args.push(String(value));
        if (action.indexOf("brightness") === 0 && Settings.backlightDevice)
            args.push("--device", Settings.backlightDevice);
        // Serialize commands so rapid scrolling cannot race volume changes.
        pending = pending.concat([args]);
        drain();
    }
    function drain() {
        if (actionProcess.running || pending.length === 0) return;
        actionProcess.command = pending[0];
        pending = pending.slice(1);
        error = "";
        actionProcess.running = true;
    }

    Process {
        id: monitor
        command: ["python3", "-u", Quickshell.shellPath("scripts/monitor.py"), "stream",
                  "--interval", String(Settings.pollSeconds),
                  "--cpu-sensor", Settings.cpuSensor, "--gpu-sensor", Settings.gpuSensor,
                  "--device", Settings.backlightDevice]
                  .concat(Settings.queryNvidia ? ["--nvidia"] : [])
                  .concat(Settings.gpuFollowHdmi ? ["--gpu-follow-hdmi"] : [])
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.data = JSON.parse(line);
                    if (root.error.startsWith("System monitor stopped")) root.error = "";
                }
                catch (e) { console.warn("Invalid monitor data:", e); }
            }
        }
        stderr: SplitParser { onRead: line => console.warn("Monitor:", line) }
        onExited: (code, status) => {
            root.error = "System monitor stopped (" + code + "). Retrying…";
            restart.start();
        }
    }
    Timer {
        id: restart
        interval: 5000
        onTriggered: monitor.running = true
    }
    Process {
        id: actionProcess
        stderr: StdioCollector { onStreamFinished: root.error = text.trim() }
        onExited: (code, status) => {
            if (code !== 0 && !root.error) root.error = "Control command failed (" + code + ")";
            Qt.callLater(root.drain);
        }
    }
}
