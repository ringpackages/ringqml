load 'guilib.ring'
load 'ringQML.ring'

new qApp {

	win=new QQuickWidget(NULL){
		setminimumWidth(300)
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
    id: myRedBoxRoot
    width: 500
    height: 500
	color:"green"
	Text {
		id:myText 
		text :"Ring QML Is Loaded"
		font.pointSize:20
	}
   
}
`

