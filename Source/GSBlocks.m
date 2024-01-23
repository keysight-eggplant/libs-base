########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 5bc407fb05ae03c77c05bcbc3cd6bea974b958f6
# Date: 2020-06-05 18:09:29 -0400
--------------------
# Committed by: Adam Fox
# Commit ID: b9587ee904e83bb52ede1b26de2143b9be7db178
# Date: 2020-01-02 20:53:16 -0700
--------------------
# Committed by: Adam Fox
# Commit ID: d0c80b003b55d818462c2d1e37388aaf2742d3e9
# Date: 2020-01-02 18:53:42 -0700
--------------------
# Committed by: Paul Landers
# Commit ID: c3ba1c91feaebf0299955f11f044b0a2a46f7b6b
# Date: 2019-02-27 13:31:48 -0700
########## End of Keysight Technologies Notice ##########
/** Implementation of GSBlocks for GNUStep
   Copyright (C) 2011 Free Software Foundation, Inc.

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

#import "Foundation/NSObject.h"

/* Declare the block copy functions ourself so that we don't depend on a
 * specific header location.
 */
// Testplant -- this workaround is temporary until we move to a newer libobjc on linux.
#ifndef __MINGW32__
void *_Block_copy(void *);
void _Block_release(void *);
#else
// Testplant -- keep this part when moving to newer libobjc on linux.
void *_Block_copy(const void *);
void _Block_release(const void *);
#endif // __MINGW32__

@interface GSBlock : NSObject
@end

@implementation GSBlock
+ (void) load
{
  unsigned int	methodCount;
  Method	*m = NULL;
  Method	*methods = class_copyMethodList(self, &methodCount);
  id		blockClass = objc_lookUpClass("_NSBlock");
  Protocol	*nscopying = NULL;

  /* If we don't have an _NSBlock class, we don't have blocks support in the
   * runtime, so give up.
   */
  if (nil == blockClass)
    {
      return;
    }

  /* Copy all of the methods in this class onto the block-runtime-provided
   * _NSBlock
   */
  for (m = methods; NULL != *m; m++)
    {
      class_addMethod(blockClass, method_getName(*m),
	method_getImplementation(*m), method_getTypeEncoding(*m));
    }
  nscopying = objc_getProtocol("NSCopying");
  class_addProtocol(blockClass, nscopying);
  free(methods);
}

- (id) copyWithZone: (NSZone*)aZone
{
  return _Block_copy(self);
}

- (id) copy
{
  return _Block_copy(self);
}

- (id) retain
{
  return _Block_copy(self);
}

- (oneway void) release
{
  _Block_release(self);
}
@end
