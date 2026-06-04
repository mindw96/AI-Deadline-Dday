import SwiftUI

@main
struct DdayMobileApp: App {
    @StateObject private var model = MobileAppModel()

    var body: some Scene {
        WindowGroup {
            MobileRootView()
                .environmentObject(model)
        }
    }
}
