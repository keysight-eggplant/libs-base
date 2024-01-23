########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 613a95f29873e44f87c989412fc617b632fa76aa
# Date: 2020-06-09 16:13:35 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 8eedc9ddaa9e420d6c9a936946712f62bfc26cc9
# Date: 2016-09-27 20:33:01 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 36f527303dd69064d2bf95c6606ab69374ab1cf7
# Date: 2016-09-17 00:21:01 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: a3b161dc84283f794c0b13149b072531acb6eaf9
# Date: 2016-09-14 14:40:34 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 61e39b584c8bcbb531df4560875c052bc30ebd46
# Date: 2015-06-16 19:12:49 +0000
########## End of Keysight Technologies Notice ##########
/* Interface for GSFileHandle for GNUStep
   Copyright (C) 1997-2002 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Date: 1997

   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110 USA.
   */

#ifndef __GSFileHandle_h_GNUSTEP_BASE_INCLUDE
#define __GSFileHandle_h_GNUSTEP_BASE_INCLUDE

#import "Foundation/NSFileHandle.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSRunLoop.h"


// Testplant-MAL-09142016: does not compile on MINGW32 without this include...
#if defined(_WIN32) && defined(__clang__)
#import <windows.h>
#import <winsock2.h>
#endif

#if	USE_ZLIB
#include <zlib.h>
#endif

#ifdef __ANDROID__
#include <android/asset_manager_jni.h>
#endif

struct sockaddr_in;

/**
 * DO NOT USE ... this header is here only for the SSL file handle support
 * and is not intended to be used by anyone else ... it is subject to
 * change or removal without warning.
 */
@interface GSFileHandle : NSFileHandle <RunLoopEvents>
{
#if	GS_EXPOSE(GSFileHandle)
  int			descriptor;
  BOOL			closeOnDealloc;
  BOOL			isStandardFile;
  BOOL			isNullDevice;
  BOOL			isSocket;
  BOOL			isNonBlocking;
  BOOL			wasNonBlocking;
  BOOL			acceptOK;
  BOOL			connectOK;
  BOOL			readOK;
  BOOL			writeOK;
  NSMutableDictionary	*readInfo;
  int			readMax;
  NSMutableArray	*writeInfo;
  int			writePos;
  NSString		*address;
  NSString		*service;
  NSString		*protocol;
#if	USE_ZLIB
  gzFile		gzDescriptor;
#endif
#if	defined(_WIN32)
  WSAEVENT  		event;
#endif
#ifdef __ANDROID__
  AAsset		*asset;
#endif
#endif
}

- (id) initAsClientAtAddress: (NSString*)address
		     service: (NSString*)service
		    protocol: (NSString*)protocol;
- (id) initAsClientInBackgroundAtAddress: (NSString*)address
				 service: (NSString*)service
				protocol: (NSString*)protocol
				forModes: (NSArray*)modes;
- (id) initAsServerAtAddress: (NSString*)address
		     service: (NSString*)service
		    protocol: (NSString*)protocol;
- (id) initForReadingAtPath: (NSString*)path;
- (id) initForWritingAtPath: (NSString*)path;
- (id) initForUpdatingAtPath: (NSString*)path;
- (id) initWithStandardError;
- (id) initWithStandardInput;
- (id) initWithStandardOutput;
- (id) initWithNullDevice;

- (void) checkAccept;
- (void) checkConnect;
- (void) checkRead;
- (void) checkWrite;

- (void) ignoreReadDescriptor;
- (void) ignoreWriteDescriptor;
- (void) setNonBlocking: (BOOL)flag;
- (void) postReadNotification;
- (void) postWriteNotification;
- (NSInteger) read: (void*)buf length: (NSUInteger)len;
- (void) receivedEvent: (void*)data
		  type: (RunLoopEventType)type
	         extra: (void*)extra
	       forMode: (NSString*)mode;

- (void) setAddr: (struct sockaddr *)sin;

- (BOOL) useCompression;
- (void) watchReadDescriptorForModes: (NSArray*)modes;
- (void) watchWriteDescriptor;
- (NSInteger) write: (const void*)buf length: (NSUInteger)len;

@end

#endif /* __GSFileHandle_h_GNUSTEP_BASE_INCLUDE */
