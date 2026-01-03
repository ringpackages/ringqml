load 'stdlibcore.ring'
load 'guilib.ring'
load 'ringQML.ring'
cFileName = substr(currentdir(),'\','/')+'/'+filename()
aSamplesFiles = listallFiles(substr(currentdir(),'\','/'),'*.ring') 
aSamplesData  = []
del(aSamplesFiles, find(aSamplesFiles,cFileName))

oProcess = new QProcess(Null){
	setreadyReadStandardOutputEvent('updateConsoleOut()')
}
nTClock_fillaSamplesData = clock()
	fillaSamplesData()

new qApp {

	oQuick = new QQuickView(){
		setWidth(400) setHeight(600)
		oQML = new RingQML(self){
			loadContent(getMain())	
		}
		oQml.root.appendLog(nl+"Ring : aSamplesData filled in ("+(((clock()-nTClock_fillaSamplesData)/clockspersecond()))+') seconds.'+nl)

		show()
	}
	exec()
}

func fillaSamplesData
	for file in aSamplesFiles
		cSampleText = justfilename(file) 
		cSampleText = substr(cSampleText,'.ring','')
		cSampleText = substr(cSampleText,'-',' ')
		cSampleText = substr(cSampleText,'_',' ')
		if numorZero(cSampleText[4])
			cSampleText=substr(cSampleText,5)
		ok

		aSamplesData+ [cSampleText ,file]
	next 

func updateConsoleOut
	cOutput =oProcess.readAllStandardOutput().data()
	if cOutput = nl return ok

	oQml.root.appendLog(cOutput)
	
	if substr(lower(cOutput),'error')
		oQml.root.forceStop()
		StopSample()
	ok 
func StopSample
	oProcess.terminate() 
	cSampleName = aSamplesData[find(aSamplesData,oProcess.arguments().at(0),2)][1]
	oQML.root.appendLog("Sample : '"+cSampleName+"' - Exit with code : "+oProcess.exitCode() )
func runSample cFile
	oProcess.start(exefilename(),new qstringlist(){append(cFile)},3)
func getMain
return `

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    width: 800
    height: 600
    color: "#1e1e2e" // Deep dark background
    
    // ---------------------------------------------------------
    // Data Source
    // ---------------------------------------------------------
    property var aSamplesData: Ring.getVar('aSamplesData') ? Ring.getVar('aSamplesData'): [
        ["Physics Engine Test", "/usr/bin/samples/physics_v2"],
        ["Ray Tracing Demo", "/usr/bin/samples/rt_demo"],
        ["Network Packet Analyzer", "/opt/net_tool/analyzer"],
        ["3D Mesh Viewer", "/usr/local/bin/mesh_view"],
        ["Audio Synthesizer", "/bin/audio_synth"],
        ["Particle System", "/bin/particles"]
    ]

    // ---------------------------------------------------------
    // Filter Logic
    // ---------------------------------------------------------
    property string filterText: ""
    property var _filteredIndices: {
        var indices = [];
        var lowerFilter = filterText.toLowerCase();
        if (aSamplesData) {
            for (var i = 0; i < aSamplesData.length; i++) {
                if (aSamplesData[i][0].toLowerCase().indexOf(lowerFilter) !== -1) {
                    indices.push(i);
                }
            }
        }
        return indices;
    }
    property var _filteredNames: {
        var names = [];
        for (var i = 0; i < _filteredIndices.length; i++) {
            names.push(aSamplesData[_filteredIndices[i]][0]);
        }
        return names;
    }

    // ---------------------------------------------------------
    // State Properties
    // ---------------------------------------------------------
    property int currentIndex: 0
    property bool isRunning: false
    property string consoleLog: "System Ready.\nSelect a sample to begin."

    // ---------------------------------------------------------
    // Functions
    // ---------------------------------------------------------
    
    // Called by the "Run" button
    function runSample() {
        if (!root.isRunning) {
            // Safety check: Ensure index is valid
            if (currentIndex >= 0 && currentIndex < aSamplesData.length) {
                root.isRunning = true;
                
                var path = aSamplesData[root.currentIndex][1];
                var name = aSamplesData[root.currentIndex][0];
                
                appendLog("------------------------------------------------");
                appendLog("Executing: " + path);
                appendLog("Running " + name + "...");
                
                Ring.callFunc('runSample', [path]);
            }
        }
    }

    // Called by the "Stop" button (User Action)
    function stopSample() {
        if (isRunning) {
            isRunning = false;
            // Tell Ring to kill the process
            Ring.callFunc("StopSample");
        }
    }

    // NEW: Called by Ring when it detects an Error or Exit (System Action)
    // This updates the UI state WITHOUT calling Ring back, preventing loops.
    function forceStop() {
        if (isRunning) {
            isRunning = false;
            appendLog(">> Status: Stopped by System/Error detection.");
        }
    }

    function clearOutPut(){
        consoleLog = "";
    }

    function appendLog(msg) {
        if (consoleLog.length > 2000) consoleLog = consoleLog.substring(consoleLog.length - 1500);
        var timestamp = new Date().toLocaleTimeString();
        consoleLog += "[" + timestamp + "] " + msg + "\n";
    }

    // Navigation Helper Functions
    function nextSample() {
        if (_filteredIndices.length === 0) return;
        var currentFilteredIndex = _filteredIndices.indexOf(currentIndex);
        var nextFiltered = currentFilteredIndex + 1;
        if (nextFiltered >= _filteredIndices.length) nextFiltered = 0;
        currentIndex = _filteredIndices[nextFiltered];
    }

    function prevSample() {
        if (_filteredIndices.length === 0) return;
        var currentFilteredIndex = _filteredIndices.indexOf(currentIndex);
        var prevFiltered = currentFilteredIndex - 1;
        if (prevFiltered < 0) prevFiltered = _filteredIndices.length - 1;
        currentIndex = _filteredIndices[prevFiltered];
    }

    // ---------------------------------------------------------
    // UI Layout
    // ---------------------------------------------------------
    Rectangle {
        id: header
        width: parent.width
        height: 60
        color: "#282a36"
        z: 10

        Text {
            anchors.centerIn: parent
            text: "RingQML Sample Runner"
            color: "#f8f8f2"
            font.pixelSize: 24
            font.bold: true
            font.family: "Segoe UI"
        }

        Rectangle {
            width: parent.width
            height: 1
            color: "#44475a"
            anchors.bottom: parent.bottom
        }
    }

    ColumnLayout {
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 20

        // 2. Visualization / Console Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#282a36"
            radius: 8
            
            border.color: isRunning ? "#50fa7b" : "#44475a"
            border.width: isRunning ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: 300 } }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                width: 80
                height: 24
                radius: 4
                color: isRunning ? "#50fa7b" : "#ff5555"
                Behavior on color { ColorAnimation { duration: 300 } }
                
                Text {
                    anchors.centerIn: parent
                    text: isRunning ? "RUNNING" : "STOPPED"
                    color: "#282a36"
                    font.bold: true
                    font.pixelSize: 10
                }
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: 15
                
                TextArea {
                    id: logArea
                    text: consoleLog
                    color: "#f8f8f2"
                    font.family: "Courier New"
                    font.pixelSize: 14
                    readOnly: true
                    background: null
                    selectByMouse: true
                    wrapMode: Text.Wrap
                    
                    // Auto-scroll logic
                    onTextChanged: {
                        cursorPosition = length
                    }
                }
            }
        }

        // 3. Search Bar
        TextField {
            id: searchField
            Layout.fillWidth: true
            Layout.preferredHeight: 45
            placeholderText: "Type to list matching samples..."
            font.pixelSize: 16
            color: "#f8f8f2"
            leftPadding: 15
            text: filterText
            
            onTextChanged: {
                filterText = text
                if (text.length > 0 && _filteredNames.length > 0) {
                    if (!sampleCombo.popup.visible) sampleCombo.popup.open()
                } else if (text.length === 0) {
                    sampleCombo.popup.close()
                }
            }

            background: Rectangle {
                color: searchField.activeFocus ? "#363948" : "#282a36"
                radius: 6
                border.color: searchField.activeFocus ? "#bd93f9" : (searchField.hovered ? "#6272a4" : "#44475a")
                border.width: searchField.activeFocus ? 2 : 1
                Behavior on border.color { ColorAnimation { duration: 200 } }
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            RoundButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10
                width: 30
                height: 30
                visible: searchField.text.length > 0
                text: "X"
                background: Rectangle {
                    radius: 15
                    color: parent.down ? "#ff5555" : "#44475a"
                }
                contentItem: Text {
                    text: "×"
                    color: "white"
                    font.pixelSize: 20
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -2
                }
                onClicked: {
                    searchField.text = ""
                    searchField.forceActiveFocus()
                }
            }
        }

        // 4. Selection Controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                id: prevBtn
                text: "<"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                hoverEnabled: true
                enabled: !isRunning // Disable navigation while running
                onClicked: prevSample()

                scale: down ? 0.95 : (hovered ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }
                
                background: Rectangle {
                    color: prevBtn.down ? "#bd93f9" : (prevBtn.hovered ? "#6272a4" : "#44475a")
                    opacity: parent.enabled ? 1.0 : 0.5
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }

            ComboBox {
                id: sampleCombo
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                model: _filteredNames
                currentIndex: _filteredIndices.indexOf(root.currentIndex)
                hoverEnabled: true
                enabled: !isRunning // Disable selection while running
                
                onActivated: {
                    if (index >= 0 && index < _filteredIndices.length) {
                        root.currentIndex = _filteredIndices[index];
                    }
                }

                delegate: ItemDelegate {
                    width: sampleCombo.width
                    hoverEnabled: true
                    contentItem: Text {
                        text: modelData
                        color: "#f8f8f2"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.highlighted ? "#6272a4" : (parent.hovered ? "#50536b" : "#282a36")
                    }
                }

                contentItem: Text {
                    leftPadding: 10
                    rightPadding: sampleCombo.indicator.width + sampleCombo.spacing
                    text: sampleCombo.displayText
                    font: sampleCombo.font
                    color: parent.enabled ? "#f8f8f2" : "#888888"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    color: sampleCombo.hovered ? "#52556a" : "#44475a"
                    radius: 4
                    border.color: sampleCombo.activeFocus ? "#bd93f9" : "#44475a"
                    border.width: 1
                }
                
                popup: Popup {
                    y: sampleCombo.height - 1
                    width: sampleCombo.width
                    implicitHeight: Math.min(contentItem.implicitHeight, 300)
                    padding: 1
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: sampleCombo.popup.visible ? sampleCombo.delegateModel : null
                        currentIndex: sampleCombo.highlightedIndex
                        ScrollIndicator.vertical: ScrollIndicator { }
                    }
                    background: Rectangle {
                        border.color: "#6272a4"
                        color: "#282a36"
                        radius: 4
                    }
                }
            }

            Button {
                id: nextBtn
                text: ">"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                hoverEnabled: true
                enabled: !isRunning
                onClicked: nextSample()
                // ... same styling ...
                background: Rectangle {
                    color: nextBtn.down ? "#bd93f9" : (nextBtn.hovered ? "#6272a4" : "#44475a")
                    opacity: parent.enabled ? 1.0 : 0.5
                    radius: 4
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                }
            }
        }

        // 5. Action Buttons (Run / Stop)
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Button {
                id: runBtn
                text: "Run Sample"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                enabled: !isRunning
                hoverEnabled: true
                onClicked: runSample()

                scale: down ? 0.98 : (hovered ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }

                background: Rectangle {
                    radius: 6
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: runBtn.enabled ? "#50fa7b" : "#44475a" }
                        GradientStop { position: 1.0; color: runBtn.enabled ? "#40ca6b" : "#343746" }
                    }
                    opacity: parent.enabled ? 1.0 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                contentItem: Text {
                    text: parent.text
                    font.bold: true
                    font.pixelSize: 16
                    color: parent.enabled ? "#282a36" : "#aaaaaa"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: stopBtn
                text: "Stop"
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                enabled: isRunning
                hoverEnabled: true
                onClicked: stopSample()

                scale: down ? 0.98 : (hovered ? 1.02 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }

                background: Rectangle {
                    radius: 6
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: stopBtn.enabled ? "#ff5555" : "#44475a" }
                        GradientStop { position: 1.0; color: stopBtn.enabled ? "#ff4444" : "#343746" }
                    }
                    opacity: parent.enabled ? 1.0 : 0.5
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                contentItem: Text {
                    text: parent.text
                    font.bold: true
                    font.pixelSize: 16
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

`

