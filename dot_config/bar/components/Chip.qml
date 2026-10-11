import QtQuick
import QtQuick.Controls
import ".."

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property string tooltip: ""
    property color accent: Theme.muted
    property color background: Theme.surface
    property bool interactive: false
    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(int delta)

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 30
    radius: Theme.radius
    color: Settings.hoverEnabled && mouse.containsMouse && interactive ? Theme.hover : background
    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 7
        Text {
            visible: root.icon !== ""
            text: root.icon
            color: root.accent
            font.family: Theme.font
            font.pixelSize: 15
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible: root.label !== ""
            text: root.label
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: Theme.fontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: Settings.hoverEnabled
        acceptedButtons: root.interactive ? Qt.LeftButton | Qt.RightButton | Qt.MiddleButton : Qt.NoButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: event => {
            if (event.button === Qt.RightButton) root.rightClicked();
            else if (event.button === Qt.MiddleButton) root.middleClicked();
            else root.clicked();
        }
        onWheel: event => {
            if (root.interactive) root.scrolled(event.angleDelta.y);
            else event.accepted = false;
        }
    }
    ToolTip.visible: Settings.hoverEnabled && mouse.containsMouse && tooltip !== ""
    ToolTip.text: tooltip
    ToolTip.delay: 500
}
