load "guilib.ring"
load "stdlibcore.ring"
load "ringQML.ring"

    OsCreateOpenFolder("snapshots_from_component")
    chdir("..") // Go back to main folder


new qApp {

    win = new QQuickView() {
        setWidth(500) 
        setHeight(600)
		setTitle("RingQML : "+substr(justfilename(filename()),'_',' '))
        
        oQML = new RingQML(win) {
            oSnapShotComponent=NewComponent("SnapShotComponent", getSnapShotComponent())
            loadContent(getMainQml())
        }

        show()
        
       
    }

    exec()
}

func teakeSnapShowNow nCounter
    ? "Ring: Button clicked. Counter is: " + nCounter
    cFileName = "snapshots_from_component/snapshot_" + nCounter + ".png" 
    cFileName2 = "snapshots_from_component/myCounter_" + nCounter + ".png" 
    oImage = oQML.TakeSnapshot("mySnapShotComponent")
    oImage2 = oQML.TakeSnapshot("myCounter")

    ? '================================='
    oImage.save(cFileName, "PNG", 80)
    ? "Ring: Saved successfully to " + cFileName
    ? '-------------------------------'
        
    oImage2.save(cFileName2, "PNG", 80)
    ? "Ring: Saved successfully to " + cFileName2
    
    
func getSnapShotComponent
    return `
    import QtQuick 2.15
    import QtQuick.Controls 2.15
    import QtQuick.Layouts 1.15

    Rectangle {
        id: root
       
        width: 320
        height: 300
        color: "#ffffff"
        radius: 15
        border.color: "#e0e0e0"
        border.width: 1
        
        property int counterValue: 0

        // High quality rendering
        layer.enabled: true 
        layer.smooth: true

        Timer {
            interval: 50 
            running: true  
            repeat: true   
            onTriggered: root.counterValue = root.counterValue + 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            // Header
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                color: "#f5f7fa"
                radius: 8
                border.color: "#dcdcdc"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "RingQML - Component"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: "#2980b9"
                }
            }

            // Counter Display
            Item {
                objectName:"myCounter"
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.centerIn: parent
                    text: root.counterValue
                    font.pixelSize: 64
                    font.bold: true
                    color: "#2c3e50"
                }
            }

            // Action Button
            Button {
                text: "Take Snapshot"
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                background: Rectangle {
                    color: parent.down ? "#1f618d" : "#2980b9"
                    radius: 8
                }

                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    // Call Ring function with the current counter value
                    Ring.callFunc("teakeSnapShowNow", [root.counterValue])
                }
            }
        }
    }
    `

func getMainQml
    return `
    import QtQuick 2.15
    import QtQuick.Controls 2.15
    import QtQuick.Layouts 1.15

    Rectangle {
        id: mainRoot
        width: 500
        height: 600
        color: "#444" // Dark background to see the widget better
        anchors.centerIn: parent

        SnapShotComponent {
            objectName: "mySnapShotComponent" 
            
            anchors.centerIn: parent
        }
    }
    `