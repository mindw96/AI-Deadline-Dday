import SwiftUI

struct MobileRootView: View {
    @EnvironmentObject private var model: MobileAppModel

    var body: some View {
        TabView {
            HomeScreen()
                .tabItem {
                    Label(model.text.homeTab, systemImage: "house")
                }

            ConferenceBrowserScreen()
                .tabItem {
                    Label(model.text.conferencesTab, systemImage: "calendar")
                }

            CustomDeadlinesScreen()
                .tabItem {
                    Label(model.text.customTab, systemImage: "plus.square")
                }

            SettingsScreen()
                .tabItem {
                    Label(model.text.settingsTab, systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MobileRootView()
        .environmentObject(MobileAppModel())
}
