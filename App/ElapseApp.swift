import SwiftUI

@main
struct ElapseApp: App {
    @StateObject private var model = ElapseModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }
    }
}
