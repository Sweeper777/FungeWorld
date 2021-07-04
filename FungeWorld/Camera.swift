import SceneKit

class FungeWorldCamera {
    enum Orientation {
        case horizontal, vertical
    }

    private let cameraNode: SCNNode
    private let xRange: ClosedRange<Float>
    private let yRange: ClosedRange<Float>
    private let zRange: ClosedRange<Float>
    private let zoomRange: ClosedRange<CGFloat> = 30...90
    private (set)var orientation = Orientation.vertical

    var zoom: CGFloat {
        get {
            cameraNode.camera!.fieldOfView
        }
        set {
            cameraNode.camera!.fieldOfView = newValue
            cameraNode.camera!.fieldOfView = zoomRange.clamp(cameraNode.camera!.fieldOfView)
        }
    }

    init(cameraNode: SCNNode, xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) {
        self.cameraNode = cameraNode
        self.xRange = xRange
        self.yRange = yRange
        self.zRange = zRange
    }

    func move(dx: Float, dy: Float) {
        cameraNode.position.x += dx
        cameraNode.position.x = xRange.clamp(cameraNode.position.x)
        switch orientation {
        case .vertical:
            cameraNode.position.z += dy
            cameraNode.position.z = zRange.clamp(cameraNode.position.z)
        case .horizontal:
            cameraNode.position.y -= dy
            cameraNode.position.y = yRange.clamp(cameraNode.position.y)
        }
    }

    func toggleOrientation() {
        SCNTransaction.animationDuration = 0.5
        SCNTransaction.begin()
        switch orientation {
        case .vertical:
             orientation = .horizontal
            cameraNode.eulerAngles = SCNVector3(0, cameraNode.eulerAngles.y, cameraNode.eulerAngles.z)
        case .horizontal:
            orientation = .vertical
            cameraNode.eulerAngles = SCNVector3(-1, cameraNode.eulerAngles.y, cameraNode.eulerAngles.z)
        }
        SCNTransaction.commit()
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}