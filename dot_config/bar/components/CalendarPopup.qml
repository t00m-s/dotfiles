import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import ".."

PanelWindow {
    id: root
    objectName: "calendarPopup"
    required property var barWindow
    required property var anchorItem
    property date today: new Date()
    property date displayedMonth: new Date(today.getFullYear(), today.getMonth(), 1, 12)
    property date selectedDate: today
    readonly property var days: monthCells(displayedMonth.getFullYear(), displayedMonth.getMonth())
    screen: barWindow.screen
    anchors { top: true; left: true }
    margins.top: barWindow.height + Settings.outerMargin
    margins.left: {
        const point = anchorItem.mapToItem(barWindow.contentItem, 0, 0);
        return Settings.outerMargin + Math.max(0, Math.min(barWindow.width - width,
            point.x + anchorItem.width / 2 - width / 2));
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    implicitWidth: 340
    implicitHeight: content.implicitHeight + 32
    color: "transparent"
    visible: false

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate();
    }
    function monthCells(year, month) {
        const first = new Date(year, month, 1, 12);
        const offset = (first.getDay() + 6) % 7; // Monday first.
        return Array.from({length: 42}, (_, index) => new Date(year, month, 1 - offset + index, 12));
    }
    function goMonth(offset) {
        displayedMonth = new Date(displayedMonth.getFullYear(), displayedMonth.getMonth() + offset, 1, 12);
    }
    function showToday() {
        selectedDate = today;
        displayedMonth = new Date(today.getFullYear(), today.getMonth(), 1, 12);
    }
    onVisibleChanged: { if (visible) showToday(); }

    HyprlandFocusGrab {
        windows: [root, root.barWindow]
        active: root.visible
        onCleared: root.visible = false
    }
    Rectangle {
        anchors.fill: parent
        radius: 20
        topLeftRadius: 0
        topRightRadius: 0
        color: Theme.panel
        border.color: Theme.border
        border.width: 1
        ColumnLayout {
            id: content
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Chip { objectName: "calendarPrevious"; icon: "‹"; interactive: true; tooltip: "Previous month"; onClicked: root.goMonth(-1) }
                Text {
                    objectName: "calendarMonth"
                    text: Qt.formatDateTime(root.displayedMonth, "MMMM yyyy")
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                }
                Chip { objectName: "calendarNext"; icon: "›"; interactive: true; tooltip: "Next month"; onClicked: root.goMonth(1) }
                Chip { objectName: "closeCalendar"; icon: "󰅖"; interactive: true; tooltip: "Close"; onClicked: root.visible = false }
            }
            Row {
                Layout.fillWidth: true
                spacing: 4
                Repeater {
                    model: 7
                    Text {
                        required property int index
                        width: (dayGrid.width - 24) / 7
                        text: Qt.formatDateTime(new Date(2024, 0, 1 + index), "ddd")
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 11
                    }
                }
            }
            Grid {
                id: dayGrid
                Layout.fillWidth: true
                columns: 7
                spacing: 4
                Repeater {
                    model: root.days
                    Rectangle {
                        id: day
                        required property var modelData
                        objectName: "calendarDay-" + Qt.formatDateTime(modelData, "yyyy-MM-dd")
                        readonly property bool currentMonth: modelData.getMonth() === root.displayedMonth.getMonth()
                        readonly property bool isToday: root.sameDay(modelData, root.today)
                        readonly property bool selected: root.sameDay(modelData, root.selectedDate)
                        width: (dayGrid.width - 24) / 7
                        height: 32
                        radius: 10
                        color: selected ? Theme.accent : (Settings.hoverEnabled && mouse.containsMouse ? Theme.hover : "transparent")
                        border.width: isToday && !selected ? 1 : 0
                        border.color: Theme.accent
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            anchors.centerIn: parent
                            text: day.modelData.getDate()
                            color: day.selected ? Theme.onAccent : (day.currentMonth ? Theme.text : Theme.muted)
                            opacity: day.currentMonth || day.selected ? 1 : 0.55
                            font.family: Theme.font
                            font.pixelSize: 12
                            font.bold: day.isToday
                        }
                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: Settings.hoverEnabled
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectedDate = day.modelData
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: Qt.formatDateTime(root.selectedDate, "ddd, dd MMM yyyy")
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 11
                }
                Chip { objectName: "calendarToday"; label: "Today"; accent: Theme.accent; interactive: true; onClicked: root.showToday() }
            }
        }
    }
}
