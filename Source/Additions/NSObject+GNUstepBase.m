########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: dba962b1310647a291b6583d24a5cafa3a6c49c5
# Date: 2020-05-18 12:06:59 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 8dd5a324fe74052aedba5cd42d36eed3d2a644d8
# Date: 2016-12-07 18:16:36 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: f0c19b9e89191fada9b2d35bf06fe21c67469c98
# Date: 2016-09-13 20:42:43 +0000
--------------------
# Committed by: Aarti Munjal
# Commit ID: 1a76eb1ccf918f2da6776518a7f06ffb341696c8
# Date: 2016-05-25 14:28:25 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 73161fea0d182352afe814098c5dc7f78992c523
# Date: 2016-03-08 22:04:34 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
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
#import "Foundation/NSArray.h"
#import "Foundation/NSException.h"
#import "Foundation/NSHashTable.h"
#import "Foundation/NSLock.h"
#import "GNUstepBase/GSObjCRuntime.h"
#import "GNUstepBase/NSObject+GNUstepBase.h"
#import "GNUstepBase/NSDebug+GNUstepBase.h"
#import "GNUstepBase/NSThread+GNUstepBase.h"

#ifdef HAVE_MALLOC_H
#include	<malloc.h>
#endif

/* This file contains methods which nominally return an id but in fact
 * always rainse an exception and never return.
 * We need to suppress the compiler warning about that.
 */
#pragma GCC diagnostic ignored "-Wreturn-type"

/**
 * Extension methods for the NSObject class
 */
@implementation NSObject (GNUstepBase)

+ (id) notImplemented: (SEL)selector
{
  [NSException raise: NSGenericException
    format: @"method %@ not implemented in %@(class)",
    selector ? (id)NSStringFromSelector(selector) : (id)@"(null)",
    NSStringFromClass(self)];
  while (1) ;   // Does not return
}

- (NSComparisonResult) compare: (id)anObject
{
  GSOnceMLog(@"WARNING: The -compare: method for NSObject is deprecated.");

  if (anObject == self)
    {
      return NSOrderedSame;
    }
  if (anObject == nil)
    {
      [NSException raise: NSInvalidArgumentException
		   format: @"nil argument for compare:"];
    }
  if ([self isEqual: anObject])
    {
      return NSOrderedSame;
    }
  /*
   * Ordering objects by their address is pretty useless,
   * so subclasses should override this is some useful way.
   */
  if ((id)self > anObject)
    {
      return NSOrderedDescending;
    }
  else
    {
      return NSOrderedAscending;
    }
}

- (BOOL) isInstance
{
  GSOnceMLog(@"Warning, the -isInstance method is deprecated. "
    @"Use 'class_isMetaClass([self class]) ? NO : YES' instead");
  return class_isMetaClass([self class]) ? NO : YES;
}

- (BOOL) makeImmutable
{
  return NO;
}

- (id) makeImmutableCopyOnFail: (BOOL)force
{
  if (force == YES)
    {
      return AUTORELEASE([self copy]);
    }
  return self;
}

- (id) notImplemented: (SEL)aSel
{
  char	c = (class_isMetaClass(object_getClass(self)) ? '+' : '-');

  [NSException
    raise: NSInvalidArgumentException
    format: @"[%@%c%@] not implemented",
    NSStringFromClass([self class]), c,
    aSel ? (id)NSStringFromSelector(aSel) : (id)@"(null)"];
  while (1) ;   // Does not return
}

- (id) shouldNotImplement: (SEL)aSel
{
  char	c = (class_isMetaClass(object_getClass(self)) ? '+' : '-');

  [NSException
    raise: NSInvalidArgumentException
    format: @"[%@%c%@] should not be implemented",
    NSStringFromClass([self class]), c,
    aSel ? (id)NSStringFromSelector(aSel) : (id)@"(null)"];
  while (1) ;   // Does not return
}

- (id) subclassResponsibility: (SEL)aSel
{
  char	c = (class_isMetaClass(object_getClass(self)) ? '+' : '-');

  [NSException raise: NSInvalidArgumentException
    format: @"[%@%c%@] should be overridden by subclass",
    NSStringFromClass([self class]), c,
    aSel ? (id)NSStringFromSelector(aSel) : (id)@"(null)"];
  while (1) ;   // Does not return
}

@end

#if     defined(GNUSTEP)
struct exitLink {
  struct exitLink	*next;
  id			obj;	// Object to release or class for atExit
  SEL			sel;	// Selector for atExit or 0 if releasing
  id			*at;	// Address of static variable or NULL
};

static struct exitLink	*exited = 0;
static BOOL		enabled = NO;
static BOOL		shouldCleanUp = NO;
static NSLock           *exitLock = nil;

static inline void setup()
{
  if (nil == exitLock)
    {
      [gnustep_global_lock lock];
      if (nil == exitLock)
        {
          exitLock = [NSLock new];
        } 
      [gnustep_global_lock unlock];
    }
}

static void
handleExit()
{
  BOOL  unknownThread = GSRegisterCurrentThread();
  CREATE_AUTORELEASE_POOL(arp);

  while (exited != 0)
    {
      struct exitLink	*tmp = exited;

      exited = tmp->next;
      if (0 != tmp->sel)
	{
	  Method	method;
	  IMP		msg;

	  method = class_getClassMethod(tmp->obj, tmp->sel);
	  msg = method_getImplementation(method);
	  if (0 != msg)
	    {
	      (*msg)(tmp->obj, tmp->sel);
	    }
	}
      else if (YES == shouldCleanUp)
	{
	  if (0 != tmp->at)
	    {
	      tmp->obj = *(tmp->at);
	      *(tmp->at) = nil;
	    }
	  [tmp->obj release];
	}
      free(tmp);
    }
  DESTROY(arp);
  if (unknownThread == YES)
    {
      GSUnregisterCurrentThread();
    }
}

@implementation NSObject(GSCleanup)

+ (id) leakAt: (id*)anAddress
{
  struct exitLink	*l;

  l = (struct exitLink*)malloc(sizeof(struct exitLink));
  l->at = anAddress;
  l->obj = [*anAddress retain];
  l->sel = 0;
  setup();
  [exitLock lock];
  l->next = exited;
  exited = l;
  [exitLock unlock];
  return l->obj;
}

+ (id) leak: (id)anObject
{
  struct exitLink	*l;

  l = (struct exitLink*)malloc(sizeof(struct exitLink));
  l->at = 0;
  l->obj = [anObject retain];
  l->sel = 0;
  setup();
  [exitLock lock];
  l->next = exited;
  exited = l;
  [exitLock unlock];
  return l->obj;
}

+ (BOOL) registerAtExit
{
  return [self registerAtExit: @selector(atExit)];
}

+ (BOOL) registerAtExit: (SEL)sel
{
  Method		m;
  Class			s;
  struct exitLink	*l;

  if (0 == sel)
    {
      sel = @selector(atExit);
    }

  m = class_getClassMethod(self, sel);
  if (0 == m)
    {
      return NO;	// method not implemented.
    }

  s = class_getSuperclass(self);
  if (0 != s && class_getClassMethod(s, sel) == m)
    {
      return NO;	// method not implemented in this class
    }

  setup();
  [exitLock lock];
  for (l = exited; l != 0; l = l->next)
    {
      if (l->obj == self && sel_isEqual(l->sel, sel))
	{
	  [exitLock unlock];
	  return NO;	// Already registered
	}
    }
  l = (struct exitLink*)malloc(sizeof(struct exitLink));
  l->obj = self;
  l->sel = sel;
  l->at = 0;
  l->next = exited;
  exited = l;
  if (NO == enabled)
    {
      atexit(handleExit);
      enabled = YES;
    }
  [exitLock unlock];
  return YES;
}

+ (void) setShouldCleanUp: (BOOL)aFlag
{
  if (YES == aFlag)
    {
      setup();
      [exitLock lock];
      if (NO == enabled)
	{
	  atexit(handleExit);
	  enabled = YES;
	}
      [exitLock unlock];
      shouldCleanUp = YES;
    }
  else
    {
      shouldCleanUp = NO;
    }
}

+ (BOOL) shouldCleanUp
{
  return shouldCleanUp;
}

@end

#else

@implementation NSObject (MemoryFootprint)
+ (NSUInteger) contentSizeOf: (NSObject*)obj
		   excluding: (NSHashTable*)exclude
{
  Class		cls = object_getClass(obj);
  NSUInteger	size = 0;

  while (cls != Nil)
    {
      unsigned	count;
      Ivar	*vars;

      if (0 != (vars = class_copyIvarList(cls, &count)))
	{
	  while (count-- > 0)
	    {
	      const char	*type = ivar_getTypeEncoding(vars[count]);

	      type = GSSkipTypeQualifierAndLayoutInfo(type);
	      if ('@' == *type)
		{
		  NSObject	*content = object_getIvar(obj, vars[count]);

		  if (content != nil)
		    {
		      size += [content sizeInBytesExcluding: exclude];
		    }
		}
	    }
	  free(vars);
	}
      cls = class_getSuperclass(cls);
    }
  return size;
}
+ (NSUInteger) sizeInBytes
{
  return 0;
}
+ (NSUInteger) sizeInBytesExcluding: (NSHashTable*)exclude
{
  return 0;
}
+ (NSUInteger) sizeOfContentExcluding: (NSHashTable*)exclude
{
  return 0;
}
+ (NSUInteger) sizeOfInstance
{
  return 0;
}
- (NSUInteger) sizeInBytes
{
  NSUInteger	bytes;
  NSHashTable	*exclude;
 
  exclude = NSCreateHashTable(NSNonOwnedPointerHashCallBacks, 0);
  bytes = [self sizeInBytesExcluding: exclude];
  NSFreeHashTable(exclude);
  return bytes;
}
- (NSUInteger) sizeInBytesExcluding: (NSHashTable*)exclude
{
  if (0 == NSHashGet(exclude, self))
    {
      NSUInteger        size = [self sizeOfInstance];

      NSHashInsert(exclude, self);
      if (size > 0)
        {
	  size += [self sizeOfContentExcluding: exclude];
        }
      return size;
    }
  return 0;
}
- (NSUInteger) sizeOfContentExcluding: (NSHashTable*)exclude
{
  return 0;
}
- (NSUInteger) sizeOfInstance
{
  NSUInteger    size;

#if     GS_SIZEOF_VOIDP > 4
  NSUInteger	xxx = (NSUInteger)(void*)self;

  if (xxx & 0x07)
    {
      return 0; // Small object has no size
    }
#endif

#if 	HAVE_MALLOC_USABLE_SIZE
  size = malloc_usable_size((void*)self - sizeof(intptr_t));
#else
  size = class_getInstanceSize(object_getClass(self));
#endif

  return size;
}

@end

/* Dummy implementation
 */
@implementation NSObject(GSCleanup)

+ (id) leakAt: (id*)anAddress
{
  [*anAddress retain];
}

+ (id) leak: (id)anObject
{
  return [anObject retain];
}

+ (BOOL) registerAtExit
{
  return [self registerAtExit: @selector(atExit)];
}

+ (BOOL) registerAtExit: (SEL)sel
{
  return NO;
}

+ (void) setShouldCleanUp: (BOOL)aFlag
{
  return;
}

+ (BOOL) shouldCleanUp
{
  return NO;
}

@end

#endif

