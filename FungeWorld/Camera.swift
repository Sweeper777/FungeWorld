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


    init(cameraNode: SCNNode, xRange: ClosedRange<Float>, yRange: ClosedRange<Float>, zRange: ClosedRange<Float>) {
        self.cameraNode = cameraNode
        self.xRange = xRange
        self.yRange = yRange
        self.zRange = zRange
    }

}
