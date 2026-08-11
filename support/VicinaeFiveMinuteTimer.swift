import AppKit
import Foundation

let stateFile = NSString(string: "~/Library/Application Support/Vicinae/five-minute-timer.end").expandingTildeInPath

func timerEnd() -> Int64? {
    guard let contents = try? String(contentsOfFile: stateFile, encoding: .utf8) else {
        return nil
    }

    return Int64(contents.trimmingCharacters(in: .whitespacesAndNewlines))
}

func formattedTime(_ seconds: Int64) -> String {
    let minutes = seconds / 60
    let remainingSeconds = seconds % 60
    return String(format: "%02lld:%02lld", minutes, remainingSeconds)
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

var finished = false

Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
    let now = Int64(Date().timeIntervalSince1970)

    guard let end = timerEnd() else {
        statusItem.button?.title = ""
        return
    }

    let remaining = end - now
    if remaining > 0 {
        finished = false
        statusItem.button?.title = formattedTime(remaining)
    } else if !finished {
        finished = true
        statusItem.button?.title = "✓"

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let currentTime = Int64(Date().timeIntervalSince1970)
            if let currentEnd = timerEnd(), currentEnd <= currentTime {
                try? FileManager.default.removeItem(atPath: stateFile)
                application.terminate(nil)
            }
        }
    }
}

application.run()
