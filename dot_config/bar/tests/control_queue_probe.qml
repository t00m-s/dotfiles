import QtQuick
import Quickshell
import "."

ShellRoot {
    Timer {
        interval: 150
        running: true
        onTriggered: {
            SystemState.control("volume-set", 10);
            SystemState.control("brightness-set", 20);
            SystemState.control("volume-set", 30);
            SystemState.control("brightness-set", 40);
            SystemState.control("volume-step", 5);
            SystemState.control("volume-set", 70);
            SystemState.control("volume-set", 80);
            finish.start();
        }
    }
    Timer {
        id: finish
        interval: 800
        onTriggered: {
            if (SystemState.pending.length === 0 && SystemState.data.volume === 80
                && SystemState.data.brightness === 40 && SystemState.data.cpu === 42
                && SystemState.error === "")
                console.log("CONTROL_QUEUE_OK");
            else console.error("CONTROL_QUEUE_FAILED", JSON.stringify(SystemState.data), SystemState.error);
            Qt.quit();
        }
    }
}
