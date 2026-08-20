import SwiftUI

class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState: ImmersiveSpaceState = .closed
}
