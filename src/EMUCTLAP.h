/*
	EMUCTLAP.h

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
	EMUlator ConTroL Api

	The narrow surface that the Swift side of the user interface is
	allowed to touch. Everything here is plain C using plain C types,
	so that Swift sees Int32 and Bool rather than the ui3b and blnr
	aliases used throughout the emulator.

	Unlike most headers in this directory, this one is included from
	more than one translation unit, so it uses an ordinary include
	guard rather than the "header already included" error guard that
	the unity build headers use.

	Nothing here may pull in a unity build header such as CONTROLM.h
	or COMOSGLU.h. Those are implementation, included exactly once
	into the backend, and a second inclusion is a hard error.
*/

#ifndef EMUCTLAP_H
#define EMUCTLAP_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
	Speed. Values 0 through 5 mean 1x, 2x, 4x, 8x, 16x and 32x.
	A value of -1 means run as fast as the host allows.
*/
#define kMNVMSpeedAllOut (-1)

extern int MNVM_GetSpeedValue(void);
extern void MNVM_PostSetSpeedValue(int v);

#ifdef __cplusplus
}
#endif

#endif /* EMUCTLAP_H */
