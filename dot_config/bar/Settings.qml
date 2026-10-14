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
    // auto: detect the hybrid laptop; otherwise monitor the display-driving GPU.
    // Override with "desktop" or "laptop" if detection needs correcting.
    property string gpuProfile: "auto"
    // Laptop profile only: HDMI is wired to NVIDIA; switch to AMD on unplug.
    property bool gpuFollowHdmi: true
    property string backlightDevice: ""
    // Optional fallback for manual/laptop sensor selection. A detected desktop
    // NVIDIA card is queried automatically, independently of this setting.
    property bool queryNvidia: false
    // Optional program to launch on right-clicking the network chip.
    // Example: ["kitty", "-e", "nmtui"] (requires NetworkManager).
    property var networkCommand: []
}
