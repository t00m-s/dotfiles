pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property var data: ({
        cpu: 5, memory: 25, memoryUsedGiB: 8, memoryTotalGiB: 32,
        cpuTemp: 45, gpuTemp: 42, volume: 30, muted: false, brightness: 60,
        networkOnline: false, batteryPresent: true, battery: 80
    })
    property string error: ""
    property string lastAction: ""
    property real lastValue: -1
    property int controlCount: 0
    function control(action, value) {
        lastAction = action;
        lastValue = value === undefined ? -1 : Number(value);
        controlCount++;
    }
    function percent(value) { return value === undefined || value === null ? "—" : Math.round(value) + "%"; }
    function temperature(value) { return value === undefined || value === null ? "—" : Math.round(value) + "°"; }
    function rate(value) { return "—"; }
}
