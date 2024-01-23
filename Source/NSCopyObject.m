########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: cc1ee6d6fb9ced9b8f2a53cf4403a8011cbd077e
# Date: 2016-09-21 19:44:33 +0000
--------------------
# Committed by: Paul Landers
# Commit ID: 079300f4d63c660a31974806ece74215985e66ac
# Date: 2016-02-25 21:53:18 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: b3f07821a081642c549fe349804ab13e8a3305b0
# Date: 2016-01-15 17:34:11 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 1552b7f3eee7d0a7890a365413ccacd01660e549
# Date: 2016-01-11 19:15:05 +0000
########## End of Keysight Technologies Notice ##########
/** Implementation of NSCopyObject() for GNUStep
   Copyright (C) 1994, 1995 Free Software Foundation, Inc.

   Written by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
   Date: August 1994

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

   <title>NSCopyObject class reference</title>
   $Date$ $Revision$
   */

#import "common.h"

NSObject *NSCopyObject(NSObject *anObject, NSUInteger extraBytes, NSZone *zone)
{
  Class	c = object_getClass(anObject);
  id copy = NSAllocateObject(c, extraBytes, zone);
  
  memcpy(copy, anObject, class_getInstanceSize(c) + extraBytes);
  return copy;
}
