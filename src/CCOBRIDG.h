/*
	CCOBRIDG.h

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
	CoCOa BRIDGing header

	Referenced by the generated Xcode project as
	SWIFT_OBJC_BRIDGING_HEADER. Whatever is visible here is visible
	to every Swift file in the target, so it is kept deliberately
	small: Foundation, and the narrow emulator control API.

	Do not add the unity build headers here. They are included once
	into the backend translation unit and error out on a second
	inclusion.
*/

#ifndef CCOBRIDG_H
#define CCOBRIDG_H

#import <Foundation/Foundation.h>

#include "EMUCTLAP.h"

#endif /* CCOBRIDG_H */
