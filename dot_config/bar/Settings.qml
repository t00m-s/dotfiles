pragma Singleton
import QtQuick

QtObject {
    property int barHeight: 34
    property int outerMargin: 0
    property bool hoverEnabled: false
    property int pollSeconds: 2
    property string timeFormat: "HH:mm"
    property string dateFormat: "ddd, dd MMM"
    // Empty strings select the first matching hwmon sensor automatically.
    property string cpuSensor: ""
    property string gpuSensor: ""
    // HDMI is wired to NVIDIA on this machine. Switch back to AMD on unplug.
    property bool gpuFollowHdmi: true
    property string backlightDevice: ""
    // Opt in: querying nvidia-smi can wake a sleeping discrete GPU.
    property bool queryNvidia: false
    // Optional program to launch on right-clicking the network chip.
    // Example: ["kitty", "-e", "nmtui"] (requires NetworkManager).
    property var networkCommand: []
}
