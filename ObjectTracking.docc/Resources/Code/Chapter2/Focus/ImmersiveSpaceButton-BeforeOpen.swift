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
            break
        case .open:
            appModel.immersiveSpaceState = .inTransition
            await dismissImmersiveSpace()
            appModel.immersiveSpaceState = .closed
        case .inTransition:
            break
        }
    }
}
