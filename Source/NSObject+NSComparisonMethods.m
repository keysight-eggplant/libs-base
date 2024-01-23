########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: b37395de2662f57739febe7827841e60a50a61c9
# Date: 2012-09-12 00:35:58 +0000
########## End of Keysight Technologies Notice ##########
/** Implementation of NSObject+NSComparisonMethods for GNUStep
   Copyright (C) 2008 Free Software Foundation, Inc.

   Written by:  Gregory Casamento <greg_casamento@yahoo.com>
   Date: 2008

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

   <title>NSObject+NSComparisonMethods category reference</title>
   $Date: 2008-11-26 04:20:34 -0500 (Wed, 26 Nov 2008) $ $Revision: 27135 $
*/

#import "common.h"
#import "Foundation/NSArray.h"

@implementation NSObject (NSComparisonMethods)
- (BOOL) doesContain: (id) object
{
  if (object)
    {
      if ([self isKindOfClass: [NSArray class]])
	{
	  [(NSArray *)self containsObject: object];
	}
    }
  return NO;
}

- (BOOL) isCaseInsensitiveLike: (id) object
{
  NSLog(@"%@ not implemented yet", NSStringFromSelector(_cmd));
  return NO;
}

- (BOOL) isEqualTo: (id) object
{
  return [self isEqual: object];
}

- (BOOL) isGreaterThan: (id) object
{
  return ([self compare: object] == NSOrderedDescending);
}

- (BOOL) isGreaterThanOrEqualTo: (id) object
{
  return ([self compare: object] == NSOrderedDescending ||
	  [self compare: object] == NSOrderedSame);
}

- (BOOL) isLessThan: (id) object
{
  return ([self compare: object] == NSOrderedAscending);
}

- (BOOL) isLessThanOrEqualTo: (id) object
{
  return ([self compare: object] == NSOrderedAscending ||
	  [self compare: object] == NSOrderedSame);
}

- (BOOL) isLike: (NSString *)object
{
  NSLog(@"%@ not implemented yet", NSStringFromSelector(_cmd));
  return NO;
}

- (BOOL) isNotEqualTo: (id) object
{
  return !([self isEqual: object]);
}
@end
