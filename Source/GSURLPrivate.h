########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 613a95f29873e44f87c989412fc617b632fa76aa
# Date: 2020-06-09 16:13:35 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 617da993d7b287e87acf40ad5546b1dae25c1578
# Date: 2017-08-03 21:55:17 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: bd1dce4f73c066cca760c6e2b7da4227873d6bbf
# Date: 2016-09-21 18:51:28 +0000
########## End of Keysight Technologies Notice ##########
/* GSURLPrivate
   Copyright (C) 2006 Free Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   
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
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02111 USA.
*/ 

#ifndef __GSURLPrivate_h_
#define __GSURLPrivate_h_

/*
 * Headers needed by many URL loading classes
 */
#import "common.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSAutoreleasePool.h"
#import "Foundation/NSData.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSHTTPCookie.h"
#import "Foundation/NSHTTPCookieStorage.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSStream.h"
#import "Foundation/NSString.h"
#import "Foundation/NSURL.h"
#import "Foundation/NSURLAuthenticationChallenge.h"
#import "Foundation/NSURLCache.h"
#import "Foundation/NSURLConnection.h"
#import "Foundation/NSURLCredential.h"
#import "Foundation/NSURLCredentialStorage.h"
#import "Foundation/NSURLDownload.h"
#import "Foundation/NSURLError.h"
#import "Foundation/NSURLProtectionSpace.h"
#import "Foundation/NSURLProtocol.h"
#import "Foundation/NSURLRequest.h"
#import "Foundation/NSURLResponse.h"

/*
 * Private accessors for URL loading classes
 */

@interface	NSURLRequest (Private)
- (BOOL) _debug;
- (id) _propertyForKey: (NSString*)key;
- (void) _setProperty: (id)value forKey: (NSString*)key;
@end


@interface	NSURLResponse (Private)
- (void) _setHeaders: (id)headers;
- (void) _setStatusCode: (NSInteger)code text: (NSString*)text;
- (void) _setValue: (NSString *)value forHTTPHeaderField: (NSString *)field;
- (NSString*) _valueForHTTPHeaderField: (NSString*)field;
@end


@interface      NSURLProtocol (Private)
+ (Class) _classToHandleRequest:(NSURLRequest *)request;
// TESTPLANT-MAL-06092020: Keeping testplant branch code...
- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode;
- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode description: (NSString*) description;
- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode description: (NSString*) description host: (NSHost*)host;
@end

/*
 * Internal class for handling HTTP authentication
 */
@class	NSLock;
@interface GSHTTPAuthentication : NSObject
{
  NSLock		*_lock;
  NSURLCredential	*_credential;
  NSURLProtectionSpace	*_space;
  NSString		*_nonce;
  NSString		*_opaque;
  NSString		*_qop;
  int			_nc;
}
/*
 *  Return the object for the specified credential/protection space.
 */
+ (GSHTTPAuthentication *) authenticationWithCredential:
  (NSURLCredential*)credential
  inProtectionSpace: (NSURLProtectionSpace*)space;

/*
 * Create/return the protection space involved in the specified authentication
 * header returned in a response to a request sent to the URL.
 */
+ (NSURLProtectionSpace*) protectionSpaceForAuthentication: (NSString*)auth
						requestURL: (NSURL*)URL;

/*
 * Return the protection space for the specified URL (if known).
 */
+ (NSURLProtectionSpace *) protectionSpaceForURL: (NSURL*)URL;

+ (void) setProtectionSpace: (NSURLProtectionSpace *)space
		 forDomains: (NSArray*)domains
		    baseURL: (NSURL*)base;

/*
 * Generate next authorisation header for the specified authentication
 * header, method, and path.
 */
- (NSString*) authorizationForAuthentication: (NSString*)authentication
				      method: (NSString*)method
					path: (NSString*)path;
- (NSURLCredential *) credential;
- (id) initWithCredential: (NSURLCredential*)credential
        inProtectionSpace: (NSURLProtectionSpace*)space;
- (NSURLProtectionSpace *) space;
@end

#endif

