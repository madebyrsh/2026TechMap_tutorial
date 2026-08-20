import SwiftUI

@MainActor
@Observable
final class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    var immersiveSpaceState: ImmersiveSpaceState = .closed
}
