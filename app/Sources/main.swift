import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private let notificationCenter = UNUserNotificationCenter.current()
    private let paramFilePath = NSString(string: "~/.claude-notify-params").expandingTildeInPath
    private let configFilePath = NSString(string: "~/.clawdnotify/config").expandingTildeInPath

    // Default to Ghostty, can be overridden via config file
    private var terminalBundleID: String {
        if let config = try? String(contentsOfFile: configFilePath, encoding: .utf8) {
            let lines = config.components(separatedBy: "\n")
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("terminal_bundle_id=") {
                    return String(trimmed.dropFirst("terminal_bundle_id=".count))
                }
            }
        }
        return "com.mitchellh.ghostty"
    }

    func applicationWillFinishLaunching(_ notification: Notification) {
        notificationCenter.delegate = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let args = CommandLine.arguments

        if args.contains("--show") {
            showNotificationFromParams()
        } else {
            // Launched from notification click - activate terminal
            activateTerminal()
            terminateAfterDelay(0.3)
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            if url.scheme == "clawdnotify" {
                activateTerminal()
                terminateAfterDelay(0.3)
                return
            }
        }
    }

    private func showNotificationFromParams() {
        guard let content = try? String(contentsOfFile: paramFilePath, encoding: .utf8) else {
            terminateAfterDelay(0.1)
            return
        }

        let lines = content.components(separatedBy: "\n")
        let title = lines.count > 0 ? lines[0] : "Claude Code"
        let subtitle = lines.count > 1 ? lines[1] : ""
        let message = lines.count > 2 ? lines[2] : ""

        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self, granted, error == nil else {
                self?.terminateAfterDelay(0.1)
                return
            }
            self.registerNotificationCategory()
            self.showNotification(title: title, subtitle: subtitle, body: message)
        }
    }

    private func registerNotificationCategory() {
        let showAction = UNNotificationAction(
            identifier: "SHOW_ACTION",
            title: "Show",
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: "CLAUDE_NOTIFICATION",
            actions: [showAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }

    private func showNotification(title: String, subtitle: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.categoryIdentifier = "CLAUDE_NOTIFICATION"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        notificationCenter.add(request) { [weak self] _ in
            self?.terminateAfterDelay(0.5)
        }
    }

    private func activateTerminal() {
        let workspace = NSWorkspace.shared
        let bundleID = terminalBundleID

        if let terminalApp = workspace.runningApplications.first(where: { $0.bundleIdentifier == bundleID }) {
            terminalApp.activate(options: [.activateIgnoringOtherApps])
        } else {
            if let url = workspace.urlForApplication(withBundleIdentifier: bundleID) {
                let config = NSWorkspace.OpenConfiguration()
                config.activates = true
                workspace.openApplication(at: url, configuration: config)
            }
        }
    }

    private func terminateAfterDelay(_ seconds: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            NSApp.terminate(nil)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "SHOW_ACTION" ||
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            activateTerminal()
        }
        completionHandler()
        terminateAfterDelay(0.3)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
