import SceneKit

class FungeWorldCamera {
    private let cameraNode: SCNNode
    private let zoomRange: ClosedRange<CGFloat> = 15...120

    var zoom: CGFloat {
        get {
            cameraNode.camera!.fieldOfView
        }
        set {
            cameraNode.camera!.fieldOfView = newValue
            cameraNode.camera!.fieldOfView = zoomRange.clamp(cameraNode.camera!.fieldOfView)
        }
    }

    init(cameraNode: SCNNode) {
        self.cameraNode = cameraNode
    }
}

extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        lowerBound > value ? lowerBound
            : upperBound < value ? upperBound
            : value
    }
}
