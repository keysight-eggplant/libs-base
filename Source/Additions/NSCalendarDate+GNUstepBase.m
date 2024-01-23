########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: dba962b1310647a291b6583d24a5cafa3a6c49c5
# Date: 2020-05-18 12:06:59 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
/* Implementation of extension methods to base additions

   Copyright (C) 2010 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>

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
#import "Foundation/NSAutoreleasePool.h"
#import "GNUstepBase/NSCalendarDate+GNUstepBase.h"

/**
 * Extension methods for the NSCalendarDate class
 */
@implementation NSCalendarDate (GNUstepBase)

- (NSUInteger) isoYear
{
  NSUInteger year = [self yearOfCommonEra];
  NSUInteger week = [self weekOfYear];
  NSUInteger month = [self monthOfYear];

  if (week == 1 && month == 12)
    {
      year++;
    }
  else if (week >= 52 && month == 1)
    {
      year--;
    }
  return year;
}

/**
 * The ISO standard week of the year is based on the first week of the
 * year being that week (starting on monday) for which the thursday
 * is on or after the first of january.<br />
 * This has the effect that, if january first is a friday, saturday or
 * sunday, the days of that week (up to and including the sunday) are
 * considered to be in week 53 of the preceding year. Similarly if the
 * last day of the year is a monday tuesday or wednesday, these days are
 * part of week 1 of the next year.
 */
- (NSInteger) weekOfYear
{
  NSInteger	dayOfWeek = [self dayOfWeek];
  NSInteger	dayOfYear;

  /*
   * Whether a week is considered to be in a year or not depends on its
   * thursday ... so find thursday for the receivers week.
   * NB. this may result in a date which is not in the same year as the
   * receiver.
   */
  if (dayOfWeek != 4)
    {
      NSAutoreleasePool	*arp = [NSAutoreleasePool new];
      NSCalendarDate	*thursday;

      /*
       * A week starts on monday ... so adjust from 0 to 7 so that a
       * sunday is counted as the last day of the week.
       */
      if (dayOfWeek == 0)
	{
	  dayOfWeek = 7;
	}
      thursday = [self dateByAddingYears: 0
				  months: 0
				    days: 4 - dayOfWeek
				   hours: 0
				 minutes: 0
				 seconds: 0];
      dayOfYear = [thursday dayOfYear];
      [arp drain];
    }
  else
    {
      dayOfYear = [self dayOfYear];
    }

  /*
   * Round up to a week boundary, so that when we divide by seven we
   * get a result in the range 1 to 53 as mandated by the ISO standard.
   * Note that dayOfYear starts at 1, too, and hence we must be careful
   * to not round up an exact multiple of 7.
   */
  dayOfYear += (7 - (dayOfYear - 1) % 7);
  return dayOfYear / 7;
}

@end
