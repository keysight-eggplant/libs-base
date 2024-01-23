########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 01b13228d3ecfd3d555d73daf1c448ad809970a9
# Date: 2016-09-13 20:15:05 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/* Implementation of ShellSort for GNUStep
   Copyright (C) 1995-2012 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>

   Modified by: Niels Grewe <niels.grewe@halbordnung.de>
   Date: September 2012

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

#import "common.h"
#import "Foundation/NSSortDescriptor.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSObjCRuntime.h"
#import "GSSorting.h"

void
_GSShellSort(id *objects,
  NSRange sortRange,
  id comparisonEntity,
  GSComparisonType type,
  void *context)
{
    /* Shell sort algorithm taken from SortingInAction - a NeXT example */
#define STRIDE_FACTOR 3	// good value for stride factor is not well-understood
                        // 3 is a fairly good choice (Sedgewick)
  NSUInteger	c;
  NSUInteger	d;
  NSUInteger	stride = 1;
  BOOL		found;
  NSUInteger	count = NSMaxRange(sortRange);
#ifdef	GSWARN
  BOOL		badComparison = NO;
#endif

  while (stride <= count)
    {
      stride = stride * STRIDE_FACTOR + 1;
    }

  while (stride > (STRIDE_FACTOR - 1))
    {
      // loop to sort for each value of stride
      stride = stride / STRIDE_FACTOR;
      for (c = (sortRange.location + stride); c < count; c++)
	{
	  found = NO;
	  if (stride > c)
	    {
	      break;
	    }
	  d = c - stride;
	  while (!found)	/* move to left until correct place */
	    {
	      id			a = objects[d + stride];
	      id			b = objects[d];
	      NSComparisonResult	r;

	      r = GSCompareUsingDescriptorOrComparator(a, b,
                comparisonEntity, type, context);
	      if (r < 0)
		{
#ifdef	GSWARN
		  if (r != NSOrderedAscending)
		    {
		      badComparison = YES;
		    }
#endif
		  objects[d + stride] = b;
		  objects[d] = a;
		  if (stride > d)
		    {
		      break;
		    }
		  d -= stride;		// jump by stride factor
		}
	      else
		{
#ifdef	GSWARN
		  if (r != NSOrderedDescending && r != NSOrderedSame)
		    {
		      badComparison = YES;
		    }
#endif
		  found = YES;
		}
	    }
	}
    }
#ifdef	GSWARN
  if (badComparison == YES)
    {
      NSWarnFLog(@"Detected bad return value from comparison");
    }
#endif
}


@interface GSShellSortPlaceHolder : NSObject
+ (void) setUnstable;
@end

@implementation GSShellSortPlaceHolder
+ (void) setUnstable
{
  _GSSortUnstable = _GSShellSort;
}
@end

