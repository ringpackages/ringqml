# Sample 12.4: Hierarchical Data with Expandable Lists
# Use case: Tree-like data structures


	load 'guilib.ring'
	load 'stdlibcore.ring'
	load 'ringqmL.ring'

	new qApp {
	    oQML = new RingQML(NULL) {
	        loadContent(QML_12_4())
	    }
	    exec()
	}
	
	func QML_12_4
	    return "
	        import QtQuick 2.15
	        import QtQuick.Controls 2.15
	        import QtQuick.Window 2.15
	        
	        Window {
	            visible: true
	            width: 400
	            height: 500
	            title: 'File Explorer'
	            
	            component FolderItem: Column {
	                id: folderItem
	                width: parent.width
	                
	                property string folderName: 'Folder'
	                property string folderIcon: '📁'
	                property int itemCount: 0
	                property bool isExpanded: false
	                
	                Rectangle {
	                    width: parent.width
	                    height: 50
	                    color: folderMouse.containsMouse ? '#ecf0f1' : 'white'
	                    
	                    Row {
	                        anchors.fill: parent
	                        anchors.leftMargin: 15
	                        spacing: 10
	                        
	                        Text {
	                            text: folderItem.isExpanded ? '▼' : '▶'
	                            font.pointSize: 10
	                            anchors.verticalCenter: parent.verticalCenter
	                            color: '#7f8c8d'
	                        }
	                        
	                        Text {
	                            text: folderItem.folderIcon
	                            font.pointSize: 20
	                            anchors.verticalCenter: parent.verticalCenter
	                        }
	                        
	                        Column {
	                            anchors.verticalCenter: parent.verticalCenter
	                            spacing: 2
	                            
	                            Text {
	                                text: folderItem.folderName
	                                font.pointSize: 12
	                                font.bold: true
	                            }
	                            
	                            Text {
	                                text: folderItem.itemCount + ' items'
	                                font.pointSize: 9
	                                color: '#95a5a6'
	                            }
	                        }
	                    }
	                    
	                    MouseArea {
	                        id: folderMouse
	                        anchors.fill: parent
	                        hoverEnabled: true
	                        cursorShape: Qt.PointingHandCursor
	                        onClicked: {
	                            folderItem.isExpanded = !folderItem.isExpanded
	                        }
	                    }
	                }
	                
	                Column {
	                    width: parent.width
	                    visible: folderItem.isExpanded
	                    
	                    Repeater {
	                        model: Math.min(folderItem.itemCount, 5)
	                        
	                        Rectangle {
	                            width: folderItem.width
	                            height: 40
	                            color: index % 2 === 0 ? '#fafafa' : 'white'
	                            
	                            Row {
	                                anchors.fill: parent
	                                anchors.leftMargin: 60
	                                spacing: 10
	                                
	                                Text {
	                                    text: '📄'
	                                    font.pointSize: 14
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                                
	                                Text {
	                                    text: 'File_' + (index + 1) + '.txt'
	                                    font.pointSize: 10
	                                    anchors.verticalCenter: parent.verticalCenter
	                                }
	                            }
	                        }
	                    }
	                    
	                    Rectangle {
	                        width: parent.width
	                        height: 30
	                        color: '#ecf0f1'
	                        visible: folderItem.itemCount > 5
	                        
	                        Text {
	                            text: '... and ' + (folderItem.itemCount - 5) + ' more'
	                            font.pointSize: 9
	                            color: '#7f8c8d'
	                            anchors.centerIn: parent
	                        }
	                    }
	                }
	                
	                Rectangle {
	                    width: parent.width
	                    height: 1
	                    color: '#ecf0f1'
	                }
	            }
	            
	            Column {
	                anchors.fill: parent
	                
	                Rectangle {
	                    width: parent.width
	                    height: 50
	                    color: '#34495e'
	                    
	                    Text {
	                        text: '📁 File Explorer'
	                        color: 'white'
	                        font.pointSize: 14
	                        font.bold: true
	                        anchors.centerIn: parent
	                    }
	                }
	                
	                ScrollView {
	                    width: parent.width
	                    height: parent.height - 50
	                    clip: true
	                    
	                    Column {
	                        width: parent.width
	                        
	                        FolderItem {
	                            folderName: 'Documents'
	                            folderIcon: '📄'
	                            itemCount: 12
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Pictures'
	                            folderIcon: '🖼'
	                            itemCount: 256
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Videos'
	                            folderIcon: '🎬'
	                            itemCount: 43
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Music'
	                            folderIcon: '🎵'
	                            itemCount: 1024
	                        }
	                        
	                        FolderItem {
	                            folderName: 'Downloads'
	                            folderIcon: '⬇'
	                            itemCount: 87
	                        }
	                    }
	                }
	            }
	        }
	    "
	
	#--> Expandable/collapsible list sections
	#--> Hierarchical data display
	#--> State management with isExpanded property