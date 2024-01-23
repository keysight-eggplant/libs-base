########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: dba962b1310647a291b6583d24a5cafa3a6c49c5
# Date: 2020-05-18 12:06:59 -0400
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
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

#include <ctype.h>

#import "GNUstepBase/NSNumber+GNUstepBase.h"

/**
 * GNUstep specific (non-standard) additions to the NSNumber class.
 */
@implementation NSNumber(GNUstepBase)

+ (NSValue*) valueFromString: (NSString*)string
{
  /* FIXME: implement this better */
  const char *str;

  str = [string UTF8String];
  if (strchr(str, '.') != NULL || strchr(str, 'e') != NULL
    || strchr(str, 'E') != NULL)
    return [NSNumber numberWithDouble: atof(str)];
  else if (strchr(str, '-') >= 0)
    return [NSNumber numberWithInt: atoi(str)];
  return [NSNumber numberWithUnsignedInt: atoi(str)];
}

@end
