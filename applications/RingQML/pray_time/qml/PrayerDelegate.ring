# --- PRAYER DELEGATE ---
func getPrayerDelegate_component
return `
import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: delegateRoot
    
    // FIX: Renamed 'modelData' to 'prayerItem' to avoid binding loop
    property var prayerItem: ({ "name": "", "time": "", "icon": "" })
    property int index
    
    property var themeModel: ({ "textColor": "#ffffff", "subduedTextColor": "#aaaaaa", "accentColor": "#00ff00", "baseFontSize": 18 })
    property string fontFamily: "Segoe UI" 
    property bool isCurrentPrayer: false
    property bool isNextPrayer: false
    property string timeToNextString: ""

    signal itemClicked()

    width: ListView.view ? ListView.view.width * 0.9 : 300
    height: 100
    x: ListView.view ? (ListView.view.width - width) / 2 : 0

    property real distanceFromCenter: ListView.view ? Math.abs(ListView.view.height / 2 - (y - ListView.view.contentY + height / 2)) : 0
    property real listViewHeight: ListView.view ? ListView.view.height : 800
    
    scale: 1.0 - (distanceFromCenter / (listViewHeight / 2)) * 0.3
    opacity: 1.0 - (distanceFromCenter / (listViewHeight / 2)) * 0.5
    
    transform: Rotation {
        origin.x: delegateRoot.width / 2
        origin.y: delegateRoot.height / 2
        axis { x: 1; y: 0; z: 0 }
        angle: ListView.view ? (y - ListView.view.contentY - ListView.view.height/2 + height/2) / 12 : 0
    }

    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on transform { RotationAnimation { duration: 150; easing.type: Easing.OutCubic } }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: delegateRoot.itemClicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 15

        IconShape {
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignVCenter
            
            // Check for prayerItem existence
            svgString: (prayerItem && prayerItem.icon) ? prayerItem.icon : ""
            iconColor: delegateRoot.ListView.isCurrentItem ? themeModel.accentColor : themeModel.subduedTextColor
            width: 40
            height: 40
        }

        Text {
            // Check for prayerItem existence
            text: (prayerItem && prayerItem.name) ? prayerItem.name : ""
            color: themeModel.textColor
            font.bold: true
            font.pixelSize: themeModel.baseFontSize + 4
            Layout.alignment: Qt.AlignHCenter
            font.family: delegateRoot.fontFamily
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
            text: (isCurrentPrayer && isNextPrayer) ? timeToNextString : ((prayerItem && prayerItem.time) ? prayerItem.time : "")
            color: isCurrentPrayer ? themeModel.accentColor : themeModel.subduedTextColor
            font.bold: isCurrentPrayer
            font.pixelSize: themeModel.baseFontSize + 2
            font.family: delegateRoot.fontFamily
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
`