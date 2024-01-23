########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 28e3291df1d6981b07367eb896b8a2a23035a72a
# Date: 2016-09-23 16:59:14 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/** NSHashTable implementation for GNUStep.
 * Copyright (C) 2009  Free Software Foundation, Inc.
 *
 * Author: Richard Frith-Macdonald <rfm@gnu.org>
 *
 * This file is part of the GNUstep Base Library.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02111 USA.
 *
 * <title>NSHashTable class reference</title>
 * $Date$ $Revision$
 */

#import "common.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSException.h"
#import "Foundation/NSPointerFunctions.h"
#import "Foundation/NSSet.h"
#import "Foundation/NSHashTable.h"
#import "NSCallBacks.h"
#import "GSPrivate.h"

@interface	NSConcreteHashTable : NSHashTable
@end

@implementation	NSHashTable


static Class	abstractClass = 0;
static Class	concreteClass = 0;

+ (id) allocWithZone: (NSZone*)aZone
{
  if (self == abstractClass)
    {
      return NSAllocateObject(concreteClass, 0, aZone);
    }
  return NSAllocateObject(self, 0, aZone);
}

+ (void) initialize
{
  if (abstractClass == 0)
    {
      abstractClass = [NSHashTable class];
      concreteClass = [NSConcreteHashTable class];
    }
}

+ (id) hashTableWithOptions: (NSPointerFunctionsOptions)options
{
  NSHashTable	*t;

  t = [self allocWithZone: NSDefaultMallocZone()];
  t = [t initWithOptions: options
		capacity: 0];
  return AUTORELEASE(t);
}

+ (id) hashTableWithWeakObjects
{
  return [self hashTableWithOptions:
    NSPointerFunctionsObjectPersonality | NSPointerFunctionsZeroingWeakMemory];
}

+ (id) weakObjectsHashTable
{
  return [self hashTableWithOptions:
    NSPointerFunctionsObjectPersonality | NSPointerFunctionsWeakMemory];
}

- (id) initWithOptions: (NSPointerFunctionsOptions)options
	      capacity: (NSUInteger)initialCapacity
{
  NSPointerFunctions	*k;
  id			o;

  k = [[NSPointerFunctions alloc] initWithOptions: options];
  o = [self initWithPointerFunctions: k capacity: initialCapacity];
  [k release];
  return o;
}

- (id) initWithPointerFunctions: (NSPointerFunctions*)functions
		       capacity: (NSUInteger)initialCapacity
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) addObject: (id)object
{
  [self subclassResponsibility: _cmd];
}

- (NSArray*) allObjects
{
  NSEnumerator	*enumerator;
  unsigned	nodeCount = [self count];
  unsigned	index;
  NSArray	*a;
  GS_BEGINITEMBUF(objects, nodeCount, id);

  enumerator = [self objectEnumerator];
  index = 0;
  while (index < nodeCount && (objects[index] = [enumerator nextObject]) != nil)
    {
      index++;
    }
  a = [[[NSArray alloc] initWithObjects: objects count: index] autorelease];
  GS_ENDITEMBUF();
  return a;
}

- (id) anyObject
{
  return [[self objectEnumerator] nextObject];
}

- (BOOL) containsObject: (id)anObject
{
  return [self member: anObject] ? YES : NO;
}

- (id) copyWithZone: (NSZone*)aZone
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (NSUInteger) count
{
  return (NSUInteger)[self subclassResponsibility: _cmd];
}

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state 	
				   objects: (id*)stackbuf
				     count: (NSUInteger)len
{
  return (NSUInteger)[self subclassResponsibility: _cmd];
}

- (void) encodeWithCoder: (NSCoder*)aCoder
{
  [self subclassResponsibility: _cmd];
}

- (NSUInteger) hash
{
  return [self count];
}

- (id) initWithCoder: (NSCoder*)aCoder
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (void) intersectHashTable: (NSHashTable*)other
{
  unsigned		count = [self count];

  if (count > 0)
    {
      NSEnumerator	*enumerator;
      NSMutableArray	*array;
      id		object;

      array = [NSMutableArray arrayWithCapacity: count];
      enumerator = [self objectEnumerator];
      while ((object = [enumerator nextObject]) != nil)
	{
	  if ([other member: object] == nil)
	    {
	      [array addObject: object];
	    }
	}
      enumerator = [array objectEnumerator];
      while ((object = [enumerator nextObject]) != nil)
	{
	  [self removeObject: object];
	}
    }
}

- (BOOL) intersectsHashTable: (NSHashTable*)other
{
  NSEnumerator	*enumerator;
  id		object;

  enumerator = [self objectEnumerator];
  while ((object = [enumerator nextObject]) != nil)
    {
      if ([other member: object] != nil)
	{
	  return YES;
	}
    }
  return NO;
}

- (BOOL) isEqual: (id)other
{
  if ([other isKindOfClass: abstractClass] == NO) return NO;
  return NSCompareHashTables(self, other);
}

- (BOOL) isEqualToHashTable: (NSHashTable*)other
{
  return NSCompareHashTables(self, other);
}

- (BOOL) isSubsetOfHashTable: (NSHashTable*)other
{
  NSEnumerator	*enumerator;
  id		object;

  enumerator = [self objectEnumerator];
  while ((object = [enumerator nextObject]) != nil)
    {
      if ([other member: object] == nil)
	{
	  return NO;
	}
    }
  return YES;
}

- (id) member: (id)object
{
  return [self subclassResponsibility: _cmd];
}

- (void) minusHashTable: (NSHashTable*)other
{
  if ([self count] > 0 && [other count] > 0)
    {
      NSEnumerator	*enumerator;
      id		object;

      enumerator = [other objectEnumerator];
      while ((object = [enumerator nextObject]) != nil)
	{
	  [self removeObject: object];
	}
    }
}

- (NSEnumerator*) objectEnumerator
{
  return [self subclassResponsibility: _cmd];
}

- (NSPointerFunctions*) pointerFunctions
{
  return [self subclassResponsibility: _cmd];
}

- (void) removeAllObjects
{
  NSEnumerator	*enumerator;
  id		object;

  enumerator = [[self allObjects] objectEnumerator];
  while ((object = [enumerator nextObject]) != nil)
    {
      [self removeObject: object];
    }
}

- (void) removeObject: (id)object
{
  [self subclassResponsibility: _cmd];
}

- (NSSet*) setRepresentation 
{
  NSEnumerator	*enumerator;
  NSMutableSet	*set;
  id		object;

  set = [NSMutableSet setWithCapacity: [self count]];
  enumerator = [[self allObjects] objectEnumerator];
  while ((object = [enumerator nextObject]) != nil)
    {
      [set addObject: object];
    }
  return [[set copy] autorelease];
}

- (void) unionHashTable: (NSHashTable*)other
{
  NSEnumerator	*enumerator;
  id		object;

  enumerator = [other objectEnumerator];
  while ((object = [enumerator nextObject]) != nil)
    {
      [self addObject: object];
    }
}

@end

