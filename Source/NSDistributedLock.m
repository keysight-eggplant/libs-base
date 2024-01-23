########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 25db3b4ad4f206e078b1854ecf99161ec643e5ad
# Date: 2017-06-20 14:48:15 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 3047907edbc861099fe405a1b33bbc190621a63f
# Date: 2016-09-13 22:29:24 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 8f66bdf4a65b1d690a41a63396f162902139861c
# Date: 2013-07-03 20:03:28 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: fb5432fdecbf837a5723d49f4166e1dc6a02e706
# Date: 2013-07-03 15:04:45 +0000
########## End of Keysight Technologies Notice ##########
/** Implementation for GNU Objective-C version of NSDistributedLock
   Copyright (C) 1997 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <richard@brainstorm.co.uk>
   Created: November 1997

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

   <title>NSDistributedLock class reference</title>
   $Date$ $Revision$
   */

#import "common.h"
#define	EXPOSE_NSDistributedLock_IVARS	1
#import "Foundation/NSDistributedLock.h"
#import "Foundation/NSException.h"
#import "Foundation/NSFileManager.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSValue.h"
#import "GSPrivate.h"


#if	defined(HAVE_SYS_FCNTL_H)
#  include	<sys/fcntl.h>
#elif	defined(HAVE_FCNTL_H)
#  include	<fcntl.h>
#endif

#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

#ifdef HAVE_WINDOWS_H
#  include <windows.h>
#endif


static NSFileManager	*mgr = nil;

/**
 *  This class does not adopt the [(NSLocking)] protocol but supports locking
 *  across processes, including processes on different machines, as long as
 *  they can access a common filesystem.
 */
@implementation NSDistributedLock

+ (void) initialize
{
  if (mgr == nil)
    {
      mgr = RETAIN([NSFileManager defaultManager]);
      [[NSObject leakAt: &mgr] release];
    }
}

/**
 * Return a distributed lock for aPath.
 * See -initWithPath: for details.
 */
+ (NSDistributedLock*) lockWithPath: (NSString*)aPath
{
  return AUTORELEASE([[self alloc] initWithPath: aPath]);
}

/**
 * Forces release of the lock whether the receiver owns it or not.<br />
 * Raises an NSGenericException if unable to remove the lock.
 */
- (void) breakLock
{
  [_localLock lock];
  NS_DURING
    {
      NSDictionary	*attributes;

      if (nil != _lockTime)
	{
	  NSLog(@"Breaking our own distributed lock %@", _lockPath);
        }
      DESTROY(_lockTime);
      attributes = [mgr fileAttributesAtPath: _lockPath traverseLink: YES];
      if (attributes != nil)
	{
	  NSDate	*modDate = [attributes fileModificationDate];

	  if ([mgr removeFileAtPath: _lockPath handler: nil] == NO)
	    {
	      NSString	*err = [[NSError _last] localizedDescription];

	      attributes = [mgr fileAttributesAtPath: _lockPath
					traverseLink: YES];
	      if ([modDate isEqual: [attributes fileModificationDate]] == YES)
		{
		  [NSException raise: NSGenericException
		    format: @"Failed to remove lock directory '%@' - %@",
		    _lockPath, err];
		}
	    }
	}
    }
  NS_HANDLER
    {
      [_localLock unlock];
      [localException raise];
    }
  NS_ENDHANDLER
  [_localLock unlock];
}

- (void) dealloc
{
  if (_lockTime != nil)
    {
      NSLog(@"[%@-dealloc] still locked for %@ since %@",
        NSStringFromClass([self class]), _lockPath, _lockTime);
      [self unlock];
    }
  RELEASE(_lockPath);
  RELEASE(_lockTime);
  RELEASE(_localLock);
  [super dealloc];
}

- (NSString*) description
{
  NSString	*result;

  [_localLock lock];
  if (_lockTime == nil)
    {
      result = [[super description] stringByAppendingFormat:
        @" path '%@' not locked", _lockPath];
    }
  else
    {
      result = [[super description] stringByAppendingFormat:
        @" path '%@' locked at %@", _lockPath, _lockTime];
    }
  [_localLock unlock];
  return result;
}

/**
 * Initialises the receiver with the specified filesystem path.<br />
 * The location in the filesystem must be accessible for this
 * to be usable.  That is, the processes using the lock must be able
 * to access, create, and destroy files at the path.<br />
 * The directory in which the last path component resides must already
 * exist ... create it using NSFileManager if you need to.
 */
- (id) initWithPath: (NSString*)aPath
{
  NSString	*lockDir;
  BOOL		isDirectory;

  _localLock = [NSLock new];
  _lockPath = [[aPath stringByStandardizingPath] copy];
  _lockTime = nil;

  lockDir = [_lockPath stringByDeletingLastPathComponent];
  if ([mgr fileExistsAtPath: lockDir isDirectory: &isDirectory] == NO)
    {
      NSLog(@"part of the path to the lock file '%@' is missing\n", aPath);
      DESTROY(self);
      return nil;
    }
  if (isDirectory == NO)
    {
      NSLog(@"part of the path to the lock file '%@' is not a directory\n",
	_lockPath);
      DESTROY(self);
      return nil;
    }
  if ([mgr isWritableFileAtPath: lockDir] == NO)
    {
      NSLog(@"parent directory of lock file '%@' is not writable\n", _lockPath);
      DESTROY(self);
      return nil;
    }
  if ([mgr isExecutableFileAtPath: lockDir] == NO)
    {
      NSLog(@"parent directory of lock file '%@' is not accessible\n",
		_lockPath);
      DESTROY(self);
      return nil;
    }
  return self;
}

/**
 * Returns the date at which the lock was acquired by <em>any</em>
 * NSDistributedLock using the same path.  If nothing has
 * the lock, this returns nil.
 */
- (NSDate*) lockDate
{
  NSDictionary	*attributes;

  attributes = [mgr fileAttributesAtPath: _lockPath traverseLink: YES];
  return [attributes fileModificationDate];
}

/**
 * Attempt to acquire the lock and return YES on success, NO on failure.<br />
 * May raise an NSGenericException if a problem occurs.
 */
- (BOOL) tryLock
{
  BOOL		locked = NO;

  [_localLock lock];
  NS_DURING
    {
      NSMutableDictionary	*attributesToSet;
      NSDictionary		*attributes;

      if (nil != _lockTime)
	{
	  [NSException raise: NSGenericException
		      format: @"Attempt to re-lock distributed lock %@",
	    _lockPath];
        }
      attributesToSet = [NSMutableDictionary dictionaryWithCapacity: 1];
      [attributesToSet setObject: [NSNumber numberWithUnsignedInt: 0755]
			  forKey: NSFilePosixPermissions];

      /* We must not use the NSFileManager directory creation methods,
       * since they consider the presence of an existing directory a
       * success, and we need to know if we can actually create a new
       * directory.
       */
#if defined(_WIN32)
      {
        const unichar   *lpath;

        lpath = [mgr fileSystemRepresentationWithPath: _lockPath];
        locked = (CreateDirectoryW(lpath, 0) != FALSE) ? YES : NO;
      }
#else
      {
        const char      *lpath;

        lpath = [mgr fileSystemRepresentationWithPath: _lockPath];
        locked = (mkdir(lpath, 0777) == 0) ? YES : NO;
      }
#endif

      if (NO == locked)
        {
          NSLog(@"Failed to create lock directory '%@' - %@",
            _lockPath, [NSError _last]);
        }
      else
	{
          [mgr changeFileAttributes: attributesToSet atPath: _lockPath];
	  attributes = [mgr fileAttributesAtPath: _lockPath
				    traverseLink: YES];
	  if (attributes == nil)
	    {
	      [NSException raise: NSGenericException
		format: @"Unable to get attributes of lock file we made at %@",
		_lockPath];
	    }
	  ASSIGN(_lockTime, [attributes fileModificationDate]);
	  if (nil == _lockTime)
	    {
	      [NSException raise: NSGenericException
		format: @"Unable to get date of lock file we made at %@",
		_lockPath];
	    }
	}
    }
  NS_HANDLER
    {
      [_localLock unlock];
      [localException raise];
    }
  NS_ENDHANDLER
  [_localLock unlock];
  return locked;
}

/**
 * Releases the lock.  Raises an NSGenericException if unable to release
 * the lock (for instance if the receiver does not own it or another
 * process has broken it).
 */
- (void) unlock
{
  [_localLock lock];
  NS_DURING
    {
      NSDictionary	*attributes;

      if (_lockTime == nil)
	{
	  [NSException raise: NSGenericException format: @"not locked by us"];
	}

      /* Don't remove the lock if it has already been broken by someone
       * else and re-created.  Unfortunately, there is a window between
       * testing and removing, but we do the bset we can.
       */
      attributes = [mgr fileAttributesAtPath: _lockPath traverseLink: YES];
      if (attributes == nil)
	{
	  DESTROY(_lockTime);
	  [NSException raise: NSGenericException
		      format: @"lock '%@' already broken", _lockPath];
	}
      if ([_lockTime isEqual: [attributes fileModificationDate]])
	{
	  DESTROY(_lockTime);
	  if ([mgr removeFileAtPath: _lockPath handler: nil] == NO)
	    {
	      [NSException raise: NSGenericException
			  format: @"Failed to remove lock directory '%@' - %@",
			      _lockPath, [NSError _last]];
	    }
	}
      else
	{
	  DESTROY(_lockTime);
	  [NSException raise: NSGenericException
		      format: @"lock '%@' already broken and in use again",
	    _lockPath];
	}
      DESTROY(_lockTime);
    }
  NS_HANDLER
    {
      [_localLock unlock];
      [localException raise];
    }
  NS_ENDHANDLER
  [_localLock unlock];
}

@end
