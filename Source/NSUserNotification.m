########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: c9ae7be7c387d5802ac9f75f9e18f590063deee5
# Date: 2018-02-02 19:58:31 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 55493fbfa927b564008e9d6f4878c3186af2c806
# Date: 2018-02-01 21:39:47 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 8eedc9ddaa9e420d6c9a936946712f62bfc26cc9
# Date: 2016-09-27 20:33:01 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: c6dc65a5a78655796f55b7e0b8894d7aeef4a71b
# Date: 2016-09-21 19:59:43 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 5975c4978044c99350f75aaff485b2d18716131e
# Date: 2016-05-13 19:01:26 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: e2b549781854b045db982cae8f73bf73d26d84a8
# Date: 2016-05-09 16:05:19 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 234beeee196ebf1490409ce4bbf593a7c23ab13c
# Date: 2016-04-18 14:53:58 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 019525c5641f31f1b28e451f29656b2ac0bee1da
# Date: 2016-01-15 17:27:24 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
/* Implementation for NSUserNotification for GNUstep
   Copyright (C) 2014 Free Software Foundation, Inc.

   Written by:  Marcus Mueller <znek@mulle-kybernetik.com>
   Date: 2014

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

#import	<GNUstepBase/GSVersionMacros.h>

#if __has_feature(objc_default_synthesize_properties)

#define	EXPOSE_NSUserNotification_IVARS	1
#define	EXPOSE_NSUserNotificationCenter_IVARS	1

#import "GNUstepBase/NSObject+GNUstepBase.h"
#import "Foundation/NSUserNotification.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSBundle.h"
#import "Foundation/NSCalendar.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSString.h"
#import "Foundation/NSTimeZone.h"
#import "Foundation/NSUserDefaults.h"

NSString * const NSUserNotificationDefaultSoundName = @"NSUserNotificationDefaultSoundName";

@interface NSUserNotification ()
// Testplant-MAL-09272016: Need to copy this...
@property (readwrite, copy) NSDate *actualDeliveryDate;
@property (readwrite, getter=isPresented) BOOL presented;
@property (readwrite, getter=isRemote) BOOL remote;
@property (readwrite) NSUserNotificationActivationType activationType;
// Testplant-MAL-09272016: Need to copy this...
@property (readwrite, copy) NSAttributedString *response;
@end

@implementation NSUserNotification

// Testplant-MAL-09272016: Our clang version doens't seem to work without this...
@synthesize title;
@synthesize subtitle;
@synthesize informativeText;
@synthesize actionButtonTitle;
@synthesize userInfo;
@synthesize deliveryDate;
@synthesize deliveryTimeZone;
@synthesize deliveryRepeatInterval;
@synthesize actualDeliveryDate;
@synthesize presented;
@synthesize remote;
@synthesize soundName;
@synthesize hasActionButton;
@synthesize activationType;
@synthesize otherButtonTitle;
@synthesize identifier;
@synthesize contentImage;
@synthesize hasReplyButton;
@synthesize responsePlaceholder;
@synthesize response;

- (id) init
{
  if (nil != (self = [super init]))
    {
      self.hasActionButton = YES;
    }
  return self;
}

- (void) dealloc
{
  RELEASE(_uniqueId);
  [super dealloc];
}

- (id) copyWithZone: (NSZone *)zone
{
  return NSCopyObject(self, 0, zone);
}

- (NSString *)description
{
  NSMutableString *d = [NSMutableString stringWithCapacity:80];
  [d appendFormat:@"<%s:%p< {", object_getClassName(self), self];
  [d appendFormat:@" title: \"%@\"", self.title];
  [d appendFormat:@" informativeText: \"%@\"", self.informativeText];
  [d appendFormat:@" actionButtonTitle: \"%@\"", self.actionButtonTitle];
  if (self.actualDeliveryDate)
  {
    [d appendFormat:@" actualDeliveryDate: %@", self.actualDeliveryDate];
    [d appendFormat:@" presented: %s", self.presented ? "YES" : "NO"];
  }
  [d appendFormat:@" next delivery date: %@", self.deliveryDate];
  [d appendString:@" }"];
  return d;
}

@end

@interface NSUserNotificationCenter ()
@property (readwrite) NSArray *deliveredNotifications;
@end

@interface NSUserNotificationCenter (Private)
+ (Class) defaultUserNotificationCenterClass;
+ (void) setDefaultUserNotificationCenter: (NSUserNotificationCenter *)unc;
- (NSUserNotification *) deliveredNotificationWithUniqueId: (id)uniqueId;
- (NSDate *) nextDeliveryDateForNotification: (NSUserNotification *)un;
@end

@implementation NSUserNotificationCenter

static NSUserNotificationCenter *defaultUserNotificationCenter = nil;

// Testplant-MAL-09272016: Our clang version doesn't seem to work without this...
@synthesize scheduledNotifications = _scheduledNotifications;
@synthesize deliveredNotifications = _deliveredNotifications;
@synthesize delegate = _delegate;

+ (Class) defaultUserNotificationCenterClass
{
#if defined(__MINGW__)
  // TESTPLANT-MAL-02022018: TESTPLANT ONLY:
  // Avoid loading user notification DLL's on Windows to avoid potential application exit
  // with bad termination status when running in CLI mode...
  if ([[NSUserDefaults standardUserDefaults] boolForKey: @"GSEnableUserNotificationCenter"])
#endif
    {
      NSBundle *bundle = [NSBundle bundleForClass: [self class]];
      NSString *bundlePath = [bundle pathForResource: @"NSUserNotification"
                                              ofType: @"bundle"
                                         inDirectory: nil];
      if (bundlePath)
        {
          bundle = [NSBundle bundleWithPath: bundlePath];
          // Testplant-MAL-09272016: Added debug...
#if defined(DEBUG)
          NSLog(@"%s:bundlePath: %@ bundle: %@", __PRETTY_FUNCTION__, bundlePath, bundle);
#endif
          if (bundle)
            {
#if defined(DEBUG)
              NSLog(@"%s:principal class: %@", __PRETTY_FUNCTION__, [bundle principalClass]);
#endif
              return [bundle principalClass];
            }
        }
    }
  return self;
}

+ (void) atExit
{
  DESTROY(defaultUserNotificationCenter);
}

+ (void) initialize
{
  if ([NSUserNotificationCenter class] == self)
    {
      Class uncClass = [self defaultUserNotificationCenterClass];
      defaultUserNotificationCenter = [[uncClass alloc] init];
      [self registerAtExit];
    }
}

+ (void) setDefaultUserNotificationCenter: (NSUserNotificationCenter *)unc
{
  ASSIGN(defaultUserNotificationCenter, unc);
}

+ (NSUserNotificationCenter *) defaultUserNotificationCenter
{
  return defaultUserNotificationCenter;
}


- (id) init
{
  self = [super init];
  if (self)
    {
      _scheduledNotifications = [[NSMutableArray alloc] init];
      _deliveredNotifications = [[NSMutableArray alloc] init];
    }
  return self;
}

- (void) dealloc
{
  [NSObject cancelPreviousPerformRequestsWithTarget: self];
  RELEASE(_scheduledNotifications);
  [self removeAllDeliveredNotifications];
  RELEASE(_deliveredNotifications);
  [super dealloc];
}

- (void) scheduleNotification: (NSUserNotification *)un
{
  if (!un.deliveryDate)
    {
      [self deliverNotification: un];
      return;
    }
  [_scheduledNotifications addObject: un];
  NSTimeInterval delay = [un.deliveryDate timeIntervalSinceNow];
  [self performSelector: @selector(deliverNotification:)
             withObject: un
             afterDelay: delay];
}

- (void) removeScheduledNotification: (NSUserNotification *)un
{
  [NSObject cancelPreviousPerformRequestsWithTarget: self
    selector: @selector(deliverNotification:)
    object: un];
  [_scheduledNotifications removeObject: un];
}

- (void) _deliverNotification: (NSUserNotification *)un
{
  un.presented = YES;
}

- (NSDate *) nextDeliveryDateForNotification: (NSUserNotification *)un
{
  NSDateComponents *repeatInterval = un.deliveryRepeatInterval;
  if (!repeatInterval)
    return nil;

  NSCalendar *cal = [[repeatInterval calendar] copy];
  if (!cal)
    cal = [[NSCalendar currentCalendar] copy];
  if ([repeatInterval timeZone])
    [cal setTimeZone:[repeatInterval timeZone]];
  if (![cal timeZone])
    [cal setTimeZone:[NSTimeZone localTimeZone]];

  NSDate *nextDeliveryDate = [cal dateByAddingComponents: repeatInterval
                                                  toDate: un.actualDeliveryDate
                                                 options: 0];
  RELEASE(cal);
  return nextDeliveryDate;
}

- (void) deliverNotification: (NSUserNotification *)un
{
  [self removeScheduledNotification: un];
  [self _deliverNotification: un];

  NSDate *actualDeliveryDate = un.deliveryDate;
  if (!actualDeliveryDate)
    actualDeliveryDate = [NSDate date];
  un.actualDeliveryDate = actualDeliveryDate;
  [_deliveredNotifications addObject: un];
  un.deliveryDate = [self nextDeliveryDateForNotification: un];
  if (un.deliveryDate)
    [self scheduleNotification: un];

  if (self.delegate && [self.delegate respondsToSelector:
    @selector(userNotificationCenter:didDeliverNotification:)])
    {
      [self.delegate userNotificationCenter: self didDeliverNotification: un];
    }
}


- (void) _removeDeliveredNotification: (NSUserNotification *)un
{
}

- (void) removeDeliveredNotification: (NSUserNotification *)un
{
  [self _removeDeliveredNotification: un];
  [_deliveredNotifications removeObject: un];
}

- (void) removeAllDeliveredNotifications
{
  NSUInteger i, count = [_deliveredNotifications count];

  for (i = 0; i < count; i++)
    {
      NSUserNotification *un = [_deliveredNotifications objectAtIndex: i];
      [self _removeDeliveredNotification:un];
    }
  [_deliveredNotifications removeAllObjects];
}

- (NSUserNotification *) deliveredNotificationWithUniqueId: (id)uniqueId
{
  NSUInteger i, count = [_deliveredNotifications count];

  for (i = 0; i < count; i++)
    {
      NSUserNotification *un = [_deliveredNotifications objectAtIndex: i];
      if ([un->_uniqueId isEqual: uniqueId])
        {
          return un;
        }
    }
  return nil;
}

@end

#endif /* __has_feature(objc_default_synthesize_properties) */
