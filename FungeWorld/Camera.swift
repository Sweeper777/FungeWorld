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
            cameraNode.position.z = xRange.clamp(cameraNode.position.z)
        case .horizontal:
            cameraNode.position.y -= dy
            cameraNode.position.y = xRange.clamp(cameraNode.position.y)
        }
    }

    func toggleOrientation() {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        switch orientation {
        case .vertical:
             orientation = .horizontal
            cameraNode.eulerAngles.x = 0
        case .horizontal:
            orientation = .vertical
            cameraNode.eulerAngles.x = -1
        }
        SCNTransaction.commit()
        SCNTransaction.animationDuration = 0
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}