/*
	EMUBRIDG.swift

	Copyright (C) 2026 Moof contributors

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
	EMUlator BRIDGe

	The single point at which Swift meets the C emulator. Every other
	Swift file talks to this type and never touches the C surface
	directly, which is what keeps C types out of the view layer.

	Reads go straight through to the emulator, which is cheap: the
	accessors in EMUCTLAP take the emulator lock, and at ordinary
	speeds that lock is free for most of every tick.

	Writes are requests. The emulator polls the flags they set, so a
	change here takes effect on a following tick rather than at once.
	Nothing in the interface should assume a setter is visible
	immediately.
*/

import Foundation
import SwiftUI

/// Emulated speed, as offered in the interface.
enum EmulatorSpeed: Int, CaseIterable, Identifiable {
	case x1 = 0
	case x2 = 1
	case x4 = 2
	case x8 = 3
	case x16 = 4
	case x32 = 5
	case allOut = -1

	var id: Int { rawValue }

	var title: String {
		switch self {
		case .x1: return "1×"
		case .x2: return "2×"
		case .x4: return "4×"
		case .x8: return "8×"
		case .x16: return "16×"
		case .x32: return "32×"
		case .allOut: return "All Out"
		}
	}
}

final class EmulatorBridge: ObservableObject {

	static let shared = EmulatorBridge()

	private init() {
		refresh()
	}

	// MARK: what this build can do

	let hasMagnify = MNVM_HasMagnify()
	let hasFullScreen = MNVM_HasFullScreen()
	let hasSound = MNVM_HasSound()
	let driveCount = Int(MNVM_GetDriveCount())

	// MARK: published state

	@Published var speed: EmulatorSpeed = .x1 {
		didSet {
			guard !isRefreshing, oldValue != speed else { return }
			MNVM_PostSetSpeedValue(Int32(speed.rawValue))
		}
	}

	@Published var isStopped: Bool = false {
		didSet {
			guard !isRefreshing, oldValue != isStopped else { return }
			MNVM_PostSetSpeedStopped(isStopped)
		}
	}

	@Published var magnify: Bool = false {
		didSet {
			guard !isRefreshing, oldValue != magnify else { return }
			MNVM_PostSetMagnify(magnify)
		}
	}

	@Published var fullScreen: Bool = false {
		didSet {
			guard !isRefreshing, oldValue != fullScreen else { return }
			MNVM_PostSetFullScreen(fullScreen)
		}
	}

	@Published var runInBackground: Bool = false {
		didSet {
			guard !isRefreshing, oldValue != runInBackground else { return }
			MNVM_PostSetRunInBackground(runInBackground)
		}
	}

	@Published var autoSlow: Bool = true {
		didSet {
			guard !isRefreshing, oldValue != autoSlow else { return }
			MNVM_PostSetAutoSlow(autoSlow)
		}
	}

	/// Which drives currently hold an image.
	@Published var insertedDrives: [Int] = []

	/*
		Guards the didSet observers while state is being pulled back
		out of the emulator. Without it, refreshing would post every
		value straight back as a fresh request, and a change the
		emulator made itself would be immediately overwritten by the
		interface echoing the old one.
	*/
	private var isRefreshing = false

	// MARK: reading back

	/// Pulls current emulator state into the published properties.
	func refresh() {
		isRefreshing = true
		defer { isRefreshing = false }

		speed = EmulatorSpeed(rawValue: Int(MNVM_GetSpeedValue())) ?? .x1
		isStopped = MNVM_GetSpeedStopped()
		magnify = MNVM_GetMagnify()
		fullScreen = MNVM_GetFullScreen()
		runInBackground = MNVM_GetRunInBackground()
		autoSlow = MNVM_GetAutoSlow()

		insertedDrives = (0 ..< driveCount).filter {
			MNVM_GetDriveInserted(Int32($0))
		}
	}

	var anyDriveInserted: Bool { MNVM_GetAnyDriveInserted() }

	// MARK: actions

	func reset() { MNVM_PostReset() }
	func interrupt() { MNVM_PostInterrupt() }
	func insertDisk() { MNVM_PostInsertDisk() }
	func requestQuit() { MNVM_PostQuit() }

	func eject(drive: Int) {
		MNVM_PostEjectDrive(Int32(drive))
		refresh()
	}
}
