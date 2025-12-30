load 'guilib.ring'
load 'ringQML.ring'

new qApp {
    oQML = new RingQML(NULL) {
        loadContent(getMainQml())
    }
    exec()
}

func getMainQml
    return "
        import QtQuick 2.15
        import QtQuick.Controls 2.15
        import QtQuick.Window 2.15
            
        Window {
            visible: true
            width: 400
            height: 400
            title: 'Ring QML Loaded'
            
            Rectangle { 
                anchors.fill: parent;
                id: myRedBoxRoot
                width: 500
                height: 500
                color: 'green'
                
                Text {
                    id: myText 
                    text: 'Ring QML Is Loaded'
                    font.pointSize: 20
                }
            }
        }
    "