import SceneKit
import SwiftyUtils

enum BefungeNodeGenerator {
    private static var textureCache: [String: UIImage] = [:]

    static let background = UIColor.black
    static let foreground = UIColor.white

    static func texture(for instruction: String) -> UIImage {
        if let cached = textureCache[instruction] {
            return cached
        }

        let size = 500
        let textSize = 400
        let offset = (size - textSize) / 2

        let fontSize = fontSizeThatFits(size: CGSize(width: textSize, height: textSize), text: instruction as NSString, font: UIFont.monospacedSystemFont(ofSize: 0, weight: .regular))
        UIGraphicsBeginImageContext(CGSize(width: size, height: size))
        background.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size, height: size))
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        (instruction as NSString).draw(in: CGRect(x: offset, y: offset, width: textSize, height: textSize), withAttributes: [
            .font: UIFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            .foregroundColor: foreground,
            .paragraphStyle: paraStyle
        ])
        let context = UIGraphicsGetCurrentContext()!
        context.scaleBy(x: -1, y: 1)
        context.translateBy(x: -size.f, y: 0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!.flipImage()!
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