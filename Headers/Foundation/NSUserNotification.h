########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 837351f5426f6ca0fd94c86a47d73ca8bb459535
# Date: 2016-09-14 14:02:59 +0000
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
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
/* Interface for NSUserNotification for GNUstep
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

#ifndef __NSUserNotification_h_INCLUDE
#define __NSUserNotification_h_INCLUDE

#define NSUserNotification_IVARS 1
#define NSUserNotificationCenter_IVARS 1
#import	<GNUstepBase/GSVersionMacros.h>

#if OS_API_VERSION(MAC_OS_X_VERSION_10_8,GS_API_LATEST)
#if __has_feature(objc_default_synthesize_properties)

#import <Foundation/NSObject.h>

#if	defined(__cplusplus)
extern "C" {
#endif


@class NSString, NSDictionary, NSArray, NSDateComponents, NSDate, NSTimeZone, NSImage, NSAttributedString;
@class NSMutableArray;

@protocol NSUserNotificationCenterDelegate;

enum
{
  NSUserNotificationActivationTypeNone				= 0,
  NSUserNotificationActivationTypeContentsClicked		= 1,
  NSUserNotificationActivationTypeActionButtonClicked           = 2
#if OS_API_VERSION(MAC_OS_X_VERSION_10_9,GS_API_LATEST)
  ,NSUserNotificationActivationTypeReplied			= 3
#endif
};
typedef NSInteger NSUserNotificationActivationType;


@interface NSUserNotification : NSObject <NSCopying>
{
#if	GS_EXPOSE(NSUserNotification)
  @public
  id _uniqueId;
  // Testplant-MAL-09142016: Addtions for supporting @synthesize which for does not
  // compile for our version of clang - why?
  NSString *title;
  NSString *subtitle;
  NSString *informativeText;
  NSString *actionButtonTitle;
  NSDictionary *userInfo;
  NSDate *deliveryDate;
  NSTimeZone *deliveryTimeZone;
  NSDateComponents *deliveryRepeatInterval;
  NSDate *actualDeliveryDate;
  BOOL presented;
  BOOL remote;
  NSString *soundName;
  BOOL hasActionButton;
  NSUserNotificationActivationType activationType;
  NSString *otherButtonTitle;
  NSString *identifier;
  NSImage *contentImage;
  BOOL hasReplyButton;
  NSString *responsePlaceholder;
  NSAttributedString *response;
#endif
}

@property (copy) NSString *title;
@property (copy) NSString *subtitle;
@property (copy) NSString *informativeText;
@property (copy) NSString *actionButtonTitle;
@property (copy) NSDictionary *userInfo;
@property (copy) NSDate *deliveryDate;
@property (copy) NSTimeZone *deliveryTimeZone;
@property (copy) NSDateComponents *deliveryRepeatInterval;
@property (readonly) NSDate *actualDeliveryDate;
@property (readonly, getter=isPresented) BOOL presented;

@property (readonly, getter=isRemote) BOOL remote;
@property (copy) NSString *soundName;
@property BOOL hasActionButton;
@property (readonly) NSUserNotificationActivationType activationType;
@property (copy) NSString *otherButtonTitle;

#if OS_API_VERSION(MAC_OS_X_VERSION_10_9,GS_API_LATEST)

@property (copy) NSString *identifier;
@property (retain) NSImage *contentImage;
@property BOOL hasReplyButton;
@property (copy) NSString *responsePlaceholder;
@property (readonly) NSAttributedString *response;

#endif /* OS_API_VERSION(MAC_OS_X_VERSION_10_9,GS_API_LATEST) */

@end

GS_EXPORT NSString * const NSUserNotificationDefaultSoundName;

@interface NSUserNotificationCenter : NSObject
{
#if	GS_EXPOSE(NSUserNotificationCenter)
  NSMutableArray *_scheduledNotifications;
  NSMutableArray *_deliveredNotifications;
  id <NSUserNotificationCenterDelegate> _delegate;
#endif
}

+ (NSUserNotificationCenter *)defaultUserNotificationCenter;

@property (assign) id <NSUserNotificationCenterDelegate> delegate;
@property (copy) NSArray *scheduledNotifications;

- (void) scheduleNotification: (NSUserNotification *)notification;
- (void) removeScheduledNotification: (NSUserNotification *)notification;

@property (readonly) NSArray *deliveredNotifications;

- (void) deliverNotification: (NSUserNotification *)notification;
- (void) removeDeliveredNotification: (NSUserNotification *)notification;
- (void) removeAllDeliveredNotifications;

@end


@protocol NSUserNotificationCenterDelegate <NSObject>
#if GS_PROTOCOLS_HAVE_OPTIONAL
@optional
#else
@end
@interface NSObject (NSUserNotificationCenterDelegateMethods)
#endif

- (void) userNotificationCenter: (NSUserNotificationCenter *)center
         didDeliverNotification: (NSUserNotification *)notification;
- (void) userNotificationCenter: (NSUserNotificationCenter *)center
        didActivateNotification: (NSUserNotification *)notification;
- (BOOL) userNotificationCenter: (NSUserNotificationCenter *)center
      shouldPresentNotification: (NSUserNotification *)notification;

@end

#if	defined(__cplusplus)
}
#endif

#endif /* OS_API_VERSION(MAC_OS_X_VERSION_10_8,GS_API_LATEST) */
#endif /* __has_feature(objc_default_synthesize_properties) */
#endif	/* __NSUserNotification_h_INCLUDE */
