load 'guilib.ring'
load 'ringQML.ring'

new qApp {

	win=new QQuickView(){
		setWidth(300)
		oQML = new RingQML(win){

			loadContent(getMainQml())
		}

		show()
	}

	exec()
}

func mytestFunc p1,p2 
	? 'p1 : '+p1
	? 'p2 : '+p2
	? 'mytestFunc : Hi :D...'
	? '-----------------'
func getMainQml
return `

import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: myRedBoxRoot
    width: 500
    height: 500
	color:"green"
	Column {
		spacing:20
		Text {
			id:myText 
			text :"Ring QML Is Loaded"
			font.pointSize:20
		}
		Button {
			id:myBtn
			text:"Click Me"
			onClicked:{
				Ring.callFunc("mytestFunc",["test 1","test 2"])
			}
		}
	}
}
`

