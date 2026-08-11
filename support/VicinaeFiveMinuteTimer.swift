import AppKit
import Foundation

let stateDirectory = NSString(string: "~/Library/Application Support/Vicinae").expandingTildeInPath
let endFile = (stateDirectory as NSString).appendingPathComponent("five-minute-timer.end")
let pausedFile = (stateDirectory as NSString).appendingPathComponent("five-minute-timer.paused")

func now() -> Int64 { Int64(Date().timeIntervalSince1970) }

func readInteger(_ path: String) -> Int64? {
    guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
    return Int64(contents.trimmingCharacters(in: .whitespacesAndNewlines))
}

func writeInteger(_ value: Int64, to path: String) {
    try? FileManager.default.createDirectory(atPath: stateDirectory, withIntermediateDirectories: true)
    try? String(value).write(toFile: path, atomically: true, encoding: .utf8)
}

func removeFile(_ path: String) { try? FileManager.default.removeItem(atPath: path) }

func formattedTime(_ seconds: Int64) -> String {
    let safeSeconds = max(0, seconds)
    return String(format: "%02lld:%02lld", safeSeconds / 60, safeSeconds % 60)
}

func pausedRemaining() -> Int64? {
    guard let remaining = readInteger(pausedFile) else { return nil }
    return max(0, remaining)
}

func activeRemaining() -> Int64? {
    guard let end = readInteger(endFile) else { return nil }
    return max(0, end - now())
}

final class TimerMenuController: NSObject {
    let statusItem: NSStatusItem
    let pauseItem: NSMenuItem
    var finishScheduled = false
    var caffeinateProcess: Process?

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        self.pauseItem = NSMenuItem(title: "Pause", action: nil, keyEquivalent: "")
        super.init()

        let menu = NSMenu()
        menu.addItem(makeItem("− 1 minute", action: #selector(subtractMinute)))
        menu.addItem(makeItem("+ 5 minutes", action: #selector(addFiveMinutes)))
        menu.addItem(.separator())
        pauseItem.action = #selector(togglePause)
        pauseItem.target = self
        menu.addItem(pauseItem)
        menu.addItem(makeItem("Reset timer", action: #selector(resetTimer)))
        menu.addItem(.separator())
        menu.addItem(makeItem("Quit timer", action: #selector(quitTimer)))
        statusItem.menu = menu
    }

    func makeItem(_ title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    func startCaffeinateIfNeeded() {
        guard caffeinateProcess?.isRunning != true else { return }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-dimsu"]
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
            caffeinateProcess = process
        } catch {
            caffeinateProcess = nil
        }
    }

    func stopCaffeinate() {
        if let process = caffeinateProcess, process.isRunning {
            process.terminate()
        }
        caffeinateProcess = nil
    }

    deinit {
        stopCaffeinate()
    }

    func refresh() {
        if let paused = pausedRemaining() {
            stopCaffeinate()
            statusItem.button?.title = "⏸ \(formattedTime(paused))"
            pauseItem.title = "Resume"
        } else if let remaining = activeRemaining(), remaining > 0 {
            startCaffeinateIfNeeded()
            statusItem.button?.title = formattedTime(remaining)
            pauseItem.title = "Pause"
        } else {
            stopCaffeinate()
            statusItem.button?.title = "—"
            pauseItem.title = "Pause"
        }
    }

    func showFinished() {
        stopCaffeinate()
        removeFile(endFile)
        removeFile(pausedFile)
        guard !finishScheduled else { return }

        finishScheduled = true
        statusItem.button?.title = "✓"
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if readInteger(endFile) == nil && pausedRemaining() == nil {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    @objc func subtractMinute() {
        if let paused = pausedRemaining() {
            if paused <= 60 { showFinished(); return }
            else { writeInteger(paused - 60, to: pausedFile) }
        } else if let end = readInteger(endFile) {
            if end <= now() + 60 { showFinished(); return }
            else { writeInteger(end - 60, to: endFile) }
        }
        refresh()
    }

    @objc func addFiveMinutes() {
        if let paused = pausedRemaining() { writeInteger(paused + 300, to: pausedFile) }
        else {
            let baseEnd = max(now(), readInteger(endFile) ?? now())
            writeInteger(baseEnd + 300, to: endFile)
        }
        refresh()
    }

    @objc func togglePause() {
        if let paused = pausedRemaining() {
            writeInteger(now() + paused, to: endFile)
            removeFile(pausedFile)
        } else if let remaining = activeRemaining(), remaining > 0 {
            writeInteger(remaining, to: pausedFile)
            removeFile(endFile)
        }
        refresh()
    }

    @objc func resetTimer() {
        stopCaffeinate()
        removeFile(endFile)
        removeFile(pausedFile)
        refresh()
    }

    @objc func quitTimer() {
        stopCaffeinate()
        removeFile(endFile)
        removeFile(pausedFile)
        NSApplication.shared.terminate(nil)
    }
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let controller = TimerMenuController(statusItem: statusItem)

Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
    if pausedRemaining() != nil {
        controller.refresh()
        return
    }
    guard let end = readInteger(endFile) else {
        controller.stopCaffeinate()
        return
    }

    let remaining = end - now()
    guard remaining > 0 else {
        controller.showFinished()
        return
    }
    controller.startCaffeinateIfNeeded()
    statusItem.button?.title = formattedTime(remaining)
}

controller.refresh()
application.run()
