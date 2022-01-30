import SceneKit
import SwiftyUtils

enum BefungeNodeGenerator {
    private static var textureCache: [String: UIImage] = [:]

    static let background = UIColor.black
    static let foreground = UIColor.white

    private static func imageFromText(_ string: String, size: CGSize, inset: CGFloat, font: UIFont, background: UIColor, foreground: UIColor) -> UIImage {
        let textSize = CGSize(width: size.width - inset * 2, height: size.height - inset * 2)
        let fontSize = fontSizeThatFits(size: textSize, text: string as NSString, font: font)
        UIGraphicsBeginImageContext(size)
        background.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        (string as NSString).draw(in: CGRect(x: inset, y: inset, width: textSize.width, height: textSize.height), withAttributes: [
            .font: font.withSize(fontSize),
            .foregroundColor: foreground,
            .paragraphStyle: paraStyle
        ])
        let context = UIGraphicsGetCurrentContext()!
        context.scaleBy(x: -1, y: 1)
        context.translateBy(x: -size.width, y: 0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        return image
    }

    static func texture(for instruction: String) -> UIImage {
        if let cached = textureCache[instruction] {
            return cached
        }

        let image = imageFromText(
                instruction,
                size: CGSize(width: 500, height: 500),
                inset: 50,
                font: UIFont.monospacedSystemFont(ofSize: 0, weight: .regular),
                background: background,
                foreground: foreground).flipImage()!
        textureCache[instruction] = image
        return image
    }

    static func materials(for instruction: String) -> [SCNMaterial] {
        let topFace = texture(for: instruction)
        let topFaceMaterial = SCNMaterial()
        topFaceMaterial.diffuse.contents = topFace
        topFaceMaterial.specular.contents = UIColor.white
        topFaceMaterial.shininess = 1
        let bottomFaceMaterial = SCNMaterial()
        bottomFaceMaterial.diffuse.contents = background
        bottomFaceMaterial.specular.contents = UIColor.white
        bottomFaceMaterial.shininess = 1
        return [bottomFaceMaterial, topFaceMaterial, bottomFaceMaterial]
    }

    static let befungeNodeSize = 0.9.f
    private static let befungeNodeHeight = 0.5.f

    static func node(for instruction: String) -> SCNNode {
        let geometry = SCNCylinder(radius: befungeNodeSize / 2, height: befungeNodeHeight)
        geometry.radialSegmentCount = 20
        geometry.materials = materials(for: instruction)
        let node = SCNNode(geometry: geometry)
        node.pivot = SCNMatrix4MakeTranslation(0, -Float(befungeNodeHeight / 2), 0)
        node.eulerAngles.y = .pi / 2
        return node
    }
    
    
    
    static func instructionPointerNode() -> SCNNode {
        let path = UIBezierPath()
        let halfNodeSize = befungeNodeSize / 2
        let thirdNodeSize = befungeNodeSize / 3
        path.move(to: CGPoint(x: 0, y: halfNodeSize))
        path.addLine(to: CGPoint(x: -halfNodeSize, y: 0))
        path.addLine(to: CGPoint(x: -halfNodeSize + thirdNodeSize, y: 0))
        path.addLine(to: CGPoint(x: -halfNodeSize + thirdNodeSize, y: -halfNodeSize))
        path.addLine(to: CGPoint(x: -halfNodeSize + 2 * thirdNodeSize, y: -halfNodeSize))
        path.addLine(to: CGPoint(x: -halfNodeSize + 2 * thirdNodeSize, y: 0))
        path.addLine(to: CGPoint(x: halfNodeSize, y: 0))
        path.addLine(to: CGPoint(x: 0, y: halfNodeSize))
        path.close()
        let geometry = SCNShape(path: path, extrusionDepth: befungeNodeHeight)
        geometry.chamferRadius = befungeNodeSize / 5
        let node = SCNNode(geometry: geometry)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        node.geometry?.firstMaterial = material
        node.eulerAngles.x = .pi / 2
        
        return node
    }
}

extension UIImage {
    func flipImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let bitmap = UIGraphicsGetCurrentContext()!

        bitmap.translateBy(x: size.width / 2, y: size.height / 2)
        bitmap.scaleBy(x: -1.0, y: -1.0)

        bitmap.translateBy(x: -size.width / 2, y: -size.height / 2)
        bitmap.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
