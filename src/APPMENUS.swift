/*
	APPMENUS.swift

	Copyright (C) 2026 Mini vMac contributors

	You can redistribute this file and/or modify it under the terms
	of version 2 of the GNU General Public License as published by
	the Free Software Foundation.  You should have received a copy
	of the license along with this file; see the file COPYING.

	This file is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	license for more details.
*/

/*
	APPlication MENUS

	The real menu bar, replacing the three item stub that existed
	when the only way to reach most commands was a character cell
	overlay drawn into the emulated screen.

	Key equivalents use Control, not Command. That is not a style
	choice: the emulated Macintosh receives every Command keystroke,
	so Command is unavailable to the host. What makes this workable
	is that the commands are now discoverable with the mouse, and
	that native full screen reveals the menu bar on hover, so nothing
	is unreachable.

	Check marks and enablement are answered in validateMenuItem
	rather than pushed. The emulator changes this state on its own —
	full screen can be left with the green button, a disk can be
	ejected by the guest — so asking at the moment the menu opens is
	both simpler and more accurate than trying to keep a copy in
	step.
*/

import AppKit

@objc(MNVMMenuController)
final class MenuController: NSObject, NSMenuItemValidation {

	@objc static let shared = MenuController()

	private var bridge: EmulatorBridge { EmulatorBridge.shared }

	private override init() {
		super.init()
	}

	/// Builds and installs the application menu bar.
	@objc static func installMainMenu() {
		let controller = MenuController.shared
		let mainMenu = NSMenu()

		mainMenu.addItem(controller.makeAppMenuItem())
		mainMenu.addItem(controller.makeFileMenuItem())
		mainMenu.addItem(controller.makeMachineMenuItem())
		mainMenu.addItem(controller.makeViewMenuItem())
		mainMenu.addItem(controller.makeWindowMenuItem())

		NSApp.mainMenu = mainMenu
	}

	// MARK: building

	private func submenu(_ title: String, _ build: (NSMenu) -> Void)
		-> NSMenuItem
	{
		let menu = NSMenu(title: title)
		build(menu)

		let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
		item.submenu = menu

		return item
	}

	@discardableResult
	private func add(_ menu: NSMenu, _ title: String,
		_ action: Selector, key: String = "",
		mask: NSEvent.ModifierFlags = .control,
		tag: Int = 0) -> NSMenuItem
	{
		let item = NSMenuItem(title: title, action: action,
			keyEquivalent: key)
		item.keyEquivalentModifierMask = mask
		item.target = self
		item.tag = tag
		menu.addItem(item)

		return item
	}

	private func makeAppMenuItem() -> NSMenuItem {
		/*
			macOS substitutes the real application name for the first
			menu's title, so what is passed here does not show.
		*/
		return submenu("Mini vMac") { menu in
			add(menu, "About Mini vMac",
				#selector(showAbout(_:)))
			menu.addItem(.separator())
			add(menu, "Settings…",
				#selector(showSettings(_:)), key: ",")
			menu.addItem(.separator())

			let hide = NSMenuItem(title: "Hide Mini vMac",
				action: #selector(NSApplication.hide(_:)),
				keyEquivalent: "")
			menu.addItem(hide)

			let hideOthers = NSMenuItem(title: "Hide Others",
				action: #selector(NSApplication.hideOtherApplications(_:)),
				keyEquivalent: "")
			menu.addItem(hideOthers)

			let showAll = NSMenuItem(title: "Show All",
				action: #selector(NSApplication.unhideAllApplications(_:)),
				keyEquivalent: "")
			menu.addItem(showAll)

			menu.addItem(.separator())

			let quit = NSMenuItem(title: "Quit Mini vMac",
				action: #selector(NSApplication.terminate(_:)),
				keyEquivalent: "q")
			quit.keyEquivalentModifierMask = .control
			menu.addItem(quit)
		}
	}

	private func makeFileMenuItem() -> NSMenuItem {
		return submenu("File") { menu in
			add(menu, "Open Disk Image…",
				#selector(openDiskImage(_:)), key: "o")
			menu.addItem(.separator())

			/*
				Populated in menuNeedsUpdate, because which drives
				hold a disk changes as the guest runs.
			*/
			let eject = NSMenuItem(title: "Eject", action: nil,
				keyEquivalent: "")
			let ejectMenu = NSMenu(title: "Eject")
			ejectMenu.delegate = self
			eject.submenu = ejectMenu
			menu.addItem(eject)
		}
	}

	private func makeMachineMenuItem() -> NSMenuItem {
		return submenu("Machine") { menu in
			add(menu, "Reset", #selector(resetMachine(_:)), key: "r")
			add(menu, "Interrupt", #selector(interruptMachine(_:)),
				key: "i")
			menu.addItem(.separator())

			let speed = NSMenuItem(title: "Speed", action: nil,
				keyEquivalent: "")
			let speedMenu = NSMenu(title: "Speed")
			for option in EmulatorSpeed.allCases {
				let item = NSMenuItem(title: option.title,
					action: #selector(setSpeed(_:)), keyEquivalent: "")
				item.target = self
				item.tag = option.rawValue
				speedMenu.addItem(item)
			}
			speed.submenu = speedMenu
			menu.addItem(speed)

			add(menu, "Pause", #selector(toggleStopped(_:)))
			menu.addItem(.separator())
			add(menu, "Run in Background",
				#selector(toggleRunInBackground(_:)))
			add(menu, "Slow Down When Idle",
				#selector(toggleAutoSlow(_:)))
		}
	}

	private func makeViewMenuItem() -> NSMenuItem {
		return submenu("View") { menu in
			if bridge.hasMagnify {
				add(menu, "Magnify", #selector(toggleMagnify(_:)),
					key: "m")
			}
			/*
				Full screen is left to AppKit's own item, which
				drives toggleFullScreen: and so keeps the green
				button, Spaces and the auto revealing menu bar
				behaving as they should.
			*/
			let full = NSMenuItem(title: "Enter Full Screen",
				action: #selector(NSWindow.toggleFullScreen(_:)),
				keyEquivalent: "f")
			full.keyEquivalentModifierMask = [.control, .command]
			menu.addItem(full)
		}
	}

	private func makeWindowMenuItem() -> NSMenuItem {
		let item = submenu("Window") { menu in
			let minimise = NSMenuItem(title: "Minimise",
				action: #selector(NSWindow.performMiniaturize(_:)),
				keyEquivalent: "")
			menu.addItem(minimise)

			let zoom = NSMenuItem(title: "Zoom",
				action: #selector(NSWindow.performZoom(_:)),
				keyEquivalent: "")
			menu.addItem(zoom)
		}
		NSApp.windowsMenu = item.submenu

		return item
	}

	// MARK: actions

	@objc private func showAbout(_ sender: Any?) {
		AboutPanel.show()
	}

	@objc private func showSettings(_ sender: Any?) {
		SettingsWindow.show()
	}

	@objc private func openDiskImage(_ sender: Any?) {
		bridge.insertDisk()
	}

	@objc private func resetMachine(_ sender: Any?) {
		bridge.reset()
	}

	@objc private func interruptMachine(_ sender: Any?) {
		bridge.interrupt()
	}

	@objc private func setSpeed(_ sender: Any?) {
		guard let item = sender as? NSMenuItem,
			let option = EmulatorSpeed(rawValue: item.tag) else { return }

		bridge.refresh()
		bridge.speed = option
	}

	@objc private func toggleStopped(_ sender: Any?) {
		bridge.refresh()
		bridge.isStopped.toggle()
	}

	@objc private func toggleMagnify(_ sender: Any?) {
		bridge.refresh()
		bridge.magnify.toggle()
	}

	@objc private func toggleRunInBackground(_ sender: Any?) {
		bridge.refresh()
		bridge.runInBackground.toggle()
	}

	@objc private func toggleAutoSlow(_ sender: Any?) {
		bridge.refresh()
		bridge.autoSlow.toggle()
	}

	@objc private func ejectDrive(_ sender: Any?) {
		guard let item = sender as? NSMenuItem else { return }

		bridge.eject(drive: item.tag)
	}

	// MARK: validation

	func validateMenuItem(_ item: NSMenuItem) -> Bool {
		switch item.action {
		case #selector(setSpeed(_:)):
			item.state = (Int(MNVM_GetSpeedValue()) == item.tag)
				? .on : .off
			return true

		case #selector(toggleStopped(_:)):
			item.state = MNVM_GetSpeedStopped() ? .on : .off
			return true

		case #selector(toggleMagnify(_:)):
			item.state = MNVM_GetMagnify() ? .on : .off
			return bridge.hasMagnify

		case #selector(toggleRunInBackground(_:)):
			item.state = MNVM_GetRunInBackground() ? .on : .off
			return true

		case #selector(toggleAutoSlow(_:)):
			item.state = MNVM_GetAutoSlow() ? .on : .off
			return true

		case #selector(ejectDrive(_:)):
			return true

		default:
			return true
		}
	}
}

/*
	The Eject submenu is rebuilt each time it opens, since the set of
	occupied drives changes while the guest runs.
*/
extension MenuController: NSMenuDelegate {

	func menuNeedsUpdate(_ menu: NSMenu) {
		menu.removeAllItems()

		bridge.refresh()

		if bridge.insertedDrives.isEmpty {
			let empty = NSMenuItem(title: "No Disks Inserted",
				action: nil, keyEquivalent: "")
			empty.isEnabled = false
			menu.addItem(empty)
			return
		}

		for drive in bridge.insertedDrives {
			let item = NSMenuItem(title: "Disk \(drive + 1)",
				action: #selector(ejectDrive(_:)), keyEquivalent: "")
			item.target = self
			item.tag = drive
			menu.addItem(item)
		}
	}
}
