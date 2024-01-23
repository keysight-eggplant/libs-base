########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 9876794bad1c1b562ab5ec9b4480a46892f2e6dc
# Date: 2018-05-23 18:29:34 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 36f527303dd69064d2bf95c6606ab69374ab1cf7
# Date: 2016-09-17 00:21:01 +0000
########## End of Keysight Technologies Notice ##########
/** 
   Copyright (C) 2008-2009 Free Software Foundation, Inc.

   By: Richard Frith-Macdonald <richard@brainstorm.co.uk>

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

   $Date: 2009-02-23 20:42:32 +0000 (Mon, 23 Feb 2009) $ $Revision: 27962 $
*/

#import "common.h"

#import "GSRunLoopWatcher.h"
#import "Foundation/NSException.h"
#import "Foundation/NSPort.h"

@implementation	GSRunLoopWatcher

- (void) dealloc
{
  [receiver release];
  [super dealloc];
}

- (id) initWithType: (RunLoopEventType)aType
	   receiver: (id)anObj
	       data: (void*)item
{
  _invalidated = NO;
  receiver = [anObj retain];
  data = item;
  switch (aType)
    {
#if	defined(_WIN32)
      case ET_HANDLE:   type = aType;   break;
      case ET_WINMSG:   type = aType;   break;
#else
      case ET_EDESC: 	type = aType;	break;
      case ET_RDESC: 	type = aType;	break;
      case ET_WDESC: 	type = aType;	break;
#endif
      case ET_RPORT: 	type = aType;	break;
      case ET_TRIGGER: 	type = aType;	break;
      default: 
	DESTROY(self);
	[NSException raise: NSInvalidArgumentException
		    format: @"NSRunLoop - unknown event type"];
    }

  if ([anObj respondsToSelector: @selector(runLoopShouldBlock:)])
    {
      checkBlocking = YES;
    }

  if (![anObj respondsToSelector: @selector(receivedEvent:type:extra:forMode:)])
    {
      DESTROY(self);
      [NSException raise: NSInvalidArgumentException
		  format: @"RunLoop listener has no event handling method"];
    }
  return self;
}

- (BOOL) runLoopShouldBlock: (BOOL*)trigger
{
  if (checkBlocking == YES)
    {
      BOOL result = [(id)receiver runLoopShouldBlock: trigger];
      return result;
    }
  else if (type == ET_TRIGGER)
    {
      *trigger = YES;
      return NO;	// By default triggers may fire immediately
    }
  *trigger = YES;
  return YES;		// By default we must wait for input sources
}
@end

