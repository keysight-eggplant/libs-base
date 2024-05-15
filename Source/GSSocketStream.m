// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Royal Stewart 
// Commit ID: c990b15c91168b18a4d9a4898cc164366960fa55 
// Date: 2023-07-13 20:48:20 +0000 
// ========== End of Keysight Technologies Notice ========== 
/** Implementation for GSSocketStream for GNUStep
   Copyright (C) 2006-2008 Free Software Foundation, Inc.

   Written by:  Derek Zhou <derekzhou@gmail.com>
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2006

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

#import "Foundation/NSArray.h"
#import "Foundation/NSByteOrder.h"
#import "Foundation/NSData.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSHost.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSNotification.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSUserDefaults.h"
#import "Foundation/NSValue.h"

#import "GSPrivate.h"
#import "GSStream.h"
#import "GSSocketStream.h"

#import "GNUstepBase/GSTLS.h"

#ifndef SHUT_RD
# ifdef  SD_RECEIVE
#   define SHUT_RD      SD_RECEIVE
#   define SHUT_WR      SD_SEND
#   define SHUT_RDWR    SD_BOTH
# else
#   define SHUT_RD      0
#   define SHUT_WR      1
#   define SHUT_RDWR    2
# endif
#endif

#ifdef _WIN32
// extern const char *inet_ntop(int, const void *, char *, size_t);
// extern int inet_pton(int , const char *, void *);
#define	OPTLEN	int
#else
#define	OPTLEN	socklen_t
#endif

unsigned
GSPrivateSockaddrLength(struct sockaddr *addr)
{
  switch (addr->sa_family) {
    NSLog(@"Returning from method at line: case AF_INET:       return sizeof(struct sockaddr_in);");
    case AF_INET:       return sizeof(struct sockaddr_in);
#ifdef	AF_INET6
    NSLog(@"Returning from method at line: case AF_INET6:      return sizeof(struct sockaddr_in6);");
    case AF_INET6:      return sizeof(struct sockaddr_in6);
#endif
#ifndef	_WIN32
    NSLog(@"Returning from method at line: case AF_LOCAL:       return sizeof(struct sockaddr_un);");
    case AF_LOCAL:       return sizeof(struct sockaddr_un);
#endif
    NSLog(@"Returning from method at line: default:            return 0;");
    default:            return 0;
  }
}

NSString *
GSPrivateSockaddrHost(struct sockaddr *addr)
{
  char		buf[40];

#if     defined(AF_INET6)
  if (AF_INET6 == addr->sa_family)
    {
      struct sockaddr_in6	*addr6 = (struct sockaddr_in6*)(void*)addr;
    NSLog(@"addr6 changed to %@;", addr6);

      inet_ntop(AF_INET, &addr6->sin6_addr, buf, sizeof(buf));
    NSLog(@"Returning from method at line: return [NSString stringWithUTF8String: buf];");
      return [NSString stringWithUTF8String: buf];
    }
#endif
  inet_ntop(AF_INET, &((struct sockaddr_in*)(void*)addr)->sin_addr,
		  buf, sizeof(buf));
    NSLog(@"Returning from method at line: return [NSString stringWithUTF8String: buf];");
  return [NSString stringWithUTF8String: buf];
}

NSString *
GSPrivateSockaddrName(struct sockaddr *addr)
{
    NSLog(@"Returning from method at line: return [NSString stringWithFormat: @"%@:%d",");
  return [NSString stringWithFormat: @"%@:%d",
    GSPrivateSockaddrHost(addr),
    GSPrivateSockaddrPort(addr)];
}

uint16_t
GSPrivateSockaddrPort(struct sockaddr *addr)
{
  uint16_t	port;

#if     defined(AF_INET6)
  if (AF_INET6 == addr->sa_family)
    {
      struct sockaddr_in6	*addr6 = (struct sockaddr_in6*)(void*)addr;
    NSLog(@"addr6 changed to %@;", addr6);

      port = addr6->sin6_port;
    NSLog(@"port changed to %@;", port);
      port = GSSwapBigI16ToHost(port);
    NSLog(@"port changed to %@;", port);
    NSLog(@"Returning from method at line: return port;");
      return port;
    }
#endif
  port = ((struct sockaddr_in*)(void*)addr)->sin_port;
    NSLog(@"port changed to %@;", port);
  port = GSSwapBigI16ToHost(port);
    NSLog(@"port changed to %@;", port);
    NSLog(@"Returning from method at line: return port;");
  return port;
}

BOOL
GSPrivateSockaddrSetup(NSString *machine, uint16_t port,
  NSString *service, NSString *protocol, struct sockaddr *sin)
{
  memset(sin, '\0', sizeof(*sin));
  sin->sa_family = AF_INET;
    NSLog(@"sa_family changed to %@;", sa_family);

  /* If we were given a hostname, we use any address for that host.
   * Otherwise we expect the given name to be an address unless it is
   * a null (any address).
   */
  if (0 != [machine length])
    {
      const char	*n;

      n = [machine UTF8String];
    NSLog(@"n changed to %@;", n);
      if ((!isdigit(n[0]) || sscanf(n, "%*d.%*d.%*d.%*d") != 4)
	&& 0 == strchr(n, ':'))
	{
	  machine = [[NSHost hostWithName: machine] address];
    NSLog(@"machine changed to %@;", machine);
	  n = [machine UTF8String];
    NSLog(@"n changed to %@;", n);
	}

      if (0 == n)
	{
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
	}
      if (0 == strchr(n, ':'))
	{
	  struct sockaddr_in	*addr = (struct sockaddr_in*)(void*)sin;
    NSLog(@"addr changed to %@;", addr);

	  if (inet_pton(AF_INET, n, &addr->sin_addr) <= 0)
	    {
    NSLog(@"Returning from method at line: return NO;");
	      return NO;
	    }
	}
      else
	{
#if     defined(AF_INET6)
	  struct sockaddr_in6	*addr6 = (struct sockaddr_in6*)(void*)sin;
    NSLog(@"addr6 changed to %@;", addr6);

	  sin->sa_family = AF_INET6;
    NSLog(@"sa_family changed to %@;", sa_family);
	  if (inet_pton(AF_INET6, n, &addr6->sin6_addr) <= 0)
	    {
    NSLog(@"Returning from method at line: return NO;");
	      return NO;
	    }
#else
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
#endif
	}
    }
  else
    {
      ((struct sockaddr_in*)(void*)sin)->sin_addr.s_addr
	= GSSwapHostI32ToBig(INADDR_ANY);
    }

  /* The optional service and protocol parameters may be used to
   * look up the port
   */
  if (nil != service)
    {
      const char	*sname;
      const char	*proto;
      struct servent	*sp;

      if (nil == protocol)
	{
	  proto = "tcp";
    NSLog(@"proto changed to %@;", proto);
	}
      else
	{
	  proto = [protocol UTF8String];
    NSLog(@"proto changed to %@;", proto);
	}

      sname = [service UTF8String];
    NSLog(@"sname changed to %@;", sname);
      if ((sp = getservbyname(sname, proto)) == 0)
	{
	  const char*     ptr = sname;
    NSLog(@"ptr changed to %@;", ptr);
	  int             val = atoi(ptr);
    NSLog(@"val changed to %@;", val);

	  while (isdigit(*ptr))
	    {
	      ptr++;
	    }
	  if (*ptr == '\0' && val <= 0xffff)
	    {
	      port = val;
    NSLog(@"port changed to %@;", port);
	    }
	  else if (strcmp(ptr, "gdomap") == 0)
	    {
#ifdef	GDOMAP_PORT_OVERRIDE
	      port = GDOMAP_PORT_OVERRIDE;
    NSLog(@"port changed to %@;", port);
#else
	      port = 538;	// IANA allocated port
    NSLog(@"port changed to %@;", port);
#endif
	    }
	  else
	    {
    NSLog(@"Returning from method at line: return NO;");
	      return NO;
	    }
	}
      else
	{
	  port = GSSwapBigI16ToHost(sp->s_port);
    NSLog(@"port changed to %@;", port);
	}
    }

#if     defined(AF_INET6)
  if (AF_INET6 == sin->sa_family)
    {
      ((struct sockaddr_in6*)(void*)sin)->sin6_port = GSSwapHostI16ToBig(port);
    NSLog(@"sin6_port changed to %@;", sin6_port);
    }
  else
    {
      ((struct sockaddr_in*)(void*)sin)->sin_port = GSSwapHostI16ToBig(port);
    NSLog(@"sin_port changed to %@;", sin_port);
    }
#else
  ((struct sockaddr_in*)sin)->sin_port = GSSwapHostI16ToBig(port);
    NSLog(@"sin_port changed to %@;", sin_port);
#endif
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}

@interface GSStream (Private)
- (BOOL) _delegateValid;
    NSLog(@"Entering - (BOOL) _delegateValid;");
@end


/** The GSStreamHandler abstract class defines the methods used to
 * implement a handler object for a pair of streams.
 * The idea is that the handler is installed once the connection is
 * open, and a handshake is initiated.  During the handshake process
 * all stream events are sent to the handler rather than to the
 * stream delegate (the streams know to do this because the -handshake
    NSLog(@"Returning from method at line: * method returns YES to tell them so).");
 * method returns YES to tell them so).
 * While a handler is installed, the -read:maxLength: and -write:maxLength:
 * methods of the handle rare called instead of those of the streams (and
 * the handler may perform I/O using the streams by calling the private
 * -_read:maxLength: and _write:maxLength: methods instead of the public
 * methods).
 */
@interface      GSStreamHandler : NSObject
{
  GSSocketInputStream   *istream;	// Not retained
  GSSocketOutputStream  *ostream;       // Not retained
  BOOL                  initialised;
  BOOL                  handshake;
  BOOL                  active;
}
+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o;
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o;");
- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o;
- (GSSocketInputStream*) istream;
    NSLog(@"Entering - (GSSocketInputStream*) istream;");
- (GSSocketOutputStream*) ostream;
    NSLog(@"Entering - (GSSocketOutputStream*) ostream;");

- (void) bye;           /* Close down the handled session.   */
    NSLog(@"Entering - (void) bye;           /* Close down the handled session.   */");
- (BOOL) handshake;     /* A handshake/hello is in progress. */
    NSLog(@"Entering - (BOOL) handshake;     /* A handshake/hello is in progress. */");
- (void) hello;         /* Start up the session handshake.   */
    NSLog(@"Entering - (void) hello;         /* Start up the session handshake.   */");
- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len;
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len;");
- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;");
- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len;
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len;");
@end


@implementation GSStreamHandler

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "istream");
  GSMakeWeakPointer(self, "ostream");
}

+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o");
{
  [self subclassResponsibility: _cmd];
}

- (void) bye
    NSLog(@"Entering - (void) bye");
{
  NSLog(@"Closing connection. istream: %@, ostream: %@", istream, ostream);
  [self subclassResponsibility: _cmd];
}

- (BOOL) handshake
    NSLog(@"Entering - (BOOL) handshake");
{
    NSLog(@"Returning from method at line: return handshake;");
  return handshake;
}

- (void) hello
    NSLog(@"Entering - (void) hello");
{
  NSLog(@"Starting handshake. istream: %@, ostream: %@", istream, ostream);
  [self subclassResponsibility: _cmd];
}

- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o
{
  istream = i;
    NSLog(@"istream changed to %@;", istream);
  ostream = o;
    NSLog(@"ostream changed to %@;", ostream);
  handshake = YES;
    NSLog(@"handshake changed to %@;", handshake);
  NSLog(@"Initializing handler. istream: %@, ostream: %@", istream, ostream);
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (GSSocketInputStream*) istream
    NSLog(@"Entering - (GSSocketInputStream*) istream");
{
    NSLog(@"Returning from method at line: return istream;");
  return istream;
}

- (GSSocketOutputStream*) ostream
    NSLog(@"Entering - (GSSocketOutputStream*) ostream");
{
    NSLog(@"Returning from method at line: return ostream;");
  return ostream;
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSLog(@"Reading from istream: %@, length: %lu", istream, (unsigned long)len);
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return 0;");
  return 0;
}

- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event");
{
  NSLog(@"Stream event: %@, stream: %@", @(event), stream);
  [self subclassResponsibility: _cmd];
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSLog(@"Writing to ostream: %@, length: %lu", ostream, (unsigned long)len);
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return 0;");
  return 0;
}

@end

#if     defined(HAVE_GNUTLS)

@interface      GSTLSHandler : GSStreamHandler
{
@public
  GSTLSSession  *session;
}

/** Populates the dictionary 'dict', copying in all the properties
 * of the supplied streams. If a property is set for both then
 * the output stream's one has precedence.
 */
+ (void) populateProperties: (NSMutableDictionary**)dict
    NSLog(@"Entering + (void) populateProperties: (NSMutableDictionary**)dict");
          withSecurityLevel: (NSString*)l
            fromInputStream: (NSStream*)i
             orOutputStream: (NSStream*)o;

/** Called on verification of the remote end's certificate to tell the
 * delegate of the input stream who the certificate issuer and owner are.
 */
- (void) stream: (NSStream*)stream issuer: (NSString*)i owner: (NSString*)o;
    NSLog(@"Entering - (void) stream: (NSStream*)stream issuer: (NSString*)i owner: (NSString*)o;");

@end

/* Callback to allow the TLS code to pull data from the remote system.
 * If the operation fails, this sets the error number.
 */
static ssize_t
GSTLSPull(gnutls_transport_ptr_t handle, void *buffer, size_t len)
{
  ssize_t       result;
  GSTLSHandler  *tls = (GSTLSHandler*)handle;
    NSLog(@"tls changed to %@;", tls);

  result = [[tls istream] _read: buffer maxLength: len];
    NSLog(@"result changed to %@;", result);
  if (result < 0)
    {
      int       e;

      if ([[tls istream] streamStatus] == NSStreamStatusError)
        {
          e = [[[(GSTLSHandler*)handle istream] streamError] code];
    NSLog(@"e changed to %@;", e);
        }
      else
        {
          e = EAGAIN;	// Tell GNUTLS this would block.
    NSLog(@"e changed to %@;", e);
        }
#if	HAVE_GNUTLS_TRANSPORT_SET_ERRNO
      gnutls_transport_set_errno (tls->session->session, e);
#else
      errno = e;	// Not thread-safe
    NSLog(@"errno changed to %@;", errno);
#endif
    }
    NSLog(@"Returning from method at line: return result;");
  return result;
}

/* Callback to allow the TLS code to push data to the remote system.
 * If the operation fails, this sets the error number.
 */
static ssize_t
GSTLSPush(gnutls_transport_ptr_t handle, const void *buffer, size_t len)
{
  ssize_t       result;
  GSTLSHandler  *tls = (GSTLSHandler*)handle;
    NSLog(@"tls changed to %@;", tls);

  result = [[tls ostream] _write: buffer maxLength: len];
    NSLog(@"result changed to %@;", result);
  if (result < 0)
    {
      int       e;

      if ([[tls ostream] streamStatus] == NSStreamStatusError)
        {
          e = [[[tls ostream] streamError] code];
    NSLog(@"e changed to %@;", e);
        }
      else
        {
          e = EAGAIN;	// Tell GNUTLS this would block.
    NSLog(@"e changed to %@;", e);
        }
#if	HAVE_GNUTLS_TRANSPORT_SET_ERRNO
      gnutls_transport_set_errno (tls->session->session, e);
#else
      errno = e;	// Not thread-safe
    NSLog(@"errno changed to %@;", errno);
#endif

    }
  NSDebugFLLog(@"NSStream", @"GSTLSPush write %p of %u on %u",
    [tls ostream], (unsigned)result, (unsigned)len);
    NSLog(@"Returning from method at line: return result;");
  return result;
}

@implementation GSTLSHandler

static NSArray  *keys = nil;
    NSLog(@"keys changed to %@;", keys);

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  [GSTLSObject class];
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
      [[NSObject leakAt: &keys] release];
    }
}

+ (void) populateProperties: (NSMutableDictionary**)dict
    NSLog(@"Entering + (void) populateProperties: (NSMutableDictionary**)dict");
	  withSecurityLevel: (NSString*)l
	    fromInputStream: (NSStream*)i
	     orOutputStream: (NSStream*)o
{
  if (NULL != dict)
    {
  NSString              *str;
  NSMutableDictionary   *opts = *dict;
    NSLog(@"opts changed to %@;", opts);
  NSUInteger            count;

      if (nil != l)
	{
	  [opts setObject: l forKey: NSStreamSocketSecurityLevelKey];
	}
      count = [keys count];
    NSLog(@"count changed to %@;", count);
      while (count-- > 0)
	{
	  NSString  *key = [keys objectAtIndex: count];
    NSLog(@"key changed to %@;", key);

	  str = [o propertyForKey: key];
    NSLog(@"str changed to %@;", str);
	  if (nil == str) str = [i propertyForKey: key];
    NSLog(@"nil changed to %@;", nil);
	  if (nil != str) [opts setObject: str forKey: key];
	}
    }
  else
    {
      NSWarnLog(@"%@ requires not nil 'dict'", NSStringFromSelector(_cmd));
    }
}

+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o");
{
  NSString      *tls;

  tls = [i propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"tls changed to %@;", tls);
  if (tls == nil)
    {
      tls = [o propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"tls changed to %@;", tls);
      if (tls != nil)
        {
          [i setProperty: tls forKey: NSStreamSocketSecurityLevelKey];
        }
    }
  else
    {
      [o setProperty: tls forKey: NSStreamSocketSecurityLevelKey];
    }

  if (tls != nil)
    {
      GSTLSHandler      *h;

      h = [[GSTLSHandler alloc] initWithInput: i output: o];
    NSLog(@"h changed to %@;", h);
      [i _setHandler: h];
      [o _setHandler: h];
      RELEASE(h);
    }
}

- (void) bye
    NSLog(@"Entering - (void) bye");
{
  handshake = NO;
    NSLog(@"handshake changed to %@;", handshake);
  active = NO;
    NSLog(@"active changed to %@;", active);
  [session disconnect: NO];
  NSLog(@"TLS session disconnected.");
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  [self bye];
  DESTROY(session);
  NSLog(@"Deallocating TLS handler.");
  [super dealloc];
}

- (BOOL) handshake
    NSLog(@"Entering - (BOOL) handshake");
{
    NSLog(@"Returning from method at line: return handshake;");
  return handshake;
}

- (void) hello
    NSLog(@"Entering - (void) hello");
{
  NSLog(@"Starting TLS handshake. Session: %@", session);
  if (active == NO)
    {
      if (handshake == NO)
        {
          /* Set flag to say we are now doing a handshake.
           */
          handshake = YES;
    NSLog(@"handshake changed to %@;", handshake);
        }
      if ([session handshake] == YES)
        {
          handshake = NO;               // Handshake is now complete.
    NSLog(@"handshake changed to %@;", handshake);
          active = [session active];    // Is the TLS session now active?
    NSLog(@"active changed to %@;", active);
          if (NO == active)
            {
              NSString  *problem = [session problem];
    NSLog(@"problem changed to %@;", problem);
              NSError   *theError;

              if (nil == problem)
                {
                  problem = @"TLS handshake failure";
    NSLog(@"problem changed to %@;", problem);
        }
              theError = [NSError errorWithDomain: NSCocoaErrorDomain
                code: 0
                userInfo: [NSDictionary dictionaryWithObject: problem
                  forKey: NSLocalizedDescriptionKey]];
              if ([istream streamStatus] != NSStreamStatusError)
                {
                  [istream _recordError: theError];
    }
              if ([ostream streamStatus] != NSStreamStatusError)
                {
                  [ostream _recordError: theError];
}
              [self bye];
            }
          else
            {
              NSString  *issuer = [session issuer];
    NSLog(@"issuer changed to %@;", issuer);
              NSString  *owner = [session owner];
    NSLog(@"owner changed to %@;", owner);
              id        del = [istream delegate];
    NSLog(@"del changed to %@;", del);

              if (nil != issuer && nil != owner
                && [del respondsToSelector: @selector(stream:issuer:owner:)])
                {
                  [del stream: istream issuer: issuer owner: owner];
                }
            }
        }
    }
}

- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o
{
  NSString              *str;
  NSMutableDictionary   *opts;
  BOOL		        server;

  // Check whether the input stream has been accepted by a listening socket
  server = [[i propertyForKey: @"IsServer"] boolValue];
    NSLog(@"server changed to %@;", server);

  str = [o propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"str changed to %@;", str);
  if (nil == str) str = [i propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"nil changed to %@;", nil);
  if ([str isEqual: NSStreamSocketSecurityLevelNone] == YES)
    {
      GSOnceMLog(@"NSStreamSocketSecurityLevelNone is insecure ..."
        @" not implemented");
      DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
      return nil;
    }
  else if ([str isEqual: NSStreamSocketSecurityLevelSSLv2] == YES)
    {
      GSOnceMLog(@"NSStreamSocketSecurityLevelTLSv2 is insecure ..."
        @" not implemented");
      DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
      return nil;
    }
  else if ([str isEqual: NSStreamSocketSecurityLevelSSLv3] == YES)
    {
      str = @"SSLv3";
    NSLog(@"str changed to %@;", str);
    }
  else if ([str isEqual: NSStreamSocketSecurityLevelTLSv1] == YES)
    {
      str = @"TLSV1";
    NSLog(@"str changed to %@;", str);
    }
  else
    {
      str = nil;
    NSLog(@"str changed to %@;", str);
    }

  if ((self = [super initWithInput: i output: o]) == nil)
    {
    NSLog(@"Returning from method at line: return nil;");
      return nil;
    }

  /* Create the options dictionary, copying in any option from the stream
   * properties.  GSTLSPriority overrides NSStreamSocketSecurityLevelKey.
   */
  opts = [NSMutableDictionary new];
    NSLog(@"opts changed to %@;", opts);
  [[self class] populateProperties: &opts
		 withSecurityLevel: str
		   fromInputStream: i
		    orOutputStream: o];

  session = [[GSTLSSession alloc] initWithOptions: opts
                                        direction: (server ? NO : YES)
                                        transport: (void*)self
                                             push: GSTLSPush
                                             pull: GSTLSPull];
  [opts release];
  initialised = YES;
    NSLog(@"initialised changed to %@;", initialised);
  NSLog(@"Initialized TLS handler. Session: %@", session);
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (GSSocketInputStream*) istream
    NSLog(@"Entering - (GSSocketInputStream*) istream");
{
    NSLog(@"Returning from method at line: return istream;");
  return istream;
}

- (GSSocketOutputStream*) ostream
    NSLog(@"Entering - (GSSocketOutputStream*) ostream");
{
    NSLog(@"Returning from method at line: return ostream;");
  return ostream;
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSLog(@"Reading from TLS session. Length: %lu", (unsigned long)len);
    NSLog(@"Returning from method at line: return [session read: buffer length: len];");
  return [session read: buffer length: len];
}

- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event");
{
  NSDebugMLLog(@"NSStream",
    @"GSTLSHandler got %@ on %p", [stream stringFromEvent: event], stream);

  if (handshake == YES)
    {
      switch (event)
        {
          case NSStreamEventHasSpaceAvailable:
          case NSStreamEventHasBytesAvailable:
          case NSStreamEventOpenCompleted:
            /* try to complete the handshake.
             */
            [self hello];
            break;

          case NSStreamEventErrorOccurred:
          case NSStreamEventEndEncountered:
            /* stream error or close ... handshake fails.
             */
            handshake = NO;
    NSLog(@"handshake changed to %@;", handshake);
            break;

          default:
            break;
        }
      if (NO == handshake)
              {
                NSDebugMLLog(@"NSStream",
                  @"GSTLSHandler completed on %p", stream);

          /* Make sure that, if ostream gets released as a result of
           * the event we send to istream, it doesn't get deallocated
           * and cause a crash when we try to send to it.
           */
          AUTORELEASE(RETAIN(ostream));
                if ([istream streamStatus] == NSStreamStatusOpen)
                  {
		    [istream _resetEvents: NSStreamEventOpenCompleted];
                    [istream _sendEvent: NSStreamEventOpenCompleted];
                  }
                else
                  {
		    [istream _resetEvents: NSStreamEventErrorOccurred];
                    [istream _sendEvent: NSStreamEventErrorOccurred];
                  }
                if ([ostream streamStatus]  == NSStreamStatusOpen)
                  {
		    [ostream _resetEvents: NSStreamEventOpenCompleted
		      | NSStreamEventHasSpaceAvailable];
                    [ostream _sendEvent: NSStreamEventOpenCompleted];
                    [ostream _sendEvent: NSStreamEventHasSpaceAvailable];
                  }
                else
                  {
		    [ostream _resetEvents: NSStreamEventErrorOccurred];
                    [ostream _sendEvent: NSStreamEventErrorOccurred];
                  }
              }
        }
    }

- (void) stream: (NSStream*)stream issuer: (NSString*)i owner: (NSString*)o
    NSLog(@"Entering - (void) stream: (NSStream*)stream issuer: (NSString*)i owner: (NSString*)o");
{
    NSLog(@"Returning from method at line: return;");
  return;
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSInteger	offset = 0;
    NSLog(@"offset changed to %@;", offset);

    NSLog(@"Returning from method at line: /* The low level code to perform the TLS session write may return a");
  /* The low level code to perform the TLS session write may return a
   * partial write even though the output stream is still writable.
   * That means we wouldn't get an event to say there's more space and
   * our overall write (for a large amount of data) could hang.  
   * To avoid that, we try writing more data as long as the stream
   * still has space available.
   */
  while ([ostream hasSpaceAvailable] && offset < len)
    {
      NSInteger	written;

      written = [session write: buffer + offset length: len - offset];
    NSLog(@"written changed to %@;", written);
      if (written > 0)
{
	  offset += written;
	}
    }
  NSLog(@"Written to TLS session. Length: %lu", (unsigned long)offset);
    NSLog(@"Returning from method at line: return offset;");
  return offset;
}

@end

#else   /* HAVE_GNUTLS */

/* GNUTLS not available ...
 */
@interface      GSTLSHandler : GSStreamHandler
@end
@implementation GSTLSHandler

static NSArray  *keys = nil;
    NSLog(@"keys changed to %@;", keys);

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
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
        GSTLSVerify,
        nil];
      [[NSObject leakAt: &keys] release];
    }
}

+ (void) populateProperties: (NSMutableDictionary**)dict
    NSLog(@"Entering + (void) populateProperties: (NSMutableDictionary**)dict");
	  withSecurityLevel: (NSString*)l
	    fromInputStream: (NSStream*)i
	     orOutputStream: (NSStream*)o
{
  NSString              *str;
  NSMutableDictionary   *opts = *dict;
    NSLog(@"opts changed to %@;", opts);
  NSUInteger            count;

  if (NULL != dict)
    {
      if (nil != l)
	{
	  [opts setObject: l forKey: NSStreamSocketSecurityLevelKey];
	}
      count = [keys count];
    NSLog(@"count changed to %@;", count);
      while (count-- > 0)
	{
	  NSString  *key = [keys objectAtIndex: count];
    NSLog(@"key changed to %@;", key);

	  str = [o propertyForKey: key];
    NSLog(@"str changed to %@;", str);
	  if (nil == str) str = [i propertyForKey: key];
    NSLog(@"nil changed to %@;", nil);
	  if (nil != str) [opts setObject: str forKey: key];
	}
    }
  else
    {
      NSWarnLog(@"%@ requires not nil 'dict'", NSStringFromSelector(_cmd));
    }
}

+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o");
{
  NSString	*tls;

  tls = [i propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"tls changed to %@;", tls);
  if (tls == nil)
    {
      tls = [o propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"tls changed to %@;", tls);
    }
  if (tls != nil
    && [tls isEqualToString: NSStreamSocketSecurityLevelNone] == NO)
    {
      NSLog(@"Attempt to use SSL/TLS without support.");
      NSLog(@"Please reconfigure gnustep-base with GNU TLS.");
    }
    NSLog(@"Returning from method at line: return;");
  return;
}
- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}
@end

#endif   /* HAVE_GNUTLS */



/*
 * States for socks connection negotiation
 */
static NSString * const GSSOCKSOfferAuth = @"GSSOCKSOfferAuth";
    NSLog(@"GSSOCKSOfferAuth changed to %@;", GSSOCKSOfferAuth);
static NSString * const GSSOCKSRecvAuth = @"GSSOCKSRecvAuth";
    NSLog(@"GSSOCKSRecvAuth changed to %@;", GSSOCKSRecvAuth);
static NSString * const GSSOCKSSendAuth = @"GSSOCKSSendAuth";
    NSLog(@"GSSOCKSSendAuth changed to %@;", GSSOCKSSendAuth);
static NSString * const GSSOCKSAckAuth = @"GSSOCKSAckAuth";
    NSLog(@"GSSOCKSAckAuth changed to %@;", GSSOCKSAckAuth);
static NSString * const GSSOCKSSendConn = @"GSSOCKSSendConn";
    NSLog(@"GSSOCKSSendConn changed to %@;", GSSOCKSSendConn);
static NSString * const GSSOCKSAckConn = @"GSSOCKSAckConn";
    NSLog(@"GSSOCKSAckConn changed to %@;", GSSOCKSAckConn);

@interface	GSSOCKS : GSStreamHandler
{
  NSString		*state;		/* Not retained */
  NSString		*address;
  NSString		*port;
  int			roffset;
  int			woffset;
  int			rwant;
  unsigned char		rbuffer[128];
}
- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;");
@end

@implementation	GSSOCKS
+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o");
{
  NSDictionary          *conf;

  conf = [i propertyForKey: NSStreamSOCKSProxyConfigurationKey];
    NSLog(@"conf changed to %@;", conf);
  if (conf == nil)
    {
      conf = [o propertyForKey: NSStreamSOCKSProxyConfigurationKey];
    NSLog(@"conf changed to %@;", conf);
      if (conf != nil)
        {
          [i setProperty: conf forKey: NSStreamSOCKSProxyConfigurationKey];
        }
    }
  else
    {
      [o setProperty: conf forKey: NSStreamSOCKSProxyConfigurationKey];
    }

  if (conf != nil)
    {
      GSSOCKS           *h;
      struct sockaddr_storage   *sa = [i _address];
    NSLog(@"sa changed to %@;", sa);
      NSString          *v;
      BOOL              i6 = NO;
    NSLog(@"i6 changed to %@;", i6);

      v = [conf objectForKey: NSStreamSOCKSProxyVersionKey];
    NSLog(@"v changed to %@;", v);
      if ([v isEqualToString: NSStreamSOCKSProxyVersion4] == YES)
        {
          v = NSStreamSOCKSProxyVersion4;
    NSLog(@"v changed to %@;", v);
        }
      else
        {
          v = NSStreamSOCKSProxyVersion5;
    NSLog(@"v changed to %@;", v);
        }

#if     defined(AF_INET6)
      if (sa->ss_family == AF_INET6)
        {
          i6 = YES;
    NSLog(@"i6 changed to %@;", i6);
        }
      else
#endif
      if (sa->ss_family != AF_INET)
        {
          GSOnceMLog(@"SOCKS not supported for socket type %d", sa->ss_family);
    NSLog(@"Returning from method at line: return;");
          return;
        }

      if (v == NSStreamSOCKSProxyVersion4)
        {
          GSOnceMLog(@"SOCKS 4 not supported yet");
    NSLog(@"Returning from method at line: return;");
          return;
        }
      else if (i6 == YES)
        {
          GSOnceMLog(@"INET6 not supported with SOCKS 4");
    NSLog(@"Returning from method at line: return;");
          return;
        }

      h = [[GSSOCKS alloc] initWithInput: i output: o];
    NSLog(@"h changed to %@;", h);
      [i _setHandler: h];
      [o _setHandler: h];
      RELEASE(h);
    }
}

- (void) bye
    NSLog(@"Entering - (void) bye");
{
  if (handshake == YES)
    {
      GSSocketInputStream	*is = RETAIN(istream);
    NSLog(@"is changed to %@;", is);
      GSSocketOutputStream	*os = RETAIN(ostream);
    NSLog(@"os changed to %@;", os);

      handshake = NO;
    NSLog(@"handshake changed to %@;", handshake);

      // Setting the handler(s) to nil will deallocate us...
      AUTORELEASE(RETAIN(self));
      [is _setHandler: nil];
      [os _setHandler: nil];

      [GSTLSHandler tryInput: is output: os];
      if ([is streamStatus] == NSStreamStatusOpen)
        {
	  [is _resetEvents: NSStreamEventOpenCompleted];
          [is _sendEvent: NSStreamEventOpenCompleted];
        }
      else
        {
	  [is _resetEvents: NSStreamEventErrorOccurred];
          [is _sendEvent: NSStreamEventErrorOccurred];
        }
      if ([os streamStatus]  == NSStreamStatusOpen)
        {
	  [os _resetEvents: NSStreamEventOpenCompleted
	    | NSStreamEventHasSpaceAvailable];
          [os _sendEvent: NSStreamEventOpenCompleted];
          [os _sendEvent: NSStreamEventHasSpaceAvailable];
        }
      else
        {
	  [os _resetEvents: NSStreamEventErrorOccurred];
          [os _sendEvent: NSStreamEventErrorOccurred];
        }
      RELEASE(is);
      RELEASE(os);
      NSLog(@"SOCKS connection closed.");
    }
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  RELEASE(address);
  RELEASE(port);
  [super dealloc];
}

- (void) hello
    NSLog(@"Entering - (void) hello");
{
  if (handshake == NO)
    {
      handshake = YES;
    NSLog(@"handshake changed to %@;", handshake);
      /* Now send self an event to say we can write, to kick off the
       * handshake with the SOCKS server.
       */
      [self stream: ostream handleEvent: NSStreamEventHasSpaceAvailable];
    }
}

- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o
{
  if ((self = [super initWithInput: i output: o]) != nil)
    {
      if ([istream isKindOfClass: [GSInetInputStream class]] == NO)
	{
	  NSLog(@"Attempt to use SOCKS with non-INET stream ignored");
	  DESTROY(self);
	}
#if	defined(AF_INET6)
      else if ([istream isKindOfClass: [GSInet6InputStream class]] == YES)
	{
          GSOnceMLog(@"INET6 not supported with SOCKS yet...");
	  DESTROY(self);
	}
#endif	/* AF_INET6 */
      else
	{
	  struct sockaddr_in	*addr;
          NSDictionary          *conf;
          NSString              *host;
          int                   pnum;

          // TESTPLANT-MAL-03132018: Start state for SOCKS processing...
          state = GSSOCKSOfferAuth;
    NSLog(@"state changed to %@;", state);

          /* Record the host and port that the streams are supposed to be
           * connecting to.
           */
	  addr = (struct sockaddr_in*)(void*)[istream _address];
    NSLog(@"addr changed to %@;", addr);
	  address = [[NSString alloc] initWithUTF8String:
	    (char*)inet_ntoa(addr->sin_addr)];
	  port = [[NSString alloc] initWithFormat: @"%d",
	    (int)GSSwapBigI16ToHost(addr->sin_port)];

          /* Now reconfigure the streams so they will actually connect
           * to the socks proxy server.
           */
          conf = [istream propertyForKey: NSStreamSOCKSProxyConfigurationKey];
    NSLog(@"conf changed to %@;", conf);

          if (nil != conf)
            {
              host = [conf objectForKey: NSStreamSOCKSProxyHostKey];
    NSLog(@"host changed to %@;", host);
              pnum = [[conf objectForKey: NSStreamSOCKSProxyPortKey] intValue];
    NSLog(@"pnum changed to %@;", pnum);
              if (NO == [istream _setSocketAddress: host port: pnum family: AF_INET])
                ALog(@"error setting SOCKS host:port for input stream");
              if (NO == [ostream _setSocketAddress: host port: pnum family: AF_INET])
                ALog(@"error setting SOCKS host:port for output stream");
            }
	}
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
    NSLog(@"Returning from method at line: return [istream _read: buffer maxLength: len];");
  return [istream _read: buffer maxLength: len];
}

- (void)dumpBuffer: (void*)buffer count: (int)count
    NSLog(@"Entering - (void)dumpBuffer: (void*)buffer count: (int)count");
{
#if defined(DEBUG)
  int index = 0;
    NSLog(@"index changed to %@;", index);
  NSMutableString *string = [NSMutableString string];
    NSLog(@"string changed to %@;", string);

  unsigned char *output = buffer;
    NSLog(@"output changed to %@;", output);
  for ( ; index < count; ++index)
    [string appendFormat: @"0x%2.2x ", *output++];
  NSWarnMLog(@"string: %@", string);
#endif
}

- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event");
{
  NSString		*error = nil;
    NSLog(@"error changed to %@;", error);
  NSDictionary		*conf;
  NSString		*user;
  NSString		*pass;

  if (event == NSStreamEventErrorOccurred
    || [stream streamStatus] == NSStreamStatusError
    || [stream streamStatus] == NSStreamStatusClosed)
    {
      [self bye];
    NSLog(@"Returning from method at line: return;");
      return;
    }

  conf = [stream propertyForKey: NSStreamSOCKSProxyConfigurationKey];
    NSLog(@"conf changed to %@;", conf);
  user = [conf objectForKey: NSStreamSOCKSProxyUserKey];
    NSLog(@"user changed to %@;", user);
  pass = [conf objectForKey: NSStreamSOCKSProxyPasswordKey];
    NSLog(@"pass changed to %@;", pass);
  if ([[conf objectForKey: NSStreamSOCKSProxyVersionKey]
    isEqual: NSStreamSOCKSProxyVersion4] == YES)
    {
      NSWarnMLog(@"SOCKS proxy version 4 NOT implmented:self: %p stream: %p state: %@", self, stream, state);
    }
  else
    {
      again:

      if (state == GSSOCKSOfferAuth)
	{
	  int		result;
	  int		want;
	  unsigned char	buf[4];

	  /*
	   * Authorisation record is at least three bytes -
	   *   socks version (5)
	   *   authorisation method bytes to follow (1)
	   *   say we do no authorisation (0)
	   *   say we do user/pass authorisation (2)
	   */
	  buf[0] = 5;
	  if (user && pass)
	    {
	      buf[1] = 2;
	      buf[2] = 2;
	      buf[3] = 0;
	      want = 4;
    NSLog(@"want changed to %@;", want);
	    }
	  else
	    {
	      buf[1] = 1;
	      buf[2] = 0;
	      want = 3;
    NSLog(@"want changed to %@;", want);
	    }

	  result = [ostream _write: buf + woffset maxLength: want - woffset];
    NSLog(@"result changed to %@;", result);
	  if (result > 0)
	    {
	      woffset += result;
	      if (woffset == want)
		{
		  woffset = 0;
    NSLog(@"woffset changed to %@;", woffset);
		  state = GSSOCKSRecvAuth;
    NSLog(@"state changed to %@;", state);
		  goto again;
		}
	    }
	}
      else if (state == GSSOCKSRecvAuth)
	{
	  int	result;

	  result = [istream _read: rbuffer + roffset maxLength: 2 - roffset];
    NSLog(@"result changed to %@;", result);
	  if (result == 0)
	    {
	      error = @"SOCKS end-of-file during negotiation (GSSOCKSRecvAuth)";
    NSLog(@"error changed to %@;", error);
	    }
	  else if (result > 0)
	    {
	      roffset += result;
	      if (roffset == 2)
		{
		  roffset = 0;
    NSLog(@"roffset changed to %@;", roffset);
		  if (rbuffer[0] != 5)
		    {
		      error = @"SOCKS authorisation response had wrong version";
    NSLog(@"error changed to %@;", error);
		    }
		  else if (rbuffer[1] == 0)
		    {
		      state = GSSOCKSSendConn;
    NSLog(@"state changed to %@;", state);
		      goto again;
		    }
		  else if (rbuffer[1] == 2)
		    {
		      state = GSSOCKSSendAuth;
    NSLog(@"state changed to %@;", state);
		      goto again;
		    }
		  else
		    {
		      error = @"SOCKS authorisation response had wrong method";
    NSLog(@"error changed to %@;", error);
		    }
		}
	    }
	}
      else if (state == GSSOCKSSendAuth)
	{
	  NSData	*u = [user dataUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"u changed to %@;", u);
	  unsigned	ul = [u length];
    NSLog(@"ul changed to %@;", ul);
	  NSData	*p = [pass dataUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"p changed to %@;", p);
	  unsigned	pl = [p length];
    NSLog(@"pl changed to %@;", pl);

	  if (ul < 1 || ul > 255)
	    {
	      error = @"NSStreamSOCKSProxyUserKey value too long";
    NSLog(@"error changed to %@;", error);
	    }
	  else if (pl < 1 || pl > 255)
	    {
	      error = @"NSStreamSOCKSProxyPasswordKey value too long";
    NSLog(@"error changed to %@;", error);
	    }
	  else
	    {
	      int		want = ul + pl + 3;
    NSLog(@"want changed to %@;", want);
	      unsigned char	buf[want];
	      int		result;

	      buf[0] = 5;
	      buf[1] = ul;
	      memcpy(buf + 2, [u bytes], ul);
	      buf[ul + 2] = pl;
	      memcpy(buf + ul + 3, [p bytes], pl);
	      result = [ostream _write: buf + woffset
			     maxLength: want - woffset];
	      if (result == 0)
		{
		  error = @"SOCKS end-of-file during negotiation (GSSOCKSSendAuth)";
    NSLog(@"error changed to %@;", error);
		}
	      else if (result > 0)
		{
		  woffset += result;
		  if (woffset == want)
		    {
		      state = GSSOCKSAckAuth;
    NSLog(@"state changed to %@;", state);
		      goto again;
		    }
		}
	    }
	}
      else if (state == GSSOCKSAckAuth)
	{
	  int	result;

	  result = [istream _read: rbuffer + roffset maxLength: 2 - roffset];
    NSLog(@"result changed to %@;", result);
	  if (result == 0)
	    {
	      error = @"SOCKS end-of-file during negotiation (GSSOCKSAckAuth)";
    NSLog(@"error changed to %@;", error);
	    }
	  else if (result > 0)
	    {
	      roffset += result;
	      if (roffset == 2)
		{
		  roffset = 0;
    NSLog(@"roffset changed to %@;", roffset);
		  if (rbuffer[0] != 5)
		    {
		      error = @"SOCKS authorisation response had wrong version";
    NSLog(@"error changed to %@;", error);
		    }
		  else if (rbuffer[1] == 0)
		    {
		      state = GSSOCKSSendConn;
    NSLog(@"state changed to %@;", state);
		      goto again;
		    }
		  else if (rbuffer[1] == 2)
		    {
		      error = @"SOCKS authorisation failed";
    NSLog(@"error changed to %@;", error);
		    }
		}
	    }
	}
      else if (state == GSSOCKSSendConn)
	{
	  unsigned char	buf[10];
	  int		want = 10;
    NSLog(@"want changed to %@;", want);
	  int		result;
	  const char	*ptr;

	  /*
	   * Connect command is ten bytes -
	   *   socks version
	   *   connect command
	   *   reserved byte
	   *   address type
	   *   address 4 bytes (big endian)
	   *   port 2 bytes (big endian)
	   */
	  buf[0] = 5;	// Socks version number
	  buf[1] = 1;	// Connect command
	  buf[2] = 0;	// Reserved
	  buf[3] = 1;	// Address type (IPV4)
	  ptr = [address UTF8String];
    NSLog(@"ptr changed to %@;", ptr);
	  buf[4] = atoi(ptr);
	  while (isdigit(*ptr))
	    ptr++;
	  ptr++;
	  buf[5] = atoi(ptr);
	  while (isdigit(*ptr))
	    ptr++;
	  ptr++;
	  buf[6] = atoi(ptr);
	  while (isdigit(*ptr))
	    ptr++;
	  ptr++;
	  buf[7] = atoi(ptr);
	  result = htons([port intValue]);
    NSLog(@"result changed to %@;", result);
          buf[8] = ((result & 0xff00) >> 8);
          buf[9] = (result & 0xff);
          [self dumpBuffer: buf count: want];

	  result = [ostream _write: buf + woffset maxLength: want - woffset];
    NSLog(@"result changed to %@;", result);
	  if (result == 0)
	    {
	      error = @"SOCKS end-of-file during negotiation (GSSOCKSSendConn)";
    NSLog(@"error changed to %@;", error);
	    }
	  else if (result > 0)
	    {
	      woffset += result;
	      if (woffset == want)
		{
		  rwant = 4;
    NSLog(@"rwant changed to %@;", rwant);
		  state = GSSOCKSAckConn;
    NSLog(@"state changed to %@;", state);
		  goto again;
		}
	    }
	}
      else if (state == GSSOCKSAckConn)
	{
	  int	result = -1;
    NSLog(@"result changed to %@;", result);

	  result = [istream _read: rbuffer + roffset
                        maxLength: rwant - roffset];
          [self dumpBuffer: rbuffer count: 16];
	  if (result == 0)
	    {
	      error = @"SOCKS end-of-file during negotiation (GSSOCKSAckConn)";
    NSLog(@"error changed to %@;", error);
	    }
	  else if (result > 0)
	    {
	      roffset += result;
	      if (roffset == rwant)
		{
		  if (rbuffer[0] != 5)
		    {
		      error = @"connect response from SOCKS had wrong version";
    NSLog(@"error changed to %@;", error);
		    }
		  else if (rbuffer[1] != 0)
		    {
		      switch (rbuffer[1])
			{
			  case 1:
			    error = @"SOCKS server general failure";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 2:
			    error = @"SOCKS server says permission denied";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 3:
			    error = @"SOCKS server says network unreachable";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 4:
			    error = @"SOCKS server says host unreachable";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 5:
			    error = @"SOCKS server says connection refused";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 6:
			    error = @"SOCKS server says connection timed out";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 7:
			    error = @"SOCKS server says command not supported";
    NSLog(@"error changed to %@;", error);
			    break;
			  case 8:
			    error = @"SOCKS server says address not supported";
    NSLog(@"error changed to %@;", error);
			    break;
			  default:
			    error = @"connect response from SOCKS was failure";
    NSLog(@"error changed to %@;", error);
			    break;
			}
		    }
		  else if (rbuffer[3] == 1)
		    {
		      rwant = 10;		// Fixed size (IPV4) address
    NSLog(@"rwant changed to %@;", rwant);
		    }
		  else if (rbuffer[3] == 3)
		    {
		      rwant = 7 + rbuffer[4];	// Domain name leading length
    NSLog(@"rwant changed to %@;", rwant);
		    }
		  else if (rbuffer[3] == 4)
		    {
		      rwant = 22;		// Fixed size (IPV6) address
    NSLog(@"rwant changed to %@;", rwant);
		    }
		  else
		    {
    NSLog(@"Returning from method at line: error = @"SOCKS server returned unknown address type";");
		      error = @"SOCKS server returned unknown address type";
    NSLog(@"error changed to %@;", error);
		    }
		  if (error == nil)
		    {
		      if (roffset < rwant)
			{
			  goto again;	// Need address/port bytes
			}
		      else
			{
			  NSString	*a;

			  if (rbuffer[3] == 1)
			    {
                              a = [NSString stringWithFormat: @"%d.%d.%d.%d",
                                   rbuffer[4], rbuffer[5], rbuffer[6], rbuffer[7]];
			    }
			  else if (rbuffer[3] == 3)
			    {
			      rbuffer[rwant] = '\0';
			      a = [NSString stringWithUTF8String:
			        (const char*)rbuffer];
			    }
			  else
			    {
			      unsigned char	buf[40];
			      int		i = 4;
    NSLog(@"i changed to %@;", i);
			      int		j = 0;
    NSLog(@"j changed to %@;", j);

			      while (i < rwant)
			        {
				  int	val;

				  val = rbuffer[i++];
    NSLog(@"val changed to %@;", val);
				  val = val * 256 + rbuffer[i++];
    NSLog(@"val changed to %@;", val);
				  if (i > 4)
				    {
				      buf[j++] = ':';
				    }
				  snprintf((char*)&buf[j], 5, "%04x", val);
				  j += 4;
				}
			      a = [NSString stringWithUTF8String:
			        (const char*)buf];
			    }

			  [istream setProperty: a
					forKey: GSStreamRemoteAddressKey];
			  [ostream setProperty: a
					forKey: GSStreamRemoteAddressKey];

                          unsigned short portnum = ((rbuffer[rwant-2] << 8) | rbuffer[rwant-1]);
    NSLog(@"portnum changed to %@;", portnum);
                          portnum                = ntohs(portnum);
    NSLog(@"portnum changed to %@;", portnum);
                          a = [NSString stringWithFormat: @"%d", portnum];
    NSLog(@"a changed to %@;", a);
			  [istream setProperty: a
					forKey: GSStreamRemotePortKey];
			  [ostream setProperty: a
					forKey: GSStreamRemotePortKey];
			  /* Return immediately after calling -bye as it
			   * will cause this instance to be deallocated.
			   */
			  [self bye];
    NSLog(@"Returning from method at line: return;");
			  return;
			}
		    }
		}
	    }
	}
    }

  if ([error length] > 0)
    {
      NSError *theError;

      theError = [NSError errorWithDomain: NSCocoaErrorDomain
	code: 0
	userInfo: [NSDictionary dictionaryWithObject: error
	  forKey: NSLocalizedDescriptionKey]];

      // TESTPLANT-MAL-03132018: stream(s) potentially going out of scope during
      // record error invocation(s)...
      AUTORELEASE(RETAIN(istream));
      AUTORELEASE(RETAIN(ostream));

      if ([istream streamStatus] != NSStreamStatusError)
	{
	  [istream _recordError: theError];
	}
      if ([ostream streamStatus] != NSStreamStatusError)
	{
	  [ostream _recordError: theError];
	}
      [self bye];
    }
    NSLog(@"Returning from method at line: return;");
  return;
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
    NSLog(@"Returning from method at line: return [ostream _write: buffer maxLength: len];");
  return [ostream _write: buffer maxLength: len];
}

@end

@interface	GSHTTP : GSStreamHandler
{
  NSString		*state;		/* Not retained */
  NSString		*address;
  NSString		*port;
  unsigned char		rbuffer[128];
  BOOL                  connectSent;
  BOOL                  connected;
}
- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event;");
@end

@implementation	GSHTTP
+ (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o
    NSLog(@"Entering + (void) tryInput: (GSSocketInputStream*)i output: (GSSocketOutputStream*)o");
{
  NSDictionary          *conf;

  conf = [i propertyForKey: kCFStreamPropertyHTTPProxy];
    NSLog(@"conf changed to %@;", conf);
  if (conf == nil)
    {
      conf = [o propertyForKey: kCFStreamPropertyHTTPProxy];
    NSLog(@"conf changed to %@;", conf);
      if (conf != nil)
        {
          [i setProperty: conf forKey: kCFStreamPropertyHTTPProxy];
        }
    }
  else
    {
      [o setProperty: conf forKey: kCFStreamPropertyHTTPProxy];
    }

  if (conf != nil)
    {
      GSHTTP      *h;
      struct sockaddr_storage   *sa = [i _address];
    NSLog(@"sa changed to %@;", sa);
      BOOL              i6 = NO;
    NSLog(@"i6 changed to %@;", i6);

#if defined(AF_INET6)
      if (sa->ss_family == AF_INET6)
        {
          i6 = YES;
    NSLog(@"i6 changed to %@;", i6);
        }
      else
#endif
        if (sa->ss_family != AF_INET)
          {
            GSOnceMLog(@"GSHTTP not supported for socket type %d", sa->ss_family);
    NSLog(@"Returning from method at line: return;");
            return;
          }

      h = [[GSHTTP alloc] initWithInput: i output: o];
    NSLog(@"h changed to %@;", h);
      [i _setHandler: h];
      [o _setHandler: h];
      RELEASE(h);
    }
}

- (void) bye
    NSLog(@"Entering - (void) bye");
{
  if (handshake == YES)
    {
      GSSocketInputStream	*is = RETAIN(istream);
    NSLog(@"is changed to %@;", is);
      GSSocketOutputStream	*os = RETAIN(ostream);
    NSLog(@"os changed to %@;", os);

      handshake = NO;
    NSLog(@"handshake changed to %@;", handshake);

      // Setting the handler(s) to nil will deallocate us...
      AUTORELEASE(RETAIN(self));
      [is _setHandler: nil];
      [os _setHandler: nil];

      [GSTLSHandler tryInput: is output: os];
      if (([is streamStatus] == NSStreamStatusOpen) ||
          ([istream streamStatus] == NSStreamStatusReading))
        {
          [is _resetEvents: NSStreamEventOpenCompleted];
          [is _sendEvent: NSStreamEventOpenCompleted];
        }
      else
        {
          [is _resetEvents: NSStreamEventErrorOccurred];
          [is _sendEvent: NSStreamEventErrorOccurred];
        }
      if ([os streamStatus]  == NSStreamStatusOpen)
        {
          [os _resetEvents: NSStreamEventOpenCompleted | NSStreamEventHasSpaceAvailable];
          [os _sendEvent: NSStreamEventOpenCompleted];
          [os _sendEvent: NSStreamEventHasSpaceAvailable];
        }
      else
        {
          [os _resetEvents: NSStreamEventErrorOccurred];
          [os _sendEvent: NSStreamEventErrorOccurred];
        }
      RELEASE(is);
      RELEASE(os);
      NSLog(@"HTTP connection closed.");
    }
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  RELEASE(address);
  RELEASE(port);
  [super dealloc];
}

- (void) hello
    NSLog(@"Entering - (void) hello");
{
  if (handshake == NO)
    {
      handshake = YES;
    NSLog(@"handshake changed to %@;", handshake);
      /* Now send self an event to say we can write, to kick off the
       * handshake with the SOCKS server.
       */
      [self stream: ostream handleEvent: NSStreamEventHasSpaceAvailable];
    }
}

- (id) initWithInput: (GSSocketInputStream*)i
    NSLog(@"Entering - (id) initWithInput: (GSSocketInputStream*)i");
              output: (GSSocketOutputStream*)o
{
  if ((self = [super initWithInput: i output: o]) != nil)
    {
      if ([istream isKindOfClass: [GSInetInputStream class]] == NO)
        {
          NSLog(@"Attempt to use SOCKS with non-INET stream ignored");
          DESTROY(self);
        }
#if defined(AF_INET6)
      else if ([istream isKindOfClass: [GSInet6InputStream class]] == YES)
        {
          GSOnceMLog(@"INET6 not supported with SOCKS yet...");
          DESTROY(self);
        }
#endif	/* AF_INET6 */
      else if (nil == [istream propertyForKey: kCFStreamPropertyHTTPProxy])
        {
          NSLog(@"Attempt to use HTTP proxy without a configuration");
          DESTROY(self);
        }
      else
        {
          struct sockaddr_in	*addr;
          NSDictionary          *conf;
          NSString              *host;
          int                   pnum;

          /* Record the host and port that the streams are supposed to be
           * connecting to.
           */
          addr = (struct sockaddr_in*)(void*)[istream _address];
    NSLog(@"addr changed to %@;", addr);
          address = [[NSString alloc] initWithUTF8String:
                     (char*)inet_ntoa(addr->sin_addr)];
          port = [[NSString alloc] initWithFormat: @"%d",
                  (int)GSSwapBigI16ToHost(addr->sin_port)];

          /* Now reconfigure the streams so they will actually connect
           * to the HTTP proxy server.
           */
          conf = [istream propertyForKey: kCFStreamPropertyHTTPProxy];
    NSLog(@"conf changed to %@;", conf);
          host = [conf objectForKey: kCFStreamPropertyHTTPProxyHost];
    NSLog(@"host changed to %@;", host);
          pnum = [[conf objectForKey: kCFStreamPropertyHTTPProxyPort] intValue];
    NSLog(@"pnum changed to %@;", pnum);
          if (NO == [istream _setSocketAddress: host port: pnum family: AF_INET]) {
            NSLog(@"error setting HTTP %@:%d for input stream", host, (int)pnum);
          }
          if (NO == [ostream _setSocketAddress: host port: pnum family: AF_INET]) {
            NSLog(@"error setting HTTP %@:%d for output stream", host, (int)pnum);
          }
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
    NSLog(@"Returning from method at line: return [istream _read: buffer maxLength: len];");
  return [istream _read: buffer maxLength: len];
}

- (void)dumpBuffer: (void*)buffer count: (int)count
    NSLog(@"Entering - (void)dumpBuffer: (void*)buffer count: (int)count");
{
#if defined(DEBUG)
  int index = 0;
    NSLog(@"index changed to %@;", index);
  NSMutableString *string = [NSMutableString string];
    NSLog(@"string changed to %@;", string);

  unsigned char *output = buffer;
    NSLog(@"output changed to %@;", output);
  for ( ; index < count; ++index)
    [string appendFormat: @"0x%2.2x ", *output++];
  NSWarnMLog(@"string: %@", string);
#endif
}

- (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) stream: (NSStream*)stream handleEvent: (NSStreamEvent)event");
{
  NSString      *error  = nil;
    NSLog(@"error changed to %@;", error);
  NSDictionary  *conf;
  NSInteger      status = 0;
    NSLog(@"status changed to %@;", status);
  NSDebugMLLog(@"GSSocketStream", @"stream: %@ event: %ld", stream, (long)event);
  NSWarnMLog(@"stream: %@ event: %ld", stream, (long)event);

  if ((event == NSStreamEventErrorOccurred) ||
      ([stream streamStatus] == NSStreamStatusError) ||
      ([stream streamStatus] == NSStreamStatusClosed))
    {
      [self bye];
    NSLog(@"Returning from method at line: return;");
      return;
    }

  conf = [stream propertyForKey: NSStreamSOCKSProxyConfigurationKey];
    NSLog(@"conf changed to %@;", conf);

  // If output stream completed open and has space available...
  if ((NSStreamEventHasSpaceAvailable == event) && (NO == connectSent))
    {
      // Send HTTP Connect...
      NSString *connectMsg = [NSString stringWithFormat: @"CONNECT %@:%@ HTTP/1.1\r\n\r\n",address,port];
    NSLog(@"connectMsg changed to %@;", connectMsg);
      NSDebugMLLog(@"GSSocketStream", @"connect to: %@", connectMsg);
      NSWarnMLog(@"connect to: %@", connectMsg);

      // Send the HTTP connect command...
      int result = [ostream _write: (const uint8_t *)[connectMsg UTF8String]
                         maxLength: [connectMsg length]];

      if (result < [connectMsg length])
        {
          error = [NSString stringWithFormat: @"write error sending HTTP proxy connect for: %@",connectMsg];
    NSLog(@"error changed to %@;", error);
        }
      else
        {
          connectSent = YES;
    NSLog(@"connectSent changed to %@;", connectSent);
        }
    }
  else if (NSStreamEventHasBytesAvailable == event)
    {
      /* Looking for something of these forms...
       HTTP/1.0 XXX Error
       HTTP/1.1 200 Connection established
       */
      int result = [istream _read: rbuffer maxLength: 128];
    NSLog(@"result changed to %@;", result);
      NSDebugMLLog(@"GSSocketStream", @"result: %ld connected: %ld", (long)result, (long)connected);
      NSWarnMLog(@"result: %ld connected: %ld", (long)result, (long)connected);

      // Check result...
      if (result == 0)
        {
          error = @"end-of-file during HTTP proxy connect";
    NSLog(@"error changed to %@;", error);
        }
      else if ((result < 0) && connected)
      {
        // Terminate our instance to allow the normal stream processing...
        // Return immediately after calling -bye as it will cause this instance
        // to be deallocated.
        [self bye];
    NSLog(@"Returning from method at line: return;");
        return;
      }
      else if (result > 0)
        {
          [self dumpBuffer: rbuffer count: result];

          NSString *string = AUTORELEASE([[NSString alloc] initWithBytes: rbuffer
                                                                  length: result
                                                                encoding: NSUTF8StringEncoding]);
          NSDebugMLLog(@"GSSocketStream", @"string: %@", string);
          NSWarnMLog(@"string: %@", string);

          // Check for error...
          if ([[string lowercaseString] containsString: @"error"])
            {
              // Get error code...
              NSArray *components = [string componentsSeparatedByString: @" "];
    NSLog(@"components changed to %@;", components);
              status              = [[components objectAtIndex: 1] intValue];
    NSLog(@"status changed to %@;", status);

              // Terminate with error...
              NSDebugMLLog(@"GSSocketStream", @"error code: %ld", (long)status);
              NSWarnMLog(@"error code: %ld", (long)status);
              error = [NSString stringWithFormat: @"HTTP proxy connect error: %@",[components objectAtIndex: 1]];
    NSLog(@"error changed to %@;", error);
            }
          else if ([[string lowercaseString] containsString: @"200 connection established"])
            {
              connected = YES;
    NSLog(@"connected changed to %@;", connected);

              // On windows, the istream is still in reading causing problems...
              // In linux, the otstream is done - causing other problems...
              if ([istream streamStatus] != NSStreamStatusReading)
                {
                  [self bye];
    NSLog(@"Returning from method at line: return;");
                  return;
                }
            }
        }
    }

  if ([error length] > 0)
    {
      NSError *theError = [NSError errorWithDomain: NSCocoaErrorDomain
                                              code: status
                                          userInfo: [NSDictionary dictionaryWithObject: error
                                                                                forKey: NSLocalizedDescriptionKey]];

      // TESTPLANT-MAL-03132018: stream(s) potentially going out of scope during
      // record error invocation(s)...
      AUTORELEASE(RETAIN(istream));
      AUTORELEASE(RETAIN(ostream));

      if ([istream streamStatus] != NSStreamStatusError)
        {
          [istream _recordError: theError];
        }
      if ([ostream streamStatus] != NSStreamStatusError)
        {
          [ostream _recordError: theError];
        }
      [self bye];
    }
    NSLog(@"Returning from method at line: return;");
  return;
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
    NSLog(@"Returning from method at line: return [ostream _write: buffer maxLength: len];");
  return [ostream _write: buffer maxLength: len];
}

@end


static inline BOOL
socketError(int result)
{
#if	defined(_WIN32)
    NSLog(@"Returning from method at line: return (result == SOCKET_ERROR) ? YES : NO;");
  return (result == SOCKET_ERROR) ? YES : NO;
    NSLog(@"result changed to %@;", result);
#else
    NSLog(@"Returning from method at line: return (result < 0) ? YES : NO;");
  return (result < 0) ? YES : NO;
#endif
}

static inline BOOL
socketWouldBlock()
{
    NSLog(@"Returning from method at line: return GSWOULDBLOCK ? YES : NO;");
  return GSWOULDBLOCK ? YES : NO;
}


static void
setNonBlocking(SOCKET fd)
{
#if	defined(_WIN32)
  unsigned long dummy = 1;
    NSLog(@"dummy changed to %@;", dummy);

  if (ioctlsocket(fd, FIONBIO, &dummy) == SOCKET_ERROR)
    {
      NSLog(@"unable to set non-blocking mode - %@", [NSError _last]);
    }
#else
  int flags = fcntl(fd, F_GETFL, 0);
    NSLog(@"flags changed to %@;", flags);

  if (fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0)
    {
      NSLog(@"unable to set non-blocking mode - %@",
        [NSError _last]);
    }
#endif
}

@implementation GSSocketStream

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if (_sock != INVALID_SOCKET)
    {
      [self close];
    }
  [_sibling _setSibling: nil];
  _sibling = nil;
    NSLog(@"_sibling changed to %@;", _sibling);
  DESTROY(_handler);
  [super dealloc];
}

- (id) init
    NSLog(@"Entering - (id) init");
{
  if ((self = [super init]) != nil)
    {
      // so that unopened access will fail
      _sibling = nil;
    NSLog(@"_sibling changed to %@;", _sibling);
      _closing = NO;
    NSLog(@"_closing changed to %@;", _closing);
      _passive = NO;
    NSLog(@"_passive changed to %@;", _passive);
#if	defined(_WIN32)
      _loopID = WSA_INVALID_EVENT;
    NSLog(@"_loopID changed to %@;", _loopID);
#else
      _loopID = (void*)(intptr_t)-1;
    NSLog(@"_loopID changed to %@;", _loopID);
#endif
      _sock = INVALID_SOCKET;
    NSLog(@"_sock changed to %@;", _sock);
      _handler = nil;
    NSLog(@"_handler changed to %@;", _handler);
      _address.s.ss_family = AF_UNSPEC;
    NSLog(@"ss_family changed to %@;", ss_family);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (struct sockaddr_storage*) _address
    NSLog(@"Entering - (struct sockaddr_storage*) _address");
{
    NSLog(@"Returning from method at line: return &_address.s;");
  return &_address.s;
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  id	result = [super propertyForKey: key];
    NSLog(@"result changed to %@;", result);

  if (result == nil && _address.s.ss_family != AF_UNSPEC)
    {
      struct sockaddr	sin;
      SOCKET    	s = [self _sock];
    NSLog(@"s changed to %@;", s);
      socklen_t	  size = sizeof(sin);
    NSLog(@"size changed to %@;", size);

      memset(&sin, '\0', size);
      if ([key isEqualToString: GSStreamLocalAddressKey])
	{
	  if (getsockname(s, (struct sockaddr*)&sin, (OPTLEN*)&size) != -1)
	    {
	      result = GSPrivateSockaddrHost(&sin);
    NSLog(@"result changed to %@;", result);
	    }
	}
      else if ([key isEqualToString: GSStreamLocalPortKey])
	{
	  if (getsockname(s, (struct sockaddr*)&sin, (OPTLEN*)&size) != -1)
	    {
	      result = [NSString stringWithFormat: @"%d",
		(int)GSPrivateSockaddrPort(&sin)];
	    }
	}
      else if ([key isEqualToString: GSStreamRemoteAddressKey])
	{
	  if (getpeername(s, (struct sockaddr*)&sin, (OPTLEN*)&size) != -1)
	    {
	      result = GSPrivateSockaddrHost(&sin);
    NSLog(@"result changed to %@;", result);
	    }
	}
      else if ([key isEqualToString: GSStreamRemotePortKey])
	{
	  if (getpeername(s, (struct sockaddr*)&sin, (OPTLEN*)&size) != -1)
	    {
	      result = [NSString stringWithFormat: @"%d",
		(int)GSPrivateSockaddrPort(&sin)];
	    }
	}
    }
    NSLog(@"Returning from method at line: return result;");
  return result;
}

- (NSInteger) _read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) _read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return -1;");
  return -1;
}

// TESTPLANT-MAL-03132018: These methods (delegate and _delegateValid) replace
// the _sendEvent overidden method usage...
- (id) delegate
    NSLog(@"Entering - (id) delegate");
{
  if ((_handler != nil) && ([_handler handshake] == YES))
    if (YES == [_handler respondsToSelector: @selector(stream:handleEvent:)])
    NSLog(@"Returning from method at line: return _handler;");
      return _handler;
    NSLog(@"Returning from method at line: return [super delegate];");
  return [super delegate];
}

- (BOOL) _delegateValid
    NSLog(@"Entering - (BOOL) _delegateValid");
{
  if ((_handler != nil) && ([_handler handshake] == YES))
    if (YES == [_handler respondsToSelector: @selector(stream:handleEvent:)])
      YES;
    NSLog(@"Returning from method at line: return [super _delegateValid];");
  return [super _delegateValid];
}

#if 0 // TESTPLANT-MAL-03132018: This doesn't work due to send event
      // recursion causing the delegate/handler going out of scope...
- (void) _sendEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) _sendEvent: (NSStreamEvent)event");
{
  /* If the receiver has a TLS handshake in progress,
   * we must send events to the TLS handler rather than
   * the stream delegate.
   */
  if (_handler != nil && [_handler handshake] == YES)
    {
      id        del = _delegate;
    NSLog(@"del changed to %@;", del);
      BOOL      val = _delegateValid;
    NSLog(@"val changed to %@;", val);

      _delegate = _handler;
    NSLog(@"_delegate changed to %@;", _delegate);
      _delegateValid = YES;
    NSLog(@"_delegateValid changed to %@;", _delegateValid);
      [super _sendEvent: event];
      _delegate = del;
    NSLog(@"_delegate changed to %@;", _delegate);
      _delegateValid = val;
    NSLog(@"_delegateValid changed to %@;", _delegateValid);
    }
  else
    {
      [super _sendEvent: event];
    }
}
#endif

- (BOOL) _setSocketAddress: (NSString*)address
    NSLog(@"Entering - (BOOL) _setSocketAddress: (NSString*)address");
                      port: (NSInteger)port
                    family: (NSInteger)family
{
  uint16_t	p = (uint16_t)port;
    NSLog(@"p changed to %@;", p);

  switch (family)
    {
      case AF_INET:
        {
          int           ptonReturn;
          const char    *addr_c;
          struct	sockaddr_in	peer;

          addr_c = [address cStringUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"addr_c changed to %@;", addr_c);
          memset(&peer, '\0', sizeof(peer));
          peer.sin_family = AF_INET;
    NSLog(@"sin_family changed to %@;", sin_family);
          peer.sin_port = GSSwapHostI16ToBig(p);
    NSLog(@"sin_port changed to %@;", sin_port);
          ptonReturn = inet_pton(AF_INET, addr_c, &peer.sin_addr);
    NSLog(@"ptonReturn changed to %@;", ptonReturn);
          if (ptonReturn <= 0)   // error
            {
              NSLog(@"inet_pton error: %d.", ptonReturn);
    NSLog(@"Returning from method at line: return NO;");
              return NO;
            }
          else
            {
              [self _setAddress: (struct sockaddr_storage*)&peer];
    NSLog(@"Returning from method at line: return YES;");
              return YES;
            }
        }

#if	defined(AF_INET6)
      case AF_INET6:
        {
          int           ptonReturn;
          const char    *addr_c;
          struct	sockaddr_in6	peer;

          addr_c = [address cStringUsingEncoding: NSUTF8StringEncoding];
    NSLog(@"addr_c changed to %@;", addr_c);
          memset(&peer, '\0', sizeof(peer));
          peer.sin6_family = AF_INET6;
    NSLog(@"sin6_family changed to %@;", sin6_family);
          peer.sin6_port = GSSwapHostI16ToBig(p);
    NSLog(@"sin6_port changed to %@;", sin6_port);
          ptonReturn = inet_pton(AF_INET6, addr_c, &peer.sin6_addr);
    NSLog(@"ptonReturn changed to %@;", ptonReturn);
          if (ptonReturn <= 0)   // error
            {
    NSLog(@"Returning from method at line: return NO;");
              return NO;
            }
          else
            {
              [self _setAddress: (struct sockaddr_storage*)&peer];
    NSLog(@"Returning from method at line: return YES;");
              return YES;
            }
        }
#endif

#ifndef	_WIN32
      case AF_LOCAL:
	{
	  struct sockaddr_un	peer;
	  const char                *c_addr;

	  c_addr = [address fileSystemRepresentation];
    NSLog(@"c_addr changed to %@;", c_addr);
	  memset(&peer, '\0', sizeof(peer));
	  peer.sun_family = AF_LOCAL;
    NSLog(@"sun_family changed to %@;", sun_family);
	  if (strlen(c_addr) > sizeof(peer.sun_path)-1) // too long
	    {
    NSLog(@"Returning from method at line: return NO;");
	      return NO;
	    }
	  else
	    {
	      strncpy(peer.sun_path, c_addr, sizeof(peer.sun_path)-1);
	      [self _setAddress: (struct sockaddr_storage*)&peer];
    NSLog(@"Returning from method at line: return YES;");
	      return YES;
	    }
	}
#endif

      default:
    NSLog(@"Returning from method at line: return NO;");
        return NO;
    }
}

- (void) _setAddress: (struct sockaddr_storage*)address
    NSLog(@"Entering - (void) _setAddress: (struct sockaddr_storage*)address");
{
  memcpy(&_address.s, address, GSPrivateSockaddrLength(address));
}

- (void) _setLoopID: (void *)ref
    NSLog(@"Entering - (void) _setLoopID: (void *)ref");
{
#if	!defined(_WIN32)
  _sock = (SOCKET)(intptr_t)ref;        // On gnu/linux _sock is _loopID
    NSLog(@"_sock changed to %@;", _sock);
#endif
  _loopID = ref;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) _setClosing: (BOOL)closing
    NSLog(@"Entering - (void) _setClosing: (BOOL)closing");
{
  _closing = closing;
    NSLog(@"_closing changed to %@;", _closing);
}

- (void) _setPassive: (BOOL)passive
    NSLog(@"Entering - (void) _setPassive: (BOOL)passive");
{
  _passive = passive;
    NSLog(@"_passive changed to %@;", _passive);
}

- (void) _setSibling: (GSSocketStream*)sibling
    NSLog(@"Entering - (void) _setSibling: (GSSocketStream*)sibling");
{
  _sibling = sibling;
    NSLog(@"_sibling changed to %@;", _sibling);
}

- (void) _setSock: (SOCKET)sock
    NSLog(@"Entering - (void) _setSock: (SOCKET)sock");
{
  setNonBlocking(sock);
  _sock = sock;
    NSLog(@"_sock changed to %@;", _sock);

  /* As well as recording the socket, we set up the stream for monitoring it.
   * On unix style systems we set the socket descriptor as the _loopID to be
   * monitored, and on mswindows systems we create an event object to be
   * monitored (the socket events are assoociated with this object later).
   */
#if	defined(_WIN32)
  _loopID = CreateEvent(NULL, NO, NO, NULL);
    NSLog(@"_loopID changed to %@;", _loopID);
#else
  _loopID = (void*)(intptr_t)sock;      // On gnu/linux _sock is _loopID
    NSLog(@"_loopID changed to %@;", _loopID);
#endif
}

- (void) _setHandler: (id)h
    NSLog(@"Entering - (void) _setHandler: (id)h");
{
  ASSIGN(_handler, h);
}

- (SOCKET) _sock
    NSLog(@"Entering - (SOCKET) _sock");
{
    NSLog(@"Returning from method at line: return _sock;");
  return _sock;
}

- (NSInteger) _write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) _write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return -1;");
  return -1;
}

@end


@implementation GSSocketInputStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "_sibling");
  if (self == [GSSocketInputStream class])
    {
      GSObjCAddClassBehavior(self, [GSSocketStream class]);
    }
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  // could be opened because of sibling
  if ([self _isOpened])
    NSLog(@"Returning from method at line: return;");
    return;
  if (_sibling && [_sibling streamStatus] == NSStreamStatusError)
    {
      [self _setStatus: NSStreamStatusError];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (_passive || (_sibling && [_sibling _isOpened]))
    goto open_ok;
  // check sibling status, avoid double connect
  if (_sibling && [_sibling streamStatus] == NSStreamStatusOpening)
    {
      [self _setStatus: NSStreamStatusOpening];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else
    {
      int result;

      if ([self _sock] == INVALID_SOCKET)
        {
          SOCKET        s;

          if (_handler == nil)
            {
              [GSHTTP tryInput: self output: _sibling];
            }
          if (_handler == nil)
            {
              [GSSOCKS tryInput: self output: _sibling];
            }
          s = socket(_address.s.ss_family, SOCK_STREAM, 0);
    NSLog(@"s changed to %@;", s);
          if (BADSOCKET(s))
            {
              [self _recordError];
    NSLog(@"Returning from method at line: return;");
              return;
            }
          else
            {
              [self _setSock: s];
              [_sibling _setSock: s];
            }
        }

      if (nil == _handler)
        {
          [GSTLSHandler tryInput: self output: _sibling];
        }

      result = connect([self _sock], (struct sockaddr*)&_address.s,
        GSPrivateSockaddrLength(&_address.s));
      if (socketError(result))
        {
          if (socketWouldBlock())
            {
              /* Need to set the status first, so that the run loop can tell
           * it needs to add the stream as waiting on writable, as an
           * indication of opened
           */
          [self _setStatus: NSStreamStatusOpening];
            }
          else
            {
              /* Had an immediate connect error.
               */
              [self _recordError];
              [_sibling _recordError];
            }
#if	defined(_WIN32)
          WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
#endif
	  if (NSCountMapTable(_loops) > 0)
	    {
	      [self _schedule];
    NSLog(@"Returning from method at line: return;");
	      return;
	    }
          else if (NSStreamStatusOpening == _currentStatus)
            {
              NSRunLoop *r;
              NSDate    *d;

              /* The stream was not scheduled in any run loop, so we
               * implement a blocking connect by running in the default
               * run loop mode.
               */
              r = [NSRunLoop currentRunLoop];
    NSLog(@"r changed to %@;", r);
              d = [NSDate distantFuture];
    NSLog(@"d changed to %@;", d);
              [r addStream: self mode: NSDefaultRunLoopMode];
              while ([r runMode: NSDefaultRunLoopMode beforeDate: d] == YES)
                {
                  if (_currentStatus != NSStreamStatusOpening)
                    {
                      break;
                    }
                }
              [r removeStream: self mode: NSDefaultRunLoopMode];
    NSLog(@"Returning from method at line: return;");
              return;
            }
        }
    }

 open_ok:
#if	defined(_WIN32)
  WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
#endif
  [super open];
}

- (void) close
    NSLog(@"Entering - (void) close");
{
  /* If the socket descriptor is still present, we need to close it to
   * avoid a leak no matter what the nominal state of the stream is.
   * The descriptor is created before the stream is formally opened.
   */
  if (INVALID_SOCKET == _sock)
    {
  if (_currentStatus == NSStreamStatusNotOpen)
    {
      NSDebugMLLog(@"NSStream",
        @"Attempt to close unopened stream %@", self);
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (_currentStatus == NSStreamStatusClosed)
    {
      NSDebugMLLog(@"NSStream",
        @"Attempt to close already closed stream %@", self);
    NSLog(@"Returning from method at line: return;");
      return;
    }
    }
  [_handler bye];
#if	defined(_WIN32)
  [super close];
  if (_sibling && [_sibling streamStatus] != NSStreamStatusClosed)
    {
      /*
       * Windows only permits a single event to be associated with a socket
       * at any time, but the runloop system only allows an event handle to
       * be added to the loop once, and we have two streams for each socket.
       * So we use two events, one for each stream, and when one stream is
       * closed, we must call WSAEventSelect to ensure that the event handle
       * of the sibling is used to signal events from now on.
       */
      WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
      shutdown(_sock, SHUT_RD);
      WSAEventSelect(_sock, [_sibling _loopID], FD_ALL_EVENTS);
    }
  else
    {
      closesocket(_sock);
    }
  WSACloseEvent(_loopID);
  _loopID = WSA_INVALID_EVENT;
    NSLog(@"_loopID changed to %@;", _loopID);
#else
  [super close];
  // read shutdown is ignored, because the other side may shutdown first.
  if (!_sibling || [_sibling streamStatus] == NSStreamStatusClosed)
    close((intptr_t)_loopID);
  else
    shutdown((intptr_t)_loopID, SHUT_RD);
  _loopID = (void*)(intptr_t)-1;
    NSLog(@"_loopID changed to %@;", _loopID);
#endif
  _sock = INVALID_SOCKET;
    NSLog(@"_sock changed to %@;", _sock);
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"zero byte read requested"];
    }

  if (_handler == nil)
    NSLog(@"Returning from method at line: return [self _read: buffer maxLength: len];");
    return [self _read: buffer maxLength: len];
  else
    NSLog(@"Returning from method at line: return [_handler read: buffer maxLength: len];");
    return [_handler read: buffer maxLength: len];
}

- (NSInteger) _read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) _read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  int readLen;

  _events &= ~NSStreamEventHasBytesAvailable;

  if ([self streamStatus] == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }
  if ([self streamStatus] == NSStreamStatusAtEnd)
    {
      readLen = 0;
    NSLog(@"readLen changed to %@;", readLen);
    }
  else
    {
#if	defined(_WIN32)
      readLen = recv([self _sock], (char*) buffer, (socklen_t) len, 0);
    NSLog(@"readLen changed to %@;", readLen);
#else
      readLen = read([self _sock], buffer, len);
    NSLog(@"readLen changed to %@;", readLen);
#endif
    }
  if (socketError(readLen))
    {
      if (_closing == YES)
        {
          /* If a read fails on a closing socket,
           * we have reached the end of all data sent by
           * the remote end before it shut down.
           */
          [self _setClosing: NO];
          [self _setStatus: NSStreamStatusAtEnd];
          [self _sendEvent: NSStreamEventEndEncountered];
          readLen = 0;
    NSLog(@"readLen changed to %@;", readLen);
        }
      else
        {
          if (socketWouldBlock())
            {
              /* We need an event from the operating system
               * to tell us we can start reading again.
               */
              [self _setStatus: NSStreamStatusReading];
            }
          else
            {
              [self _recordError];
            }
          readLen = -1;
    NSLog(@"readLen changed to %@;", readLen);
        }
    }
  else if (readLen == 0)
    {
      [self _setStatus: NSStreamStatusAtEnd];
      [self _sendEvent: NSStreamEventEndEncountered];
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
    }
  NSLog(@"Read %d bytes from %@ (Socket: %d)", readLen, [self propertyForKey: GSStreamRemoteAddressKey], [self _sock]);
    NSLog(@"Returning from method at line: return readLen;");
  return readLen;
}

- (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len
    NSLog(@"Entering - (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len");
{
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
#if	defined(_WIN32)
  AUTORELEASE(RETAIN(self));
  /*
   * Windows only permits a single event to be associated with a socket
   * at any time, but the runloop system only allows an event handle to
   * be added to the loop once, and we have two streams for each socket.
   * So we use two events, one for each stream, and the _dispatch method
   * must handle things for both streams.
   */
  if ([self streamStatus] == NSStreamStatusClosed)
    {
      /*
       * It is possible the stream is closed yet recieving event because
       * of not closed sibling
       */
      NSAssert([_sibling streamStatus] != NSStreamStatusClosed,
	@"Received event for closed stream");
      [_sibling _dispatch];
    }
  else if ([self streamStatus] == NSStreamStatusError)
    {
      [self _sendEvent: NSStreamEventErrorOccurred];
    }
  else
    {
      WSANETWORKEVENTS events;
      int error = 0;
    NSLog(@"error changed to %@;", error);
      int getReturn = -1;
    NSLog(@"getReturn changed to %@;", getReturn);

      if (WSAEnumNetworkEvents(_sock, _loopID, &events) == SOCKET_ERROR)
	{
	  error = WSAGetLastError();
    NSLog(@"error changed to %@;", error);
	}
// else NSLog(@"EVENTS 0x%x on %p", events.lNetworkEvents, self);

      if ([self streamStatus] == NSStreamStatusOpening)
	{
	  [self _unschedule];
	  if (error == 0)
	    {
	      socklen_t len = sizeof(error);
    NSLog(@"len changed to %@;", len);

	      getReturn = getsockopt(_sock, SOL_SOCKET, SO_ERROR,
		(char*)&error, (OPTLEN*)&len);
	    }

	  if (getReturn >= 0 && error == 0
	    && (events.lNetworkEvents & FD_CONNECT))
	    { // finish up the opening
	      _passive = YES;
    NSLog(@"_passive changed to %@;", _passive);
	      [self open];
	      // notify sibling
	      if (_sibling)
		{
		  [_sibling open];
		  [_sibling _sendEvent: NSStreamEventOpenCompleted];
		}
	      [self _sendEvent: NSStreamEventOpenCompleted];
	    }
	}

      if (error != 0)
	{
	  errno = error;
    NSLog(@"errno changed to %@;", errno);
	  [self _recordError];
	  [_sibling _recordError];
	  [self _sendEvent: NSStreamEventErrorOccurred];
	  [_sibling _sendEvent: NSStreamEventErrorOccurred];
	}
      else
	{
	  if (events.lNetworkEvents & FD_WRITE)
	    {
	      NSAssert([_sibling _isOpened], NSInternalInconsistencyException);
	      /* Clear NSStreamStatusWriting if it was set */
	      [_sibling _setStatus: NSStreamStatusOpen];
	    }

	  /* On winsock a socket is always writable unless it has had
	   * failure/closure or a write blocked and we have not been
	   * signalled again.
	   */
	  while ([_sibling _unhandledData] == NO
	    && [_sibling hasSpaceAvailable])
	    {
	      [_sibling _sendEvent: NSStreamEventHasSpaceAvailable];
	    }

	  if (events.lNetworkEvents & FD_READ)
	    {
	      [self _setStatus: NSStreamStatusOpen];
	      while ([self hasBytesAvailable]
		&& [self _unhandledData] == NO)
		{
	          [self _sendEvent: NSStreamEventHasBytesAvailable];
		}
	    }

	  if (events.lNetworkEvents & FD_CLOSE)
	    {
	      [self _setClosing: YES];
	      [_sibling _setClosing: YES];
	      while ([self hasBytesAvailable]
		&& [self _unhandledData] == NO)
		{
		  [self _sendEvent: NSStreamEventHasBytesAvailable];
		}
	    }
	  if (events.lNetworkEvents == 0)
	    {
	      [self _sendEvent: NSStreamEventHasBytesAvailable];
	    }
	}
    }
#else
  NSStreamEvent myEvent;

  if ([self streamStatus] == NSStreamStatusOpening)
    {
      int error;
      int result;
      socklen_t len = sizeof(error);
    NSLog(@"len changed to %@;", len);

      IF_NO_GC([[self retain] autorelease];)
      [self _unschedule];
      result = getsockopt([self _sock], SOL_SOCKET, SO_ERROR,
	&error, (OPTLEN*)&len);

      if (result >= 0 && !error)
        { // finish up the opening
          myEvent = NSStreamEventOpenCompleted;
    NSLog(@"myEvent changed to %@;", myEvent);
          _passive = YES;
    NSLog(@"_passive changed to %@;", _passive);
          [self open];
          // notify sibling
          [_sibling open];
          [_sibling _sendEvent: myEvent];
        }
      else // must be an error
        {
          if (error)
            errno = error;
    NSLog(@"errno changed to %@;", errno);
          [self _recordError];
          myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
          [_sibling _recordError];
          [_sibling _sendEvent: myEvent];
        }
    }
  else if ([self streamStatus] == NSStreamStatusAtEnd)
    {
      myEvent = NSStreamEventEndEncountered;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if ([self streamStatus] == NSStreamStatusError)
    {
      myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
      myEvent = NSStreamEventHasBytesAvailable;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  [self _sendEvent: myEvent];
#endif
}

#if	defined(_WIN32)
- (BOOL) runLoopShouldBlock: (BOOL*)trigger
    NSLog(@"Entering - (BOOL) runLoopShouldBlock: (BOOL*)trigger");
{
  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}
#endif

@end


@implementation GSSocketOutputStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "_sibling");
  if (self == [GSSocketOutputStream class])
    {
      GSObjCAddClassBehavior(self, [GSSocketStream class]);
    }
}

- (NSInteger) _write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) _write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  int writeLen;

  _events &= ~NSStreamEventHasSpaceAvailable;

  if ([self streamStatus] == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }
  if ([self streamStatus] == NSStreamStatusAtEnd)
    {
      [self _sendEvent: NSStreamEventEndEncountered];
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

#if	defined(_WIN32)
  writeLen = send([self _sock], (char*) buffer, (socklen_t) len, 0);
    NSLog(@"writeLen changed to %@;", writeLen);
#else
  writeLen = write([self _sock], buffer, (socklen_t) len);
    NSLog(@"writeLen changed to %@;", writeLen);
#endif

  if (socketError(writeLen))
    {
      if (_closing == YES)
        {
          /* If a write fails on a closing socket,
           * we know the other end is no longer reading.
           */
          [self _setClosing: NO];
          [self _setStatus: NSStreamStatusAtEnd];
          [self _sendEvent: NSStreamEventEndEncountered];
          writeLen = 0;
    NSLog(@"writeLen changed to %@;", writeLen);
        }
      else
        {
          if (socketWouldBlock())
            {
              /* We need an event from the operating system
               * to tell us we can start writing again.
               */
              [self _setStatus: NSStreamStatusWriting];
            }
          else
            {
              [self _recordError];
            }
          writeLen = -1;
    NSLog(@"writeLen changed to %@;", writeLen);
        }
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
    }
  NSLog(@"Write %d bytes to %@ (Socket: %d)", writeLen, [self propertyForKey: GSStreamRemoteAddressKey], [self _sock]);
    NSLog(@"Returning from method at line: return writeLen;");
  return writeLen;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  // could be opened because of sibling
  if ([self _isOpened])
    NSLog(@"Returning from method at line: return;");
    return;
  if (_sibling && [_sibling streamStatus] == NSStreamStatusError)
    {
      [self _setStatus: NSStreamStatusError];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (_passive || (_sibling && [_sibling _isOpened]))
    goto open_ok;
  // check sibling status, avoid double connect
  if (_sibling && [_sibling streamStatus] == NSStreamStatusOpening)
    {
      [self _setStatus: NSStreamStatusOpening];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else
    {
      int result;

      if ([self _sock] == INVALID_SOCKET)
        {
          SOCKET        s;

          if (_handler == nil)
            {
              [GSHTTP tryInput: _sibling output: self];
            }
          if (_handler == nil)
            {
              [GSSOCKS tryInput: _sibling output: self];
            }
          s = socket(_address.s.ss_family, SOCK_STREAM, 0);
    NSLog(@"s changed to %@;", s);
          if (BADSOCKET(s))
            {
              [self _recordError];
    NSLog(@"Returning from method at line: return;");
              return;
            }
          else
            {
              [self _setSock: s];
              [_sibling _setSock: s];
            }
        }

      if (nil == _handler)
        {
          [GSTLSHandler tryInput: _sibling output: self];
        }

      result = connect([self _sock], (struct sockaddr*) &_address.s,
        GSPrivateSockaddrLength(&_address.s));
      if (socketError(result))
        {
          if (socketWouldBlock())
            {
          /*
           * Need to set the status first, so that the run loop can tell
           * it needs to add the stream as waiting on writable, as an
           * indication of opened
           */
          [self _setStatus: NSStreamStatusOpening];
            }
          else
            {
              /* Had an immediate connect error.
               */
              [self _recordError];
              [_sibling _recordError];
            }
#if	defined(_WIN32)
          WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
#endif
	  if (NSCountMapTable(_loops) > 0)
	    {
	      [self _schedule];
    NSLog(@"Returning from method at line: return;");
	      return;
	    }
          else if (NSStreamStatusOpening == _currentStatus)
            {
              NSRunLoop *r;
              NSDate    *d;

              /* The stream was not scheduled in any run loop, so we
               * implement a blocking connect by running in the default
               * run loop mode.
               */
              r = [NSRunLoop currentRunLoop];
    NSLog(@"r changed to %@;", r);
              d = [NSDate distantFuture];
    NSLog(@"d changed to %@;", d);
              [r addStream: self mode: NSDefaultRunLoopMode];
              while ([r runMode: NSDefaultRunLoopMode beforeDate: d] == YES)
                {
                  if (_currentStatus != NSStreamStatusOpening)
                    {
                      break;
                    }
                }
              [r removeStream: self mode: NSDefaultRunLoopMode];
    NSLog(@"Returning from method at line: return;");
              return;
            }
        }
    }

 open_ok:
#if	defined(_WIN32)
  WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
#endif
  [super open];
}


- (void) close
    NSLog(@"Entering - (void) close");
{
  /* If the socket descriptor is still present, we need to close it to
   * avoid a leak no matter what the nominal state of the stream is.
   * The descriptor is created before the stream is formally opened.
   */
  if (INVALID_SOCKET == _sock)
    {
  if (_currentStatus == NSStreamStatusNotOpen)
    {
      NSDebugMLLog(@"NSStream",
        @"Attempt to close unopened stream %@", self);
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (_currentStatus == NSStreamStatusClosed)
    {
      NSDebugMLLog(@"NSStream",
        @"Attempt to close already closed stream %@", self);
    NSLog(@"Returning from method at line: return;");
      return;
    }
    }
  [_handler bye];
#if	defined(_WIN32)
  if (_sibling && [_sibling streamStatus] != NSStreamStatusClosed)
    {
      /*
       * Windows only permits a single event to be associated with a socket
       * at any time, but the runloop system only allows an event handle to
       * be added to the loop once, and we have two streams for each socket.
       * So we use two events, one for each stream, and when one stream is
       * closed, we must call WSAEventSelect to ensure that the event handle
       * of the sibling is used to signal events from now on.
       */
      WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
      shutdown(_sock, SHUT_WR);
      WSAEventSelect(_sock, [_sibling _loopID], FD_ALL_EVENTS);
    }
  else
    {
      closesocket(_sock);
    }
  WSACloseEvent(_loopID);
  [super close];
  _loopID = WSA_INVALID_EVENT;
    NSLog(@"_loopID changed to %@;", _loopID);
#else
  // read shutdown is ignored, because the other side may shutdown first.
  if (!_sibling || [_sibling streamStatus] == NSStreamStatusClosed)
    close((intptr_t)_loopID);
  else
    shutdown((intptr_t)_loopID, SHUT_WR);
  [super close];
  _loopID = (void*)(intptr_t)-1;
    NSLog(@"_loopID changed to %@;", _loopID);
#endif
  _sock = INVALID_SOCKET;
    NSLog(@"_sock changed to %@;", _sock);
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  if (len == 0)
    {
      /*
       *  The method allows the 'len' equal to 0. In this case the 'buffer'
       *  is ignored. This can be useful if there is a necessity to postpone
       *  actual writing (for no data are ready for example) without leaving
       *  the stream in the state of unhandled NSStreamEventHasSpaceAvailable
       *  (to keep receiving of that event from a runloop).
       *  The delegate's -[stream:handleEvent:] would keep calling of
       *  -[write: NULL maxLength: 0] until the delegate's state allows it
       *  to write actual bytes.
       *  The downside of that is that it produces a busy wait ... with the
       *  run loop immediately notifying the stream that it has space to
       *  write, so care should be taken to ensure that the delegate has a
       *  near constant supply of data to write, or has some mechanism to
       *  detect that no more data is arriving, and shut down.
       */
      _events &= ~NSStreamEventHasSpaceAvailable;
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"null pointer for buffer"];
    }

  if (_handler == nil)
    NSLog(@"Returning from method at line: return [self _write: buffer maxLength: len];");
    return [self _write: buffer maxLength: len];
  else
    NSLog(@"Returning from method at line: return [_handler write: buffer maxLength: len];");
    return [_handler write: buffer maxLength: len];
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
#if	defined(_WIN32)
  AUTORELEASE(RETAIN(self));
  /*
   * Windows only permits a single event to be associated with a socket
   * at any time, but the runloop system only allows an event handle to
   * be added to the loop once, and we have two streams for each socket.
   * So we use two events, one for each stream, and the _dispatch method
   * must handle things for both streams.
   */
  if ([self streamStatus] == NSStreamStatusClosed)
    {
      /*
       * It is possible the stream is closed yet recieving event because
       * of not closed sibling
       */
      NSAssert([_sibling streamStatus] != NSStreamStatusClosed,
	@"Received event for closed stream");
      [_sibling _dispatch];
    }
  else if ([self streamStatus] == NSStreamStatusError)
    {
      [self _sendEvent: NSStreamEventErrorOccurred];
    }
  else
    {
      WSANETWORKEVENTS events;
      int error = 0;
    NSLog(@"error changed to %@;", error);
      int getReturn = -1;
    NSLog(@"getReturn changed to %@;", getReturn);

      if (WSAEnumNetworkEvents(_sock, _loopID, &events) == SOCKET_ERROR)
	{
	  error = WSAGetLastError();
    NSLog(@"error changed to %@;", error);
	}
// else NSLog(@"EVENTS 0x%x on %p", events.lNetworkEvents, self);

      if ([self streamStatus] == NSStreamStatusOpening)
	{
	  [self _unschedule];
	  if (error == 0)
	    {
	      socklen_t len = sizeof(error);
    NSLog(@"len changed to %@;", len);

	      getReturn = getsockopt(_sock, SOL_SOCKET, SO_ERROR,
		(char*)&error, (OPTLEN*)&len);
	    }

	  if (getReturn >= 0 && error == 0
	    && (events.lNetworkEvents & FD_CONNECT))
	    { // finish up the opening
	      events.lNetworkEvents ^= FD_CONNECT;
	      _passive = YES;
    NSLog(@"_passive changed to %@;", _passive);
	      [self open];
	      // notify sibling
	      if (_sibling)
		{
		  [_sibling open];
		  [_sibling _sendEvent: NSStreamEventOpenCompleted];
		}
	      [self _sendEvent: NSStreamEventOpenCompleted];
	    }
	}

      if (error != 0)
	{
	  errno = error;
    NSLog(@"errno changed to %@;", errno);
	  [self _recordError];
	  [_sibling _recordError];
	  [self _sendEvent: NSStreamEventErrorOccurred];
	  [_sibling _sendEvent: NSStreamEventErrorOccurred];
	}
      else
	{
	  if (events.lNetworkEvents & FD_WRITE)
	    {
	      /* Clear NSStreamStatusWriting if it was set */
	      [self _setStatus: NSStreamStatusOpen];
	    }

	  /* On winsock a socket is always writable unless it has had
	   * failure/closure or a write blocked and we have not been
	   * signalled again.
	   */
	  while ([self _unhandledData] == NO && [self hasSpaceAvailable])
	    {
	      [self _sendEvent: NSStreamEventHasSpaceAvailable];
	    }

	  if (events.lNetworkEvents & FD_READ)
 {
	      [_sibling _setStatus: NSStreamStatusOpen];
	      while ([_sibling hasBytesAvailable]
		&& [_sibling _unhandledData] == NO)
		{
	          [_sibling _sendEvent: NSStreamEventHasBytesAvailable];
		}
	    }
	  if (events.lNetworkEvents & FD_CLOSE)
	    {
	      [self _setClosing: YES];
	      [_sibling _setClosing: YES];
	      while ([_sibling hasBytesAvailable]
		&& [_sibling _unhandledData] == NO)
		{
		  [_sibling _sendEvent: NSStreamEventHasBytesAvailable];
		}
	    }
	  if (events.lNetworkEvents == 0)
	    {
	      [self _sendEvent: NSStreamEventHasSpaceAvailable];
	    }
	}
    }
#else
  NSStreamEvent myEvent;

  if ([self streamStatus] == NSStreamStatusOpening)
    {
      int error;
      socklen_t len = sizeof(error);
    NSLog(@"len changed to %@;", len);
      int result;

      IF_NO_GC([[self retain] autorelease];)
      [self _schedule];
      result = getsockopt((intptr_t)_loopID, SOL_SOCKET, SO_ERROR,
	&error, (OPTLEN*)&len);
      if (result >= 0 && !error)
        { // finish up the opening
          myEvent = NSStreamEventOpenCompleted;
    NSLog(@"myEvent changed to %@;", myEvent);
          _passive = YES;
    NSLog(@"_passive changed to %@;", _passive);
          [self open];
          // notify sibling
          [_sibling open];
          [_sibling _sendEvent: myEvent];
        }
      else // must be an error
        {
          if (error)
            errno = error;
    NSLog(@"errno changed to %@;", errno);
          [self _recordError];
          myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
          [_sibling _recordError];
          [_sibling _sendEvent: myEvent];
        }
    }
  else if ([self streamStatus] == NSStreamStatusAtEnd)
    {
      myEvent = NSStreamEventEndEncountered;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if ([self streamStatus] == NSStreamStatusError)
    {
      myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
      myEvent = NSStreamEventHasSpaceAvailable;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  [self _sendEvent: myEvent];
#endif
}

#if	defined(_WIN32)
- (BOOL) runLoopShouldBlock: (BOOL*)trigger
    NSLog(@"Entering - (BOOL) runLoopShouldBlock: (BOOL*)trigger");
{
  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
  if ([self _unhandledData] == YES && [self streamStatus] == NSStreamStatusOpen)
    {
      /* In winsock, a writable status is only signalled if an earlier
       * write failed (because it would block), so we must simulate the
       * writable event by having the run loop trigger without blocking.
       */
    NSLog(@"Returning from method at line: return NO;");
      return NO;
    }
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}
#endif

@end

@implementation GSSocketServerStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "_sibling");
  if (self == [GSSocketServerStream class])
    {
      GSObjCAddClassBehavior(self, [GSSocketStream class]);
    }
}

- (Class) _inputStreamClass
    NSLog(@"Entering - (Class) _inputStreamClass");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return Nil;");
  return Nil;
}

- (Class) _outputStreamClass
    NSLog(@"Entering - (Class) _outputStreamClass");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return Nil;");
  return Nil;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  int bindReturn;
  int listenReturn;
  SOCKET s;

  if (_currentStatus != NSStreamStatusNotOpen)
    {
      NSDebugMLLog(@"NSStream",
        @"Attempt to re-open stream %@", self);
    NSLog(@"Returning from method at line: return;");
      return;
    }

  s = socket(_address.s.ss_family, SOCK_STREAM, 0);
    NSLog(@"s changed to %@;", s);
  if (BADSOCKET(s))
    {
      [self _recordError];
      [self _sendEvent: NSStreamEventErrorOccurred];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else
    {
      [(GSSocketStream*)self _setSock: s];
    }

#ifndef	BROKEN_SO_REUSEADDR
  if (_address.s.ss_family == AF_INET
#ifdef  AF_INET6
    || _address.s.ss_family == AF_INET6
#endif
  )
    {
      /*
       * Under decent systems, SO_REUSEADDR means that the port can be reused
       * immediately that this process exits.  Under some it means
       * that multiple processes can serve the same port simultaneously.
       * We don't want that broken behavior!
       */
      int	status = 1;
    NSLog(@"status changed to %@;", status);

      if (setsockopt([self _sock], SOL_SOCKET, SO_REUSEADDR,
        (char *)&status, (OPTLEN)sizeof(status)) < 0)
        {
          NSDebugMLLog(@"GSTcpTune", @"setsockopt reuseaddr failed");
        }
    }
#endif

  bindReturn = bind([self _sock],
    (struct sockaddr*)&_address.s, GSPrivateSockaddrLength(&_address.s));
  if (socketError(bindReturn))
    {
      [self _recordError];
      [self _sendEvent: NSStreamEventErrorOccurred];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  listenReturn = listen([self _sock], GSBACKLOG);
    NSLog(@"listenReturn changed to %@;", listenReturn);
  if (socketError(listenReturn))
    {
      [self _recordError];
      [self _sendEvent: NSStreamEventErrorOccurred];
    NSLog(@"Returning from method at line: return;");
      return;
    }
#if	defined(_WIN32)
  WSAEventSelect(_sock, _loopID, FD_ALL_EVENTS);
#endif
  [super open];
}

- (void) close
    NSLog(@"Entering - (void) close");
{
#if	defined(_WIN32)
  if (_loopID != WSA_INVALID_EVENT)
    {
      WSACloseEvent(_loopID);
    }
  if (_sock != INVALID_SOCKET)
    {
      closesocket(_sock);
      [super close];
      _loopID = WSA_INVALID_EVENT;
    NSLog(@"_loopID changed to %@;", _loopID);
    }
#else
  if (_loopID != (void*)(intptr_t)-1)
    {
      close((intptr_t)_loopID);
      [super close];
      _loopID = (void*)(intptr_t)-1;
    NSLog(@"_loopID changed to %@;", _loopID);
    }
#endif
  _sock = INVALID_SOCKET;
    NSLog(@"_sock changed to %@;", _sock);
}

- (void) acceptWithInputStream: (NSInputStream **)inputStream
    NSLog(@"Entering - (void) acceptWithInputStream: (NSInputStream **)inputStream");
                  outputStream: (NSOutputStream **)outputStream
{
  NSArray *keys;
  NSUInteger count;
  NSMutableDictionary *opts;
  NSString *str;

  GSSocketStream *ins = AUTORELEASE([[self _inputStreamClass] new]);
    NSLog(@"ins changed to %@;", ins);
  GSSocketStream *outs = AUTORELEASE([[self _outputStreamClass] new]);
    NSLog(@"outs changed to %@;", outs);
  /* Align on a 2 byte boundary for a 16bit port number in the sockaddr
   */
  struct {
    uint8_t bytes[BUFSIZ];
  } __attribute__((aligned(2)))buf;
  struct sockaddr_storage       *addr = (struct sockaddr_storage*)&buf;
    NSLog(@"addr changed to %@;", addr);
  socklen_t		len = sizeof(buf);
    NSLog(@"len changed to %@;", len);
  int			acceptReturn;

  acceptReturn = accept([self _sock], (struct sockaddr*)addr, (OPTLEN*)&len);
    NSLog(@"acceptReturn changed to %@;", acceptReturn);
  _events &= ~NSStreamEventHasBytesAvailable;
  if (socketError(acceptReturn))
    { // test for real error
      if (!socketWouldBlock())
	{
          [self _recordError];
	}
      ins = nil;
    NSLog(@"ins changed to %@;", ins);
      outs = nil;
    NSLog(@"outs changed to %@;", outs);
    }
  else
    {
      // no need to connect again
      [ins _setPassive: YES];
      [outs _setPassive: YES];

      // copy the addr to outs
      [ins _setAddress: addr];
      [outs _setAddress: addr];
      [ins _setSock: acceptReturn];
      [outs _setSock: acceptReturn];

      /* Set property to indicate that the input stream was accepted by
       * a listening socket (server) rather than produced by an outgoing
       * connection (client).
       */
      [ins setProperty: @"YES" forKey: @"IsServer"];

      /* At this point, we can insert the handler to deal with TLS
       */
      str = [self propertyForKey: NSStreamSocketSecurityLevelKey];
    NSLog(@"str changed to %@;", str);
      if(nil != str)
	{
	  opts = [NSMutableDictionary new];
    NSLog(@"opts changed to %@;", opts);
	  [opts setObject: str forKey: NSStreamSocketSecurityLevelKey];
	  // copy the properties in the 'opts'
	  [GSTLSHandler populateProperties: &opts
			 withSecurityLevel: str
			   fromInputStream: self
			    orOutputStream: nil];
	  // and set the input/output streams's properties from the 'opts'
	  keys = [opts allKeys];
    NSLog(@"keys changed to %@;", keys);
	  count = [keys count];
    NSLog(@"count changed to %@;", count);
	  while(count-- > 0)
	    {
	      NSString *key = [keys objectAtIndex: count];
    NSLog(@"key changed to %@;", key);
	      str = [opts objectForKey: key];
    NSLog(@"str changed to %@;", str);
	      [ins setProperty: str forKey: key];
	      [outs setProperty: str forKey: key];
    }

          /* Set the streams to be 'open' in order to have the TLS
           * handshake done.  On completion the state will be reset.
           */
          [ins _setStatus: NSStreamStatusOpen];
          [outs _setStatus: NSStreamStatusOpen];
	  [GSTLSHandler tryInput: (GSSocketInputStream *)ins
			  output: (GSSocketOutputStream *)outs];
	  DESTROY(opts);
	}
    }
  if (inputStream)
    {
      [ins _setSibling: outs];
      *inputStream = (NSInputStream*)ins;
    NSLog(@"inputStream changed to %@;", inputStream);
    }
  if (outputStream)
    {
      [outs _setSibling: ins];
      *outputStream = (NSOutputStream*)outs;
    NSLog(@"outputStream changed to %@;", outputStream);
    }
  /* Now the streams are redy to be opened.
   */
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
#if	defined(_WIN32)
  WSANETWORKEVENTS events;

  if (WSAEnumNetworkEvents(_sock, _loopID, &events) == SOCKET_ERROR)
    {
      errno = WSAGetLastError();
    NSLog(@"errno changed to %@;", errno);
      [self _recordError];
      [self _sendEvent: NSStreamEventErrorOccurred];
    }
  else if (events.lNetworkEvents & FD_ACCEPT)
    {
      events.lNetworkEvents ^= FD_ACCEPT;
      [self _setStatus: NSStreamStatusReading];
      [self _sendEvent: NSStreamEventHasBytesAvailable];
    }
#else
  NSStreamEvent myEvent;

  [self _setStatus: NSStreamStatusOpen];
  myEvent = NSStreamEventHasBytesAvailable;
    NSLog(@"myEvent changed to %@;", myEvent);
  [self _sendEvent: myEvent];
#endif
}

@end



@implementation GSInetInputStream

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ((self = [super init]) != nil)
    {
      if ([self _setSocketAddress: addr port: port family: AF_INET] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

@end

@implementation GSInet6InputStream
#if	defined(AF_INET6)

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ((self = [super init]) != nil)
    {
      if ([self _setSocketAddress: addr port: port family: AF_INET6] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

#else
- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}
#endif
@end

@implementation GSInetOutputStream

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ((self = [super init]) != nil)
    {
      if ([self _setSocketAddress: addr port: port family: AF_INET] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

@end

@implementation GSInet6OutputStream
#if	defined(AF_INET6)

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ((self = [super init]) != nil)
    {
      if ([self _setSocketAddress: addr port: port family: AF_INET6] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

#else
- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}
#endif
@end

@implementation GSInetServerStream

- (Class) _inputStreamClass
    NSLog(@"Entering - (Class) _inputStreamClass");
{
    NSLog(@"Returning from method at line: return [GSInetInputStream class];");
  return [GSInetInputStream class];
}

- (Class) _outputStreamClass
    NSLog(@"Entering - (Class) _outputStreamClass");
{
    NSLog(@"Returning from method at line: return [GSInetOutputStream class];");
  return [GSInetOutputStream class];
}

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ((self = [super init]) != nil)
    {
      if ([addr length] == 0)
        {
          addr = @"0.0.0.0";
    NSLog(@"addr changed to %@;", addr);
        }
      if ([self _setSocketAddress: addr port: port family: AF_INET] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

@end

@implementation GSInet6ServerStream
#if	defined(AF_INET6)
- (Class) _inputStreamClass
    NSLog(@"Entering - (Class) _inputStreamClass");
{
    NSLog(@"Returning from method at line: return [GSInet6InputStream class];");
  return [GSInet6InputStream class];
}

- (Class) _outputStreamClass
    NSLog(@"Entering - (Class) _outputStreamClass");
{
    NSLog(@"Returning from method at line: return [GSInet6OutputStream class];");
  return [GSInet6OutputStream class];
}

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  if ([super init] != nil)
    {
      if ([addr length] == 0)
        {
          addr = @"0:0:0:0:0:0:0:0";   /* Bind on all addresses */
    NSLog(@"addr changed to %@;", addr);
        }
      if ([self _setSocketAddress: addr port: port family: AF_INET6] == NO)
        {
          DESTROY(self);
        }
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}
#else
- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}
#endif
@end

