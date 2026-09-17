/*
	EMUTHRED.m

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
	EMUlator THREaD

	See EMUTHRED.h for the contract and for why this uses one coarse
	lock instead of lock free channels.
*/

#import "EMUTHRED.h"

#import <AppKit/AppKit.h>

#include <pthread.h>
#include <sched.h>
#include <time.h>

/*
	ProgramMain is the portable emulator loop, declared in PROGMAIN.h
	and compiled into the backend translation unit. It is declared
	here by hand rather than by including that header, because the
	headers in this project are unity build implementation that may
	be included exactly once.
*/
extern void ProgramMain(void);

static pthread_t gThread;
static pthread_mutex_t gLock;
static bool gLockReady = false;
static bool gThreadStarted = false;
static volatile bool gFinished = false;

static void EmuLock_EnsureReady(void)
{
	if (! gLockReady) {
		pthread_mutexattr_t attr;

		pthread_mutexattr_init(&attr);
		/*
			Recursive, so that a main thread path already holding
			the lock can call into code that takes it again. The
			housekeeping path does exactly that.
		*/
		pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
		pthread_mutex_init(&gLock, &attr);
		pthread_mutexattr_destroy(&attr);

		gLockReady = true;
	}
}

void EmuLock_Acquire(void)
{
	EmuLock_EnsureReady();
	pthread_mutex_lock(&gLock);
}

void EmuLock_Release(void)
{
	if (gLockReady) {
		pthread_mutex_unlock(&gLock);
	}
}

void EmuLock_Yield(void)
{
	if (gLockReady) {
		pthread_mutex_unlock(&gLock);
		/*
			sched_yield alone is not enough here: the main thread
			may not be runnable yet, and a bare yield can be
			answered by immediately rescheduling this thread. A
			very short sleep reliably lets the main thread take
			the lock, at a cost that only applies in "all out"
			mode where there is no pacing sleep anyway.
		*/
		struct timespec rqt;
		rqt.tv_sec = 0;
		rqt.tv_nsec = 100000; /* 0.1 ms */
		(void) nanosleep(&rqt, NULL);
		pthread_mutex_lock(&gLock);
	}
}

static void * EmuThread_Main(void *arg)
{
	(void) arg;

	pthread_setname_np("minivmac emulator");

	/*
		The loop holds the lock while it computes and releases it
		while pacing. WaitForNextTick performs that release, so the
		lock is taken here once on entry.
	*/
	EmuLock_Acquire();

	ProgramMain();

	EmuLock_Release();

	gFinished = true;

	/*
		The emulator has left its loop, so the application should
		follow. This stops the run loop rather than calling
		terminate, because terminate exits the process without
		unwinding main, which would skip UnInitOSGLU and with it
		the sound teardown, the drive flush and the menu bar
		restore.

		NSApplication only notices a stop when it next handles an
		event, so one is posted.
	*/
	dispatch_async(dispatch_get_main_queue(), ^{
		[NSApp stop: nil];

		NSEvent *wake = [NSEvent
			otherEventWithType: NSEventTypeApplicationDefined
			location: NSMakePoint(0, 0)
			modifierFlags: 0
			timestamp: 0.0
			windowNumber: 0
			context: nil
			subtype: 0
			data1: 0
			data2: 0];
		[NSApp postEvent: wake atStart: YES];
	});

	return NULL;
}

bool EmuThread_Start(void)
{
	if (gThreadStarted) {
		return true;
	}

	EmuLock_EnsureReady();

	if (0 != pthread_create(&gThread, NULL, EmuThread_Main, NULL)) {
		NSLog(@"EMUTHRED: could not create emulator thread");
		return false;
	}

	gThreadStarted = true;

	return true;
}

void EmuThread_Stop(void)
{
	if (! gThreadStarted) {
		return;
	}

	/*
		Ask the emulator loop to leave. The flag is read by the
		emulator, so it is set under the lock like any other
		emulator state.
	*/
	EmuLock_Acquire();
	(void) EmuThread_RequestStop();
	EmuLock_Release();

	(void) pthread_join(gThread, NULL);

	gThreadStarted = false;
}

bool EmuThread_HasFinished(void)
{
	return gFinished;
}

bool EmuThread_IsCurrent(void)
{
	if (! gThreadStarted) {
		return false;
	}

	return (0 != pthread_equal(pthread_self(), gThread));
}
