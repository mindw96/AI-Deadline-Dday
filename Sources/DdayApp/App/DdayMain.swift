import AppKit

@main
enum DdayMain {
    @MainActor
    static func main() {
        let appDelegate = AppDelegate()
        let app = NSApplication.shared
        app.delegate = appDelegate
        withExtendedLifetime(appDelegate) {
            app.run()
        }
    }
}
