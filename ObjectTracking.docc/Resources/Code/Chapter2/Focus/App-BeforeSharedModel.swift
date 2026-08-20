import SwiftUI

@main
struct ObjectTrackingWithRCPApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ObjectTrackingSpace") {
            ImmersiveView()
                .environment(appModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
