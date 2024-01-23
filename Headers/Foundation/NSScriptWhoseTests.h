########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Frank Le Grand
# Commit ID: f610b134e138a6d3527261a7a7ebd0d1ed95c520
# Date: 2013-10-31 20:42:07 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: b37395de2662f57739febe7827841e60a50a61c9
# Date: 2012-09-12 00:35:58 +0000
########## End of Keysight Technologies Notice ##########
/*
   Global include file for the GNUstep Base Library.

   Copyright (C) 1997 Free Software Foundation, Inc.

   Date: Sep 2012
   
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

#ifndef __NSScriptWhoseTests_h_GNUSTEP_BASE_INCLUDE
#define __NSScriptWhoseTests_h_GNUSTEP_BASE_INCLUDE

#import <Foundation/NSObject.h>

@interface NSObject (NSComparisonMethods)
- (BOOL) doesContain: (id) object;
- (BOOL) isCaseInsensitiveLike: (id) object;
- (BOOL) isEqualTo: (id) object;
- (BOOL) isGreaterThan: (id) object;
- (BOOL) isGreaterThanOrEqualTo: (id) object;
- (BOOL) isLessThan: (id) object;
- (BOOL) isLessThanOrEqualTo: (id) object;
- (BOOL) isLike: (NSString *)object;
- (BOOL) isNotEqualTo: (id) object;
@end

#endif /* __NSScriptWhoseTests_h_GNUSTEP_BASE_INCLUDE */
