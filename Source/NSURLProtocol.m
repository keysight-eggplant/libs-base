// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: e8c66e701f66e2137698230d75377ac7408ef299 
// Date: 2020-12-09 13:36:10 -0500 
// ========== End of Keysight Technologies Notice ========== 
/* Implementation for NSURLProtocol for GNUstep
   Copyright (C) 2006 Software Foundation, Inc.

   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2006
   Parts (FTP and About in particular) based on later code by Nikolaus Schaller
   
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

#import "common.h"

#define	EXPOSE_NSURLProtocol_IVARS	1
#import "Foundation/NSError.h"
#import "Foundation/NSHost.h"
#import "Foundation/NSNotification.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSTimer.h"
#import "Foundation/NSUserDefaults.h"
#import "Foundation/NSValue.h"

#import "GSPrivate.h"
#import "GSURLPrivate.h"
#import "GNUstepBase/GSMime.h"
#import "GNUstepBase/GSTLS.h"
#import "GNUstepBase/NSData+GNUstepBase.h"
#import "GNUstepBase/NSStream+GNUstepBase.h"
#import "GNUstepBase/NSString+GNUstepBase.h"
#import "GNUstepBase/NSURL+GNUstepBase.h"

/* Define to 1 for experimental (net yet working) compression support
 */
#ifdef	USE_ZLIB
# undef	USE_ZLIB
#endif
#define	USE_ZLIB	0


#if	USE_ZLIB
#if	defined(HAVE_ZLIB_H)
#include	<zlib.h>

static void*
zalloc(void *opaque, unsigned nitems, unsigned size)
{
  return calloc(nitems, size);
}
static void
zfree(void *opaque, void *mem)
{
  free(mem);
}
#else
# undef	USE_ZLIB
# define	USE_ZLIB	0
#endif
#endif


static void
debugRead(id handle, int len, const unsigned char *ptr)
{
  int           pos;
  uint8_t       *hex;
  NSUInteger    hl;
  id            handlein = ((NO == [handle respondsToSelector:@selector(in)]) ?
				nil : [handle in]);

  hl = ((len + 2) / 3) * 4;
  hex = malloc(hl + 1);
  hex[hl] = '\0';
  GSPrivateEncodeBase64(ptr, (NSUInteger)len, hex);

  for (pos = 0; pos < len; pos++)
    {
      if (0 == ptr[pos])
        {
          NSData        *data;
          char          *esc;

          data = [[NSData alloc] initWithBytesNoCopy: (void*)ptr
                                              length: len
                                        freeWhenDone: NO];
          esc = [data escapedRepresentation: 0];

          NSLog(@"Read for %p %@ of %d bytes (escaped) - '%s'\n<[%s]>",
            handle, handlein, len, esc, hex); 
          free(esc);
          RELEASE(data);
          free(hex);
          return;
        }
    }
  NSLog(@"Read for %p %@ of %d bytes - '%*.*s'\n<[%s]>",
    handle, handlein, len, len, len, ptr, hex); 
  free(hex);
}
static void
debugWrite(id handle, int len, const unsigned char *ptr)
{
  int           pos;
  uint8_t       *hex;
  NSUInteger    hl;
  id            handleout = ((NO == [handle respondsToSelector:@selector(out)]) ?
				nil : [handle out]);

  hl = ((len + 2) / 3) * 4;
  hex = malloc(hl + 1);
  hex[hl] = '\0';
  GSPrivateEncodeBase64(ptr, (NSUInteger)len, hex);

  for (pos = 0; pos < len; pos++)
    {
      if (0 == ptr[pos])
        {
          NSData        *data;
          char          *esc;

          data = [[NSData alloc] initWithBytesNoCopy: (void*)ptr
                                              length: len
                                        freeWhenDone: NO];
          esc = [data escapedRepresentation: 0];
          NSLog(@"Write for %p %@ of %d bytes (escaped) - '%s'\n<[%s]>",
            handle, handleout, len, esc, hex); 
          free(esc);
          RELEASE(data);
          free(hex);
          return;
        }
    }
  NSLog(@"Write for %p %@ of %d bytes - '%*.*s'\n<[%s]>",
    handle, handleout, len, len, len, ptr, hex); 
  free(hex);
}

@interface	GSSocketStreamPair : NSObject
{
  NSInputStream		*ip;
  NSOutputStream	*op;
  NSHost		*host;
  uint16_t		port;
  NSDate		*expires;
  BOOL			ssl;
}
+ (void) purge: (NSNotification*)n;
- (void) cache: (NSDate*)when;
- (void) close;
- (NSDate*) expires;
- (id) initWithHost: (NSHost*)h port: (uint16_t)p forSSL: (BOOL)s;
- (NSInputStream*) inputStream;
- (NSOutputStream*) outputStream;
@end

@implementation	GSSocketStreamPair

static NSMutableArray	*pairCache = nil;
static NSLock		*pairLock = nil;

+ (void) initialize
{
  if (pairCache == nil)
    {
      /* No use trying to use a dictionary ... NSHost objects all hash
       * to the same value.
       */
      pairCache = [NSMutableArray new];
      [[NSObject leakAt: &pairCache] release];
      pairLock = [NSLock new];
      [[NSObject leakAt: &pairLock] release];
      /*  Purge expired pairs at intervals.
       */
      [[NSNotificationCenter defaultCenter] addObserver: self
	selector: @selector(purge:)
	name: @"GSHousekeeping" object: nil];
    }
}

+ (void) purge: (NSNotification*)n
{
  NSDate	*now = [NSDate date];
  unsigned	count;

  [pairLock lock];
  count = [pairCache count];
  while (count-- > 0)
    {
      GSSocketStreamPair	*p = [pairCache objectAtIndex: count];

      if ([[p expires] timeIntervalSinceDate: now] <= 0.0)
	{
	  [pairCache removeObjectAtIndex: count];
	}
    }
  [pairLock unlock];
}

- (void) cache: (NSDate*)when
{
  NSTimeInterval	ti = [when timeIntervalSinceNow];

  if (ti <= 0.0)
    {
      [self close];
      return;
    }
  NSAssert(ip != nil, NSGenericException);
  if (ti > 120.0)
    {
      ASSIGN(expires, [NSDate dateWithTimeIntervalSinceNow: 120.0]);
    }
  else
    { 
      ASSIGN(expires, when);
    }
  [pairLock lock];
  [pairCache addObject: self];
  [pairLock unlock];
}

- (void) close
{
  [ip setDelegate: nil];
  [op setDelegate: nil];
  [ip removeFromRunLoop: [NSRunLoop currentRunLoop]
		forMode: NSDefaultRunLoopMode];
  [op removeFromRunLoop: [NSRunLoop currentRunLoop]
		forMode: NSDefaultRunLoopMode];
  [ip close];
  [op close];
  DESTROY(ip);
  DESTROY(op);
}

- (void) dealloc
{
  [self close];
  DESTROY(host);
  DESTROY(expires);
  [super dealloc];
}

- (NSDate*) expires
{
  return expires;
}

- (id) init
{
  DESTROY(self);
  return nil;
}

- (id) initWithHost: (NSHost*)h port: (uint16_t)p forSSL: (BOOL)s;
{
  unsigned		count;
  NSDate		*now;

  now = [NSDate date];
  [pairLock lock];
  count = [pairCache count];
  while (count-- > 0)
    {
      GSSocketStreamPair	*pair = [pairCache objectAtIndex: count];

      if ([pair->expires timeIntervalSinceDate: now] <= 0.0)
	{
	  [pairCache removeObjectAtIndex: count];
	}
      else if (pair->port == p && pair->ssl == s && [pair->host isEqual: h])
	{
	  /* Found a match ... remove from cache and return as self.
	   */
	  DESTROY(self);
	  self = [pair retain];
	  [pairCache removeObjectAtIndex: count];
	  [pairLock unlock];
	  return self;
	}
    }
  [pairLock unlock];

  if ((self = [super init]) != nil)
    {
      [NSStream getStreamsToHost: host
			    port: port
		     inputStream: &ip
		    outputStream: &op];
      if (ip == nil || op == nil)
	{
	  DESTROY(self);
	  return nil;
	}
      ssl = s;
      port = p;
      host = [h retain];
      [ip retain];
      [op retain];
      if (ssl == YES)
        {
          [ip setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
		   forKey: NSStreamSocketSecurityLevelKey];
          [op setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
		   forKey: NSStreamSocketSecurityLevelKey];
        }
    }
  return self;
}

- (NSInputStream*) inputStream
{
  return ip;
}

- (NSOutputStream*) outputStream
{
  return op;
}

@end

@interface _NSAboutURLProtocol : NSURLProtocol
@end

@interface _NSFTPURLProtocol : NSURLProtocol
@end

@interface _NSFileURLProtocol : NSURLProtocol
@end

@interface _NSHTTPURLProtocol : NSURLProtocol
  <NSURLAuthenticationChallengeSender>
{
  GSMimeParser		*_parser;	// Parser handling incoming data
  unsigned		_parseOffset;	// Bytes of body loaded in parser.
  float			_version;	// The HTTP version in use.
  int			_statusCode;	// The HTTP status code returned.
  NSInputStream		*_body;		// for sending the body
  unsigned		_writeOffset;	// Request data to write
  NSData		*_writeData;	// Request bytes written so far
  BOOL			_complete;
  BOOL			_debug;
  BOOL			_isLoading;
  BOOL			_shouldClose;
  NSURLAuthenticationChallenge	*_challenge;
  NSURLCredential		*_credential;
  NSHTTPURLResponse		*_response;
}
@end

@interface _NSHTTPSURLProtocol : _NSHTTPURLProtocol
@end

@interface _NSDataURLProtocol : NSURLProtocol
@end


// Internal data storage
typedef struct {
  NSInputStream			*input;
  NSOutputStream		*output;
  NSCachedURLResponse		*cachedResponse;
  id <NSURLProtocolClient>	client;
  NSURLRequest			*request;
  unsigned char     *_inputBuffer;
  unsigned char     *_outputBuffer;
  NSTimer           *_timer;
#if	USE_ZLIB
  z_stream			z;		// context for decompress
  BOOL				compressing;	// are we compressing?
  BOOL				decompressing;	// are we decompressing?
  NSData			*compressed;	// only partially decompressed
#endif
} Internal;
 
#define	this          ((Internal*)(self->_NSURLProtocolInternal))
#define	inst          ((Internal*)(o->_NSURLProtocolInternal))
#define READ_BUFFER   (this->_inputBuffer)
#define WRITE_BUFFER  (this->_outputBuffer)

#define MAX_READ_BUFFER  BUFSIZ*64
#define MAX_WRITE_BUFFER MAX_READ_BUFFER

static NSMutableArray	*registered = nil;
static NSLock		*regLock = nil;
static Class		abstractClass = nil;
static Class		placeholderClass = nil;
static NSURLProtocol	*placeholder = nil;

@interface	NSURLProtocolPlaceholder : NSURLProtocol
@end
@implementation	NSURLProtocolPlaceholder
- (void) dealloc
{
  if (self == placeholder)
    {
      [self retain];
      return;
    }
  [super dealloc];
}
- (oneway void) release
{
  /* In a multi-threaded environment we could have two threads release the
   * class at the same time ... causing -dealloc to be called twice at the
   * same time, so that we can get an exception as we try to decrement the
   * retain count beyond zero.  To avoid this we make the placeholder be a
   * subclass whose -retain method prevents us even calling -dealoc in any
   * normal circumstances.
   */
  return;
}
@end

@implementation	NSURLProtocol

+ (id) allocWithZone: (NSZone*)z
{
  NSURLProtocol	*o;

  if ((self == abstractClass) && (z == 0 || z == NSDefaultMallocZone()))
    {
      /* Return a default placeholder instance to avoid the overhead of
       * creating and destroying instances of the abstract class.
       */
      o = placeholder;
    }
  else
    {
      /* Create and return an instance of the concrete subclass.
       */
      o = (NSURLProtocol*)NSAllocateObject(self, 0, z);
    }
  return o;
}

+ (void) initialize
{
  if (registered == nil)
    {
      abstractClass = [NSURLProtocol class];
      placeholderClass = [NSURLProtocolPlaceholder class];
      placeholder = (NSURLProtocol*)NSAllocateObject(placeholderClass, 0,
	NSDefaultMallocZone());
      [[NSObject leakAt: &placeholder] release];
      registered = [NSMutableArray new];
      [[NSObject leakAt: &registered] release];
      regLock = [NSLock new];
      [[NSObject leakAt: &regLock] release];
      [self registerClass: [_NSHTTPURLProtocol class]];
      [self registerClass: [_NSHTTPSURLProtocol class]];
      [self registerClass: [_NSFTPURLProtocol class]];
      [self registerClass: [_NSFileURLProtocol class]];
      [self registerClass: [_NSAboutURLProtocol class]];
      [self registerClass: [_NSDataURLProtocol class]];
    }
}

+ (id) propertyForKey: (NSString *)key inRequest: (NSURLRequest *)request
{
  return [request _propertyForKey: key];
}

+ (BOOL) registerClass: (Class)protocolClass
{
  if ([protocolClass isSubclassOfClass: [NSURLProtocol class]] == YES)
    {
      [regLock lock];
      [registered addObject: protocolClass];
      [regLock unlock];
      return YES;
    }
  return NO;
}

+ (void) setProperty: (id)value
	      forKey: (NSString *)key
	   inRequest: (NSMutableURLRequest *)request
{
  [request _setProperty: value forKey: key];
}

+ (void) unregisterClass: (Class)protocolClass
{
  [regLock lock];
  [registered removeObjectIdenticalTo: protocolClass];
  [regLock unlock];
}

- (NSCachedURLResponse *) cachedResponse
{
  return this->cachedResponse;
}

- (id <NSURLProtocolClient>) client
{
  return this->client;
}

- (void) dealloc
{
  if (this != 0)
    {
      [self stopLoading];
      if (this->input != nil)
	{
	  [this->input setDelegate: nil];
	  [this->output setDelegate: nil];
	  [this->input removeFromRunLoop: [NSRunLoop currentRunLoop]
				 forMode: NSDefaultRunLoopMode];
	  [this->output removeFromRunLoop: [NSRunLoop currentRunLoop]
				  forMode: NSDefaultRunLoopMode];
          [this->input close];
          [this->output close];
          DESTROY(this->input);
          DESTROY(this->output);
	}
      NSZoneFree([self zone], READ_BUFFER);
      NSZoneFree([self zone], WRITE_BUFFER);
      
      DESTROY(this->cachedResponse);
      DESTROY(this->request);
      DESTROY(this->client);
#if	USE_ZLIB
      if (this->compressing == YES)
	{
	  deflateEnd(&this->z);
	}
      else if (this->decompressing == YES)
	{
	  inflateEnd(&this->z);
	}
      DESTROY(this->compressed);
#endif
      NSZoneFree([self zone], this);
      _NSURLProtocolInternal = 0;
    }
  [super dealloc];
}

- (NSString*) description
{
  return [NSString stringWithFormat:@"%@ %@",
    [super description], this ? (id)this->request : nil];
}

- (id) init
{
  if ((self = [super init]) != nil)
    {
      Class	c = object_getClass(self);

      if (c != abstractClass && c != placeholderClass)
	{
	  _NSURLProtocolInternal = NSZoneCalloc([self zone],
	    1, sizeof(Internal));
	}
    }
  return self;
}

- (id) initWithRequest: (NSURLRequest *)request
	cachedResponse: (NSCachedURLResponse *)cachedResponse
		client: (id <NSURLProtocolClient>)client
{
  Class	c = object_getClass(self);

  if (c == abstractClass || c == placeholderClass)
    {
      unsigned	count;

      DESTROY(self);
      [regLock lock];
      count = [registered count];
      while (count-- > 0)
        {
	  Class	proto = [registered objectAtIndex: count];

	  if ([proto canInitWithRequest: request] == YES)
	    {
	      self = [proto alloc];
	      break;
	    }
	}
      [regLock unlock];
      return [self initWithRequest: request
		    cachedResponse: cachedResponse
			    client: client];
    }
  if ((self = [self init]) != nil)
    {
      this->request = [request copy];
      this->cachedResponse = RETAIN(cachedResponse);
      this->client = RETAIN(client);
      READ_BUFFER = NSZoneCalloc([self zone], 1, MAX_READ_BUFFER);
      WRITE_BUFFER = NSZoneCalloc([self zone], 1, MAX_WRITE_BUFFER);
    }
  return self;
}

- (NSURLRequest *) request
{
  return this->request;
}

@end

@implementation	NSURLProtocol (Private)

+ (Class) _classToHandleRequest:(NSURLRequest *)request
{
  Class protoClass = nil;
  int count;
  [regLock lock];

  count = [registered count];
  while (count-- > 0)
    {
      Class	proto = [registered objectAtIndex: count];

      if ([proto canInitWithRequest: request] == YES)
	{
	  protoClass = proto;
	  break;
}
    }
  [regLock unlock];
  return protoClass;
}

- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode description: (NSString*) description host: (NSHost*)host
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
          [this->request URL],  NSURLErrorFailingURLErrorKey,
          host,                 NSErrorFailingURLStringKey,
          description,          NSLocalizedDescriptionKey,
          description,          NSLocalizedFailureReasonErrorKey,
          nil];
}

- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode description: (NSString*) description
{
  NSURL   *url  = [this->request URL];
  NSHost	*host = [NSHost hostWithName: [url host]];
  //int	port = [[url port] intValue];
  
  if (host == nil)
  {
    host = [NSHost hostWithAddress: [url host]];	// try dotted notation
  }
  if (host == nil)
  {
    host = [NSHost hostWithAddress: @"127.0.0.1"];	// final default
  }
  
  if (host)
    return [self _userInfoForErrorCode: errorCode description: description host: host];

  return [NSDictionary dictionaryWithObjectsAndKeys:
          [this->request URL],                  NSURLErrorFailingURLErrorKey,
          [[this->request URL] absoluteString], NSErrorFailingURLStringKey,
          description,                          NSLocalizedDescriptionKey,
          description,                          NSLocalizedFailureReasonErrorKey,
          nil];
}

- (NSDictionary*) _userInfoForErrorCode: (NSUInteger) errorCode
{
  return [NSDictionary dictionaryWithObjectsAndKeys:
          [this->request URL],                  @"URL",
          [[this->request URL] path],           @"path",
          [this->request URL],                  NSURLErrorFailingURLErrorKey,
          [[this->request URL] absoluteString], NSErrorFailingURLStringKey,
          @"unknown error occurred",            NSLocalizedDescriptionKey,
          @"unknown error occurred",            NSLocalizedFailureReasonErrorKey,
          nil];
}

@end

@implementation	NSURLProtocol (Subclassing)

+ (BOOL) canInitWithRequest: (NSURLRequest *)request
{
  [self subclassResponsibility: _cmd];
  return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest: (NSURLRequest *)request
{
  return request;
}

+ (BOOL) requestIsCacheEquivalent: (NSURLRequest *)a
			toRequest: (NSURLRequest *)b
{
  a = [self canonicalRequestForRequest: a];
  b = [self canonicalRequestForRequest: b];
  return [a isEqual: b];
}

- (void) startLoading
{
  [self subclassResponsibility: _cmd];
}

- (void) stopLoading
{
  [self subclassResponsibility: _cmd];
}

@end






@implementation _NSHTTPURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"http"];
}

+ (NSURLRequest*) canonicalRequestForRequest: (NSURLRequest*)request
{
  return request;
}

- (void) cancelAuthenticationChallenge: (NSURLAuthenticationChallenge*)c
{
  if (c == _challenge)
    {
      DESTROY(_challenge);	// We should cancel the download
    }
}

- (void) continueWithoutCredentialForAuthenticationChallenge:
  (NSURLAuthenticationChallenge*)c
{
  if (c == _challenge)
    {
      DESTROY(_credential);	// We download the challenge page
    }
}

- (void) dealloc
{
  RELEASE(_parser);     // received headers
  RELEASE(_body);       // for sending the body
  RELEASE(_response);
  RELEASE(_credential);
  [super dealloc];
}

- (void) _timedout: (NSTimer*)timer
{
  if (_debug)
  {
    NSWarnMLog(@"request timed out: %@ after %f secs", this->request, [[timer userInfo] doubleValue]);
  }
  NSTimeInterval timeInterval = [[timer userInfo] doubleValue]; // the original timeout value used...
  NSString       *description = [NSString stringWithFormat: @"Timeout: Host failed to respond after %.0f seconds",timeInterval];
  NSDictionary   *userinfo    = [self _userInfoForErrorCode: 0 description: description];
  NSError        *error       = [NSError errorWithDomain: @"Timeout on connection"
                                                    code: 0
                                                userInfo: userinfo];
  [self stopLoading];
  [this->client URLProtocol: self didFailWithError: error];
  DESTROY(this->client);
}

- (NSTimeInterval) _timeInterval
{
  static const NSTimeInterval DefaultConnectionTimeout = 60.0;
  NSTimeInterval timeout = [this->request timeoutInterval];
  if (timeout <= 0)
  {
    // Check defaults next for a value...
    if ([[NSUserDefaults standardUserDefaults] objectForKey: @"GSURLProtocolConnectionTimeout"])
    {
      timeout = [[NSUserDefaults standardUserDefaults] doubleForKey: @"GSURLProtocolConnectionTimeout"];
      if (timeout <= 0)
      {
        timeout = DefaultConnectionTimeout;
      }
    }
    else
    {
      timeout = DefaultConnectionTimeout;
    }
  }
  
  return timeout;
}

- (void) _stopTimer
{
  if ((NULL != this) && (this->_timer))
  {
    [this->_timer invalidate];
    this->_timer = nil; // We hold a weak reference...
  }
}

- (void) _startTimer
{
  // First stop any current timer...
  [self _stopTimer];
  
  // TESTPLANT-MAL-090892017: Start a timer for this operation to avoid hangs...
  NSTimeInterval timeout = [self _timeInterval];
  
  // Log the timeout value...
  if (_debug)
    NSWarnMLog(@"req: %@ using connection timeout: %f", this->request, timeout);
  
  // Start and schedule the timer...weak reference to avoid circular...
  this->_timer = [NSTimer scheduledTimerWithTimeInterval: timeout
                                                  target: self
                                                selector: @selector(_timedout:)
                                                userInfo: [NSNumber numberWithDouble: timeout]
                                                 repeats: NO];
}

- (void) startLoading
{
  static NSDictionary *methods = nil;

  _debug = GSDebugSet(@"NSURLProtocol");
  if (YES == [this->request _debug]) _debug = YES;

  if (methods == nil)
    {
      methods = [[NSDictionary alloc] initWithObjectsAndKeys: 
	self, @"HEAD",
	self, @"GET",
	self, @"POST",
	self, @"PATCH",
	self, @"PUT",
	self, @"DELETE",
	self, @"TRACE",
	self, @"OPTIONS",
	self, @"CONNECT",
	nil];
      }
  if ([methods objectForKey: [this->request HTTPMethod]] == nil)
    {
      NSLog(@"Invalid HTTP Method: %@", this->request);
      [self stopLoading];
      [this->client URLProtocol: self didFailWithError:
       [NSError errorWithDomain: @"Invalid HTTP Method"
                           code: 0
                       userInfo: [self _userInfoForErrorCode: 0]]];
      DESTROY(this->client);
      return;
    }
  if (_isLoading == YES)
    {
      NSLog(@"startLoading when load in progress");
      return;
    }

  _statusCode = 0;	/* No status returned yet.	*/
  _isLoading = YES;
  _complete = NO;

  /* Perform a redirect if the path is empty.
   * As per MacOs-X documentation.
   */
  if ([[[this->request URL] fullPath] length] == 0)
    {
      NSString		*s = [[this->request URL] absoluteString];
      NSURL		*url;

      if ([s rangeOfString: @"?"].length > 0)
        {
	  s = [s stringByReplacingString: @"?" withString: @"/?"];
	}
      else if ([s rangeOfString: @"#"].length > 0)
        {
	  s = [s stringByReplacingString: @"#" withString: @"/#"];
	}
      else
        {
          s = [s stringByAppendingString: @"/"];
	}
      url = [NSURL URLWithString: s];
      if (url == nil)
	{
	  NSError	*e;

	  e = [NSError errorWithDomain: @"Invalid redirect request"
				  code: 0
			      userInfo: [self _userInfoForErrorCode: 0]];
	  [self stopLoading];
	  [this->client URLProtocol: self didFailWithError: e];
    DESTROY(this->client);
	}
      else
	{
	  NSMutableURLRequest	*request;

	  request = AUTORELEASE([this->request mutableCopy]);
	  [request setURL: url];
          // This invocation may end up detroying us so need to retain/autorelease...
          AUTORELEASE(RETAIN(self));
    [this->client URLProtocol: self
       wasRedirectedToRequest: request
             redirectResponse: nil];
	}
      if (NO == _isLoading)
        {
	  return;	// Loading cancelled
	}
      if (nil != this->input)
	{
	  return;	// Following redirection
	}
      // Fall through to continue original connect.
    }

  if (0 && this->cachedResponse)
    {
    }
  else
    {
      NSURL	*url = [this->request URL];
      NSHost	*host = [NSHost hostWithName: [url host]];
      int	port = [[url port] intValue];

      _parseOffset = 0;
      DESTROY(_parser);

      if (host == nil)
        {
	  host = [NSHost hostWithAddress: [url host]];	// try dotted notation
	}
      if (host == nil)
        {
	  host = [NSHost hostWithAddress: @"127.0.0.1"];	// final default
	}
      if (port == 0)
        {
	  // default if not specified
	  port = [[url scheme] isEqualToString: @"https"] ? 443 : 80;
	}

      [NSStream getStreamsToHost: host
			    port: port
		     inputStream: &this->input
		    outputStream: &this->output];
      if (!this->input || !this->output)
	{
	  if (_debug == YES)
	    {
	      NSLog(@"%@ did not create streams for %@:%@",
		self, host, [url port]);
	    }
	  [self stopLoading];
	  [this->client URLProtocol: self didFailWithError:
           [NSError errorWithDomain: @"can't connect" code: 0
                           userInfo: [self _userInfoForErrorCode: 0 description: @"can't find host" host: host]]];
    DESTROY(this->client);
	  return;
	}
      [this->input retain];
      [this->output retain];
      if ([[url scheme] isEqualToString: @"https"] == YES)
        {
          static NSArray        *keys;
          NSUInteger            count;

          [this->input setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
                            forKey: NSStreamSocketSecurityLevelKey];
          [this->output setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
                             forKey: NSStreamSocketSecurityLevelKey];
          if (nil == keys)
            {
              keys = [[NSArray alloc] initWithObjects:
                GSTLSCAFile,
                GSTLSCertificateFile,
                GSTLSCertificateKeyFile,
                GSTLSCertificateKeyPassword,
                GSTLSDebug,
                GSTLSPriority,
                GSTLSRemoteHosts,
                GSTLSRevokeFile,
                GSTLSServerName,
                GSTLSVerify,
                nil];
            }
          count = [keys count];
          while (count-- > 0)
            {
              NSString      *key = [keys objectAtIndex: count];
              NSString      *str = [this->request _propertyForKey: key];

              if (nil != str)
                {
                  [this->output setProperty: str forKey: key];
                }
            }
          /* If there is no value set for the server name, and the host in the
           * URL is a domain name rather than an address, we use that.
           */
          if (nil == [this->output propertyForKey: GSTLSServerName])
            {
              NSString  *host = [url host];
              unichar   c;

              c = [host length] == 0 ? 0 : [host characterAtIndex: 0];
              if (c != 0 && c != ':' && !isdigit(c))
                {
                  [this->output setProperty: host forKey: GSTLSServerName];
                }
            }
          if (_debug) [this->output setProperty: @"YES" forKey: GSTLSDebug];
        }
      [this->input setDelegate: self];
      [this->output setDelegate: self];
      [this->input scheduleInRunLoop: [NSRunLoop currentRunLoop]
			     forMode: NSDefaultRunLoopMode];
      [this->output scheduleInRunLoop: [NSRunLoop currentRunLoop]
			      forMode: NSDefaultRunLoopMode];
      [this->input open];
      [this->output open];
      
      // TESTPLANT-MAL-090892017: Start a timer for this operation to avoid hangs...
      [self _startTimer];
    }
}

- (void) stopLoading
{
  if (_debug == YES)
    {
      NSWarnMLog(@"%@ stopLoading", self);
    }
  _isLoading = NO;
  DESTROY(_writeData);
  if (this->input != nil)
    {
      [this->input setDelegate: nil];
      [this->output setDelegate: nil];
      [this->input removeFromRunLoop: [NSRunLoop currentRunLoop]
			     forMode: NSDefaultRunLoopMode];
      [this->output removeFromRunLoop: [NSRunLoop currentRunLoop]
			      forMode: NSDefaultRunLoopMode];
      [this->input close];
      [this->output close];
      DESTROY(this->input);
      DESTROY(this->output);
      [self _stopTimer];
    }
}

- (void) _didLoad: (NSData*)d
{
  [this->client URLProtocol: self didLoadData: d];
}

- (void) _got: (NSStream*)stream
{
  int 		readCount = -1;
  NSError	*e;
  NSData	*d;
  BOOL		wasInHeaders = NO;
  int           totalRead = 0;
  
  if (_debug)
    {
      NSWarnMLog(@"streamStatus: %ld hasBytesAvailable: %ld",
                 (long)[stream  streamStatus], (long)[(NSInputStream *)stream hasBytesAvailable]);
    }

  // Continue reading until we've either filled our buffer or nothing
  // left to read - as the event for another *may* not happen depending on timing...

  NSStreamStatus sstat = [stream streamStatus];
  while ((totalRead < MAX_READ_BUFFER) && ([(NSInputStream *)stream hasBytesAvailable] || sstat == NSStreamStatusReading))
    {
      readCount = [(NSInputStream *)stream read: &READ_BUFFER[totalRead] maxLength: MAX_READ_BUFFER-totalRead];
      sstat = [stream streamStatus];
      
      if (_debug)
        {
          NSWarnMLog(@"-> readCount: %ld totalRead: %ld", (long)readCount, (long)totalRead);
        }

#if defined(_WIN32)
      // If the Tcp-Wait-For-Server-Close header was specfied in the request,
      // then hold the stream open until the server closes it.
      if ([[[this->request valueForHTTPHeaderField:@"Tcp-Wait-For-Server-Close"] lowercaseString] isEqualToString:@"true"])
        {
          // On Windows, the socket call is non-blocking, so we can't rely
          // on the readCount alone to tell us whether or not we're done.
          if (readCount < 0)
            {
              if (WSAGetLastError() == WSAEWOULDBLOCK)
                {
                  //  Try to read again
                  sstat = NSStreamStatusReading;
                  continue;
                }
              else
                {
                  // Error
                  break;
                }
            }
          else if (readCount == 0)
            {
              // EOF
              break;
            }
        }
      else
        {
          // Break on error...
          if (readCount <= 0)
            break;
        }
#else
      // Break on error...
      if (readCount <= 0)
        break;
#endif
      
      // Otherwise update the total read count...
      totalRead += readCount;
    }
  
  if (_debug)
    {
      NSWarnMLog(@"readCount: %ld totalRead: %ld", (long)readCount, (long)totalRead);
    }
  
  if ((readCount <= 0) && (totalRead == 0))
    {
      if (_debug)
        {
          NSWarnMLog(@"streamStatus: %ld", (long)[stream  streamStatus]);
        }
      
      if ([stream  streamStatus] == NSStreamStatusError)
        {
	  e = [stream streamError];
	  if (_debug)
	    {
	      NSWarnMLog(@"%@ receive error %@", self, e);
	    }
          [self stopLoading];
          [this->client URLProtocol: self didFailWithError: e];
          DESTROY(this->client);
	}
      return;
    }
  
  readCount = totalRead;
  if (_debug)
    {
      debugRead(self, readCount, READ_BUFFER);
    }

  if (_parser == nil)
    {
      _parser = [GSMimeParser new];
      [_parser setIsHttp];
    }
  wasInHeaders = [_parser isInHeaders];
  d = [NSData dataWithBytes: READ_BUFFER length: readCount];
  
  if ([_parser parse: d] == NO && (_complete = [_parser isComplete]) == NO)
    {
      if (_debug == YES)
	{
	  NSWarnMLog(@"%@ HTTP parse failure - %@", self, _parser);
	}
      e = [NSError errorWithDomain: @"parse error"
			      code: 0
			  userInfo: nil];
      [self stopLoading];
      [this->client URLProtocol: self didFailWithError: e];
      DESTROY(this->client);
      return;
    }
  else
    {
      BOOL		isInHeaders = [_parser isInHeaders];
      GSMimeDocument	*document = [_parser mimeDocument];
      unsigned		bodyLength;
      
      if (_debug)
        {
          NSWarnMLog(@"document: %@", document);
        }

      _complete = [_parser isComplete];
      if ((_complete == NO) && ([stream  streamStatus] == NSStreamStatusAtEnd))
        {
          if (_debug)
          {
            NSWarnMLog(@"premature stream status at END (NSStreamStatusAtEnd) complete: %ld", (long)_complete);
          }
          // Force to complete...
          _complete = YES;
        }

      if (_debug)
        {
          NSWarnMLog(@"_complete: %ld wasInHeaders: %ld isInHeaders: %ld", (long)_complete,
                     (long)wasInHeaders, (long)isInHeaders);
        }
      
      if (YES == wasInHeaders && NO == isInHeaders)
        {
	  GSMimeHeader		*info;
	  int			len = -1;
	  NSString		*ct;
	  NSString		*st;
	  NSString		*s;

	  info = [document headerNamed: @"http"];

	  _version = [[info value] floatValue];
	  if (_version < 1.1)
	    {
	      _shouldClose = YES;
	    }
	  else if ((s = [[document headerNamed: @"connection"] value]) != nil
	    && [s caseInsensitiveCompare: @"close"] == NSOrderedSame)
	    {
	      _shouldClose = YES;
	    }
	  else
	    {
	      _shouldClose = NO;	// Keep connection alive.
	    }

	  s = [info objectForKey: NSHTTPPropertyStatusCodeKey];
	  _statusCode = [s intValue];

	  s = [[document headerNamed: @"content-length"] value];
	  if ([s length] > 0)
	    {
	      len = [s intValue];
	    }
          
          if (_debug)
            {
              NSWarnMLog(@"statusCode: %ld len: %ld", (long)_statusCode, (long)len);
            }
          
	  s = [info objectForKey: NSHTTPPropertyStatusReasonKey];

/* Should use this?
	  NSString		*enc;
	  enc = [[document headerNamed: @"content-transfer-encoding"] value];
	  if (enc == nil)
	    {
	      enc = [[document headerNamed: @"transfer-encoding"] value];
	    }
*/

	  info = [document headerNamed: @"content-type"];
	  ct = [document contentType];
	  st = [document contentSubtype];
	  if (ct && st)
	    {
	      ct = [ct stringByAppendingFormat: @"/%@", st];
	    }
	  else
	    {
	      ct = nil;
	    }
	  _response = [[NSHTTPURLResponse alloc]
	    initWithURL: [this->request URL]
	    MIMEType: ct
	    expectedContentLength: len
	    textEncodingName: [info parameterForKey: @"charset"]];
	  [_response _setStatusCode: _statusCode text: s];
	  [document deleteHeaderNamed: @"http"];
	  [_response _setHeaders: [document allHeaders]];
          
          if (_debug)
            {
              NSWarnMLog(@"[document allHeaders]: %@", [document allHeaders]);
            }
          
          if (_statusCode == 204 || _statusCode == 304 || _statusCode == 404)
	    {
	      _complete = YES;	// No body expected.
	    }
	  else if (_complete == NO && [d length] == 0)
	    {
	      _complete = YES;	// Had EOF ... terminate
	    }

	  if (_statusCode == 401)
	    {
	      /* This is an authentication challenge, so we keep reading
	       * until the challenge is complete, then try to deal with it.
	       */
              _complete = _complete || ([this->input hasBytesAvailable] == NO);
              if (_debug)
                {
                  NSWarnMLog(@"[this->input hasBytesAvailable]: %ld streamStatus]: %ld",
                             (long)[this->input hasBytesAvailable], (long)[stream  streamStatus]);
                }
            }
          else if (((_statusCode >= 300) && (_statusCode <= 310)) && // Redirect status codes...
                   ([@"HEAD" isEqualToString: [this->request HTTPMethod]] == NO) && // Skip if a head request...
                   ((s = [[document headerNamed: @"location"] value]) != nil)) // Skip if no location specified...
            {
              // Some sites are a bit wierd...with the '//' or '/' prefix the redirect
              // don't work properly so we need to add/default the scheme if not present...
              if ([s hasPrefix: @"//"])
                {
                  s = [@"http:" stringByAppendingString: s];
                }
              else if ([s hasPrefix: @"/"])
                {
                  s = [@"http:/" stringByAppendingString: s];
                }
              
              // Create the URL...
              NSURL	*url = [NSURL URLWithString: s];
              
              if (url == nil)
                {
                  NSError	*e;
                  
                  e = [NSError errorWithDomain: @"Invalid redirect request"
                                          code: 0
                                      userInfo: nil];
                  [self stopLoading];
                  [this->client URLProtocol: self
                           didFailWithError: e];
                  DESTROY(this->client);
                }
              else
                {
                  NSMutableURLRequest	*request = AUTORELEASE([this->request mutableCopy]);
                  
                  [request setURL: url];
                  
                  // This invocation may end up detroying us so need to retain/autorelease...
                  AUTORELEASE(RETAIN(self));
                  
                  // Redirect to the new URL...
                  [this->client URLProtocol: self
                     wasRedirectedToRequest: request
                           redirectResponse: _response];
                }
            }
	  else
	    {
	      NSURLCacheStoragePolicy policy;

	      /* Get cookies from the response and accept them into
	       * shared storage if policy permits
	       */
	      if ([this->request HTTPShouldHandleCookies] == YES
		&& [_response isKindOfClass: [NSHTTPURLResponse class]] == YES)
		{
		  NSDictionary	*hdrs;
		  NSArray	*cookies;
		  NSURL		*url;

		  url = [_response URL];
		  hdrs = [_response allHeaderFields];
		  cookies = [NSHTTPCookie cookiesWithResponseHeaderFields: hdrs
								   forURL: url];
                  if (_debug)
                    {
                      NSWarnMLog(@"cookies: %@", cookies);
                    }
                  
                  // Store the cookie(s)...
		  [[NSHTTPCookieStorage sharedHTTPCookieStorage]
		    setCookies: cookies
		    forURL: url
		    mainDocumentURL: [this->request mainDocumentURL]];
		}

	      /* Tell the client that we have a response and how
	       * it should be cached.
	       */
	      policy = [this->request cachePolicy];
	      if (policy
		== (NSURLCacheStoragePolicy)NSURLRequestUseProtocolCachePolicy)
		{
		  if ([self isKindOfClass: [_NSHTTPSURLProtocol class]] == YES)
		    {
		      /* For HTTPS we should not allow caching unless the
		       * request explicitly wants it.
		       */
		      policy = NSURLCacheStorageNotAllowed;
		    }
		  else
		    {
		      /* For HTTP we allow caching unless the request
		       * specifically denies it.
		       */
		      policy = NSURLCacheStorageAllowed;
		    }
		}
	      [this->client URLProtocol: self
		     didReceiveResponse: _response
		     cacheStoragePolicy: policy];
	    }
	  
#if	USE_ZLIB
	  s = [[document headerNamed: @"content-encoding"] value];
	  if ([s isEqualToString: @"gzip"] || [s isEqualToString: @"x-gzip"])
	    {
	      this->decompressing = YES;
	      this->z.opaque = 0;
	      this->z.zalloc = zalloc;
	      this->z.zfree = zfree;
	      this->z.next_in = 0;
	      this->z.avail_in = 0;
	      inflateInit2(&this->z, 1);	// FIXME
	    }
#endif
	}
      
      if (_debug)
        {
          NSWarnMLog(@"complete: %ld d-length: %ld", (long)_complete, (long)[d length]);
        }
      
      if (_complete == YES)
	{
	  if (_statusCode == 401)
	    {
	      NSURLProtectionSpace	*space;
	      NSString			*hdr;
	      NSURL			*url;
	      int			failures = 0;

	      /* This was an authentication challenge.
	       */
	      hdr = [[document headerNamed: @"WWW-Authenticate"] value];
	      url = [this->request URL];
	      space = [GSHTTPAuthentication
		protectionSpaceForAuthentication: hdr requestURL: url];
	      DESTROY(_credential);	
	      if (space != nil)
		{
		  /* Create credential from user and password
		   * stored in the URL.
		   * Returns nil if we have no username or password.
		   */
		  _credential = [[NSURLCredential alloc]
		    initWithUser: [url user]
		    password: [url password]
		    persistence: NSURLCredentialPersistenceForSession];
		  if (_credential == nil)
		    {
		      /* No credential from the URL, so we try using the
		       * default credential for the protection space.
		       */
		      ASSIGN(_credential,
			[[NSURLCredentialStorage sharedCredentialStorage]
			  defaultCredentialForProtectionSpace: space]);
		    }
		}

	      if (_challenge != nil)
		{
		  /* The failure count is incremented if we have just
		   * tried a request in the same protection space.
		   */
		  if (YES == [[_challenge protectionSpace] isEqual: space])
		    {
		      failures = [_challenge previousFailureCount] + 1; 
		    }
		}
	      else if ([this->request valueForHTTPHeaderField:@"Authorization"])
		{
		  /* Our request had an authorization header, so we should
		   * count that as a failure or we wouldn't have been
		   * challenged.
		   */
		  failures = 1;
		}
	      DESTROY(_challenge);

	      _challenge = [[NSURLAuthenticationChallenge alloc]
		initWithProtectionSpace: space
		proposedCredential: _credential
		previousFailureCount: failures
		failureResponse: _response
		error: nil
		sender: self];

	      /* Allow the client to control the credential we send
	       * or whether we actually send at all.
	       */
	      [this->client URLProtocol: self
		didReceiveAuthenticationChallenge: _challenge];

	      if (_challenge == nil)
		{
		  NSError	*e;

		  /* The client cancelled the authentication challenge
		   * so we must cancel the download.
		   */
		  e = [NSError errorWithDomain: @"Authentication cancelled"
					  code: 0
				      userInfo: nil];
		  [self stopLoading];
		  [this->client URLProtocol: self didFailWithError: e];
      DESTROY(this->client);
		}
	      else
		{
		  NSString	*auth = nil;

		  if (_credential != nil)
		    {
		      GSHTTPAuthentication	*authentication;

		      /* Get information about basic or
		       * digest authentication.
		       */
		      authentication = [GSHTTPAuthentication
			authenticationWithCredential: _credential
			inProtectionSpace: space];

		      /* Generate authentication header value for the
		       * authentication type in the challenge.
		       */
		      auth = [authentication
			authorizationForAuthentication: hdr
			method: [this->request HTTPMethod]
			path: [url fullPath]];
		    }

		  if (auth == nil)
		    {
		      NSURLCacheStoragePolicy policy;

		      /* We have no authentication credentials so we
		       * treat this as a download of the challenge page.
		       */

		      /* Tell the client that we have a response and how
		       * it should be cached.
		       */
		      policy = [this->request cachePolicy];
		      if (policy == (NSURLCacheStoragePolicy)
			NSURLRequestUseProtocolCachePolicy)
			{
			  if ([self isKindOfClass: [_NSHTTPSURLProtocol class]])
			    {
			      /* For HTTPS we should not allow caching unless
			       * the request explicitly wants it.
			       */
			      policy = NSURLCacheStorageNotAllowed;
			    }
			  else
			    {
			      /* For HTTP we allow caching unless the request
			       * specifically denies it.
			       */
			      policy = NSURLCacheStorageAllowed;
			    }
			}
		      [this->client URLProtocol: self
			     didReceiveResponse: _response
			     cacheStoragePolicy: policy];
		      /* Fall through to code providing page data.
		       */
		    }
		  else
		    {
		      NSMutableURLRequest	*request;

		      /* To answer the authentication challenge,
		       * we must retry with a modified request and
		       * with the cached response cleared.
		       */
		      request = [this->request mutableCopy];
		      [request setValue: auth
			forHTTPHeaderField: @"Authorization"];
		      [self stopLoading];
		      [this->request release];
		      this->request = request;
		      DESTROY(this->cachedResponse);
		      [self startLoading];
		      return;
		    }
		}
	    }

	  [this->input removeFromRunLoop: [NSRunLoop currentRunLoop]
				 forMode: NSDefaultRunLoopMode];
	  [this->output removeFromRunLoop: [NSRunLoop currentRunLoop]
				  forMode: NSDefaultRunLoopMode];
	  if (_shouldClose == YES)
	    {
	      [this->input setDelegate: nil];
	      [this->output setDelegate: nil];
	      [this->input close];
	      [this->output close];
	      DESTROY(this->input);
	      DESTROY(this->output);
              [self _stopTimer];
	    }

	  /*
	   * Tell superclass that we have successfully loaded the data
	   * (as long as we haven't had the load terminated by the client).
	   */
	  if (_isLoading == YES)
	    {
	      d = [_parser data];
	      bodyLength = [d length];
	      if (bodyLength > _parseOffset)
		{
		  if (_parseOffset > 0)
		    {
		      d = [d subdataWithRange: 
			NSMakeRange(_parseOffset, bodyLength - _parseOffset)];
		    }
		  _parseOffset = bodyLength;
		  [self _didLoad: d];
		}

	      /* Check again in case the client cancelled the load inside
	       * the URLProtocol:didLoadData: callback.
	       */
	      if (_isLoading == YES)
	        {
		  _isLoading = NO;
	          [this->client URLProtocolDidFinishLoading: self];
            DESTROY(this->client);
		}
	    }
	}
      else if (_isLoading == YES && _statusCode != 401)
	{
	  /*
	   * Report partial data if possible.
	   */
	  if ([_parser isInBody])
	    {
	      d = [_parser data];
	      bodyLength = [d length];
	      if (bodyLength > _parseOffset)
	        {
		  if (_parseOffset > 0)
		    {
		      d = [d subdataWithRange: 
			NSMakeRange(_parseOffset, [d length] - _parseOffset)];
		    }
		  _parseOffset = bodyLength;
		  [self _didLoad: d];
		}
	    }
          
          // Status code 200 with HEAD request is complete at this point...
          //if ((_statusCode == 200) && ([[this->request HTTPMethod] isEqualToString: @"HEAD"]))
          if (([[this->request HTTPMethod] isEqualToString: @"HEAD"]) && (isInHeaders == NO))
            {
              _isLoading = NO;
              [this->client URLProtocolDidFinishLoading: self];
              DESTROY(this->client);
            }
	}

      if (_complete == NO && readCount == 0 && _isLoading == YES)
	{
	  /* The read failed ... dropped, but parsing is not complete.
	   * The request was sent, so we can't know whether it was
	   * lost in the network or the remote end received it and
	   * the response was lost.
	   */
	  if (_debug == YES)
	    {
	      NSWarnMLog(@"%@ HTTP response not received - %@", self, _parser);
	    }
	  [self stopLoading];
    NSError *error = [NSError errorWithDomain: @"receive incomplete" code: 0 userInfo: nil];
    [this->client URLProtocol: self didFailWithError:error];
    //[self _userInfoForErrorCode: 0 description: @"receive incomplete"]
    DESTROY(this->client);
	}
    }
}

- (void) stream: (NSStream*) stream handleEvent: (NSStreamEvent) event
{
  /* Make sure no action triggered by anything else destroys us prematurely.
   */
  IF_NO_GC([[self retain] autorelease];)

  if (_debug)
    {
      NSWarnMLog(@"stream: %@ handleEvent: %p for: %@ (ip %p, op %p)",
            stream, (void*)event, self, this->input, this->output);
    }
  
  if (stream == this->input) 
    {
      switch(event)
	{
	  case NSStreamEventHasBytesAvailable: 
	  case NSStreamEventEndEncountered:
	    [self _got: stream];
	    return;

	  case NSStreamEventOpenCompleted: 
	    if (_debug == YES)
	      {
		NSWarnMLog(@"%@ HTTP input stream opened", self);
	      }
	    return;

	  default: 
	    break;
	}
    }
  else if (stream == this->output)
    {
      switch(event)
	{
	  case NSStreamEventOpenCompleted: 
	    {
	      NSMutableData	*m;
	      NSDictionary	*d;
	      NSEnumerator	*e;
	      NSString		*s;
	      NSURL		*u;
	      int		l;		

	      if (_debug == YES)
	        {
	          NSWarnMLog(@"%@ HTTP output stream opened", self);
	        }
	      DESTROY(_writeData);
	      _writeOffset = 0;
	      if ([this->request HTTPBodyStream] == nil)
	        {
		  // Not streaming
		  l = [[this->request HTTPBody] length];
		  _version = 1.1;
		}
	      else
	        {
		  // Stream and close
		  l = -1;
	          _version = 1.0;
		  // TESTPLANT-MAL-20201209: This closes the stream before it completely
		  // is able to finish writing out the data...
		  //_shouldClose = YES;
		}

	      m = [[NSMutableData alloc] initWithCapacity: 1024];

	      /* The request line is of the form:
	       * method /path?query HTTP/version
	       * where the query part may be missing
	       */
	      [m appendData: [[this->request HTTPMethod]
                dataUsingEncoding: NSASCIIStringEncoding]];
	      [m appendBytes: " " length: 1];
	      u = [this->request URL];
	      s = [[u fullPath] stringByAddingPercentEscapesUsingEncoding:
		NSUTF8StringEncoding];
	      if ([s hasPrefix: @"/"] == NO)
	        {
		  [m appendBytes: "/" length: 1];
		}
	      [m appendData: [s dataUsingEncoding: NSASCIIStringEncoding]];
	      s = [u query];
	      if ([s length] > 0)
	        {
		  [m appendBytes: "?" length: 1];
		  [m appendData: [s dataUsingEncoding: NSASCIIStringEncoding]];
		}
	      s = [NSString stringWithFormat: @" HTTP/%0.1f\r\n", _version];
	      [m appendData: [s dataUsingEncoding: NSASCIIStringEncoding]];

	      d = [this->request allHTTPHeaderFields];
	      e = [d keyEnumerator];
	      while ((s = [e nextObject]) != nil)
	        {
                  GSMimeHeader      *h;

                  h = [[GSMimeHeader alloc] initWithName: s
                                                   value: [d objectForKey: s]
                                              parameters: nil];
                  [m appendData:
                    [h rawMimeDataPreservingCase: YES foldedAt: 0]];
                  RELEASE(h);
		}

	      /* Use valueForHTTPHeaderField: to check for content-type
	       * header as that does a case insensitive comparison and
	       * we therefore won't end up adding a second header by
	       * accident because the two header names differ in case.
	       */
	      if ([[this->request HTTPMethod] isEqual: @"POST"]
	        && [this->request valueForHTTPHeaderField:
		  @"Content-Type"] == nil)
		{
		  /* On MacOSX, this is automatically added to POST methods */
                  static char   *ct
                    = "Content-Type: application/x-www-form-urlencoded\r\n";
		  [m appendBytes: ct length: strlen(ct)];
		}
	      if ([this->request valueForHTTPHeaderField: @"Host"] == nil)
		{
                  NSString      *s = [u scheme];
		  id	p = [u port];
		  id	h = [u host];

		  if (h == nil)
		    {
		      h = @"";	// Must send an empty host header
		    }
                  if (([s isEqualToString: @"http"] && [p intValue] == 80)
                    || ([s isEqualToString: @"https"] && [p intValue] == 443))
		    {
                      /* Some buggy systems object to the port being in
                       * the Host header when it's the default (optional)
                       * value.
                       * To keep them happy let's omit it in those cases.
                       */
                      p = nil;
                    }
		  if (nil == p)
		    {
		      s = [NSString stringWithFormat: @"Host: %@\r\n", h];
		    }
		  else
		    {
		      s = [NSString stringWithFormat: @"Host: %@:%@\r\n", h, p];
		    }
                  [m appendData: [s dataUsingEncoding: NSASCIIStringEncoding]];
		}
	      if (l >= 0 && [this->request
	        valueForHTTPHeaderField: @"Content-Length"] == nil)
		{
                  s = [NSString stringWithFormat: @"Content-Length: %d\r\n", l];
                  [m appendData: [s dataUsingEncoding: NSASCIIStringEncoding]];
		}
	      [m appendBytes: "\r\n" length: 2];	// End of headers
	      _writeData  = m;
	    }			// Fall through to do the write

	  case NSStreamEventHasSpaceAvailable: 
	    {
	      int	written;
	      BOOL	sent = NO;

	      // FIXME: should also send out relevant Cookies
	      if (_writeData != nil)
		{
		  const unsigned char	*bytes = [_writeData bytes];
		  unsigned		len = [_writeData length];
                  
                  if (_debug)
                    {
                      NSWarnMLog(@"self: %@ writing _writeData len: %ld", self, (long)len);
                    }

		  written = [this->output write: bytes + _writeOffset
				      maxLength: len - _writeOffset];
                  
                  if (_debug)
                    {
                      NSWarnMLog(@"self: %@ wrote len: %ld", self, (long)written);
                    }

                  if (written > 0)
		    {
		      if (_debug == YES)
		        {
                          debugWrite(self, written, bytes + _writeOffset);
			}
		      _writeOffset += written;
		      if (_writeOffset >= len)
		        {
			  DESTROY(_writeData);
			  if (_body == nil)
			    {
			      _body = RETAIN([this->request HTTPBodyStream]);
			      if (_body == nil)
				{
				  NSData	*d = [this->request HTTPBody];

				  if (d != nil)
				    {
				      _body = [NSInputStream alloc];
				      _body = [_body initWithData: d];
				      [_body open];
				    }
				  else
				    {
				      sent = YES;
				    }
				}
			      else //if ([_body streamStatus] == NSStreamStatusNotOpen)
				{
				    // TESTPLANT-MAL-20201203:
				    // Ensure that the body stream we get is open...
				    // NOTE: invoking streamStatus in the if above makes
				    // this fail for some reason...
				    [_body open];
				}
			    }
			}
		    }
		}
	      else if (_body != nil)
		{
		  if ([_body hasBytesAvailable])
		    {
		      int len;

                      // Probably need a read until end here also similar to _got...
		      len = [_body read: WRITE_BUFFER maxLength: MAX_WRITE_BUFFER];
                      if (_debug)
                        {
                          NSWarnMLog(@"self: %@ _body read len: %ld streamStatus: %ld", self, (long)len, (long)[_body streamStatus]);
                        }
		      if (len < 0)
			{
			  if (_debug == YES)
			    {
			      NSWarnMLog(@"%@ error reading from HTTPBody stream %@", self, [NSError _last]);
			    }
			  [self stopLoading];
			  NSError *error = [NSError errorWithDomain: @"can't read body" code: 0 userInfo: nil];
			  [this->client URLProtocol: self didFailWithError: error];
			  DESTROY(this->client);
			  return;
			}
		      else if (len > 0)
		        {
			  written = [this->output write: WRITE_BUFFER maxLength: len];
			  if (written > 0)
			    {
			      if (_debug == YES)
				{
                                  debugWrite(self, written, WRITE_BUFFER);
				}
			      len -= written;
			      if (len > 0)
			        {
				  /* Couldn't write it all now, save and try
				   * again later.
				   */
				  _writeData = [[NSData alloc] initWithBytes:
				    WRITE_BUFFER + written length: len];
				  _writeOffset = 0;
				}
			      else if (len == 0 && ![_body hasBytesAvailable])
				{
				  /* all _body's bytes are read and written
                                   * so we shouldn't wait for another
                                   * opportunity to close _body and set
				   * the flag 'sent'.
				   */
				  [_body close];
				  DESTROY(_body);
				  sent = YES;
                                }
			    }
                          else if ([this->output streamStatus] == NSStreamStatusWriting)
                            {
                              /* Couldn't write it all now, save and try
                               * again later.
                               */
                              if (_debug)
                                {
                                  NSWarnMLog(@"self: %@ saving _writeData len: %ld", self, (long)len);
                                }
                              _writeData = [[NSData alloc] initWithBytes:
                                            WRITE_BUFFER length: len];
                              _writeOffset = 0;
                            }
                        }
		      else
		        {
			  [_body close];
			  DESTROY(_body);
			  sent = YES;
			}
		    }
		  else
		    {
		      [_body close];
		      DESTROY(_body);
		      sent = YES;
		    }
		}
	      if (sent == YES)
		{
		  if (_debug)
		    {
		      NSWarnMLog(@"%@ request sent - should close: %ld", self, (long)_shouldClose);
		    }
		  if (_shouldClose == YES)
		    {
		      [this->output setDelegate: nil];
		      [this->output removeFromRunLoop:
			[NSRunLoop currentRunLoop]
			forMode: NSDefaultRunLoopMode];
		      [this->output close];
		      DESTROY(this->output);
		    }
		}
	      return;  // done
	    }
	  default: 
	    break;
	}
    }
  else
    {
      NSLog(@"Unexpected event %"PRIuPTR
	" occurred on stream %@ not being used by %@",
	event, stream, self);
    }
  if (event == NSStreamEventErrorOccurred)
    {
      NSError	*error = AUTORELEASE(RETAIN([stream streamError]));

      [self stopLoading];
      [this->client URLProtocol: self didFailWithError: error];
      DESTROY(this->client);
    }
  else
    {
      NSLog(@"Unexpected event %"PRIuPTR" ignored on stream %@ of %@",
	event, stream, self);
    }
}

- (void) useCredential: (NSURLCredential*)credential
  forAuthenticationChallenge: (NSURLAuthenticationChallenge*)challenge
{
  if (challenge == _challenge)
    {
      ASSIGN(_credential, credential);
    }
}
@end

@implementation _NSHTTPSURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"https"];
}

@end

@implementation _NSFTPURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"ftp"];
}

+ (NSURLRequest*) canonicalRequestForRequest: (NSURLRequest*)request
{
  return request;
}

- (void) startLoading
{
  if (this->cachedResponse)
    { // handle from cache
    }
  else
    {
      NSURL	*url = [this->request URL];
      NSHost	*host = [NSHost hostWithName: [url host]];

      if (host == nil)
        {
	  host = [NSHost hostWithAddress: [url host]];
	}
      [NSStream getStreamsToHost: host
			    port: [[url port] intValue]
		     inputStream: &this->input
		    outputStream: &this->output];
      if (this->input == nil || this->output == nil)
	{
    NSError *error = [NSError errorWithDomain: @"can't connect" code: 0 userInfo: nil];
	  [this->client URLProtocol: self didFailWithError: error];
    DESTROY(this->client);
	  return;
	}
      [this->input retain];
      [this->output retain];
      if ([[url scheme] isEqualToString: @"https"] == YES)
        {
          [this->input setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
                            forKey: NSStreamSocketSecurityLevelKey];
          [this->output setProperty: NSStreamSocketSecurityLevelNegotiatedSSL
                             forKey: NSStreamSocketSecurityLevelKey];
        }
      [this->input setDelegate: self];
      [this->output setDelegate: self];
      [this->input scheduleInRunLoop: [NSRunLoop currentRunLoop]
			     forMode: NSDefaultRunLoopMode];
      [this->output scheduleInRunLoop: [NSRunLoop currentRunLoop]
			      forMode: NSDefaultRunLoopMode];
      // set socket options for ftps requests
      [this->input open];
      [this->output open];
    }
}

- (void) stopLoading
{
  if (this->input)
    {
      [this->input setDelegate: nil];
      [this->output setDelegate: nil];
      [this->input removeFromRunLoop: [NSRunLoop currentRunLoop]
			     forMode: NSDefaultRunLoopMode];
      [this->output removeFromRunLoop: [NSRunLoop currentRunLoop]
			      forMode: NSDefaultRunLoopMode];
      [this->input close];
      [this->output close];
      DESTROY(this->input);
      DESTROY(this->output);
    }
}

- (void) stream: (NSStream *) stream handleEvent: (NSStreamEvent) event
{
  if (stream == this->input) 
    {
      switch(event)
	{
	  case NSStreamEventHasBytesAvailable: 
	    {
	    NSLog(@"FTP input stream has bytes available");
      // implement FTP protocol
      //[this->client URLProtocol: self didLoadData: [NSData dataWithBytes: buffer length: len]];	// notify
	    return;
	    }
	  case NSStreamEventEndEncountered: 	// can this occur in parallel to NSStreamEventHasBytesAvailable???
		  NSLog(@"FTP input stream did end");
		  [this->client URLProtocolDidFinishLoading: self];
      DESTROY(this->client);
		  return;
	  case NSStreamEventOpenCompleted: 
		  // prepare to receive header
		  NSLog(@"FTP input stream opened");
		  return;
	  default: 
		  break;
	}
    }
  else if (stream == this->output)
    {
      NSLog(@"An event occurred on the output stream.");
  	// if successfully opened, send out FTP request header
    }
  else
    {
      NSLog(@"Unexpected event %"PRIuPTR
	" occurred on stream %@ not being used by %@",
	event, stream, self);
    }
  if (event == NSStreamEventErrorOccurred)
    {
      NSLog(@"An error %@ occurred on stream %@ of %@",
            [stream streamError], stream, self);
      [self stopLoading];
      [this->client URLProtocol: self didFailWithError: [stream streamError]];
      DESTROY(this->client);
    }
  else
    {
      NSLog(@"Unexpected event %"PRIuPTR" ignored on stream %@ of %@",
	event, stream, self);
    }
}

@end

@implementation _NSFileURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"file"];
}

+ (NSURLRequest*) canonicalRequestForRequest: (NSURLRequest*)request
{
  return request;
}

- (void) startLoading
{
  // check for GET/PUT/DELETE etc so that we can also write to a file
  NSData	*data;
  NSURLResponse	*r;

  data = [NSData dataWithContentsOfFile: [[this->request URL] path]
  /* options: error: - don't use that because it is based on self */];
  if (data == nil)
    {
      NSDictionary *errorinfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [this->request URL], @"URL",
                                 [[this->request URL] path], @"path",
                                 nil];
      NSError      *error = [NSError errorWithDomain: @"can't load file" code: 0 userInfo: errorinfo];
      [this->client URLProtocol: self didFailWithError: error];
      DESTROY(this->client);
      return;
    }

  /* FIXME ... maybe should infer MIME type and encoding from extension or BOM
   */
  r = [[NSURLResponse alloc] initWithURL: [this->request URL]
				MIMEType: @"text/html"
		   expectedContentLength: [data length]
			textEncodingName: @"unknown"];	
  [this->client URLProtocol: self
    didReceiveResponse: r
    cacheStoragePolicy: NSURLRequestUseProtocolCachePolicy];
  [this->client URLProtocol: self didLoadData: data];
  [this->client URLProtocolDidFinishLoading: self];
  DESTROY(this->client);
  RELEASE(r);
}

- (void) stopLoading
{
  return;
}

@end

@implementation _NSDataURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"data"];
}

+ (NSURLRequest*) canonicalRequestForRequest: (NSURLRequest*)request
{
  return request;
}

- (void) startLoading
{
  NSURLResponse *r;
  NSString      *mime = @"text/plain";
  NSString      *encoding = @"US-ASCII";
  NSData        *data;
  NSString      *spec = [[this->request URL] resourceSpecifier];
  NSRange       comma = [spec rangeOfString:@","];
  NSEnumerator  *types;
  NSString      *type;
  BOOL          base64 = NO;

  if (comma.location == NSNotFound)
    {
      NSDictionary      *ui;
      NSError           *error;

      ui = [NSDictionary dictionaryWithObjectsAndKeys:
        [this->request URL], @"URL",
        [[this->request URL] path], @"path",
        nil];
      error = [NSError errorWithDomain: @"can't load data"
                                  code: 0
                              userInfo: ui];
      [this->client URLProtocol: self didFailWithError: error];
      DESTROY(this->client);
      return;
    }
  types = [[[spec substringToIndex: comma.location]
    componentsSeparatedByString: @";"] objectEnumerator];
  while (nil != (type = [types nextObject]))
    {
      if ([type isEqualToString: @"base64"])
	{
	  base64 = YES;
	}
      else if ([type hasPrefix: @"charset="])
	{
	  encoding = [type substringFromIndex: 8];
	}
      else if ([type length] > 0)
	{
	  mime = type;
	}
    }
  spec = [spec substringFromIndex: comma.location + 1];
  if (YES == base64)
    {
      data = [GSMimeDocument decodeBase64:
        [spec dataUsingEncoding: NSUTF8StringEncoding]];
    }
  else
    {
      data = [[spec stringByReplacingPercentEscapesUsingEncoding:
        NSUTF8StringEncoding] dataUsingEncoding: NSUTF8StringEncoding];
    }
  r = [[NSURLResponse alloc] initWithURL: [this->request URL]
    MIMEType: mime
    expectedContentLength: [data length]
    textEncodingName: encoding];

  [this->client URLProtocol: self
         didReceiveResponse: r 
	 cacheStoragePolicy: NSURLRequestUseProtocolCachePolicy];
  [this->client URLProtocol: self didLoadData: data];
  [this->client URLProtocolDidFinishLoading: self];
  DESTROY(this->client);
  RELEASE(r);
}

- (void) stopLoading
{
  return;
}

@end

@implementation _NSAboutURLProtocol

+ (BOOL) canInitWithRequest: (NSURLRequest*)request
{
  return [[[request URL] scheme] isEqualToString: @"about"];
}

+ (NSURLRequest*) canonicalRequestForRequest: (NSURLRequest*)request
{
  return request;
}

- (void) startLoading
{
  NSURLResponse	*r;
  NSData	*data = [NSData data];	// no data

  // we could pass different content depending on the url path
  r = [[NSURLResponse alloc] initWithURL: [this->request URL]
				MIMEType: @"text/html"
		   expectedContentLength: 0
			textEncodingName: @"utf-8"];	
  [this->client URLProtocol: self
    didReceiveResponse: r
    cacheStoragePolicy: NSURLRequestUseProtocolCachePolicy];
  [this->client URLProtocol: self didLoadData: data];
  [this->client URLProtocolDidFinishLoading: self];
  DESTROY(this->client);
  RELEASE(r);
}

- (void) stopLoading
{
  return;
}

@end
