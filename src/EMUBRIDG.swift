/*
	EMUBRIDG.swift

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
	EMUlator BRIDGe

	The single point at which Swift meets the C emulator. Every other
	Swift file in this target talks to this type and never touches the
	C surface directly, which keeps C types out of the view layer.

	Reads are answered from the status published by the emulator
	thread. Writes are posted as commands and take effect on the next
	emulator tick, so a setter here is a request, never an immediate
	mutation.
*/

import Foundation

@objc(MNVMEmulatorBridge)
final class EmulatorBridge: NSObject {

	@objc static let shared = EmulatorBridge()

	private override init() {
		super.init()
	}

	/// Speed as an exponent: 0 is 1x, 5 is 32x. `nil` means all out.
	var speedMultiplierExponent: Int? {
		get {
			let v = MNVM_GetSpeedValue()
			return v == kMNVMSpeedAllOut ? nil : Int(v)
		}
		set {
			MNVM_PostSetSpeedValue(
				newValue.map(Int32.init) ?? Int32(kMNVMSpeedAllOut))
		}
	}

	/*
		Boundary probe. Confirms that Swift can call into C and that
		Objective-C can call back into Swift through the generated
		interface header. Called once during startup.
	*/
	@objc static func describeBoundary() -> String {
		let bridge = EmulatorBridge.shared
		if let e = bridge.speedMultiplierExponent {
			return "swift bridge live, speed exponent \(e)"
		} else {
			return "swift bridge live, speed all out"
		}
	}
}
