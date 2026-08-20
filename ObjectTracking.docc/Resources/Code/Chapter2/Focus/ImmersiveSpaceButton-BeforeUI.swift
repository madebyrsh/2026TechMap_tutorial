import SwiftUI

struct ImmersiveSpaceButton: View {
    var body: some View {
        EmptyView()
    }

    private func toggleImmersiveSpace() async {
        switch appModel.immersiveSpaceState {
        case .closed:
            appModel.immersiveSpaceState = .inTransition
            let result = await openImmersiveSpace(id: "ObjectTrackingSpace")

            switch result {
            case .opened:
                appModel.immersiveSpaceState = .open
            case .userCancelled, .error:
                appModel.immersiveSpaceState = .closed
            @unknown default:
                appModel.immersiveSpaceState = .closed
            }
        case .open:
            appModel.immersiveSpaceState = .inTransition
            await dismissImmersiveSpace()
            appModel.immersiveSpaceState = .closed
        case .inTransition:
            break
        }
    }
}
