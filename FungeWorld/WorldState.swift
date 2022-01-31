import Befunge

@MainActor
final class WorldState {
    enum PlayingState: Codable {
        case paused
        case playing
        case terminated
    }
    
    var state: State
    var code = ""
    var playingState: PlayingState = .paused
    var outputBuffer = [UnicodeScalar]()
    var inputCharBuffer = [UnicodeScalar]()
    
    init(state: State) {
        self.state = state
    }
}

extension WorldState: Codable {
    
}
