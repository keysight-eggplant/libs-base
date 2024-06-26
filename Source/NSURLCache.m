// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1 
// Date: 2015-07-07 22:31:41 +0000 
// ========== End of Keysight Technologies Notice ========== 
/* Implementation for NSURLCache for GNUstep
   Copyright (C) 2006 Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2006
   
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

#define	EXPOSE_NSURLCache_IVARS	1
#import "GSURLPrivate.h"

// FIXME ... locking and disk storage needed
typedef struct {
  unsigned		diskCapacity;
  unsigned		memoryCapacity;
  unsigned		diskUsage;
  unsigned		memoryUsage;
  NSString		*path;
  NSMutableDictionary	*memory;
} Internal;
 
#define	this	((Internal*)(self->_NSURLCacheInternal))
#define	inst	((Internal*)(o->_NSURLCacheInternal))


static NSURLCache	*shared = nil;

@implementation	NSURLCache

+ (id) allocWithZone: (NSZone*)z
{
  NSURLCache	*o = [super allocWithZone: z];

  if (o != nil)
    {
      o->_NSURLCacheInternal = NSZoneCalloc(z, 1, sizeof(Internal));
    }
  return o;
}

+ (void) setSharedURLCache: (NSURLCache *)cache
{
  [gnustep_global_lock lock];
  ASSIGN(shared, cache);
  [gnustep_global_lock unlock];
}

- (void) dealloc
{
  if (this != 0)
    {
      RELEASE(this->memory);
      RELEASE(this->path);
      NSZoneFree([self zone], this);
    }
  [super dealloc];
}

+ (NSURLCache *) sharedURLCache
{
  NSURLCache	*c;

  [gnustep_global_lock lock];
  if (shared == nil)
    {
      NSString	*path = nil;

// FIXME user-library-path/Caches/current-app-name

      shared = [[self alloc] initWithMemoryCapacity: 4 * 1024 * 1024
				       diskCapacity: 20 * 1024 * 1024
					   diskPath: path];
      
    }
  c = RETAIN(shared);
  [gnustep_global_lock unlock];
  return AUTORELEASE(c);
}

- (NSCachedURLResponse *) cachedResponseForRequest: (NSURLRequest *)request
{
  // FIXME ... handle disk cache
  return [this->memory objectForKey: request];
}

- (NSUInteger) currentDiskUsage
{
  return this->diskUsage;
}

- (NSUInteger) currentMemoryUsage
{
  return this->memoryUsage;
}

- (NSUInteger) diskCapacity
{
  return this->diskCapacity;
}

- (id) initWithMemoryCapacity: (NSUInteger)memoryCapacity
		 diskCapacity: (NSUInteger)diskCapacity
		     diskPath: (NSString *)path
{
  if ((self = [super init]) != nil)
    {
      this->diskUsage = 0;
      this->diskCapacity = diskCapacity;
      this->memoryUsage = 0;
      this->memoryCapacity = memoryCapacity;
      this->path = [path copy];
      this->memory = [NSMutableDictionary new];
    }
  return self;
}

- (NSUInteger) memoryCapacity
{
  return this->memoryCapacity;
}

- (void) removeAllCachedResponses
{
  // FIXME ... disk storage
  [this->memory removeAllObjects];
  this->diskUsage = 0;
  this->memoryUsage = 0;
}

- (void) removeCachedResponseForRequest: (NSURLRequest *)request
{
  NSCachedURLResponse	*item = [self cachedResponseForRequest: request];

  if (item != nil)
    {
      // FIXME ... disk storage
      this->memoryUsage -= [[item data] length];
      [this->memory removeObjectForKey: request];
    }
}

- (void) setDiskCapacity: (NSUInteger)diskCapacity
{
  [self notImplemented: _cmd];
  // FIXME
}

- (void) setMemoryCapacity: (NSUInteger)memoryCapacity
{
  [self notImplemented: _cmd];
  // FIXME
}

- (void) storeCachedResponse: (NSCachedURLResponse *)cachedResponse
		  forRequest: (NSURLRequest *)request
{
  switch ([cachedResponse storagePolicy])
    {
      case NSURLCacheStorageAllowed:
// FIXME ... maybe on disk?

      case NSURLCacheStorageAllowedInMemoryOnly:
        {
	  unsigned		size = [[cachedResponse data] length];

	  if (size < this->memoryCapacity)
	    {
	      NSCachedURLResponse	*old;

	      old = [this->memory objectForKey: request];
	      if (old != nil)
		{
		  this->memoryUsage -= [[old data] length];
		  [this->memory removeObjectForKey: request];
		}
	      while (this->memoryUsage + size > this->memoryCapacity)
	        {
// FIXME ... should delete least recently used.
		  [self removeCachedResponseForRequest:
		    [[this->memory allKeys] lastObject]];
		}
	      [this->memory setObject: cachedResponse forKey: request];
	      this->memoryUsage += size;
	    }
	  }
        break;

      case NSURLCacheStorageNotAllowed:
        break;

      default:
        [NSException raise: NSInternalInconsistencyException
		    format: @"storing cached response with bad policy (%d)",
		    [cachedResponse storagePolicy]];
    }
}

@end

