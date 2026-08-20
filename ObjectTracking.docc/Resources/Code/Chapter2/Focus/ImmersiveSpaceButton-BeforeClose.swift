import SwiftUI

struct ImmersiveSpaceButton: View {
    @Environment(AppModel.self) private var appModel
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        Button {
            Task {
                await toggleImmersiveSpace()
            }
        } label: {
            switch appModel.immersiveSpaceState {
            case .closed:
                Text("오브젝트 트래킹 시작")
            case .inTransition:
                Text("처리 중...")
            case .open:
                Text("오브젝트 트래킹 종료")
            }
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
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
            break
        case .inTransition:
            break
        }
    }
}
