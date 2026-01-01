# --- MAIN QML FILE ---
func getqml
    return `
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 400
    height: 800
    color: "#000000"

    property bool isLandscape: width > height
    property real timeOffset: 0
    property var effectiveCurrentTime: new Date()
    // Explicitly use multiple fonts for better Arabic support
    property var cFontFamily: "Segoe UI, Tahoma, Arial" 
    property var backgroundImages: (typeof Ring !== "undefined") ? Ring.callFunc("getBgImages") : []
    property int currentImageIndex: 0
    property int nextPrayerIndex: 0
    property string timeToNextPrayer: "00:00:00"
    property real progressCurrentMinute: 0.0

    property var activePrayerListView: portraitLayout.visible ? prayerListView_p : prayerListView_l

    // --- Theme Manager ---
    QtObject {
        id: theme
        property int currentThemeIndex: 0
        property int baseFontSize: 18
        property var themes: [
            { name: "Dark", bgColor: "#0c1e31", textColor: "#ffffff", subduedTextColor: "#a0c0e0", accentColor: "#3498db", cardColor: "#152a4aCC", highlightCardColor: "#1f4a7cAA", shadowColor: "#90000000", filterOpacity: 0.85 },
            { name: "Light", bgColor: "#f0f2f5", textColor: "#2c3e50", subduedTextColor: "#7f8c8d", accentColor: "#2980b9", cardColor: "#ffffffCC", highlightCardColor: "#eaf5ffAA", shadowColor: "#30999999", filterOpacity: 0.70 },
            { name: "Sepia", bgColor: "#f4e9db", textColor: "#5b4636", subduedTextColor: "#8d7867", accentColor: "#8c5e3c", cardColor: "#faf3e9CC", highlightCardColor: "#e9dfd1AA", shadowColor: "#30776655", filterOpacity: 0.75 },
            { name: "Forest", bgColor: "#2c3e50", textColor: "#ecf0f1", subduedTextColor: "#bdc3c7", accentColor: "#27ae60", cardColor: "#34495eCC", highlightCardColor: "#41607eAA", shadowColor: "#90000000", filterOpacity: 0.85 }
        ]
        property var currentTheme: themes[currentThemeIndex]
        property color bgColor: currentTheme.bgColor
        property color textColor: currentTheme.textColor
        property color subduedTextColor: currentTheme.subduedTextColor
        property color accentColor: currentTheme.accentColor
        property color cardColor: currentTheme.cardColor
        property color highlightCardColor: currentTheme.highlightCardColor
        property color shadowColor: currentTheme.shadowColor

        function cycleTheme() { currentThemeIndex = (currentThemeIndex + 1) % themes.length; }
    }

    property var prayTimesFromRing: (typeof Ring !== "undefined") ? Ring.callFunc("getpraytimesforthiday") : ["04:00","04:30","06:00","12:30","15:45","18:15","19:45"]
    
    // SVG Data - simplified regex in IconShape handles these standard attributes
    property var prayerData: [
        { name: "الفجر الأول", time: prayTimesFromRing[0] || "04:00", icon: '<svg viewBox="0 0 24 24"><path d="M2 18h20m-10-4V3M5 14h14" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "الفجر الثاني", time: prayTimesFromRing[1] || "04:30", icon: '<svg viewBox="0 0 24 24"><path d="M2 18h20M5 14a7 7 0 0 1 14 0" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "الشروق", time: prayTimesFromRing[2] || "06:00", icon: '<svg viewBox="0 0 24 24"><path d="M2 18h20M12 14a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM12 2v4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "الظهر", time: prayTimesFromRing[3] || "12:30", icon: '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/><path d="M12 2V4M12 20V22M5.6 5.6L7 7M17 17L18.4 18.4M2 12H4M20 12H22M5.6 18.4L7 17M17 7L18.4 5.6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "العصر", time: prayTimesFromRing[4] || "03:45", icon: '<svg viewBox="0 0 24 24"><path d="M2 18h20M10 18v-8l-4 4" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/><circle cx="16" cy="6" r="2" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "المغرب", time: prayTimesFromRing[5] || "06:15", icon: '<svg viewBox="0 0 24 24"><path d="M12 18a4 4 0 0 0 0-8 4 4 0 0 0 0 8zM2 18h20M12 14V6" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' },
        { name: "العشاء", time: prayTimesFromRing[6] || "07:45", icon: '<svg viewBox="0 0 24 24"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/><path d="M18 5l-1 2-2-1 1-2 2 1zM15 8l-1 2-2-1 1-2 2 1z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>' }
    ]
    property string settingsIconSvg: '<svg viewBox="0 0 24 24"><path d="M19.4 12.6c.2-.5.2-1 0-1.5l-1.8-4.3c-.2-.5-.5-.8-.9-1l-4.3-1.8c-.5-.2-1-.2-1.5 0l-4.3 1.8c-.5.2-.8.5-1 .9l-1.8 4.3c-.2.5-.2 1 0 1.5l1.8 4.3c.2.5.5.8.9 1l4.3 1.8c.5.2 1 .2 1.5 0l4.3-1.8c.5-.2.8-.5 1-.9l1.8-4.3z" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/><circle cx="12" cy="12" r="3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" stroke="currentColor"/></svg>'

    function updateAllUI() {
        var formattedTime = formatCurrentTime(effectiveCurrentTime);
        var formattedDate = effectiveCurrentTime.toLocaleDateString("ar-SA", { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

        currentTimeText_p.text = formattedTime;
        dateText_p.text = formattedDate;
        currentTimeText_l.text = formattedTime;
        dateText_l.text = formattedDate;

        findNextPrayer(); 
        if (!activePrayerListView.model || activePrayerListView.count === 0) return;
        var trackedPrayer = activePrayerListView.model[activePrayerListView.currentIndex];
        if (trackedPrayer) {
            timeToNextPrayer = calculateTimeRemaining(trackedPrayer.time, activePrayerListView.currentIndex);
        }
        progressCurrentMinute = effectiveCurrentTime.getSeconds() / 60.0;
    }

    function formatCurrentTime(date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'م' : 'ص';
        hours = hours % 12;
        hours = hours ? hours : 12;
        minutes = minutes < 10 ? '0' + minutes : minutes;
        return hours + ':' + minutes + ' ' + ampm;
    }

    function findNextPrayer() {
        var now = effectiveCurrentTime;
        var totalCurrentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();
        var adjustedCurrentSeconds = totalCurrentSeconds + 3;

        for (var i = 0; i < prayerData.length; i++) {
            var timeParts = prayerData[i].time.split(":");
            var hour = parseInt(timeParts[0]);
            if (hour < 12 && i >= 4) { hour += 12; }
            var totalPrayerSeconds = hour * 3600 + parseInt(timeParts[1]) * 60;

            if (adjustedCurrentSeconds < totalPrayerSeconds) {
                if (nextPrayerIndex !== i) {
                    nextPrayerIndex = i;
                }
                if (activePrayerListView.currentIndex === (i > 0 ? i - 1 : prayerData.length - 1) && !scrollBackTimer.running) {
                    activePrayerListView.currentIndex = i;
                }
                return;
            }
        }
        if (nextPrayerIndex !== 0) {
            nextPrayerIndex = 0;
            if (activePrayerListView.currentIndex === prayerData.length - 1 && !scrollBackTimer.running) {
                 activePrayerListView.currentIndex = 0;
            }
        }
    }

    function calculateTimeRemaining(targetTime, prayerIndex) {
        var now = effectiveCurrentTime;
        var totalCurrentSeconds = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();
        var timeParts = targetTime.split(":");
        var hour = parseInt(timeParts[0]);
        if (hour < 12 && prayerIndex >= 4) { hour += 12; }
        var totalTargetSeconds = hour * 3600 + parseInt(timeParts[1]) * 60;
        var diffSeconds;
        if (totalCurrentSeconds <= totalTargetSeconds) {
            diffSeconds = totalTargetSeconds - totalCurrentSeconds;
        } else {
            var secondsInDay = 24 * 3600;
            diffSeconds = (secondsInDay - totalCurrentSeconds) + totalTargetSeconds;
        }
        var h = Math.floor(diffSeconds / 3600);
        var m = Math.floor((diffSeconds % 3600) / 60);
        var s = diffSeconds % 60;
        return (h < 10 ? "0" + h : h) + ":" + (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    Component.onCompleted: {
        if (typeof Ring !== "undefined") {
            var backendTimeStr = Ring.callFunc('time');
            var localTime = new Date();
            if (backendTimeStr && backendTimeStr.split(':').length === 3) {
                var parts = backendTimeStr.split(':');
                var backendTime = new Date();
                backendTime.setHours(parseInt(parts[0]), parseInt(parts[1]), parseInt(parts[2]), 0);
                timeOffset = backendTime.getTime() - localTime.getTime();
            }
        }
        updateAllUI();
        startupTimer.start();
    }

    SequentialAnimation {
        id: imageFadeAnimation
        NumberAnimation { target: backgroundImage; property: "opacity"; to: 0; duration: 300; easing.type: Easing.InOutQuad }
        ScriptAction { script: root.currentImageIndex = (root.currentImageIndex + 1) % (root.backgroundImages && root.backgroundImages.length ? root.backgroundImages.length : 1) }
        NumberAnimation { target: backgroundImage; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InOutQuad }
    }
    Timer { id: backgroundChangeTimer; interval: 10000; running: true; repeat: true; onTriggered: imageFadeAnimation.start() }
    Timer {
        id: startupTimer
        interval: 100
        onTriggered: {
            activePrayerListView.currentIndex = root.nextPrayerIndex;
            activePrayerListView.positionViewAtIndex(activePrayerListView.currentIndex, ListView.Center);
        }
    }
    Timer {
        id: masterClock; interval: 1000; running: true; repeat: true
        onTriggered: {
            var now = new Date();
            effectiveCurrentTime = new Date(now.getTime() + timeOffset);
            updateAllUI();
        }
    }
    Timer {
        id: scrollBackTimer
        interval: 3000
        onTriggered: {
            activePrayerListView.currentIndex = root.nextPrayerIndex
        }
    }

    Image {
        id: backgroundImage
        source: (root.backgroundImages && root.backgroundImages.length > 0) ? root.backgroundImages[root.currentImageIndex] : ""
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: 0
        onStatusChanged: {
            if (status === Image.Ready) {
                imageErrorFallback.visible = false;
                backgroundImage.opacity = 1;
            } else if (status === Image.Error) {
                imageErrorFallback.visible = true;
            }
        }
    }
    Rectangle { id: imageErrorFallback; anchors.fill: parent; color: "#1c1c1c"; visible: false }
    Rectangle {
        id: colorFilterOverlay
        anchors.fill: parent
        color: theme.bgColor
        opacity: theme.currentTheme.filterOpacity
        Behavior on color { ColorAnimation { duration: 300 } }
        Behavior on opacity { NumberAnimation { duration: 300 } }
    }

    states: [
        State {
            name: "portrait"
            when: !root.isLandscape
            PropertyChanges { target: portraitLayout; visible: true }
            PropertyChanges { target: landscapeLayout; visible: false }
        },
        State {
            name: "landscape"
            when: root.isLandscape
            PropertyChanges { target: portraitLayout; visible: false }
            PropertyChanges { target: landscapeLayout; visible: true }
        }
    ]

    ColumnLayout {
        id: portraitLayout
        anchors.fill: parent
        anchors.bottomMargin: 40
        spacing: 0
        visible: !root.isLandscape

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            
            IconShape {
                width: theme.baseFontSize + 6
                height: theme.baseFontSize + 6
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 20
                }
                svgString: root.settingsIconSvg
                iconColor: theme.textColor
                
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.isLandscape) settingsPopup.open(); else settingsDrawer.open(); } }
            }
            
            ColumnLayout {
                anchors.centerIn: parent; spacing: 4
                Text { text: "مواقيت الصلاة"; color: theme.textColor; font.pixelSize: theme.baseFontSize + 6; font.bold: true; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                Text { id: dateText_p; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                Text { id: currentTimeText_p; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize - 2; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
            }
        }

        Item {
            id: mainDisplay_p
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 220
            Layout.preferredHeight: 220
            property var currentModel: (activePrayerListView.model && activePrayerListView.count > 0) ? activePrayerListView.model[activePrayerListView.currentIndex] : null
            
            MinuteCircle { 
                anchors.centerIn: parent
                width: 220
                height: 220
                progress: root.progressCurrentMinute
                baseColor: Qt.lighter(theme.cardColor, 1.2)
                progressColor: theme.accentColor
            }
            
            ColumnLayout {
                anchors.centerIn: parent; spacing: 5
                width: parent.width * 0.8
                Text { text: activePrayerListView.currentIndex === root.nextPrayerIndex ? "الصلاة التالية" : "الصلاة المحددة"; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                Text { 
                    text: mainDisplay_p.currentModel ? mainDisplay_p.currentModel.name : ""
                    color: theme.textColor
                    font.pixelSize: theme.baseFontSize + 18
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 12
                    font.family: cFontFamily 
                }
                Text { text: timeToNextPrayer; color: theme.textColor; font.pixelSize: theme.baseFontSize + 4; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
            }
            MouseArea { anchors.fill: parent; onClicked: imageFadeAnimation.start() }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 120
                color: theme.highlightCardColor; radius: 20; border.color: Qt.lighter(theme.highlightCardColor, 1.5)
                Behavior on color { ColorAnimation { duration: 300 } }
            }
            ListView {
                id: prayerListView_p
                anchors.fill: parent; 
                model: prayerData; 
                
                delegate: PrayerDelegate {
                    // FIX: Rename property to 'prayerItem' to avoid binding loop with 'modelData'
                    prayerItem: modelData 
                    themeModel: theme
                    fontFamily: cFontFamily
                    isCurrentPrayer: index === activePrayerListView.currentIndex
                    isNextPrayer: index === root.nextPrayerIndex
                    timeToNextString: root.timeToNextPrayer
                    
                    onItemClicked: {
                        detailPopup.prayerModel = modelData;
                        detailPopup.timeRemaining = calculateTimeRemaining(modelData.time, index);
                        detailPopup.open();
                    }
                }

                orientation: ListView.Vertical; snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange; preferredHighlightBegin: (height / 2) - 50; preferredHighlightEnd: (height / 2) - 50
                boundsBehavior: Flickable.StopAtBounds
                Behavior on contentY { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                onCurrentIndexChanged: {
                    if (currentIndex !== root.nextPrayerIndex) {
                        scrollBackTimer.restart();
                    } else {
                        scrollBackTimer.stop();
                    }
                }
            }
        }
    }

    RowLayout {
        id: landscapeLayout
        anchors.fill: parent
        anchors.bottomMargin: 40
        spacing: 0
        visible: root.isLandscape

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width * 0.7
            Layout.fillHeight: true
            clip: true
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter; width: parent.width; height: 120
                color: theme.highlightCardColor; radius: 20; border.color: Qt.lighter(theme.highlightCardColor, 1.5)
                Behavior on color { ColorAnimation { duration: 300 } }
            }
            ListView {
                id: prayerListView_l
                anchors.fill: parent; model: prayerData; 
                
                delegate: PrayerDelegate {
                    // FIX: Rename property to 'prayerItem'
                    prayerItem: modelData
                    themeModel: theme
                    fontFamily: cFontFamily
                    isCurrentPrayer: index === activePrayerListView.currentIndex
                    isNextPrayer: index === root.nextPrayerIndex
                    timeToNextString: root.timeToNextPrayer
                    
                    onItemClicked: {
                        detailPopup.prayerModel = modelData;
                        detailPopup.timeRemaining = calculateTimeRemaining(modelData.time, index);
                        detailPopup.open();
                    }
                }
                
                orientation: ListView.Vertical; snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.StrictlyEnforceRange; preferredHighlightBegin: (height / 2) - 50; preferredHighlightEnd: (height / 2) - 50
                boundsBehavior: Flickable.StopAtBounds
                Behavior on contentY { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                onCurrentIndexChanged: {
                    if (currentIndex !== root.nextPrayerIndex) {
                        scrollBackTimer.restart();
                    } else {
                        scrollBackTimer.stop();
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                
                IconShape {
                    width: theme.baseFontSize + 6
                    height: theme.baseFontSize + 6
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: 20
                    }
                    svgString: root.settingsIconSvg
                    iconColor: theme.textColor
                    
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.isLandscape) settingsPopup.open(); else settingsDrawer.open(); } }
                }

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 4
                    Text { text: "مواقيت الصلاة"; color: theme.textColor; font.pixelSize: theme.baseFontSize + 6; font.bold: true; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                    Text { id: dateText_l; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                    Text { id: currentTimeText_l; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize - 2; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                }
            }
            Item {
                id: mainDisplay_l
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 220
                Layout.preferredHeight: 220
                property var currentModel: (activePrayerListView.model && activePrayerListView.count > 0) ? activePrayerListView.model[activePrayerListView.currentIndex] : null
                
                MinuteCircle { 
                    anchors.centerIn: parent
                    width: 220
                    height: 220
                    progress: root.progressCurrentMinute
                    baseColor: Qt.lighter(theme.cardColor, 1.2)
                    progressColor: theme.accentColor
                }
                
                ColumnLayout {
                    anchors.centerIn: parent; spacing: 5
                    width: parent.width * 0.8
                    Text { text: activePrayerListView.currentIndex === root.nextPrayerIndex ? "الصلاة التالية" : "الصلاة المحددة"; color: theme.subduedTextColor; font.pixelSize: theme.baseFontSize; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                    Text { 
                        text: mainDisplay_l.currentModel ? mainDisplay_l.currentModel.name : ""
                        color: theme.textColor
                        font.pixelSize: theme.baseFontSize + 18
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        fontSizeMode: Text.Fit
                        minimumPixelSize: 12
                        font.family: cFontFamily 
                    }
                    Text { text: timeToNextPrayer; color: theme.textColor; font.pixelSize: theme.baseFontSize + 4; Layout.alignment: Qt.AlignHCenter; font.family: cFontFamily }
                }
                MouseArea { anchors.fill: parent; onClicked: imageFadeAnimation.start() }
            }
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        text: "مواقيت الصلاة في مدينة الشرقاط وضواحيها\nلاتنسونا من صالح دعائكم"
        color: theme.subduedTextColor
        font.pixelSize: theme.baseFontSize - 6
        font.family: cFontFamily
        horizontalAlignment: Text.AlignHCenter
    }
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: mouse.accepted = false
        onPositionChanged: mouse.accepted = false
        onReleased: mouse.accepted = false
        onWheel: (wheel) => {
            activePrayerListView.flick(0, wheel.angleDelta.y * -1.2);
            wheel.accepted = true;
        }
    }

    Drawer {
        id: settingsDrawer
        width: root.width
        height: root.height * 0.6
        edge: Qt.BottomEdge
        background: Rectangle { 
            color: Qt.rgba(theme.bgColor.r, theme.bgColor.g, theme.bgColor.b, 0.85)
            border.color: "#50ffffff"
            border.width: 1
            radius: 15
        }
        
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.9
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 25
            layoutDirection: Qt.RightToLeft
            Text {
                text: "الإعدادات"
                color: theme.textColor
                font.pixelSize: theme.baseFontSize + 8
                font.bold: true
                font.family: cFontFamily
            }
            SettingsContent {
                Layout.fillWidth: true
                themeModel: theme
                fontFamily: cFontFamily
                onThemeClicked: theme.cycleTheme()
                onBackgroundClicked: imageFadeAnimation.start()
            }
        }
    }

    Popup {
        id: settingsPopup
        width: root.width
        height: root.height
        x: 0
        y: 0
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        padding: 0
        background: Rectangle { 
            color: Qt.rgba(theme.bgColor.r, theme.bgColor.g, theme.bgColor.b, 0.65)
            border.color: "#50ffffff"
            border.width: 1
        }
        
        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 25
            layoutDirection: Qt.RightToLeft
            
            RowLayout {
                layoutDirection: Qt.RightToLeft
                width: parent.width
                Text {
                    text: "الإعدادات"
                    color: theme.textColor
                    font.pixelSize: theme.baseFontSize + 8
                    font.bold: true
                    font.family: cFontFamily
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "X"
                    color: theme.subduedTextColor
                    font.pixelSize: theme.baseFontSize + 8
                    font.family: cFontFamily
                    font.bold: true
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsPopup.close()
                    }
                }
            }
            SettingsContent {
                Layout.fillWidth: true
                themeModel: theme
                fontFamily: cFontFamily
                onThemeClicked: theme.cycleTheme()
                onBackgroundClicked: imageFadeAnimation.start()
            }
        }
    }

    Popup {
        id: detailPopup
        x: (root.width - width) / 2
        y: (root.height - height) / 2
        width: root.width * 0.8
        height: 300
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnAnyPress
        padding: 0
        property var prayerModel: ({})
        property string timeRemaining: ""
        background: Rectangle {
            color: Qt.rgba(theme.bgColor.r, theme.bgColor.g, theme.bgColor.b, 0.85)
            radius: 15
            border.color: "#50ffffff"
            border.width: 1
        }
        Text {
            text: "X"
            color: theme.subduedTextColor
            font.pixelSize: theme.baseFontSize + 4
            font.family: cFontFamily
            font.bold: true
            anchors.top: parent.top
            anchors.right: parent.right
            padding: 15
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: detailPopup.close()
            }
        }
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 15
            Text {
                text: detailPopup.prayerModel.name ? detailPopup.prayerModel.name : ""
                color: theme.textColor
                font.pixelSize: theme.baseFontSize + 12
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                font.family: cFontFamily
            }
            Text {
                text: detailPopup.prayerModel.time ? "الوقت: " + detailPopup.prayerModel.time : ""
                color: theme.textColor
                font.pixelSize: theme.baseFontSize + 4
                Layout.alignment: Qt.AlignHCenter
                font.family: cFontFamily
            }
            Text {
                text: detailPopup.timeRemaining ? "الوقت المتبقي: " + detailPopup.timeRemaining : ""
                color: theme.subduedTextColor
                font.pixelSize: theme.baseFontSize
                Layout.alignment: Qt.AlignHCenter
                font.family: cFontFamily
            }
        }
    }
}
`