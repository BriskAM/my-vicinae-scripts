import AppKit
import Foundation

let stateDirectory = NSString(string: "~/Library/Application Support/Vicinae").expandingTildeInPath
let enabledFile = (stateDirectory as NSString).appendingPathComponent("coffee-mode.enabled")

func coffeeModeIsEnabled() -> Bool { FileManager.default.fileExists(atPath: enabledFile) }
func removeCoffeeState() { try? FileManager.default.removeItem(atPath: enabledFile) }

final class CoffeeMenuController: NSObject {
    let statusItem: NSStatusItem
    var caffeinateProcess: Process?

    init(statusItem: NSStatusItem) {
        self.statusItem = statusItem
        super.init()

        let menu = NSMenu()
        let status = NSMenuItem(title: "Coffee Mode On", action: nil, keyEquivalent: "")
        status.isEnabled = false
        menu.addItem(status)
        menu.addItem(.separator())
        let turnOff = NSMenuItem(title: "Turn Off Coffee Mode", action: #selector(turnOffCoffeeMode), keyEquivalent: "")
        turnOff.target = self
        menu.addItem(turnOff)
        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
        quit.target = self
        menu.addItem(quit)

        statusItem.button?.image = NSImage(systemSymbolName: "cup.and.saucer.fill", accessibilityDescription: "Coffee Mode")
        statusItem.menu = menu
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
            statusItem.button?.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: "Coffee Mode Error")
        }
    }

    func stopCaffeinate() {
        if let process = caffeinateProcess, process.isRunning { process.terminate() }
        caffeinateProcess = nil
    }

    @objc func turnOffCoffeeMode() {
        removeCoffeeState()
        stopCaffeinate()
        NSApplication.shared.terminate(nil)
    }

    @objc func quit() {
        removeCoffeeState()
        stopCaffeinate()
        NSApplication.shared.terminate(nil)
    }
}

let application = NSApplication.shared
application.setActivationPolicy(.accessory)
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
let controller = CoffeeMenuController(statusItem: statusItem)

Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
    if coffeeModeIsEnabled() { controller.startCaffeinateIfNeeded() }
    else { controller.stopCaffeinate(); application.terminate(nil) }
}

controller.startCaffeinateIfNeeded()
application.run()
