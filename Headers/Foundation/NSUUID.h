// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1 
// Date: 2015-07-07 22:31:41 +0000 
// ========== End of Keysight Technologies Notice ========== 
/* Interface for NSUUID for GNUStep
   Copyright (C) 2013 Free Software Foundation, Inc.

   Written by:  Graham Lee <graham@iamleeg.com>
   Created: 2013
   
   This file is part of the GNUstep Base Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.
   */ 

#ifndef __NSUUID_h_GNUSTEP_BASE_INCLUDE
#define __NSUUID_h_GNUSTEP_BASE_INCLUDE

#import <GNUstepBase/GSVersionMacros.h>
#import	<Foundation/NSObject.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_8,GS_API_LATEST)

#if	defined(__cplusplus)
extern "C" {
#endif

typedef uint8_t gsuuid_t[16];

#if	defined(uuid_t)
#undef	uuid_t
#endif
#define	uuid_t	gsuuid_t


@class NSString;

@interface NSUUID : NSObject <NSCopying, NSCoding>
{
  @private
  gsuuid_t uuid;
}

+ (id)UUID;
- (id)initWithUUIDString:(NSString *)string;
- (id)initWithUUIDBytes:(gsuuid_t)bytes;
- (NSString *)UUIDString;
- (void)getUUIDBytes:(gsuuid_t)bytes;

@end

#if     defined(__cplusplus)
}
#endif

#endif

#endif /* __NSUUID_h_GNUSTEP_BASE_INCLUDE */
