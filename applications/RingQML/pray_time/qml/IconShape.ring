
# --- COMPONENT: ICON SHAPE ---
func getIconShapeComponent
return `
import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: shIcon
    property string svgString: ""
    property color iconColor: "white"

    // Helper function encapsulated within the component
    function extractSvgPaths(svgString) {
        if (!svgString) return [];
        var paths = [];
        // Simplified regex that handles standard path attributes
        var pathReg = /d\s*=\s*"([^"]+)"/g;
        var match;
        while ((match = pathReg.exec(svgString)) !== null) {
            paths.push({d: match[1]});
        }
        var circleReg = /cx\s*=\s*"([\d\.]+)"\s+cy\s*=\s*"([\d\.]+)"\s+r\s*=\s*"([\d\.]+)"/g;
        while ((match = circleReg.exec(svgString)) !== null) {
             var cx = parseFloat(match[1]);
             var cy = parseFloat(match[2]);
             var r = parseFloat(match[3]);
             var d = "M " + (cx - r) + " " + cy + 
                     " A " + r + " " + r + " 0 1 0 " + (cx + r) + " " + cy + 
                     " A " + r + " " + r + " 0 1 0 " + (cx - r) + " " + cy + " Z";
             paths.push({d: d});
        }
        return paths;
    }

    property var paths: extractSvgPaths(svgString)
    
    Shape {
        width: 24; height: 24
        anchors.centerIn: parent
        // Scale to fit the parent container
        scale: Math.min(shIcon.width/24, shIcon.height/24)
        
        ShapePath {
            strokeWidth: 2
            strokeColor: shIcon.iconColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: (shIcon.paths.length > 0) ? shIcon.paths[0].d : "" }
        }
        ShapePath {
            strokeWidth: 2
            strokeColor: shIcon.iconColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: (shIcon.paths.length > 1) ? shIcon.paths[1].d : "" }
        }
    }
}
`