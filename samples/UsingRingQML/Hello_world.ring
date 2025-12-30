load 'guilib.ring'
load 'stdlibcore.ring'
load 'ringQML.ring'

new qApp {

	win=new QQuickView(){
		setWidth(500) setHeight(600)
		setTitle("RingQML : "+substr(justfilename(filename()),'_',' '))
		oQML = new RingQML(win){
			loadContent(getMainQml())
		}

		show()
	}

	exec()
}

func getMainQml
return `

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 500
    height: 500
	color:"transparent"
	anchors.centerIn:parent
	Text {
		id:myText 
		anchors.fill: parent
		horizontalAlignment: Text.AlignHCenter
		text :"Hello World"
		font.pointSize:40
	}
   
}
`

