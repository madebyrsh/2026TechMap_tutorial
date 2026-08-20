import SwiftUI

struct ImmersiveView: View {
    var body: some View {
        EmptyRealityView { content in
            do {
                let objectTrackingScene = try await Entity(
                    named: "ObjectTrackingScene",
                    in: realityKitContentBundle
                )
                content.add(objectTrackingScene)
            } catch {
                print("오브젝트 트래킹 Scene 로드 실패: \(error)")
            }
        }
    }
}
