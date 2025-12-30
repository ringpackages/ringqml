load 'guilib.ring'
load 'ringQML.ring'
load 'stdlibcore.ring'
myVar=''
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
func ShowMyVar
	see 'ShowMyVar : '
	if islist(myVar) ? list2code(myVar) return ok 
	? myVar

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
			text:"Set myVar to number"
			onClicked:{
				Ring.setVar("myVar",100)
				console.log("myVar :",Ring.getVar('myVar'))
				Ring.callFunc("ShowMyVar")
			}
		}
		Button {
			id:myBtn2
			text:"Set myVar to string"
			onClicked:{
				Ring.setVar("myVar","My Var String")
				console.log("myVar :",Ring.getVar('myVar'))
				Ring.callFunc("ShowMyVar")
			}
		}

		Button {
			id:myBtn3
			text:"Set myVar to list"
			onClicked:{
				Ring.setVar("myVar",[1,2,3,4,5,6])
				console.log("myVar :",Ring.getVar('myVar'))
				Ring.callFunc("ShowMyVar")
			}
		}

		Button {
			id:myBtn4
			text:"Set myVar to JS Object (Ring Table)"
			onClicked:{
				Ring.setVar("myVar",{name:"my var",type:"JSObject"})
				console.log("myVar :",Ring.getVar('myVar'))
				Ring.callFunc("ShowMyVar")
			}
		}

		Button {
			id:myBtn5
			text:"Set myVar to pointer"
			onClicked:{
				Ring.setVar("myVar",myBtn5)
				console.log("myVar :",Ring.getVar('myVar'))
				Ring.callFunc("ShowMyVar")
			}
		}
	}
}
`

