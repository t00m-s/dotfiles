import QtQuick
import ".."

Rectangle {
    property bool leftEdge: true
    color: Theme.surface
    radius: Theme.radius
    // Square the screen-facing end without changing the inward-facing corners.
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom }
        x: parent.leftEdge ? 0 : parent.width - width
        width: parent.radius
        color: parent.color
    }
}
