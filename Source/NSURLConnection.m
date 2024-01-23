########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 21ac81f26fa1ec2964cee6fceb07b05f24f2a9b1
# Date: 2020-09-04 16:37:50 -0400
--------------------
# Committed by: Bekki Freeman
# Commit ID: 03d6f1148033c341b0cb73543b98305fc7c6bfd8
# Date: 2018-01-10 17:48:35 +0000
--------------------
# Committed by: Bekki Freeman
# Commit ID: 4b0fad75e0ee45cb72dc54e5f72ce8cbcf0e0e05
# Date: 2018-01-09 03:09:17 +0000
--------------------
# Committed by: Bekki Freeman
# Commit ID: 94e1d09506d5ee989c9699c15c99e96c1b0cf578
# Date: 2018-01-05 19:16:41 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 21dbe2815d4bcd5ff9e411723b8a1e59ef6d2d0d
# Date: 2017-11-29 15:36:15 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 4961c52309b99927ef6d0970f83684921105ef23
# Date: 2017-11-28 20:55:18 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 896ebcf42836efa120a8faaaafdb791b28e1223d
# Date: 2016-09-23 20:37:19 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/* Implementation for NSURLConnection for GNUstep
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

#define	EXPOSE_NSURLConnection_IVARS	1
#import "Foundation/NSError.h"
#import "Foundation/NSURLError.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSThread.h"
#import "Foundation/NSUserDefaults.h"
#import "GSURLPrivate.h"

@interface _NSURLConnectionDataCollector : NSObject
{
  NSURLConnection	*_connection;	// Not retained
  NSMutableData		*_data;
  NSError		*_error;
  NSURLResponse		*_response;
  BOOL			_done;
}

- (NSData*) data;
- (BOOL) done;
- (NSError*) error;
- (NSURLResponse*) response;
- (void) setConnection: (NSURLConnection *)c;

@end

@implementation _NSURLConnectionDataCollector

- (void) dealloc
{
  [_data release];
  [_error release];
  [_response release];
  [super dealloc];
}

- (BOOL) done
{
  return _done;
}

- (NSData*) data
{
  return _data;
}

- (id) init
{
  if (nil != (self = [super init]))
    {
      _data = [NSMutableData new];      // Empty data unless we get an error
    }
  return self;
}

- (NSError*) error
{
  return _error;
}

- (NSURLResponse*) response
{
  return _response;
}

- (void) setConnection: (NSURLConnection*)c
{
  _connection = c;	// Not retained ... the connection retains us
}

- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error
{
  ASSIGN(_error, error);
  DESTROY(_data);       // On error, we make the data nil
  _done = YES;
}

- (void) connection: (NSURLConnection *)connection
 didReceiveResponse: (NSURLResponse*)response
{
  ASSIGN(_response, response);
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
  _done = YES;
}

- (void) connection: (NSURLConnection *)connection
     didReceiveData: (NSData *)data
{
  [_data appendData: data];
}

@end

typedef struct
{
  NSMutableURLRequest		*_request;
  NSURLProtocol			*_protocol;
  id				_delegate;
  BOOL				_debug;
} Internal;
 
#define	this	((Internal*)(self->_NSURLConnectionInternal))
#define	inst	((Internal*)(o->_NSURLConnectionInternal))

@implementation	NSURLConnection

+ (id) allocWithZone: (NSZone*)z
{
  NSURLConnection	*o = [super allocWithZone: z];

  if (o != nil)
    {
      o->_NSURLConnectionInternal = NSZoneCalloc([self zone],
	1, sizeof(Internal));
    }
  return o;
}

+ (BOOL) canHandleRequest: (NSURLRequest *)request
{
  return ([NSURLProtocol _classToHandleRequest: request] != nil);
}

+ (NSURLConnection *) connectionWithRequest: (NSURLRequest *)request
				   delegate: (id)delegate
{
  NSURLConnection	*o = [self alloc];

  o = [o initWithRequest: request delegate: delegate];
  return AUTORELEASE(o);
}

- (void) start
{
  if (NULL != this)
    {
      // Delegate is retained at the start of the connection processing and
      // released when completed...
      this->_delegate = [this->_delegate retain];
      this->_protocol = [[NSURLProtocol alloc] initWithRequest: this->_request
                                                cachedResponse: nil
                                                        client: (id<NSURLProtocolClient>)self];
      [this->_protocol startLoading];
    }
}

- (void) cancel
{
  if (NULL != this)
    {
      [this->_protocol stopLoading];
      DESTROY(this->_protocol);
      DESTROY(this->_delegate);
    }
}

- (void) dealloc
{
  if (this != 0)
    {
      [self cancel];
      DESTROY(this->_request);
      DESTROY(this->_delegate);
      NSZoneFree([self zone], this);
      _NSURLConnectionInternal = 0;
    }
  [super dealloc];
}

- (void) finalize
{
  if (this != 0)
    {
      [self cancel];
    }
}

/**
 * TESTPLANT-MAL-09042020:
 * This is not a complete implementation.  Since the current implementation
 * of NSURLProtocol defaults to the current runloop/mode we would need to modify
 * that also.  There are also missing methods in this class like:
 * scheduleInRunLoop:forMode:
 * unscheduleFromRunLoop:forMode:
 * setDelegateQueue:
 * but it suffices for our current requirements.  Note, that this still assumes
 * that the connection will be scheduled in the current runloop so cancel, etc
 * should still be invoked on the same thread/runloop that it started on.
**/
- (id) initWithRequest: (NSURLRequest *)request delegate: (id)delegate startImmediately: (BOOL)startImmediately
{
  if ((self = [super init]) != nil)
    {
      this->_request = [request mutableCopyWithZone: [self zone]];
      
      /* Enrich the request with the appropriate HTTP cookies,
       * if desired.
       */
      if ([this->_request HTTPShouldHandleCookies] == YES)
        {
          NSArray *cookies;
          
          cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]
                     cookiesForURL: [this->_request URL]];
          if ([cookies count] > 0)
            {
              NSDictionary  *headers;
              NSEnumerator  *enumerator;
              NSString    *header;
              
              headers = [NSHTTPCookie requestHeaderFieldsWithCookies: cookies];
              enumerator = [headers keyEnumerator];
              while (nil != (header = [enumerator nextObject]))
                {
                  [this->_request addValue: [headers valueForKey: header]
                        forHTTPHeaderField: header];
                }
            }
        }
      
      /* According to bug #35686, Cocoa has a bizarre deviation from the
       * convention that delegates are retained here.
       * For compatibility we retain the delegate and release it again
       * when the operation is over.
       */
      this->_debug = GSDebugSet(@"NSURLConnection");
      this->_delegate = delegate;

      // Start if requested...
      if (startImmediately)
        {
          [self start];
        }
    }
  return self;
}

- (id) initWithRequest: (NSURLRequest *)request delegate: (id)delegate
{
  if ((self = [self initWithRequest: request delegate: delegate startImmediately: YES]) != nil)
    {
    }
  return self;
}

@end



@implementation NSObject (NSURLConnectionDelegate)

- (void) connection: (NSURLConnection *)connection
  didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
  return;
}

- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error
{
  return;
}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
  return;
}

- (void) connection: (NSURLConnection *)connection
  didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
  if ([challenge proposedCredential] == nil
    || [challenge previousFailureCount] > 0)
    {
      /* continue without a credential if there is no proposed credential
       * at all or if an authentication failure has already happened.
       */
  [[challenge sender]
    continueWithoutCredentialForAuthenticationChallenge: challenge];
}
}

- (void) connection: (NSURLConnection *)connection
     didReceiveData: (NSData *)data
{
  return;
}

- (void) connection: (NSURLConnection *)connection
 didReceiveResponse: (NSURLResponse *)response
{
  return;
}

- (NSCachedURLResponse *) connection: (NSURLConnection *)connection
  willCacheResponse: (NSCachedURLResponse *)cachedResponse
{
  return cachedResponse;
}

- (NSURLRequest *) connection: (NSURLConnection *)connection
	      willSendRequest: (NSURLRequest *)request
	     redirectResponse: (NSURLResponse *)response
{
  return request;
}

@end



@implementation NSURLConnection (NSURLConnectionSynchronousLoading)

+ (void) synchronousConnectionThread: (NSDictionary*)infodict
{
  NSAutoreleasePool             *pool = [NSAutoreleasePool new];
  NSUInteger                     status = 0;
  NSURLRequest                  *request = [infodict objectForKey: @"request"];
  _NSURLConnectionDataCollector *collector = [infodict objectForKey: @"collector"];
  NSURLConnection               *conn = [[self alloc] initWithRequest: request delegate: collector];

  if (nil != conn)
    {
      NSRunLoop	*loop;
      NSDate	*limit;
      
      [collector setConnection: conn];
      loop = [NSRunLoop currentRunLoop];
      limit = [[NSDate alloc] initWithTimeIntervalSinceNow: [request timeoutInterval]];
      
      while ([collector done] == NO && [limit timeIntervalSinceNow] > 0.0)
        {
          [loop runMode: NSDefaultRunLoopMode beforeDate: limit];
        }
      RELEASE(limit);
      [conn release];
    }
  
  [pool drain];
}

+ (NSData *) sendSynchronousRequest: (NSURLRequest *)request
		  returningResponse: (NSURLResponse **)response
			      error: (NSError **)error
{
  NSData	*data = nil;

  if (0 != response)
    {
      *response = nil;
    }
  if (0 != error)
    {
      *error = nil;
    }
  if ([self canHandleRequest: request] == YES)
    {
      _NSURLConnectionDataCollector *collector;

      collector = [_NSURLConnectionDataCollector new];
      
      // Cocoa OSX documentation says this is run asynchronously and this method should BLOCK...
      NSDictionary  *infodict = @{ @"request" : request, @"collector" : collector };
      NSThread      *thread   = [[NSThread alloc] initWithTarget: self
                                                        selector: @selector(synchronousConnectionThread:)
                                                          object: infodict];
      
      // If no thread allocated then...
      if (thread == nil)
        {
          // What to do here???
          NSLog(@"%s:unable to allocate a thread for the request: %@", __PRETTY_FUNCTION__, request);
          
          // Return an error if the user passed an address...
          if (0 != error)
            {
              *error = [NSError errorWithDomain: NSURLErrorDomain
                                           code: NSURLErrorUnknown
                                       userInfo: [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [request URL],                  @"URL",
                                                  [[request URL] path],           @"path",
                                                  [request URL],                  NSURLErrorFailingURLErrorKey,
                                                  [[request URL] absoluteString], NSErrorFailingURLStringKey,
                                                  @"unable to allocate thread",   NSLocalizedDescriptionKey,
                                                  @"unable to allocate thread",   NSLocalizedFailureReasonErrorKey,
                                                  nil]];
            }
        }
      else
        {
          // Start the thread...
          [thread start];
          
          // Wait for thread to finish...
          NSNumber *delayNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"GSUrlConnectionDelay"];
          CGFloat sleepInterval = delayNumber ? [delayNumber doubleValue] : 0.05;
          while ([thread isFinished] == NO)
            {
              [NSThread sleepForTimeInterval: sleepInterval];
            }
          
          // Cleanup...
          [thread release];
          
          // Check and get data...
          if (NO == [collector done])
            {
              data = nil;
              if (0 != response)
                {
                  *response = nil;
                }
              if (0 != error)
                {
                  *error = [NSError errorWithDomain: NSURLErrorDomain
                                               code: NSURLErrorTimedOut
                                           userInfo: nil];
                }
            }
          else
            {
              data = [[[collector data] retain] autorelease];
              if (0 != response)
                {
                  *response = [[[collector response] retain] autorelease];
                }
              if (0 != error)
                {
                  *error = [[[collector error] retain] autorelease];
                }
            }
        }

      // Cleanup...
      [collector release];
    }
  return data;
}

@end


@implementation	NSURLConnection (URLProtocolClient)

- (void) URLProtocol: (NSURLProtocol *)protocol
  cachedResponseIsValid: (NSCachedURLResponse *)cachedResponse
{
  return;
}

- (void) URLProtocol: (NSURLProtocol *)protocol
    didFailWithError: (NSError *)error
{
  id    o = this->_delegate;

  this->_delegate = nil;
  [o connection: self didFailWithError: error];
  DESTROY(o);
}

- (void) URLProtocol: (NSURLProtocol *)protocol
	 didLoadData: (NSData *)data
{
  [this->_delegate connection: self didReceiveData: data];
}

- (void) URLProtocol: (NSURLProtocol *)protocol
  didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
  [this->_delegate connection: self
    didReceiveAuthenticationChallenge: challenge];
}

- (void) URLProtocol: (NSURLProtocol *)protocol
  didReceiveResponse: (NSURLResponse *)response
  cacheStoragePolicy: (NSURLCacheStoragePolicy)policy
{
  [this->_delegate connection: self didReceiveResponse: response];
  if (policy == NSURLCacheStorageAllowed
    || policy == NSURLCacheStorageAllowedInMemoryOnly)
    {
      // FIXME ... cache response here?
    }
}

- (void) URLProtocol: (NSURLProtocol *)protocol
  wasRedirectedToRequest: (NSURLRequest *)request
  redirectResponse: (NSURLResponse *)redirectResponse
{
  if (this->_debug)
    {
      NSLog(@"%@ tell delegate %@ about redirect to %@ as a result of %@",
        self, this->_delegate, request, redirectResponse);
    }
  request = [this->_delegate connection: self
			willSendRequest: request
		       redirectResponse: redirectResponse];
  if (this->_protocol == nil)
    {
      if (this->_debug)
	{
          NSLog(@"%@ delegate cancelled request", self);
	}
      /* Our protocol is nil, so we have been cancelled by the delegate.
       */
      return;
    }
  if (request != nil)
    {
      if (this->_debug)
	{
          NSLog(@"%@ delegate allowed redirect to %@", self, request);
	}
      /* Follow the redirect ... stop the old load and start a new one.
       */
      [this->_protocol stopLoading];
      DESTROY(this->_protocol);
      ASSIGNCOPY(this->_request, request);
      this->_protocol = [[NSURLProtocol alloc]
	initWithRequest: this->_request
	cachedResponse: nil
	client: (id<NSURLProtocolClient>)self];
      [this->_protocol startLoading];
    }
  else if (this->_debug)
    {
      NSLog(@"%@ delegate cancelled redirect", self);
    }
}

- (void) URLProtocolDidFinishLoading: (NSURLProtocol *)protocol
{
  id    o = this->_delegate;

  this->_delegate = nil;
  [o connectionDidFinishLoading: self];
  DESTROY(o);
}

- (void) URLProtocol: (NSURLProtocol *)protocol
  didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
{
  [this->_delegate connection: self
    didCancelAuthenticationChallenge: challenge];
}

@end

