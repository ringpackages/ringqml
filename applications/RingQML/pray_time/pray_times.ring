# Load necessary libraries
    load "guilib.ring"
    load "ringQML.ring"
# load Pray Time Table
    load 'getTimesFromTables.ring'
# load QML Components
    load 'qml/main.ring'
    load 'qml/IconShape.ring'
    load 'qml/MinuteCircle.ring'
    load 'qml/SettingsContent.ring'
    load 'qml/PrayerDelegate.ring'

new qApp {
    oQuick = new qQuickview() {
        setWidth(400)
        setHeight(800)
        setTitle('Pray Times')
        
        oQml = new RingQML(self) {
            # Register components (IconShape first as others use it)
            NewComponent("IconShape", getIconShapeComponent())
            NewComponent("MinuteCircle", getMinuteCircleComponent())
            NewComponent("SettingsContent", getSettingsContentComponent())
            NewComponent("PrayerDelegate", getPrayerDelegate_component())
        }

        # Load the main QML
        oQML.loadContent(getqml())
        show()
    }
    exec()
}

func getBgImages
    return [
        'images/1.jpg',
        'images/2.jpg',
        'images/3.jpg',
        'images/4.jpg',
        'images/5.jpg'
    ]

func getpraytimesforthiday
    return getThisDayPrayTimeList()
