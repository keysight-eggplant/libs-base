// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: 9767fe51d240eac76d92d209db166b05be1c1079 
// Date: 2017-11-16 21:58:28 +0000 
// ========== End of Keysight Technologies Notice ========== 
/** Implementation of connection object for remote object messaging
   Copyright (C) 1994-2013 Free Software Foundation, Inc.

   Created by:  Andrew Kachites McCallum <mccallum@gnu.ai.mit.edu>
   Date: July 1994
   Minor rewrite for OPENSTEP by: Richard Frith-Macdonald <rfm@gnu.org>
   Date: August 1997
   Major rewrite for MACOSX by: Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2000

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

   <title>NSConnection class reference</title>
   $Date$ $Revision$
   */

#import "common.h"

#if !defined (__GNU_LIBOBJC__)
#  include <objc/encoding.h>
#endif

#define	GS_NSConnection_IVARS \
  BOOL			_isValid; \
  BOOL			_independentQueueing; \
  BOOL			_authenticateIn; \
  BOOL			_authenticateOut; \
  BOOL			_multipleThreads; \
  BOOL			_shuttingDown; \
  BOOL			_useKeepalive; \
  BOOL			_keepaliveWait; \
  NSPort		*_receivePort; \
  NSPort		*_sendPort; \
  unsigned		_requestDepth; \
  unsigned		_messageCount; \
  unsigned		_reqOutCount; \
  unsigned		_reqInCount; \
  unsigned		_repOutCount; \
  unsigned		_repInCount; \
  GSIMapTable		_localObjects; \
  GSIMapTable		_localTargets; \
  GSIMapTable		_remoteProxies; \
  GSIMapTable		_replyMap; \
  NSTimeInterval	_replyTimeout; \
  NSTimeInterval	_requestTimeout; \
  NSMutableArray	*_requestModes; \
  NSMutableArray	*_runLoops; \
  NSMutableArray	*_requestQueue; \
  id			_delegate; \
  NSRecursiveLock	*_refGate; \
  NSMutableArray	*_cachedDecoders; \
  NSMutableArray	*_cachedEncoders; \
  NSString		*_remoteName; \
  NSString		*_registeredName; \
  NSPortNameServer	*_nameServer; \
  int			_lastKeepalive

#define	EXPOSE_NSDistantObject_IVARS	1

#ifdef HAVE_MALLOC_H
#if !defined(__OpenBSD__)
#include <malloc.h>
#endif
#endif
#ifdef HAVE_ALLOCA_H
#include <alloca.h>
#endif

#import "Foundation/NSEnumerator.h"
#import "GNUstepBase/GSLock.h"

/* Skip past an argument and also any offset information before the next.
 */
static inline const char *
skip_argspec(const char *ptr)
{
  if (ptr != NULL)
    {
      ptr = NSGetSizeAndAlignment(ptr, NULL, NULL);
    NSLog(@"ptr changed to %@;", ptr);
      if (*ptr == '+') ptr++;
    NSLog(@"ptr changed to %@;", ptr);
      while (isdigit(*ptr)) ptr++;
    }
    NSLog(@"Returning from method at line: return ptr;");
  return ptr;
}

/*
 *	Setup for inline operation of pointer map tables.
 */
#define	GSI_MAP_KTYPES	GSUNION_PTR | GSUNION_OBJ | GSUNION_NSINT
#define	GSI_MAP_VTYPES	GSUNION_PTR | GSUNION_OBJ
#define	GSI_MAP_RETAIN_KEY(M, X)
#define	GSI_MAP_RELEASE_KEY(M, X)
#define	GSI_MAP_RETAIN_VAL(M, X)
#define	GSI_MAP_RELEASE_VAL(M, X)
#define	GSI_MAP_HASH(M, X)	((X).nsu ^ ((X).nsu >> 3))
#define	GSI_MAP_EQUAL(M, X,Y)	((X).ptr == (Y).ptr)
#define	GSI_MAP_NOCLEAN	1


#include "GNUstepBase/GSIMap.h"

#define	_IN_CONNECTION_M
#import "Foundation/NSConnection.h"
#undef	_IN_CONNECTION_M

#import "Foundation/NSPortCoder.h"
#import "GNUstepBase/DistributedObjects.h"

#import "Foundation/NSHashTable.h"
#import "Foundation/NSMapTable.h"
#import "Foundation/NSData.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSValue.h"
#import "Foundation/NSDate.h"
#import "Foundation/NSException.h"
#import "Foundation/NSLock.h"
#import "Foundation/NSThread.h"
#import "Foundation/NSPort.h"
#import "Foundation/NSPortMessage.h"
#import "Foundation/NSPortNameServer.h"
#import "Foundation/NSNotification.h"
#import "GSInvocation.h"
#import "GSPortPrivate.h"
#import "GSPrivate.h"


static inline NSRunLoop *
GSRunLoopForThread(NSThread *aThread)
{
  GSRunLoopThreadInfo   *info = GSRunLoopInfoForThread(aThread);
    NSLog(@"info changed to %@;", info);

  if (info == nil || info->loop == nil)
    {
      if (aThread == nil || aThread == GSCurrentThread())
        {
    NSLog(@"Returning from method at line: return [NSRunLoop currentRunLoop];");
          return [NSRunLoop currentRunLoop];
        }
    NSLog(@"Returning from method at line: return nil;");
      return nil;
    }
    NSLog(@"Returning from method at line: return info->loop;");
  return info->loop;
}


@interface	NSPortCoder (Private)
- (NSMutableArray*) _components;
    NSLog(@"Entering - (NSMutableArray*) _components;");
@end
@interface	NSPortMessage (Private)
- (NSMutableArray*) _components;
    NSLog(@"Entering - (NSMutableArray*) _components;");
@end

@interface NSConnection (GNUstepExtensions)
- (void) finalize;
    NSLog(@"Entering - (void) finalize;");
- (void) forwardInvocation: (NSInvocation *)inv
    NSLog(@"Entering - (void) forwardInvocation: (NSInvocation *)inv");
		  forProxy: (NSDistantObject*)object;
- (const char *) typeForSelector: (SEL)sel remoteTarget: (unsigned)target;
    NSLog(@"Entering - (const char *) typeForSelector: (SEL)sel remoteTarget: (unsigned)target;");
@end

#define GS_F_LOCK(X) \
{NSDebugFLLog(@"GSConnection",@"Lock %@",X);[X lock];}
#define GS_F_UNLOCK(X) \
{NSDebugFLLog(@"GSConnection",@"Unlock %@",X);[X unlock];}
#define GS_M_LOCK(X) \
{NSDebugMLLog(@"GSConnection",@"Lock %@",X);[X lock];}
#define GSM_UNLOCK(X) \
{NSDebugMLLog(@"GSConnection",@"Unlock %@",X);[X unlock];}

NSString * const NSDestinationInvalidException =
  @"NSDestinationInvalidException";
NSString * const NSFailedAuthenticationException =
  @"NSFailedAuthenticationExceptions";
NSString * const NSObjectInaccessibleException =
  @"NSObjectInaccessibleException";
NSString * const NSObjectNotAvailableException =
  @"NSObjectNotAvailableException";

/*
 * Cache various class pointers.
 */
static id	dummyObject;
static Class	connectionClass;
static Class	dateClass;
static Class	distantObjectClass;
static Class	sendCoderClass;
static Class	recvCoderClass;
static Class	runLoopClass;

static NSString*
stringFromMsgType(int type)
{
  switch (type)
    {
      case METHOD_REQUEST:
    NSLog(@"Returning from method at line: return @"method request";");
	return @"method request";
      case METHOD_REPLY:
    NSLog(@"Returning from method at line: return @"method reply";");
	return @"method reply";
      case ROOTPROXY_REQUEST:
    NSLog(@"Returning from method at line: return @"root proxy request";");
	return @"root proxy request";
      case ROOTPROXY_REPLY:
    NSLog(@"Returning from method at line: return @"root proxy reply";");
	return @"root proxy reply";
      case CONNECTION_SHUTDOWN:
    NSLog(@"Returning from method at line: return @"connection shutdown";");
	return @"connection shutdown";
      case METHODTYPE_REQUEST:
    NSLog(@"Returning from method at line: return @"methodtype request";");
	return @"methodtype request";
      case METHODTYPE_REPLY:
    NSLog(@"Returning from method at line: return @"methodtype reply";");
	return @"methodtype reply";
      case PROXY_RELEASE:
    NSLog(@"Returning from method at line: return @"proxy release";");
	return @"proxy release";
      case PROXY_RETAIN:
    NSLog(@"Returning from method at line: return @"proxy retain";");
	return @"proxy retain";
      case RETAIN_REPLY:
    NSLog(@"Returning from method at line: return @"retain replay";");
	return @"retain replay";
      default:
    NSLog(@"Returning from method at line: return @"unknown operation type!";");
	return @"unknown operation type!";
    }
}



/*
 * CachedLocalObject is a trivial class to keep track of local
 * proxies which have been removed from their connections and
 * need to persist a while in case another process needs them.
 */
@interface	CachedLocalObject : NSObject
{
  NSDistantObject	*obj;
  int			time;
}
- (BOOL) countdown;
    NSLog(@"Entering - (BOOL) countdown;");
- (NSDistantObject*) obj;
    NSLog(@"Entering - (NSDistantObject*) obj;");
+ (id) newWithObject: (NSDistantObject*)o time: (int)t;
    NSLog(@"Entering + (id) newWithObject: (NSDistantObject*)o time: (int)t;");
@end

@implementation	CachedLocalObject

+ (id) newWithObject: (NSDistantObject*)o time: (int)t
    NSLog(@"Entering + (id) newWithObject: (NSDistantObject*)o time: (int)t");
{
  CachedLocalObject	*item;

  item = (CachedLocalObject*)NSAllocateObject(self, 0, NSDefaultMallocZone());
    NSLog(@"item changed to %@;", item);
  item->obj = RETAIN(o);
    NSLog(@"obj changed to %@;", obj);
  item->time = t;
    NSLog(@"time changed to %@;", time);
    NSLog(@"Returning from method at line: return item;");
  return item;
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  RELEASE(obj);
  [super dealloc];
}

- (BOOL) countdown
    NSLog(@"Entering - (BOOL) countdown");
{
  if (time-- > 0)
    NSLog(@"Returning from method at line: return YES;");
    return YES;
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (NSDistantObject*) obj
    NSLog(@"Entering - (NSDistantObject*) obj");
{
    NSLog(@"Returning from method at line: return obj;");
  return obj;
}

@end



/** <ignore> */

#define	GSInternal	NSConnectionInternal
#include	"GSInternal.h"
GS_PRIVATE_INTERNAL(NSConnection)

#define	IisValid		(internal->_isValid)
#define	IindependentQueueing	(internal->_independentQueueing)
#define	IauthenticateIn		(internal->_authenticateIn)
#define	IauthenticateOut	(internal->_authenticateOut)
#define	ImultipleThreads	(internal->_multipleThreads)
#define	IshuttingDown		(internal->_shuttingDown)
#define	IuseKeepalive		(internal->_useKeepalive)
#define	IkeepaliveWait		(internal->_keepaliveWait)
#define	IreceivePort		(internal->_receivePort)
#define	IsendPort		(internal->_sendPort)
#define	IrequestDepth		(internal->_requestDepth)
#define	ImessageCount		(internal->_messageCount)
#define	IreqOutCount		(internal->_reqOutCount)
#define	IreqInCount		(internal->_reqInCount)
#define	IrepOutCount		(internal->_repOutCount)
#define	IrepInCount		(internal->_repInCount)
#define	IlocalObjects		(internal->_localObjects)
#define	IlocalTargets		(internal->_localTargets)
#define	IremoteProxies		(internal->_remoteProxies)
#define	IreplyMap		(internal->_replyMap)
#define	IreplyTimeout		(internal->_replyTimeout)
#define	IrequestTimeout		(internal->_requestTimeout)
#define	IrequestModes		(internal->_requestModes)
#define	IrunLoops		(internal->_runLoops)
#define	IrequestQueue		(internal->_requestQueue)
#define	Idelegate		(internal->_delegate)
#define	IrefGate		(internal->_refGate)
#define	IcachedDecoders		(internal->_cachedDecoders)
#define	IcachedEncoders		(internal->_cachedEncoders)
#define	IremoteName		(internal->_remoteName)
#define	IregisteredName		(internal->_registeredName)
#define	InameServer		(internal->_nameServer)
#define	IlastKeepalive		(internal->_lastKeepalive)

/** </ignore> */

@interface NSConnection(Private)

- (void) handlePortMessage: (NSPortMessage*)msg;
    NSLog(@"Entering - (void) handlePortMessage: (NSPortMessage*)msg;");
- (void) _runInNewThread;
    NSLog(@"Entering - (void) _runInNewThread;");
+ (int) setDebug: (int)val;
    NSLog(@"Entering + (int) setDebug: (int)val;");
- (void) _enableKeepalive;
    NSLog(@"Entering - (void) _enableKeepalive;");

- (void) addLocalObject: (NSDistantObject*)anObj;
    NSLog(@"Entering - (void) addLocalObject: (NSDistantObject*)anObj;");
- (void) removeLocalObject: (NSDistantObject*)anObj;
    NSLog(@"Entering - (void) removeLocalObject: (NSDistantObject*)anObj;");

- (void) _doneInReply: (NSPortCoder*)c;
    NSLog(@"Entering - (void) _doneInReply: (NSPortCoder*)c;");
- (void) _doneInRmc: (NSPortCoder*)c;
    NSLog(@"Entering - (void) _doneInRmc: (NSPortCoder*)c;");
- (void) _failInRmc: (NSPortCoder*)c;
    NSLog(@"Entering - (void) _failInRmc: (NSPortCoder*)c;");
- (void) _failOutRmc: (NSPortCoder*)c;
    NSLog(@"Entering - (void) _failOutRmc: (NSPortCoder*)c;");
- (NSPortCoder*) _getReplyRmc: (int)sn for: (const char*)request;
    NSLog(@"Entering - (NSPortCoder*) _getReplyRmc: (int)sn for: (const char*)request;");
- (NSPortCoder*) _newInRmc: (NSMutableArray*)components;
    NSLog(@"Entering - (NSPortCoder*) _newInRmc: (NSMutableArray*)components;");
- (NSPortCoder*) _newOutRmc: (int)sequence generate: (int*)sno reply: (BOOL)f;
    NSLog(@"Entering - (NSPortCoder*) _newOutRmc: (int)sequence generate: (int*)sno reply: (BOOL)f;");
- (void) _portIsInvalid: (NSNotification*)notification;
    NSLog(@"Entering - (void) _portIsInvalid: (NSNotification*)notification;");
- (void) _sendOutRmc: (NSPortCoder*) NS_CONSUMED c
    NSLog(@"Entering - (void) _sendOutRmc: (NSPortCoder*) NS_CONSUMED c");
                type: (int)msgid
            sequence: (int)sno;

- (void) _service_forwardForProxy: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_forwardForProxy: (NSPortCoder*)rmc;");
- (void) _service_release: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_release: (NSPortCoder*)rmc;");
- (void) _service_retain: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_retain: (NSPortCoder*)rmc;");
- (void) _service_rootObject: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_rootObject: (NSPortCoder*)rmc;");
- (void) _service_shutdown: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_shutdown: (NSPortCoder*)rmc;");
- (void) _service_typeForSelector: (NSPortCoder*)rmc;
    NSLog(@"Entering - (void) _service_typeForSelector: (NSPortCoder*)rmc;");
- (void) _shutdown;
    NSLog(@"Entering - (void) _shutdown;");
+ (void) _threadWillExit: (NSNotification*)notification;
    NSLog(@"Entering + (void) _threadWillExit: (NSNotification*)notification;");
@end



/* class defaults */
static NSTimer		*timer = nil;
    NSLog(@"timer changed to %@;", timer);

static BOOL cacheCoders = NO;
    NSLog(@"cacheCoders changed to %@;", cacheCoders);
static int debug_connection = 0;
    NSLog(@"debug_connection changed to %@;", debug_connection);

static NSHashTable	*connection_table;
static GSLazyRecursiveLock		*connection_table_gate = nil;
    NSLog(@"connection_table_gate changed to %@;", connection_table_gate);

/*
 * Locate an existing connection with the specified send and receive ports.
    NSLog(@"Returning from method at line: * nil ports act as wildcards and return the first match.");
 * nil ports act as wildcards and return the first match.
 */
static NSConnection*
existingConnection(NSPort *receivePort, NSPort *sendPort)
{
  NSHashEnumerator	enumerator;
  NSConnection		*c;

  GS_F_LOCK(connection_table_gate);
  enumerator = NSEnumerateHashTable(connection_table);
    NSLog(@"enumerator changed to %@;", enumerator);
  while ((c = (NSConnection*)NSNextHashEnumeratorItem(&enumerator)) != nil)
    {
      if ((sendPort == nil || [sendPort isEqual: [c sendPort]])
        && (receivePort == nil || [receivePort isEqual: [c receivePort]]))
	{
	  /*
	   * We don't want this connection to be destroyed by another thread
    NSLog(@"Returning from method at line: * between now and when it's returned from this function and used!");
	   * between now and when it's returned from this function and used!
	   */
	  IF_NO_GC([[c retain] autorelease];)
	  break;
	}
    }
  NSEndHashTableEnumeration(&enumerator);
  GS_F_UNLOCK(connection_table_gate);
    NSLog(@"Returning from method at line: return c;");
  return c;
}

static NSMapTable *root_object_map;
static NSLock *root_object_map_gate = nil;
    NSLog(@"root_object_map_gate changed to %@;", root_object_map_gate);

static id
rootObjectForInPort(NSPort *aPort)
{
  id	rootObject;

  GS_F_LOCK(root_object_map_gate);
  rootObject = (id)NSMapGet(root_object_map, (void*)(uintptr_t)aPort);
    NSLog(@"rootObject changed to %@;", rootObject);
  GS_F_UNLOCK(root_object_map_gate);
    NSLog(@"Returning from method at line: return rootObject;");
  return rootObject;
}

/* Pass nil to remove any reference keyed by aPort. */
static void
setRootObjectForInPort(id anObj, NSPort *aPort)
{
  id	oldRootObject;

  GS_F_LOCK(root_object_map_gate);
  oldRootObject = (id)NSMapGet(root_object_map, (void*)(uintptr_t)aPort);
    NSLog(@"oldRootObject changed to %@;", oldRootObject);
  if (oldRootObject != anObj)
    {
      if (anObj != nil)
	{
	  NSMapInsert(root_object_map, (void*)(uintptr_t)aPort,
	    (void*)(uintptr_t)anObj);
	}
      else /* anObj == nil && oldRootObject != nil */
	{
	  NSMapRemove(root_object_map, (void*)(uintptr_t)aPort);
	}
    }
  GS_F_UNLOCK(root_object_map_gate);
}

static NSMapTable *targetToCached = NULL;
    NSLog(@"targetToCached changed to %@;", targetToCached);
static NSLock	*cached_proxies_gate = nil;
    NSLog(@"cached_proxies_gate changed to %@;", cached_proxies_gate);




/**
 * NSConnection objects are used to manage communications between
 * objects in different processes, in different machines, or in
 * different threads.
 */
@implementation NSConnection

/**
 * Returns an array containing all the NSConnection objects known to
 * the system. These connections will be valid at the time that the
 * array was created, but may be invalidated by other threads
 * before you get to examine the array.
 */
+ (NSArray*) allConnections
    NSLog(@"Entering + (NSArray*) allConnections");
{
  NSArray	*a;

  GS_M_LOCK(connection_table_gate);
  a = NSAllHashTableObjects(connection_table);
    NSLog(@"a changed to %@;", a);
  GSM_UNLOCK(connection_table_gate);
    NSLog(@"Returning from method at line: return a;");
  return a;
}

/**
 * Returns a connection initialised using -initWithReceivePort:sendPort:<br />
 * Both ports must be of the same type.
 */
+ (NSConnection*) connectionWithReceivePort: (NSPort*)r
    NSLog(@"Entering + (NSConnection*) connectionWithReceivePort: (NSPort*)r");
				   sendPort: (NSPort*)s
{
  NSConnection	*c = existingConnection(r, s);
    NSLog(@"c changed to %@;", c);

  if (c == nil)
    {
      c = [self allocWithZone: NSDefaultMallocZone()];
    NSLog(@"c changed to %@;", c);
      c = [c initWithReceivePort: r sendPort: s];
    NSLog(@"c changed to %@;", c);
      IF_NO_GC([c autorelease];)
    }
    NSLog(@"Returning from method at line: return c;");
  return c;
}

/**
 * <p>Returns an NSConnection object whose send port is that of the
 * NSConnection registered under the name n on the host h
 * </p>
 * <p>This method calls +connectionWithRegisteredName:host:usingNameServer:
 * using the default system name server.
 * </p>
 * <p>Use [NSSocketPortNameServer] for connections to remote hosts.
 * </p>
 */
+ (NSConnection*) connectionWithRegisteredName: (NSString*)n
    NSLog(@"Entering + (NSConnection*) connectionWithRegisteredName: (NSString*)n");
					  host: (NSString*)h
{
  NSPortNameServer	*s;

  s = [NSPortNameServer systemDefaultPortNameServer];
    NSLog(@"s changed to %@;", s);
    NSLog(@"Returning from method at line: return [self connectionWithRegisteredName: n");
  return [self connectionWithRegisteredName: n
				       host: h
			    usingNameServer: s];
}

/**
 * <p>
 *   Returns an NSConnection object whose send port is that of the
 *   NSConnection registered under <em>name</em> on <em>host</em>.
 * </p>
 * <p>
 *   The nameserver <em>server</em> is used to look up the send
 *   port to be used for the connection.<br />
 *   Use [NSSocketPortNameServer+sharedInstance]
 *   for connections to remote hosts.
 * </p>
 * <p>
 *   If <em>host</em> is <code>nil</code> or an empty string,
 *   the host is taken to be the local machine.<br />
 *   If it is an asterisk ('*') then the nameserver checks all
 *   hosts on the local subnet (unless the nameserver is one
 *   that only manages local ports).<br />
 *   In the GNUstep implementation, the local host is searched before
 *   any other hosts.<br />
 *   NB. if the nameserver does not support connections to remote hosts
 *   (the default situation) the host argeument should be omitted.
 * </p>
 * <p>
 *   If no NSConnection can be found for <em>name</em> and
    NSLog(@"Returning from method at line: *   <em>host</em>host, the method returns <code>nil</code>.");
 *   <em>host</em>host, the method returns <code>nil</code>.
 * </p>
 * <p>
    NSLog(@"Returning from method at line: *   The returned object has the default NSConnection of the");
 *   The returned object has the default NSConnection of the
 *   current thread as its parent (it has the same receive port
 *   as the default connection).
 * </p>
 */
+ (NSConnection*) connectionWithRegisteredName: (NSString*)n
    NSLog(@"Entering + (NSConnection*) connectionWithRegisteredName: (NSString*)n");
					  host: (NSString*)h
			       usingNameServer: (NSPortNameServer*)s
{
  NSConnection		*con = nil;
    NSLog(@"con changed to %@;", con);

  if (s != nil)
    {
      NSPort	*sendPort = [s portForName: n onHost: h];
    NSLog(@"sendPort changed to %@;", sendPort);

      if (sendPort != nil)
	{
	  NSPort	*recvPort;

	  recvPort = [[self defaultConnection] receivePort];
    NSLog(@"recvPort changed to %@;", recvPort);
	  if (recvPort == sendPort)
	    {
	      /*
	       * If the receive and send port are the same, the server
	       * must be in this process - so we need to create a new
	       * connection to talk to it.
	       */
	      recvPort = [NSPort port];
    NSLog(@"recvPort changed to %@;", recvPort);
	    }
	  else if (![recvPort isMemberOfClass: [sendPort class]])
	    {
	      /*
	      We can only use the port of the default connection for
	      connections using the same port class. For other port classes,
	      we must use a receiving port of the same class as the sending
	      port, so we allocate one here.
	      */
	      recvPort = [[sendPort class] port];
    NSLog(@"recvPort changed to %@;", recvPort);
	    }

	  con = existingConnection(recvPort, sendPort);
    NSLog(@"con changed to %@;", con);
	  if (con == nil)
	    {
	      con = [self connectionWithReceivePort: recvPort
					   sendPort: sendPort];
	    }
	  ASSIGNCOPY(GSIVar(con, _remoteName), n);
	}
    }
    NSLog(@"Returning from method at line: return con;");
  return con;
}

/**
 * Return the current conversation ... not implemented in GNUstep
 */
+ (id) currentConversation
    NSLog(@"Entering + (id) currentConversation");
{
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}

/**
 * Returns the default connection for a thread.<br />
 * Creates a new instance if necessary.<br />
 * The default connection has a single NSPort object used for
 * both sending and receiving - this it can't be used to
 * connect to a remote process, but can be used to vend objects.<br />
 * Possible problem - if the connection is invalidated, it won't be
 * cleaned up until this thread calls this method again.  The connection
 * and it's ports could hang around for a very long time.
 */
+ (NSConnection*) defaultConnection
    NSLog(@"Entering + (NSConnection*) defaultConnection");
{
  static NSString	*tkey = @"NSConnectionThreadKey";
    NSLog(@"tkey changed to %@;", tkey);
  NSConnection		*c;
  NSMutableDictionary	*d;

  d = GSCurrentThreadDictionary();
    NSLog(@"d changed to %@;", d);
  c = (NSConnection*)[d objectForKey: tkey];
    NSLog(@"c changed to %@;", c);
  if (c != nil && [c isValid] == NO)
    {
      /*
       * If the default connection for this thread has been invalidated -
       * release it and create a new one.
       */
      [d removeObjectForKey: tkey];
      c = nil;
    NSLog(@"c changed to %@;", c);
    }
  if (c == nil)
    {
      NSPort	*port;

      c = [self alloc];
    NSLog(@"c changed to %@;", c);
      port = [NSPort port];
    NSLog(@"port changed to %@;", port);
      c = [c initWithReceivePort: port sendPort: nil];
    NSLog(@"c changed to %@;", c);
      if (c != nil)
	{
	  [d setObject: c forKey: tkey];
	  RELEASE(c);
	}
    }
    NSLog(@"Returning from method at line: return c;");
  return c;
}

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  if (connectionClass == nil)
    {
      NSNotificationCenter	*nc;

      GSMakeWeakPointer(self, "delegate");
      connectionClass = self;
    NSLog(@"connectionClass changed to %@;", connectionClass);
      dateClass = [NSDate class];
    NSLog(@"dateClass changed to %@;", dateClass);
      distantObjectClass = [NSDistantObject class];
    NSLog(@"distantObjectClass changed to %@;", distantObjectClass);
      sendCoderClass = [NSPortCoder class];
    NSLog(@"sendCoderClass changed to %@;", sendCoderClass);
      recvCoderClass = [NSPortCoder class];
    NSLog(@"recvCoderClass changed to %@;", recvCoderClass);
      runLoopClass = [NSRunLoop class];
    NSLog(@"runLoopClass changed to %@;", runLoopClass);

      dummyObject = [NSObject new];
    NSLog(@"dummyObject changed to %@;", dummyObject);
      [[NSObject leakAt: &dummyObject] release];

      connection_table =
	NSCreateHashTable(NSNonRetainedObjectHashCallBacks, 0);
      [[NSObject leakAt: &connection_table] release];

      targetToCached =
	NSCreateMapTable(NSIntegerMapKeyCallBacks,
	  NSObjectMapValueCallBacks, 0);
      [[NSObject leakAt: &targetToCached] release];

      root_object_map =
	NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks,
	  NSObjectMapValueCallBacks, 0);
      [[NSObject leakAt: &root_object_map] release];

      if (connection_table_gate == nil)
	{
	  connection_table_gate = [GSLazyRecursiveLock new];
    NSLog(@"connection_table_gate changed to %@;", connection_table_gate);
          [[NSObject leakAt: &connection_table_gate] release];
	}
      if (cached_proxies_gate == nil)
	{
	  cached_proxies_gate = [GSLazyLock new];
    NSLog(@"cached_proxies_gate changed to %@;", cached_proxies_gate);
          [[NSObject leakAt: &cached_proxies_gate] release];
	}
      if (root_object_map_gate == nil)
	{
	  root_object_map_gate = [GSLazyLock new];
    NSLog(@"root_object_map_gate changed to %@;", root_object_map_gate);
          [[NSObject leakAt: &root_object_map_gate] release];
	}

      /*
       * When any thread exits, we must check to see if we are using its
       * runloop, and remove ourselves from it if necessary.
       */
      nc = [NSNotificationCenter defaultCenter];
    NSLog(@"nc changed to %@;", nc);
      [nc addObserver: self
	     selector: @selector(_threadWillExit:)
		 name: NSThreadWillExitNotification
	       object: nil];
    }
}

/**
 * Undocumented feature for compatibility with OPENSTEP/MacOS-X
    NSLog(@"Returning from method at line: * +new returns the default connection.");
 * +new returns the default connection.
 */
+ (id) new
    NSLog(@"Entering + (id) new");
{
    NSLog(@"Returning from method at line: return RETAIN([self defaultConnection]);");
  return RETAIN([self defaultConnection]);
}

/**
 * This method calls
 * +rootProxyForConnectionWithRegisteredName:host:usingNameServer:
    NSLog(@"Returning from method at line: * to return a proxy for a root object on the remote connection with");
 * to return a proxy for a root object on the remote connection with
 * the send port registered under name n on host h.
 */
+ (NSDistantObject*) rootProxyForConnectionWithRegisteredName: (NSString*)n
    NSLog(@"Entering + (NSDistantObject*) rootProxyForConnectionWithRegisteredName: (NSString*)n");
						         host: (NSString*)h
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
    NSLog(@"arp changed to %@;", arp);
  NSConnection		*connection;
  NSDistantObject	*proxy = nil;
    NSLog(@"proxy changed to %@;", proxy);

  connection = [self connectionWithRegisteredName: n host: h];
    NSLog(@"connection changed to %@;", connection);
  if (connection != nil)
    {
      proxy = [[connection rootProxy] retain];
    NSLog(@"proxy changed to %@;", proxy);
    }
  [arp drain];
    NSLog(@"Returning from method at line: return [proxy autorelease];");
  return [proxy autorelease];
}

/**
 * This method calls
 * +connectionWithRegisteredName:host:usingNameServer:
 * to get a connection, then sends it a -rootProxy message to get
 * a proxy for the root object being vended by the remote connection.
 * Returns the proxy or nil if it couldn't find a connection or if
 * the root object for the connection has not been set.<br />
 * Use [NSSocketPortNameServer+sharedInstance]
 * for connections to remote hosts.
 */
+ (NSDistantObject*) rootProxyForConnectionWithRegisteredName: (NSString*)n
    NSLog(@"Entering + (NSDistantObject*) rootProxyForConnectionWithRegisteredName: (NSString*)n");
  host: (NSString*)h usingNameServer: (NSPortNameServer*)s
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
    NSLog(@"arp changed to %@;", arp);
  NSConnection		*connection;
  NSDistantObject	*proxy = nil;
    NSLog(@"proxy changed to %@;", proxy);

  connection = [self connectionWithRegisteredName: n
					     host: h
				  usingNameServer: s];
  if (connection != nil)
    {
      proxy = RETAIN([connection rootProxy]);
    NSLog(@"proxy changed to %@;", proxy);
    }
  [arp drain];
    NSLog(@"Returning from method at line: return AUTORELEASE(proxy);");
  return AUTORELEASE(proxy);
}

+ (id) serviceConnectionWithName: (NSString *)name
    NSLog(@"Entering + (id) serviceConnectionWithName: (NSString *)name");
                      rootObject: (id)root
{
    NSLog(@"Returning from method at line: return [self serviceConnectionWithName: name");
  return [self serviceConnectionWithName: name
    rootObject: root
    usingNameServer: [NSPortNameServer systemDefaultPortNameServer]];
}

+ (id) serviceConnectionWithName: (NSString *)name
    NSLog(@"Entering + (id) serviceConnectionWithName: (NSString *)name");
                      rootObject: (id)root
                 usingNameServer: (NSPortNameServer *)server
{
  NSConnection  *c;
  NSPort        *p;

  if ([server isKindOfClass: [NSMessagePortNameServer class]] == YES)
    {
      p = [NSMessagePort port];
    NSLog(@"p changed to %@;", p);
    }
  else if ([server isKindOfClass: [NSSocketPortNameServer class]] == YES)
    {
      p = [NSSocketPort port];
    NSLog(@"p changed to %@;", p);
    }
  else
    {
      p = nil;
    NSLog(@"p changed to %@;", p);
    }

  c = [[NSConnection alloc] initWithReceivePort: p sendPort: nil];
    NSLog(@"c changed to %@;", c);
  [c setRootObject: root];
  if ([c registerName: name withNameServer: server] == NO)
    {
      DESTROY(c);
    }
    NSLog(@"Returning from method at line: return AUTORELEASE(c);");
  return AUTORELEASE(c);
}

+ (void) _timeout: (NSTimer*)t
    NSLog(@"Entering + (void) _timeout: (NSTimer*)t");
{
  NSArray	*cached_locals;
  int	i;

  GS_M_LOCK(cached_proxies_gate);
  cached_locals = NSAllMapTableValues(targetToCached);
    NSLog(@"cached_locals changed to %@;", cached_locals);
  for (i = [cached_locals count]; i > 0; i--)
    NSLog(@"i changed to %@;", i);
    {
      CachedLocalObject *item = [cached_locals objectAtIndex: i-1];
    NSLog(@"item changed to %@;", item);

      if ([item countdown] == NO)
	{
	  NSDistantObject	*obj = [item obj];
    NSLog(@"obj changed to %@;", obj);

	  NSMapRemove(targetToCached,
	    (void*)(uintptr_t)obj->_handle);
	}
    }
  if ([cached_locals count] == 0)
    {
      [t invalidate];
      timer = nil;
    NSLog(@"timer changed to %@;", timer);
    }
  GSM_UNLOCK(cached_proxies_gate);
}

/**
 * Adds mode to the run loop modes that the NSConnection
 * will listen to for incoming messages.
 */
- (void) addRequestMode: (NSString*)mode
    NSLog(@"Entering - (void) addRequestMode: (NSString*)mode");
{
  GS_M_LOCK(IrefGate);
  if ([self isValid] == YES)
    {
      if ([IrequestModes containsObject: mode] == NO)
	{
	  NSUInteger	c = [IrunLoops count];
    NSLog(@"c changed to %@;", c);

	  while (c-- > 0)
	    {
	      NSRunLoop	*loop = [IrunLoops objectAtIndex: c];
    NSLog(@"loop changed to %@;", loop);

	      [IreceivePort addConnection: self toRunLoop: loop forMode: mode];
	    }
	  [IrequestModes addObject: mode];
	}
    }
  GSM_UNLOCK(IrefGate);
}

/**
 * Adds loop to the set of run loops that the NSConnection
 * will listen to for incoming messages.
 */
- (void) addRunLoop: (NSRunLoop*)loop
    NSLog(@"Entering - (void) addRunLoop: (NSRunLoop*)loop");
{
  GS_M_LOCK(IrefGate);
  if ([self isValid] == YES)
    {
      if ([IrunLoops indexOfObjectIdenticalTo: loop] == NSNotFound)
	{
	  NSUInteger		c = [IrequestModes count];
    NSLog(@"c changed to %@;", c);

	  while (c-- > 0)
	    {
	      NSString	*mode = [IrequestModes objectAtIndex: c];
    NSLog(@"mode changed to %@;", mode);

	      [IreceivePort addConnection: self toRunLoop: loop forMode: mode];
	    }
	  [IrunLoops addObject: loop];
	}
    }
  GSM_UNLOCK(IrefGate);
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if (debug_connection)
    NSLog(@"deallocating %@", self);
  [self finalize];
  if (internal != nil)
    {
      GS_DESTROY_INTERNAL(NSConnection);
    }
  [super dealloc];
}

/**
 * Returns the delegate of the NSConnection.
 */
- (id) delegate
    NSLog(@"Entering - (id) delegate");
{
    NSLog(@"Returning from method at line: return Idelegate;");
  return Idelegate;
}

- (NSString*) description
    NSLog(@"Entering - (NSString*) description");
{
    NSLog(@"Returning from method at line: return [NSString stringWithFormat: @"%@ local: '%@',%@ remote '%@',%@",");
  return [NSString stringWithFormat: @"%@ local: '%@',%@ remote '%@',%@",
    [super description],
    IregisteredName ? (id)IregisteredName : (id)@"", [self receivePort],
    IremoteName ? (id)IremoteName : (id)@"", [self sendPort]];
}

/**
 * Sets the NSConnection configuration so that multiple threads may
 * use the connection to send requests to the remote connection.<br />
 * This option is inherited by child connections.<br />
 * NB. A connection with multiple threads enabled will run slower than
 * a normal connection.
 */
- (void) enableMultipleThreads
    NSLog(@"Entering - (void) enableMultipleThreads");
{
  ImultipleThreads = YES;
    NSLog(@"ImultipleThreads changed to %@;", ImultipleThreads);
}

/**
 * Returns YES if the NSConnection is configured to
 * handle remote messages atomically, NO otherwise.<br />
 * This option is inherited by child connections.
 */
- (BOOL) independentConversationQueueing
    NSLog(@"Entering - (BOOL) independentConversationQueueing");
{
    NSLog(@"Returning from method at line: return IindependentQueueing;");
  return IindependentQueueing;
}

/**
 * Return a connection able to act as a server receive incoming requests.
 */
- (id) init
    NSLog(@"Entering - (id) init");
{
  NSPort	*port = [NSPort port];
    NSLog(@"port changed to %@;", port);

  self = [self initWithReceivePort: port sendPort: nil];
    NSLog(@"self changed to %@;", self);
    NSLog(@"Returning from method at line: return self;");
  return self;
}

/** <init />
 * Initialises an NSConnection with the receive port r and the
 * send port s.<br />
 * Behavior varies with the port values as follows -
 * <deflist>
 *   <term>r is <code>nil</code></term>
 *   <desc>
    NSLog(@"Returning from method at line: *     The NSConnection is released and the method returns");
 *     The NSConnection is released and the method returns
 *     <code>nil</code>.
 *   </desc>
 *   <term>s is <code>nil</code></term>
 *   <desc>
 *     The NSConnection uses r as the send port as
 *     well as the receive port.
 *   </desc>
 *   <term>s is the same as r</term>
 *   <desc>
 *     The NSConnection is usable only for vending objects.
 *   </desc>
 *   <term>A connection with the same ports exists</term>
 *   <desc>
 *     The new connection is released and the old connection
    NSLog(@"Returning from method at line: *     is retained and returned.");
 *     is retained and returned.
 *   </desc>
 *   <term>A connection with the same ports (swapped) exists</term>
 *   <desc>
 *     The new connection is initialised as normal, and will
 *     communicate with the old connection.
 *   </desc>
 * </deflist>
 * <p>
 *   If a connection exists whose send and receive ports are
 *   both the same as the new connections receive port, that
 *   existing connection is deemed to be the parent of the
 *   new connection.  The new connection inherits configuration
 *   information from the parent, and the delegate of the
 *   parent has a chance to adjust the configuration of the
 *   new connection or veto its creation.
 *   <br/>
 *   NSConnectionDidInitializeNotification is posted once a new
 *   connection is initialised.
 * </p>
 */
- (id) initWithReceivePort: (NSPort*)r
    NSLog(@"Entering - (id) initWithReceivePort: (NSPort*)r");
		  sendPort: (NSPort*)s
{
  NSNotificationCenter	*nCenter;
  NSConnection		*parent;
  NSConnection		*conn;
  NSRunLoop		*loop;
  id			del;
  NSZone		*z;

  z = NSDefaultMallocZone();
    NSLog(@"z changed to %@;", z);
  /*
    NSLog(@"Returning from method at line: * If the receive port is nil, deallocate connection and return nil.");
   * If the receive port is nil, deallocate connection and return nil.
   */
  if (r == nil)
    {
      if (debug_connection > 2)
	{
	  NSLog(@"Asked to create connection with nil receive port");
	}
      DESTROY(self);
    NSLog(@"Returning from method at line: return self;");
      return self;
    }

  /*
   * If the send port is nil, set it to the same as the receive port
   * This connection will then only be useful to act as a server.
   */
  if (s == nil)
    {
      s = r;
    NSLog(@"s changed to %@;", s);
    }

  conn = existingConnection(r, s);
    NSLog(@"conn changed to %@;", conn);

  /*
   * If the send and receive ports match an existing connection
    NSLog(@"Returning from method at line: * deallocate the new one and retain and return the old one.");
   * deallocate the new one and retain and return the old one.
   */
  if (conn != nil)
    {
      DESTROY(self);
      self = RETAIN(conn);
    NSLog(@"self changed to %@;", self);
      if (debug_connection > 2)
	{
	  NSLog(@"Found existing connection (%@) for \n\t%@\n\t%@",
	    conn, r, s);
	}
    NSLog(@"Returning from method at line: return self;");
      return self;
    }

  /* Create our private data structure.
   */
  GS_CREATE_INTERNAL(NSConnection);

  /*
   * The parent connection is the one whose send and receive ports are
   * both the same as our receive port.
   */
  parent = existingConnection(r, r);
    NSLog(@"parent changed to %@;", parent);

  if (debug_connection)
    {
      NSLog(@"Initialising new connection with parent %@, %@\n  "
	@"Send: %@\n  Recv: %@", parent, self, s, r);
    }

  GS_M_LOCK(connection_table_gate);

  IisValid = YES;
    NSLog(@"IisValid changed to %@;", IisValid);
  IreceivePort = RETAIN(r);
    NSLog(@"IreceivePort changed to %@;", IreceivePort);
  IsendPort = RETAIN(s);
    NSLog(@"IsendPort changed to %@;", IsendPort);
  ImessageCount = 0;
    NSLog(@"ImessageCount changed to %@;", ImessageCount);
  IrepOutCount = 0;
    NSLog(@"IrepOutCount changed to %@;", IrepOutCount);
  IreqOutCount = 0;
    NSLog(@"IreqOutCount changed to %@;", IreqOutCount);
  IrepInCount = 0;
    NSLog(@"IrepInCount changed to %@;", IrepInCount);
  IreqInCount = 0;
    NSLog(@"IreqInCount changed to %@;", IreqInCount);

  /*
   * These arrays cache NSPortCoder objects
   */
  if (cacheCoders == YES)
    {
      IcachedDecoders = [NSMutableArray new];
    NSLog(@"IcachedDecoders changed to %@;", IcachedDecoders);
      IcachedEncoders = [NSMutableArray new];
    NSLog(@"IcachedEncoders changed to %@;", IcachedEncoders);
    }

  /*
   * This is used to queue up incoming NSPortMessages representing requests
   * that can't immediately be dealt with.
   */
  IrequestQueue = [NSMutableArray new];
    NSLog(@"IrequestQueue changed to %@;", IrequestQueue);

  /*
   * This maps request sequence numbers to the NSPortCoder objects representing
   * replies arriving from the remote connection.
   */
  IreplyMap = (GSIMapTable)NSZoneMalloc(z, sizeof(GSIMapTable_t));
    NSLog(@"IreplyMap changed to %@;", IreplyMap);
  GSIMapInitWithZoneAndCapacity(IreplyMap, z, 4);

  /*
   * This maps (void*)obj to (id)obj.  The obj's are retained.
   * We use this instead of an NSHashTable because we only care about
   * the object's address, and don't want to send the -hash message to it.
   */
  IlocalObjects
    = (GSIMapTable)NSZoneMalloc(z, sizeof(GSIMapTable_t));
  GSIMapInitWithZoneAndCapacity(IlocalObjects, z, 4);

  /*
   * This maps handles for local objects to their local proxies.
   */
  IlocalTargets
    = (GSIMapTable)NSZoneMalloc(z, sizeof(GSIMapTable_t));
  GSIMapInitWithZoneAndCapacity(IlocalTargets, z, 4);

  /*
   * This maps targets to remote proxies.
   */
  IremoteProxies
    = (GSIMapTable)NSZoneMalloc(z, sizeof(GSIMapTable_t));
  GSIMapInitWithZoneAndCapacity(IremoteProxies, z, 4);

  IrequestDepth = 0;
    NSLog(@"IrequestDepth changed to %@;", IrequestDepth);
  Idelegate = nil;
    NSLog(@"Idelegate changed to %@;", Idelegate);
  IrefGate = [GSLazyRecursiveLock new];
    NSLog(@"IrefGate changed to %@;", IrefGate);

  /*
   * Some attributes are inherited from the parent if possible.
   */
  if (parent != nil)
    {
      NSUInteger	count;

      ImultipleThreads = GSIVar(parent, _multipleThreads);
    NSLog(@"ImultipleThreads changed to %@;", ImultipleThreads);
      IindependentQueueing = GSIVar(parent, _independentQueueing);
    NSLog(@"IindependentQueueing changed to %@;", IindependentQueueing);
      IreplyTimeout = GSIVar(parent, _replyTimeout);
    NSLog(@"IreplyTimeout changed to %@;", IreplyTimeout);
      IrequestTimeout = GSIVar(parent, _requestTimeout);
    NSLog(@"IrequestTimeout changed to %@;", IrequestTimeout);
      IrunLoops = [GSIVar(parent, _runLoops) mutableCopy];
    NSLog(@"IrunLoops changed to %@;", IrunLoops);
      count = [GSIVar(parent, _requestModes) count];
    NSLog(@"count changed to %@;", count);
      IrequestModes
	= [[NSMutableArray alloc] initWithCapacity: count];
      while (count-- > 0)
	{
	  [self addRequestMode:
	    [GSIVar(parent, _requestModes) objectAtIndex: count]];
	}
      if (GSIVar(parent, _useKeepalive) == YES)
	{
	  [self _enableKeepalive];
	}
    }
  else
    {
      ImultipleThreads = NO;
    NSLog(@"ImultipleThreads changed to %@;", ImultipleThreads);
      IindependentQueueing = NO;
    NSLog(@"IindependentQueueing changed to %@;", IindependentQueueing);
      IreplyTimeout = 1.0E12;
    NSLog(@"IreplyTimeout changed to %@;", IreplyTimeout);
      IrequestTimeout = 1.0E12;
    NSLog(@"IrequestTimeout changed to %@;", IrequestTimeout);
      /*
       * Set up request modes array and make sure the receiving port
       * is added to the run loop to get data.
       */
      loop = GSRunLoopForThread(nil);
    NSLog(@"loop changed to %@;", loop);
      IrunLoops = [[NSMutableArray alloc] initWithObjects: &loop count: 1];
    NSLog(@"IrunLoops changed to %@;", IrunLoops);
      IrequestModes = [[NSMutableArray alloc] initWithCapacity: 2];
    NSLog(@"IrequestModes changed to %@;", IrequestModes);
      [self addRequestMode: NSDefaultRunLoopMode];
      [self addRequestMode: NSConnectionReplyMode];
      IuseKeepalive = NO;
    NSLog(@"IuseKeepalive changed to %@;", IuseKeepalive);

      /*
       * If we have no parent, we must handle incoming packets on our
       * receive port ourself - so we set ourself up as the port delegate.
       */
      [IreceivePort setDelegate: self];
    }

  /* Ask the delegate for permission, (OpenStep-style and GNUstep-style). */

    NSLog(@"Returning from method at line: /* Preferred MacOS-X version, which just allows the returning of BOOL */");
  /* Preferred MacOS-X version, which just allows the returning of BOOL */
  del = [parent delegate];
    NSLog(@"del changed to %@;", del);
  if ([del respondsToSelector: @selector(connection:shouldMakeNewConnection:)])
    {
      if ([del connection: parent shouldMakeNewConnection: self] == NO)
	{
	  GSM_UNLOCK(connection_table_gate);
	  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
	  return nil;
	}
    }
    NSLog(@"Returning from method at line: /* Deprecated OpenStep version, which just allows the returning of BOOL */");
  /* Deprecated OpenStep version, which just allows the returning of BOOL */
  if ([del respondsToSelector: @selector(makeNewConnection:sender:)])
    {
      if (![del makeNewConnection: self sender: parent])
	{
	  GSM_UNLOCK(connection_table_gate);
	  DESTROY(self);
    NSLog(@"Returning from method at line: return nil;");
	  return nil;
	}
    }
  /* Here is the GNUstep version, which allows the delegate to specify
     a substitute.  Note: The delegate is responsible for freeing
    NSLog(@"Returning from method at line: newConn if it returns something different. */");
     newConn if it returns something different. */
  if ([del respondsToSelector: @selector(connection:didConnect:)])
    {
      self = [del connection: parent didConnect: self];
    NSLog(@"self changed to %@;", self);
    }

  nCenter = [NSNotificationCenter defaultCenter];
    NSLog(@"nCenter changed to %@;", nCenter);
  /*
   * Register ourselves for invalidation notification when the
   * ports become invalid.
   */
  [nCenter addObserver: self
	      selector: @selector(_portIsInvalid:)
		  name: NSPortDidBecomeInvalidNotification
		object: r];
  if (s != nil)
    {
      [nCenter addObserver: self
		  selector: @selector(_portIsInvalid:)
		      name: NSPortDidBecomeInvalidNotification
		    object: s];
    }

  /* In order that connections may be deallocated - there is an
     implementation of [-release] to automatically remove the connection
     from this array when it is the only thing retaining it. */
  NSHashInsert(connection_table, (void*)self);
  GSM_UNLOCK(connection_table_gate);

  [nCenter postNotificationName: NSConnectionDidInitializeNotification
			 object: self];

    NSLog(@"Returning from method at line: return self;");
  return self;
}

/**
 * Marks the receiving NSConnection as invalid.
 * <br />
 * Removes the NSConnections ports from any run loops.
 * <br />
 * Posts an NSConnectionDidDieNotification.
 * <br />
 * Invalidates all remote objects and local proxies.
 */
- (void) invalidate
    NSLog(@"Entering - (void) invalidate");
{
  GS_M_LOCK(IrefGate);
  if (IisValid == NO)
    {
      GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (IshuttingDown == NO)
    {
      IshuttingDown = YES;
    NSLog(@"IshuttingDown changed to %@;", IshuttingDown);
      /*
       * Not invalidated as a result of a shutdown from the other end,
       * so tell the other end it must shut down.
       */
      //[self _shutdown];
    }
  IisValid = NO;
    NSLog(@"IisValid changed to %@;", IisValid);
  GS_M_LOCK(connection_table_gate);
  NSHashRemove(connection_table, self);
  GSM_UNLOCK(connection_table_gate);

  GSM_UNLOCK(IrefGate);

  /*
   * Don't need notifications any more - so remove self as observer.
   */
  [[NSNotificationCenter defaultCenter] removeObserver: self];

  /*
   * Make sure we are not registered.
   */
#if	!defined(_WIN32)
  if ([IreceivePort isKindOfClass: [NSMessagePort class]])
    {
      [self registerName: nil
	  withNameServer: [NSMessagePortNameServer sharedInstance]];
    }
  else
#endif
  if ([IreceivePort isKindOfClass: [NSSocketPort class]])
    {
      [self registerName: nil
	  withNameServer: [NSSocketPortNameServer sharedInstance]];
    }
  else
    {
      [self registerName: nil];
    }

  /*
   * Withdraw from run loops.
   */
  [self setRequestMode: nil];

  IF_NO_GC(RETAIN(self);)

  if (debug_connection)
    {
      NSLog(@"Invalidating connection %@", self);
    }
  /*
   * We need to notify any watchers of our death - but if we are already
   * in the deallocation process, we can't have a notification retaining
   * and autoreleasing us later once we are deallocated - so we do the
   * notification with a local autorelease pool to ensure that any release
   * is done before the deallocation completes.
   */
  {
    NSAutoreleasePool	*arp = [NSAutoreleasePool new];
    NSLog(@"arp changed to %@;", arp);

    [[NSNotificationCenter defaultCenter]
      postNotificationName: NSConnectionDidDieNotification
		    object: self];
    [arp drain];
  }

  /*
   *	If we have been invalidated, we don't need to retain proxies
   *	for local objects any more.  In fact, we want to get rid of
   *	these proxies in case they are keeping us retained when we
   *	might otherwise de deallocated.
   */
  GS_M_LOCK(IrefGate);
  if (IlocalTargets != 0)
    {
      NSMutableArray		*targets;
      NSUInteger		i = IlocalTargets->nodeCount;
    NSLog(@"i changed to %@;", i);
      GSIMapEnumerator_t	enumerator;
      GSIMapNode 		node;

      targets = [[NSMutableArray alloc] initWithCapacity: i];
    NSLog(@"targets changed to %@;", targets);
      enumerator = GSIMapEnumeratorForMap(IlocalTargets);
    NSLog(@"enumerator changed to %@;", enumerator);
      node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
      while (node != 0)
	{
	  [targets addObject: node->value.obj];
	  node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
	}
      while (i-- > 0)
	{
	  [self removeLocalObject: [targets objectAtIndex: i]];
	}
      RELEASE(targets);
      GSIMapEmptyMap(IlocalTargets);
      NSZoneFree(IlocalTargets->zone, (void*)IlocalTargets);
      IlocalTargets = 0;
    NSLog(@"IlocalTargets changed to %@;", IlocalTargets);
    }
  if (IremoteProxies != 0)
    {
      GSIMapEmptyMap(IremoteProxies);
      NSZoneFree(IremoteProxies->zone, (void*)IremoteProxies);
      IremoteProxies = 0;
    NSLog(@"IremoteProxies changed to %@;", IremoteProxies);
    }
  if (IlocalObjects != 0)
    {
      GSIMapEnumerator_t	enumerator;
      GSIMapNode 		node;

      enumerator = GSIMapEnumeratorForMap(IlocalObjects);
    NSLog(@"enumerator changed to %@;", enumerator);
      node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);

      while (node != 0)
	{
	  RELEASE(node->key.obj);
	  node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
	}
      GSIMapEmptyMap(IlocalObjects);
      NSZoneFree(IlocalObjects->zone, (void*)IlocalObjects);
      IlocalObjects = 0;
    NSLog(@"IlocalObjects changed to %@;", IlocalObjects);
    }
  GSM_UNLOCK(IrefGate);

  /*
   * If we are invalidated, we shouldn't be receiving any event and
   * should not need to be in any run loops.
   */
  while ([IrunLoops count] > 0)
    {
      [self removeRunLoop: [IrunLoops lastObject]];
    }

  /*
   * Invalidate the current conversation so we don't leak.
   */
  if ([IsendPort isValid] == YES)
    {
      [[IsendPort conversation: IreceivePort] invalidate];
    }

  RELEASE(self);
}

/**
 * Returns YES if the connection is valid, NO otherwise.
 * A connection is valid until it has been sent an -invalidate message.
 */
- (BOOL) isValid
    NSLog(@"Entering - (BOOL) isValid");
{
    NSLog(@"Returning from method at line: return IisValid;");
  return IisValid;
}

/**
 * Returns an array of all the local objects that have proxies at the
 * remote end of the connection because they have been sent over the
 * connection and not yet released by the far end.
 */
- (NSArray*) localObjects
    NSLog(@"Entering - (NSArray*) localObjects");
{
  NSArray	*a;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  if (IlocalObjects != 0)
    {

      GSIMapEnumerator_t	enumerator;
      GSIMapNode 		node;
      NSMutableArray            *c;

      enumerator = GSIMapEnumeratorForMap(IlocalObjects);
    NSLog(@"enumerator changed to %@;", enumerator);
      node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);

      c = [NSMutableArray arrayWithCapacity: IlocalObjects->nodeCount];
    NSLog(@"c changed to %@;", c);
      while (node != 0)
	{
	  [c addObject: node->key.obj];
	  node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
	}
      a = c;
    NSLog(@"a changed to %@;", a);
    }
  else
    {
      a = [NSArray array];
    NSLog(@"a changed to %@;", a);
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return a;");
  return a;
}

/**
 * Returns YES if the connection permits multiple threads to use it to
 * send requests, NO otherwise.<br />
 * See the -enableMultipleThreads method.
 */
- (BOOL) multipleThreadsEnabled
    NSLog(@"Entering - (BOOL) multipleThreadsEnabled");
{
    NSLog(@"Returning from method at line: return ImultipleThreads;");
  return ImultipleThreads;
}

/**
 * Returns the NSPort object on which incoming messages are received.
 */
- (NSPort*) receivePort
    NSLog(@"Entering - (NSPort*) receivePort");
{
    NSLog(@"Returning from method at line: return IreceivePort;");
  return IreceivePort;
}

/**
 * Simply invokes -registerName:withNameServer:
 * passing it the default system nameserver.
 */
- (BOOL) registerName: (NSString*)name
    NSLog(@"Entering - (BOOL) registerName: (NSString*)name");
{
  NSPortNameServer	*svr = [NSPortNameServer systemDefaultPortNameServer];
    NSLog(@"svr changed to %@;", svr);

    NSLog(@"Returning from method at line: return [self registerName: name withNameServer: svr];");
  return [self registerName: name withNameServer: svr];
}

/**
 * Registers the receive port of the NSConnection as name and
 * unregisters the previous value (if any).<br />
 * Returns YES on success, NO on failure.<br />
 * On failure, the connection remains registered under the
 * previous name.<br />
 * Supply nil as name to unregister the NSConnection.
 */
- (BOOL) registerName: (NSString*)name withNameServer: (NSPortNameServer*)svr
    NSLog(@"Entering - (BOOL) registerName: (NSString*)name withNameServer: (NSPortNameServer*)svr");
{
  BOOL			result = YES;
    NSLog(@"result changed to %@;", result);

  if (name != nil)
    {
      result = [svr registerPort: IreceivePort forName: name];
    NSLog(@"result changed to %@;", result);
    }
  if (result == YES)
    {
      if (IregisteredName != nil)
	{
	  [InameServer removePort: IreceivePort forName: IregisteredName];
	}
      ASSIGN(IregisteredName, name);
      ASSIGN(InameServer, svr);
    }
    NSLog(@"Returning from method at line: return result;");
  return result;
}

- (oneway void) release
    NSLog(@"Entering - (oneway void) release");
{
  /* We lock the connection table while checking, to prevent
   * another thread from grabbing this connection while we are
   * checking it.
   * If we are going to deallocate the object, we first remove
   * it from the table so that no other thread will find it
   * and try to use it while it is being deallocated.
   */
  GS_M_LOCK(connection_table_gate);
  if (NSDecrementExtraRefCountWasZero(self))
    {
      NSHashRemove(connection_table, self);
      GSM_UNLOCK(connection_table_gate);
      [self dealloc];
    }
  else
    {
      GSM_UNLOCK(connection_table_gate);
    }
}

/**
 * Returns an array of proxies to all the remote objects known to
 * the NSConnection.
 */
- (NSArray *) remoteObjects
    NSLog(@"Entering - (NSArray *) remoteObjects");
{
  NSMutableArray	*c;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  if (IremoteProxies != 0)
    {
      GSIMapEnumerator_t	enumerator;
      GSIMapNode 		node;

      enumerator = GSIMapEnumeratorForMap(IremoteProxies);
    NSLog(@"enumerator changed to %@;", enumerator);
      node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);

      c = [NSMutableArray arrayWithCapacity: IremoteProxies->nodeCount];
    NSLog(@"c changed to %@;", c);
      while (node != 0)
	{
	  [c addObject: node->key.obj];
	  node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
	}
    }
  else
    {
      c = [NSMutableArray array];
    NSLog(@"c changed to %@;", c);
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return c;");
  return c;
}

/**
 * Removes mode from the run loop modes used to receive incoming messages.
 */
- (void) removeRequestMode: (NSString*)mode
    NSLog(@"Entering - (void) removeRequestMode: (NSString*)mode");
{
  GS_M_LOCK(IrefGate);
  if (IrequestModes != nil && [IrequestModes containsObject: mode])
    {
      NSUInteger	c = [IrunLoops count];
    NSLog(@"c changed to %@;", c);

      while (c-- > 0)
	{
	  NSRunLoop	*loop = [IrunLoops objectAtIndex: c];
    NSLog(@"loop changed to %@;", loop);

	  [IreceivePort removeConnection: self
			     fromRunLoop: loop
				 forMode: mode];
	}
      [IrequestModes removeObject: mode];
    }
  GSM_UNLOCK(IrefGate);
}

/**
 * Removes loop from the run loops used to receive incoming messages.
 */
- (void) removeRunLoop: (NSRunLoop*)loop
    NSLog(@"Entering - (void) removeRunLoop: (NSRunLoop*)loop");
{
  GS_M_LOCK(IrefGate);
  if (IrunLoops != nil)
    {
      NSUInteger	pos = [IrunLoops indexOfObjectIdenticalTo: loop];
    NSLog(@"pos changed to %@;", pos);

      if (pos != NSNotFound)
	{
	  NSUInteger	c = [IrequestModes count];
    NSLog(@"c changed to %@;", c);

	  while (c-- > 0)
	    {
	      NSString	*mode = [IrequestModes objectAtIndex: c];
    NSLog(@"mode changed to %@;", mode);

	      [IreceivePort removeConnection: self
				 fromRunLoop: [IrunLoops objectAtIndex: pos]
				     forMode: mode];
	    }
	  [IrunLoops removeObjectAtIndex: pos];
	}
    }
  GSM_UNLOCK(IrefGate);
}

/**
 * Returns the timeout interval used when waiting for a reply to
 * a request sent on the NSConnection.  This value is inherited
 * from the parent connection or may be set using the -setReplyTimeout:
 * method.<br />
 * The default value is the maximum delay (effectively infinite).
 */
- (NSTimeInterval) replyTimeout
    NSLog(@"Entering - (NSTimeInterval) replyTimeout");
{
    NSLog(@"Returning from method at line: return IreplyTimeout;");
  return IreplyTimeout;
}

/**
 * Returns an array of all the run loop modes that the NSConnection
 * uses when waiting for an incoming request.
 */
- (NSArray*) requestModes
    NSLog(@"Entering - (NSArray*) requestModes");
{
  NSArray	*c;

  GS_M_LOCK(IrefGate);
  c = AUTORELEASE([IrequestModes copy]);
    NSLog(@"c changed to %@;", c);
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return c;");
  return c;
}

/**
 * Returns the timeout interval used when trying to send a request
 * on the NSConnection.  This value is inherited from the parent
 * connection or may be set using the -setRequestTimeout: method.<br />
 * The default value is the maximum delay (effectively infinite).
 */
- (NSTimeInterval) requestTimeout
    NSLog(@"Entering - (NSTimeInterval) requestTimeout");
{
    NSLog(@"Returning from method at line: return IrequestTimeout;");
  return IrequestTimeout;
}

/**
 * Returns the object that is made available by this connection
 * or by its parent (the object is associated with the receive port).<br />
 * Returns nil if no root object has been set.
 */
- (id) rootObject
    NSLog(@"Entering - (id) rootObject");
{
    NSLog(@"Returning from method at line: return rootObjectForInPort(IreceivePort);");
  return rootObjectForInPort(IreceivePort);
}

/**
 * Returns the proxy for the root object of the remote NSConnection.<br />
 * Generally you will wish to call [NSDistantObject-setProtocolForProxy:]
 * immediately after obtaining such a root proxy.
 */
- (NSDistantObject*) rootProxy
    NSLog(@"Entering - (NSDistantObject*) rootProxy");
{
  NSPortCoder		*op;
  NSPortCoder		*ip;
  NSDistantObject	*newProxy = nil;
    NSLog(@"newProxy changed to %@;", newProxy);
  int			seq_num;

  NSParameterAssert(IreceivePort);
  NSParameterAssert(IisValid);

  NS_DURING
    {
      /*
       * If this is a server connection without a remote end, its root proxy
       * is the same as its root object.
       */
      if (IreceivePort == IsendPort)
        {
    NSLog(@"Returning from method at line: return [self rootObject];");
          return [self rootObject];
        }
      op = [self _newOutRmc: 0 generate: &seq_num reply: YES];
    NSLog(@"op changed to %@;", op);
      [self _sendOutRmc: op type: ROOTPROXY_REQUEST sequence: seq_num];

      ip = [self _getReplyRmc: seq_num for: "rootproxy"];
    NSLog(@"ip changed to %@;", ip);
      [ip decodeValueOfObjCType: @encode(id) at: &newProxy];
      [self _doneInRmc: ip];
    }
  NS_HANDLER
    {
      /* The ports/connection may have been invalidated while getting the
    NSLog(@"Returning from method at line: * root proxy ... if so we should return nil.");
       * root proxy ... if so we should return nil.
       */
      newProxy = nil;
    NSLog(@"newProxy changed to %@;", newProxy);
    }
  NS_ENDHANDLER

    NSLog(@"Returning from method at line: return AUTORELEASE(newProxy);");
  return AUTORELEASE(newProxy);
}

/**
 * Removes the NSConnection from the current threads default
 * run loop, then creates a new thread and runs the NSConnection in it.
 */
- (void) runInNewThread
    NSLog(@"Entering - (void) runInNewThread");
{
  [self removeRunLoop: GSRunLoopForThread(nil)];
  [NSThread detachNewThreadSelector: @selector(_runInNewThread)
			   toTarget: self
			 withObject: nil];
}

/**
 * Returns the port on which the NSConnection sends messages.
 */
- (NSPort*) sendPort
    NSLog(@"Entering - (NSPort*) sendPort");
{
    NSLog(@"Returning from method at line: return IsendPort;");
  return IsendPort;
}

/**
 * Sets the NSConnection's delegate (without retaining it).<br />
 * The delegate is able to control some of the NSConnection's
 * behavior by implementing methods in an informal protocol.
 */
- (void) setDelegate: (id)anObj
    NSLog(@"Entering - (void) setDelegate: (id)anObj");
{
  Idelegate = anObj;
    NSLog(@"Idelegate changed to %@;", Idelegate);
  IauthenticateIn =
    [anObj respondsToSelector: @selector(authenticateComponents:withData:)];
  IauthenticateOut =
    [anObj respondsToSelector: @selector(authenticationDataForComponents:)];
}

/**
 * Sets whether or not the NSConnection should handle requests
 * arriving from the remote NSConnection atomically.<br />
 * By default, this is set to NO ... if set to YES then any messages
 * arriving while one message is being dealt with, will be queued.<br />
 * NB. careful - use of this option can cause deadlocks.
 */
- (void) setIndependentConversationQueueing: (BOOL)flag
    NSLog(@"Entering - (void) setIndependentConversationQueueing: (BOOL)flag");
{
  IindependentQueueing = flag;
    NSLog(@"IindependentQueueing changed to %@;", IindependentQueueing);
}

/**
 * Sets the time interval that the NSConnection will wait for a
 * reply for one of its requests before raising an
 * NSPortTimeoutException.<br />
 * NB. In GNUstep you may also get such an exception if the connection
 * becomes invalidated while waiting for a reply to a request.
 */
- (void) setReplyTimeout: (NSTimeInterval)to
    NSLog(@"Entering - (void) setReplyTimeout: (NSTimeInterval)to");
{
  if (to <= 0.0 || to > 1.0E12) to = 1.0E12;
    NSLog(@"to changed to %@;", to);
  IreplyTimeout = to;
    NSLog(@"IreplyTimeout changed to %@;", IreplyTimeout);
}

/**
 * Sets the runloop mode in which requests will be sent to the remote
 * end of the connection.  Normally this is NSDefaultRunloopMode
 */
- (void) setRequestMode: (NSString*)mode
    NSLog(@"Entering - (void) setRequestMode: (NSString*)mode");
{
  GS_M_LOCK(IrefGate);
  if (IrequestModes != nil)
    {
      while ([IrequestModes count] > 0
	&& [IrequestModes objectAtIndex: 0] != mode)
	{
	  [self removeRequestMode: [IrequestModes objectAtIndex: 0]];
	}
      while ([IrequestModes count] > 1)
	{
	  [self removeRequestMode: [IrequestModes objectAtIndex: 1]];
	}
      if (mode != nil && [IrequestModes count] == 0)
	{
	  [self addRequestMode: mode];
	}
    }
  GSM_UNLOCK(IrefGate);
}

/**
 * Sets the time interval that the NSConnection will wait to send
 * one of its requests before raising an NSPortTimeoutException.
 */
- (void) setRequestTimeout: (NSTimeInterval)to
    NSLog(@"Entering - (void) setRequestTimeout: (NSTimeInterval)to");
{
  if (to <= 0.0 || to > 1.0E12) to = 1.0E12;
    NSLog(@"to changed to %@;", to);
  IrequestTimeout = to;
    NSLog(@"IrequestTimeout changed to %@;", IrequestTimeout);
}

/**
 * Sets the root object that is vended by the connection.
 */
- (void) setRootObject: (id)anObj
    NSLog(@"Entering - (void) setRootObject: (id)anObj");
{
  setRootObjectForInPort(anObj, IreceivePort);
#if	defined(_WIN32)
  /* On ms-windows, the operating system does not inform us when the remote
   * client of a message port goes away ... so we need to enable keepalive
   * to detect that condition.
   */
  if ([IreceivePort isKindOfClass: [NSMessagePort class]])
    {
      [self _enableKeepalive];
    }
#endif
}

/**
 * Returns an object containing various statistics for the
 * NSConnection.
 * <br />
 * On GNUstep the dictionary contains -
 * <deflist>
 *   <term>NSConnectionRepliesReceived</term>
 *   <desc>
 *     The number of messages replied to by the remote NSConnection.
 *   </desc>
 *   <term>NSConnectionRepliesSent</term>
 *   <desc>
 *     The number of replies sent to the remote NSConnection.
 *   </desc>
 *   <term>NSConnectionRequestsReceived</term>
 *   <desc>
 *     The number of messages received from the remote NSConnection.
 *   </desc>
 *   <term>NSConnectionRequestsSent</term>
 *   <desc>
 *     The number of messages sent to the remote NSConnection.
 *   </desc>
 *   <term>NSConnectionLocalCount</term>
 *   <desc>
 *     The number of local objects currently vended.
 *   </desc>
 *   <term>NSConnectionProxyCount</term>
 *   <desc>
 *     The number of remote objects currently in use.
 *   </desc>
 * </deflist>
 */
- (NSDictionary*) statistics
    NSLog(@"Entering - (NSDictionary*) statistics");
{
  NSMutableDictionary	*d;
  id			o;

  d = [NSMutableDictionary dictionaryWithCapacity: 8];
    NSLog(@"d changed to %@;", d);

  GS_M_LOCK(IrefGate);

  /*
   *	These are in OPENSTEP 4.2
   */
  o = [NSNumber numberWithUnsignedInt: IrepInCount];
    NSLog(@"o changed to %@;", o);
  [d setObject: o forKey: NSConnectionRepliesReceived];
  o = [NSNumber numberWithUnsignedInt: IrepOutCount];
    NSLog(@"o changed to %@;", o);
  [d setObject: o forKey: NSConnectionRepliesSent];
  o = [NSNumber numberWithUnsignedInt: IreqInCount];
    NSLog(@"o changed to %@;", o);
  [d setObject: o forKey: NSConnectionRequestsReceived];
  o = [NSNumber numberWithUnsignedInt: IreqOutCount];
    NSLog(@"o changed to %@;", o);
  [d setObject: o forKey: NSConnectionRequestsSent];

  /*
   *	These are GNUstep extras
   */
  o = [NSNumber numberWithUnsignedInt:
    IlocalTargets ? IlocalTargets->nodeCount : 0];
  [d setObject: o forKey: NSConnectionLocalCount];
  o = [NSNumber numberWithUnsignedInt:
    IremoteProxies ? IremoteProxies->nodeCount : 0];
  [d setObject: o forKey: NSConnectionProxyCount];
  o = [NSNumber numberWithUnsignedInt:
    IreplyMap ? IreplyMap->nodeCount : 0];
  [d setObject: o forKey: @"NSConnectionReplyQueue"];
  o = [NSNumber numberWithUnsignedInt: [IrequestQueue count]];
    NSLog(@"o changed to %@;", o);
  [d setObject: o forKey: @"NSConnectionRequestQueue"];

  GSM_UNLOCK(IrefGate);

    NSLog(@"Returning from method at line: return d;");
  return d;
}

@end



@implementation	NSConnection (GNUstepExtensions)

+ (NSConnection*) newRegisteringAtName: (NSString*)name
    NSLog(@"Entering + (NSConnection*) newRegisteringAtName: (NSString*)name");
			withRootObject: (id)anObject
{
  NSConnection	*conn;

  GSOnceMLog(@"This method is deprecated, use standard initialisation");

  conn = [[self alloc] initWithReceivePort: [NSPort port]
				  sendPort: nil];
  [conn setRootObject: anObject];
  if ([conn registerName: name] == NO)
    {
      DESTROY(conn);
    }
    NSLog(@"Returning from method at line: return conn;");
  return conn;
}

- (void) finalize
    NSLog(@"Entering - (void) finalize");
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
    NSLog(@"arp changed to %@;", arp);

  if (debug_connection)
    NSLog(@"finalising %@", self);

  [self invalidate];

  /* Remove rootObject from root_object_map if this is last connection */
  if (IreceivePort != nil && existingConnection(IreceivePort, nil) == nil)
    {
      setRootObjectForInPort(nil, IreceivePort);
    }

  /* Remove receive port from run loop. */
  [self setRequestMode: nil];

  DESTROY(IrequestModes);
  DESTROY(IrunLoops);

  /*
   * Finished with ports - releasing them may generate a notification
   * If we are the receive port delagate, try to shift responsibility.
   */
  if ([IreceivePort delegate] == self)
    {
      NSConnection	*root = existingConnection(IreceivePort, IreceivePort);
    NSLog(@"root changed to %@;", root);

      if (root == nil)
	{
	  root =  existingConnection(IreceivePort, nil);
    NSLog(@"root changed to %@;", root);
	}
      [IreceivePort setDelegate: root];
    }
  DESTROY(IreceivePort);
  DESTROY(IsendPort);

  DESTROY(IrequestQueue);
  if (IreplyMap != 0)
    {
      GSIMapEnumerator_t	enumerator;
      GSIMapNode 		node;

      enumerator = GSIMapEnumeratorForMap(IreplyMap);
    NSLog(@"enumerator changed to %@;", enumerator);
      node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);

      while (node != 0)
	{
	  if (node->value.obj != dummyObject)
	    {
	      RELEASE(node->value.obj);
	    }
	  node = GSIMapEnumeratorNextNode(&enumerator);
    NSLog(@"node changed to %@;", node);
	}
      GSIMapEmptyMap(IreplyMap);
      NSZoneFree(IreplyMap->zone, (void*)IreplyMap);
      IreplyMap = 0;
    NSLog(@"IreplyMap changed to %@;", IreplyMap);
    }

  DESTROY(IcachedDecoders);
  DESTROY(IcachedEncoders);

  DESTROY(IremoteName);

  DESTROY(IrefGate);

  [arp drain];
}

/*
 * NSDistantObject's -forwardInvocation: method calls this to send the message
 * over the wire.
 */
- (void) forwardInvocation: (NSInvocation*)inv
    NSLog(@"Entering - (void) forwardInvocation: (NSInvocation*)inv");
		  forProxy: (NSDistantObject*)object
{
  NSPortCoder	*op;
  BOOL		outParams;
  BOOL		needsResponse;
  const char	*name;
  const char	*type;
  unsigned	seq;
  NSRunLoop	*runLoop = GSRunLoopForThread(nil);
    NSLog(@"runLoop changed to %@;", runLoop);

  if ([IrunLoops indexOfObjectIdenticalTo: runLoop] == NSNotFound)
    {
      if (ImultipleThreads == NO)
	{
	  [NSException raise: NSObjectInaccessibleException
            format: @"Forwarding message for %p in wrong thread - %@",
            object, inv];
	}
      else
	{
	  [self addRunLoop: runLoop];
	}
    }

  /* Encode the method on an RMC, and send it. */

  NSParameterAssert (IisValid);

  /* get the method types from the selector */
  type = [[inv methodSignature] methodType];
    NSLog(@"type changed to %@;", type);
  if (type == 0 || *type == '\0')
    {
      type = [[object methodSignatureForSelector: [inv selector]] methodType];
    NSLog(@"type changed to %@;", type);
      if (type)
	{
	  GSSelectorFromNameAndTypes(sel_getName([inv selector]), type);
	}
    }
  NSParameterAssert(type);
  NSParameterAssert(*type);

  op = [self _newOutRmc: 0 generate: (int*)&seq reply: YES];
    NSLog(@"op changed to %@;", op);

  if (debug_connection > 4)
    NSLog(@"building packet seq %d", seq);

  [inv setTarget: object];
  outParams = [inv encodeWithDistantCoder: op passPointers: NO];
    NSLog(@"outParams changed to %@;", outParams);

  if (outParams == YES)
    {
      needsResponse = YES;
    NSLog(@"needsResponse changed to %@;", needsResponse);
    }
  else
    {
      int		flags;

      needsResponse = NO;
    NSLog(@"needsResponse changed to %@;", needsResponse);
      flags = objc_get_type_qualifiers(type);
    NSLog(@"flags changed to %@;", flags);
      if ((flags & _F_ONEWAY) == 0)
	{
	  needsResponse = YES;
    NSLog(@"needsResponse changed to %@;", needsResponse);
	}
      else
	{
	  const char	*tmptype = objc_skip_type_qualifiers(type);
    NSLog(@"tmptype changed to %@;", tmptype);

	  if (*tmptype != _C_VOID)
	    {
	      needsResponse = YES;
    NSLog(@"needsResponse changed to %@;", needsResponse);
	    }
	}
    }

  [self _sendOutRmc: op type: METHOD_REQUEST sequence: seq];
  name = sel_getName([inv selector]);
    NSLog(@"name changed to %@;", name);
  NSDebugMLLog(@"NSConnection", @"Sent message %s RMC %d to 0x%"PRIxPTR,
    name, seq, (NSUInteger)self);

  if (needsResponse == NO)
    {
      GSIMapNode	node;

      /*
       * Since we don't need a response, we can remove the placeholder from
       * the IreplyMap.  However, in case the other end has already sent us
       * a response, we must check for it and scrap it if necessary.
       */
      GS_M_LOCK(IrefGate);
      node = GSIMapNodeForKey(IreplyMap, (GSIMapKey)(NSUInteger)seq);
    NSLog(@"node changed to %@;", node);
      if (node != 0 && node->value.obj != dummyObject)
	{
	  BOOL	is_exception = NO;
    NSLog(@"is_exception changed to %@;", is_exception);

	  [node->value.obj decodeValueOfObjCType: @encode(BOOL)
					      at: &is_exception];
	  if (is_exception == YES)
	    NSLog(@"Got exception with %s", name);
	  else
	    NSLog(@"Got response with %@", name);
	  [self _doneInRmc: node->value.obj];
	}
      GSIMapRemoveKey(IreplyMap, (GSIMapKey)(NSUInteger)seq);
      GSM_UNLOCK(IrefGate);
    }
  else
    {
      int		argnum;
      int		flags;
      const char	*tmptype;
      void		*datum;
      NSPortCoder	*aRmc;
      BOOL		is_exception;

      if ([self isValid] == NO)
	{
	  [NSException raise: NSGenericException
	    format: @"connection waiting for request was shut down"];
	}
      aRmc = [self _getReplyRmc: seq for: name];
    NSLog(@"aRmc changed to %@;", aRmc);

      /*
    NSLog(@"Returning from method at line: * Find out if the server is returning an exception instead");
       * Find out if the server is returning an exception instead
    NSLog(@"Returning from method at line: * of the return values.");
       * of the return values.
       */
      [aRmc decodeValueOfObjCType: @encode(BOOL) at: &is_exception];
      if (is_exception == YES)
	{
	  /* Decode the exception object, and raise it. */
	  id exc = [aRmc decodeObject];
    NSLog(@"exc changed to %@;", exc);

	  [self _doneInReply: aRmc];
	  [exc raise];
	}

    NSLog(@"Returning from method at line: /* Get the return type qualifier flags, and the return type. */");
      /* Get the return type qualifier flags, and the return type. */
      flags = objc_get_type_qualifiers(type);
    NSLog(@"flags changed to %@;", flags);
      tmptype = objc_skip_type_qualifiers(type);
    NSLog(@"tmptype changed to %@;", tmptype);

    NSLog(@"Returning from method at line: /* Decode the return value and pass-by-reference values, if there");
      /* Decode the return value and pass-by-reference values, if there
    NSLog(@"Returning from method at line: are any.  OUT_PARAMETERS should be the value returned by");
	 are any.  OUT_PARAMETERS should be the value returned by
	 cifframe_dissect_call(). */
      if (outParams || *tmptype != _C_VOID || (flags & _F_ONEWAY) == 0)
	/* xxx What happens with method declared "- (oneway) foo: (out int*)ip;" */
	/* xxx What happens with method declared "- (in char *) bar;" */
	/* xxx Is this right?  Do we also have to check _F_ONEWAY? */
	{
	  id	obj;

    NSLog(@"Returning from method at line: /* If there is a return value, decode it, and put it in datum. */");
	  /* If there is a return value, decode it, and put it in datum. */
	  if (*tmptype != _C_VOID || (flags & _F_ONEWAY) == 0)
	    {
	      switch (*tmptype)
		{
		  case _C_ID:
		    datum = &obj;
    NSLog(@"datum changed to %@;", datum);
		    [aRmc decodeValueOfObjCType: tmptype at: datum];
		    [obj autorelease];
		    break;
		  case _C_PTR:
    NSLog(@"Returning from method at line: /* We are returning a pointer to something. */");
		    /* We are returning a pointer to something. */
		    tmptype++;
		    datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
		    [aRmc decodeValueOfObjCType: tmptype at: datum];
		    break;

		  case _C_VOID:
		    datum = alloca (sizeof (int));
    NSLog(@"datum changed to %@;", datum);
		    [aRmc decodeValueOfObjCType: @encode(int) at: datum];
		    break;

		  default:
		    datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
		    [aRmc decodeValueOfObjCType: tmptype at: datum];
		    break;
		}
	    }
	  else
	    {
	      datum = 0;
    NSLog(@"datum changed to %@;", datum);
	    }
	  [inv setReturnValue: datum];

    NSLog(@"Returning from method at line: /* Decode the values returned by reference.  Note: this logic");
	  /* Decode the values returned by reference.  Note: this logic
	     must match exactly the code in _service_forwardForProxy:
	     */
	  if (outParams)
	    {
	      /* Step through all the arguments, finding the ones that were
		 passed by reference. */
	      for (tmptype = skip_argspec (tmptype), argnum = 0;
    NSLog(@"tmptype changed to %@;", tmptype);
	        *tmptype != '\0';
	        tmptype = skip_argspec (tmptype), argnum++)
		{
		  /* Get the type qualifiers, like IN, OUT, INOUT, ONEWAY. */
		  flags = objc_get_type_qualifiers(tmptype);
    NSLog(@"flags changed to %@;", flags);
		  /* Skip over the type qualifiers, so now TYPE is
		     pointing directly at the char corresponding to the
		     argument's type. */
		  tmptype = objc_skip_type_qualifiers(tmptype);
    NSLog(@"tmptype changed to %@;", tmptype);

		  if (*tmptype == _C_PTR
		    && ((flags & _F_OUT) || !(flags & _F_IN)))
		    {
		      /* If the arg was byref, we obtain its address
		       * and decode the data directly to it.
		       */
		      tmptype++;
		      [inv getArgument: &datum atIndex: argnum];
		      [aRmc decodeValueOfObjCType: tmptype at: datum];
		      if (*tmptype == _C_ID)
			{
			  [*(id*)datum autorelease];
			}
		    }
		  else if (*tmptype == _C_CHARPTR
		    && ((flags & _F_OUT) || !(flags & _F_IN)))
		    {
		      [aRmc decodeValueOfObjCType: tmptype at: &datum];
		      [inv setArgument: datum atIndex: argnum];
		    }
		}
	    }
	}
      [self _doneInReply: aRmc];
    }
}

- (const char *) typeForSelector: (SEL)sel remoteTarget: (unsigned)target
    NSLog(@"Entering - (const char *) typeForSelector: (SEL)sel remoteTarget: (unsigned)target");
{
  id op, ip;
  char	*type = 0;
    NSLog(@"type changed to %@;", type);
  int	seq_num;
  NSData *data;

  NSParameterAssert(IreceivePort);
  NSParameterAssert (IisValid);
  op = [self _newOutRmc: 0 generate: &seq_num reply: YES];
    NSLog(@"op changed to %@;", op);
  [op encodeValueOfObjCType: ":" at: &sel];
  [op encodeValueOfObjCType: @encode(unsigned) at: &target];
  [self _sendOutRmc: op type: METHODTYPE_REQUEST sequence: seq_num];
  ip = [self _getReplyRmc: seq_num for: "methodtype"];
    NSLog(@"ip changed to %@;", ip);
  [ip decodeValueOfObjCType: @encode(char*) at: &type];
  data = type ? [NSData dataWithBytes: type length: strlen(type)+1] : nil;
    NSLog(@"data changed to %@;", data);
  [self _doneInRmc: ip];
    NSLog(@"Returning from method at line: return (const char*)[data bytes];");
  return (const char*)[data bytes];
}


/* Class-wide stats and collections. */

+ (unsigned) connectionsCount
    NSLog(@"Entering + (unsigned) connectionsCount");
{
  unsigned	result;

  GS_M_LOCK(connection_table_gate);
  result = NSCountHashTable(connection_table);
    NSLog(@"result changed to %@;", result);
  GSM_UNLOCK(connection_table_gate);
    NSLog(@"Returning from method at line: return result;");
  return result;
}

+ (unsigned) connectionsCountWithInPort: (NSPort*)aPort
    NSLog(@"Entering + (unsigned) connectionsCountWithInPort: (NSPort*)aPort");
{
  unsigned		count = 0;
    NSLog(@"count changed to %@;", count);
  NSHashEnumerator	enumerator;
  NSConnection		*o;

  GS_M_LOCK(connection_table_gate);
  enumerator = NSEnumerateHashTable(connection_table);
    NSLog(@"enumerator changed to %@;", enumerator);
  while ((o = (NSConnection*)NSNextHashEnumeratorItem(&enumerator)) != nil)
    {
      if ([aPort isEqual: [o receivePort]])
	{
	  count++;
	}
    }
  NSEndHashTableEnumeration(&enumerator);
  GSM_UNLOCK(connection_table_gate);

    NSLog(@"Returning from method at line: return count;");
  return count;
}

@end





@implementation	NSConnection (Private)

- (void) handlePortMessage: (NSPortMessage*)msg
    NSLog(@"Entering - (void) handlePortMessage: (NSPortMessage*)msg");
{
  NSPortCoder		*rmc;
  int			type = [msg msgid];
    NSLog(@"type changed to %@;", type);
  NSMutableArray	*components = [msg _components];
    NSLog(@"components changed to %@;", components);
  NSPort		*rp = [msg receivePort];
    NSLog(@"rp changed to %@;", rp);
  NSPort		*sp = [msg sendPort];
    NSLog(@"sp changed to %@;", sp);
  NSConnection		*conn;

  if (debug_connection > 4)
    {
      NSLog(@"handling packet of type %d (%@)", type, stringFromMsgType(type));
    }
  conn = [connectionClass connectionWithReceivePort: rp sendPort: sp];
    NSLog(@"conn changed to %@;", conn);
  if (conn == nil)
    {
      NSLog(@"Received port message for unknown connection - %@", msg);
      NSLog(@"All connections: %@", [NSConnection allConnections]);
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else if ([conn isValid] == NO)
    {
      if (debug_connection)
	{
	  NSLog(@"received port message for invalid connection - %@", msg);
	}
    NSLog(@"Returning from method at line: return;");
      return;
    }
  if (debug_connection > 4)
    {
      NSLog(@"  connection is %@", conn);
    }

  if (GSIVar(conn, _authenticateIn) == YES
    && (type == METHOD_REQUEST || type == METHOD_REPLY))
    {
      NSData	        *d;
      NSUInteger	count = [components count];
    NSLog(@"count changed to %@;", count);

      d = RETAIN([components objectAtIndex: --count]);
    NSLog(@"d changed to %@;", d);
      [components removeObjectAtIndex: count];
      if ([[conn delegate] authenticateComponents: components
					 withData: d] == NO)
	{
	  RELEASE(d);
	  [NSException raise: NSFailedAuthenticationException
		      format: @"message not authenticated by delegate"];
	}
      RELEASE(d);
    }

  rmc = [conn _newInRmc: components];
    NSLog(@"rmc changed to %@;", rmc);
  if (debug_connection > 5)
    {
      NSLog(@"made rmc %p for %d", rmc, type);
    }

  switch (type)
    {
      case ROOTPROXY_REQUEST:
	/* It won't take much time to handle this, so go ahead and service
	   it, even if we are waiting for a reply. */
	[conn _service_rootObject: rmc];
	break;

      case METHODTYPE_REQUEST:
	/* It won't take much time to handle this, so go ahead and service
	   it, even if we are waiting for a reply. */
	[conn _service_typeForSelector: rmc];
	break;

      case METHOD_REQUEST:
	/*
	 * We just got a new request; we need to decide whether to queue
	 * it or service it now.
	 * If the REPLY_DEPTH is 0, then we aren't in the middle of waiting
	 * for a reply, we are waiting for requests---so service it now.
	 * If REPLY_DEPTH is non-zero, we may still want to service it now
	 * if independent_queuing is NO.
	 */
	GS_M_LOCK(GSIVar(conn, _refGate));
	if (GSIVar(conn, _requestDepth) == 0
	  || GSIVar(conn, _independentQueueing) == NO)
	  {
	    GSIVar(conn, _requestDepth)++;
	    GSM_UNLOCK(GSIVar(conn, _refGate));
	    [conn _service_forwardForProxy: rmc];	// Catches exceptions
	    GS_M_LOCK(GSIVar(conn, _refGate));
	    GSIVar(conn, _requestDepth)--;
	  }
	else
	  {
	    [GSIVar(conn, _requestQueue) addObject: rmc];
	  }
	/*
	 * Service any requests that were queued while we
	 * were waiting for replies.
	 */
	while (GSIVar(conn, _requestDepth) == 0
	  && [GSIVar(conn, _requestQueue) count] > 0)
	  {
	    rmc = [GSIVar(conn, _requestQueue) objectAtIndex: 0];
    NSLog(@"rmc changed to %@;", rmc);
	    [GSIVar(conn, _requestQueue) removeObjectAtIndex: 0];
	    GSM_UNLOCK(GSIVar(conn, _refGate));
	    [conn _service_forwardForProxy: rmc];	// Catches exceptions
	    GS_M_LOCK(GSIVar(conn, _refGate));
	  }
	GSM_UNLOCK(GSIVar(conn, _refGate));
	break;

      /*
       * For replies, we read the sequence number from the reply object and
       * store it in a map using thee sequence number as the key.  That way
       * it's easy for the connection to find replies by their numbers.
       */
      case ROOTPROXY_REPLY:
      case METHOD_REPLY:
      case METHODTYPE_REPLY:
      case RETAIN_REPLY:
	{
	  int		sequence;
	  GSIMapNode	node;

	  [rmc decodeValueOfObjCType: @encode(int) at: &sequence];
	  if (type == ROOTPROXY_REPLY && GSIVar(conn, _keepaliveWait) == YES
	    && sequence == GSIVar(conn, _lastKeepalive))
	    {
	      GSIVar(conn, _keepaliveWait) = NO;
	      NSDebugMLLog(@"NSConnection", @"Handled keepalive %d on %@",
		sequence, conn);
	      [self _doneInRmc: rmc];
	      break;
	    }
	  GS_M_LOCK(GSIVar(conn, _refGate));
	  node = GSIMapNodeForKey(GSIVar(conn, _replyMap),
	    (GSIMapKey)(NSUInteger)sequence);
	  if (node == 0)
	    {
	      NSDebugMLLog(@"NSConnection", @"Ignoring reply RMC %d on %@",
		sequence, conn);
	      [self _doneInRmc: rmc];
	    }
	  else if (node->value.obj == dummyObject)
	    {
	      NSDebugMLLog(@"NSConnection", @"Saving reply RMC %d on %@",
		sequence, conn);
	      node->value.obj = rmc;
    NSLog(@"obj changed to %@;", obj);
	    }
	  else
	    {
	      NSDebugMLLog(@"NSConnection", @"Replace reply RMC %d on %@",
		sequence, conn);
	      [self _doneInRmc: node->value.obj];
	      node->value.obj = rmc;
    NSLog(@"obj changed to %@;", obj);
	    }
	  GSM_UNLOCK(GSIVar(conn, _refGate));
	}
	break;

      case CONNECTION_SHUTDOWN:
	{
	  [conn _service_shutdown: rmc];
	  break;
	}
      case PROXY_RELEASE:
	{
	  [conn _service_release: rmc];
	  break;
	}
      case PROXY_RETAIN:
	{
	  [conn _service_retain: rmc];
	  break;
	}
      default:
	[NSException raise: NSGenericException
		    format: @"unrecognized NSPortCoder identifier"];
    }
}

- (void) _runInNewThread
    NSLog(@"Entering - (void) _runInNewThread");
{
  NSRunLoop	*loop = GSRunLoopForThread(nil);
    NSLog(@"loop changed to %@;", loop);

  [self addRunLoop: loop];
  [loop run];
}

+ (int) setDebug: (int)val
    NSLog(@"Entering + (int) setDebug: (int)val");
{
  int   old = debug_connection;
    NSLog(@"old changed to %@;", old);

  debug_connection = val;
    NSLog(@"debug_connection changed to %@;", debug_connection);
    NSLog(@"Returning from method at line: return old;");
  return old;
}

- (void) _keepalive: (NSNotification*)n
    NSLog(@"Entering - (void) _keepalive: (NSNotification*)n");
{
  if ([self isValid])
    {
      if (IkeepaliveWait == NO)
	{
	  NSPortCoder	*op;

	  /* Send out a root proxy request to ping the other end.
	   */
	  op = [self _newOutRmc: 0 generate: &IlastKeepalive reply: NO];
    NSLog(@"op changed to %@;", op);
	  IkeepaliveWait = YES;
    NSLog(@"IkeepaliveWait changed to %@;", IkeepaliveWait);
	  [self _sendOutRmc: op
                       type: ROOTPROXY_REQUEST
                   sequence: IlastKeepalive];
	}
      else
	{
	  /* keepalive timeout outstanding still.
	   */
	  [self invalidate];
	}
    }
}

/**
 */
- (void) _enableKeepalive
    NSLog(@"Entering - (void) _enableKeepalive");
{
  IuseKeepalive = YES;	/* Set so that child connections will inherit. */
    NSLog(@"IuseKeepalive changed to %@;", IuseKeepalive);
  IkeepaliveWait = NO;
    NSLog(@"IkeepaliveWait changed to %@;", IkeepaliveWait);
  if (IreceivePort !=IsendPort)
    {
      /* If this is not a listening connection, we actually enable the
       * keepalive timing (usng the regular housekeeping notifications)
       * and must also enable multiple thread support as the keepalive
       * notification may arrive in a different thread from the one we
       * are running in.
       */
      [self enableMultipleThreads];
      [[NSNotificationCenter defaultCenter] addObserver: self
	selector: @selector(_keepalive:)
	name: @"GSHousekeeping" object: nil];
    }
}


/* NSConnection calls this to service the incoming method request. */
- (void) _service_forwardForProxy: (NSPortCoder*)aRmc
    NSLog(@"Entering - (void) _service_forwardForProxy: (NSPortCoder*)aRmc");
{
  char		*forward_type = 0;
    NSLog(@"forward_type changed to %@;", forward_type);
  NSPortCoder	*decoder = nil;
    NSLog(@"decoder changed to %@;", decoder);
  NSPortCoder	*encoder = nil;
    NSLog(@"encoder changed to %@;", encoder);
  NSInvocation	*inv = nil;
    NSLog(@"inv changed to %@;", inv);
  unsigned	seq;

  /* Save this for later */
  [aRmc decodeValueOfObjCType: @encode(int) at: &seq];

  /*
   * Make sure don't let exceptions caused by servicing the client's
   * request cause us to crash.
   */
  NS_DURING
    {
      NSRunLoop		*runLoop = GSRunLoopForThread(nil);
    NSLog(@"runLoop changed to %@;", runLoop);
      const char	*type;
      const char	*tmptype;
      const char	*etmptype;
      id		tmp;
      id		target;
      SEL		selector;
      BOOL		is_exception = NO;
    NSLog(@"is_exception changed to %@;", is_exception);
      BOOL		is_async = NO;
    NSLog(@"is_async changed to %@;", is_async);
      BOOL		is_void = NO;
    NSLog(@"is_void changed to %@;", is_void);
      unsigned		flags;
      int		argnum;
      unsigned		in_parameters = 0;
    NSLog(@"in_parameters changed to %@;", in_parameters);
      unsigned		out_parameters = 0;
    NSLog(@"out_parameters changed to %@;", out_parameters);
      NSMethodSignature	*sig;
      const char	*encoded_types = forward_type;
    NSLog(@"encoded_types changed to %@;", encoded_types);

      NSParameterAssert (IisValid);
      if ([IrunLoops indexOfObjectIdenticalTo: runLoop] == NSNotFound)
	{
	  if (ImultipleThreads == YES)
	    {
	      [self addRunLoop: runLoop];
	    }
	  else
	    {
	      [NSException raise: NSObjectInaccessibleException
			  format: @"Message received in wrong thread"];
	    }
	}

      /*
       * Get the types that we're using, so that we know
       * exactly what qualifiers the forwarder used.
       * If all selectors included qualifiers and I could make
       * sel_types_match() work the way I wanted, we wouldn't need
       * to do this.
       */
      [aRmc decodeValueOfObjCType: @encode(char*) at: &forward_type];

      if (debug_connection > 1)
        {
          NSLog(@"Handling message (sig %s) RMC %d from %p",
	    forward_type, seq, self);
	}

      IreqInCount++;	/* Handling an incoming request. */

      encoded_types = forward_type;
    NSLog(@"encoded_types changed to %@;", encoded_types);
      etmptype = encoded_types;
    NSLog(@"etmptype changed to %@;", etmptype);

      decoder = aRmc;
    NSLog(@"decoder changed to %@;", decoder);

      /* Decode the object, (which is always the first argument to a method).
       * Use the -decodeObject method to ensure that the target of the
       * invocation is autoreleased and will be deallocated when we finish.
       */
      target = [decoder decodeObject];
    NSLog(@"target changed to %@;", target);

      /* Decode the selector, (which is the second argument to a method). */
      /* xxx @encode(SEL) produces "^v" in gcc 2.5.8.  It should be ":" */
      [decoder decodeValueOfObjCType: @encode(SEL) at: &selector];

      /* Get the "selector type" for this method.  The "selector type" is
    NSLog(@"Returning from method at line: a string that lists the return and argument types, and also");
	 a string that lists the return and argument types, and also
	 indicates in which registers and where on the stack the arguments
	 should be placed before the method call.  The selector type
    NSLog(@"Returning from method at line: string we get here should have the same argument and return types");
	 string we get here should have the same argument and return types
	 as the ENCODED_TYPES string, but it will have different register
	 and stack locations if the ENCODED_TYPES came from a machine of a
	 different architecture. */
      sig = [target methodSignatureForSelector: selector];
    NSLog(@"sig changed to %@;", sig);
      if (nil == sig)
	{
	  [NSException raise: NSInvalidArgumentException
		       format: @"decoded object %p doesn't handle %s",
	    target, sel_getName(selector)];
	}
      type = [sig methodType];
    NSLog(@"type changed to %@;", type);

      /* Make sure we successfully got the method type, and that its
	 types match the ENCODED_TYPES. */
      NSCParameterAssert (type);
      if (GSSelectorTypesMatch(encoded_types, type) == NO)
	{
	  [NSException raise: NSInvalidArgumentException
	    format: @"NSConection types (%s / %s) mismatch for %s",
	    encoded_types, type, sel_getName(selector)];
	}

      inv = [[NSInvocation alloc] initWithMethodSignature: sig];
    NSLog(@"inv changed to %@;", inv);

      tmptype = skip_argspec (type);
    NSLog(@"tmptype changed to %@;", tmptype);
      etmptype = skip_argspec (etmptype);
    NSLog(@"etmptype changed to %@;", etmptype);
      [inv setTarget: target];

      tmptype = skip_argspec (tmptype);
    NSLog(@"tmptype changed to %@;", tmptype);
      etmptype = skip_argspec (etmptype);
    NSLog(@"etmptype changed to %@;", etmptype);
      [inv setSelector: selector];


      /* Step TMPTYPE and ETMPTYPE in lock-step through their
	 method type strings. */

      for (tmptype = skip_argspec (tmptype),
	   etmptype = skip_argspec (etmptype), argnum = 2;
    NSLog(@"etmptype changed to %@;", etmptype);
	   *tmptype != '\0';
	   tmptype = skip_argspec (tmptype),
	   etmptype = skip_argspec (etmptype), argnum++)
	{
	  void	*datum;

	  /* Get the type qualifiers, like IN, OUT, INOUT, ONEWAY. */
	  flags = objc_get_type_qualifiers (etmptype);
    NSLog(@"flags changed to %@;", flags);
	  /* Skip over the type qualifiers, so now TYPE is pointing directly
	     at the char corresponding to the argument's type.  */
	  tmptype = objc_skip_type_qualifiers(tmptype);
    NSLog(@"tmptype changed to %@;", tmptype);

	  /* Decide how, (or whether or not), to decode the argument
	     depending on its FLAGS and TMPTYPE.  Only the first two cases
	     involve parameters that may potentially be passed by
	     reference, and thus only the first two may change the value
	     of OUT_PARAMETERS.  *** Note: This logic must match exactly
	     the code in cifframe_dissect_call(); that function should
	     encode exactly what we decode here. *** */

	  switch (*tmptype)
	    {
	      case _C_CHARPTR:
		/* Handle a (char*) argument. */
		/* If the char* is qualified as an OUT parameter, or if it
		   not explicitly qualified as an IN parameter, then we will
		   have to get this char* again after the method is run,
		   because the method may have changed it.  Set
		   OUT_PARAMETERS accordingly. */
		if ((flags & _F_OUT) || !(flags & _F_IN))
		  out_parameters++;
		else
		  in_parameters++;
		/* If the char* is qualified as an IN parameter, or not
		   explicity qualified as an OUT parameter, then decode it.
		   Note: the decoder allocates memory for holding the
		   string, and it is also responsible for making sure that
		   the memory gets freed eventually, (usually through the
		   autorelease of NSData object). */
		if ((flags & _F_IN) || !(flags & _F_OUT))
		  {
		    datum = alloca (sizeof(char*));
    NSLog(@"datum changed to %@;", datum);
		    [decoder decodeValueOfObjCType: tmptype at: datum];
		    [inv setArgument: datum atIndex: argnum];
		  }
		break;

	      case _C_PTR:
		/* If the pointer's value is qualified as an OUT parameter,
		   or if it not explicitly qualified as an IN parameter,
		   then we will have to get the value pointed to again after
		   the method is run, because the method may have changed
		   it.  Set OUT_PARAMETERS accordingly. */
		if ((flags & _F_OUT) || !(flags & _F_IN))
		  out_parameters++;
		else
		  in_parameters++;

		/* Handle an argument that is a pointer to a non-char.  But
		   (void*) and (anything**) is not allowed. */
		/* The argument is a pointer to something; increment TYPE
		     so we can see what it is a pointer to. */
		tmptype++;
		/* If the pointer's value is qualified as an IN parameter,
		   or not explicity qualified as an OUT parameter, then
		   decode it. */
		if ((flags & _F_IN) || !(flags & _F_OUT))
		  {
		    datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
		    [decoder decodeValueOfObjCType: tmptype at: datum];
		    [inv setArgument: &datum atIndex: argnum];
		  }
		break;

	      default:
		in_parameters++;
		datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
		if (*tmptype == _C_ID)
		  {
		    *(id*)datum = [decoder decodeObject];
    NSLog(@"datum changed to %@;", datum);
		  }
		else
		  {
		    [decoder decodeValueOfObjCType: tmptype at: datum];
		  }
		[inv setArgument: datum atIndex: argnum];
	    }
	}

      /* Stop using the decoder.
       */
      tmp = decoder;
    NSLog(@"tmp changed to %@;", tmp);
      decoder = nil;
    NSLog(@"decoder changed to %@;", decoder);
      [self _doneInRmc: tmp];

    NSLog(@"Returning from method at line: /* Get the qualifier type of the return value. */");
      /* Get the qualifier type of the return value. */
      flags = objc_get_type_qualifiers (encoded_types);
    NSLog(@"flags changed to %@;", flags);
    NSLog(@"Returning from method at line: /* Get the return type; store it our two temporary char*'s. */");
      /* Get the return type; store it our two temporary char*'s. */
      etmptype = objc_skip_type_qualifiers (encoded_types);
    NSLog(@"etmptype changed to %@;", etmptype);
      tmptype = objc_skip_type_qualifiers (type);
    NSLog(@"tmptype changed to %@;", tmptype);

      if (_C_VOID == *tmptype)
	{
	  is_void = YES;
    NSLog(@"is_void changed to %@;", is_void);
	}

      /* If this is a oneway void with no out parameters, we don't need to
       * send back any response.
       */
      if (YES == is_void && (flags & _F_ONEWAY) && !out_parameters)
        {
	  is_async = YES;
    NSLog(@"is_async changed to %@;", is_async);
	}

      NSDebugMLLog(@"RMC", @"RMC %d %s method '%s' on %p(%s)", seq,
	(YES == is_async) ? "async" : "invoke",
	selector ? sel_getName(selector) : "nil",
	target, target ? class_getName([target class]) : "nil");

      /* Invoke the method! */
      [inv invoke];

      if (YES == is_async)
        {
	  tmp = inv;
    NSLog(@"tmp changed to %@;", tmp);
	  inv = nil;
    NSLog(@"inv changed to %@;", inv);
	  [tmp release];
	  NS_VOIDRETURN;
	}

      /* It is possible that our connection died while the method was
       * being called - in this case we mustn't try to send the result
       * back to the remote application!
       */
      if ([self isValid] == NO)
	{
    NSLog(@"Returning from method at line: NSDebugMLLog(@"RMC", @"RMC %d invalidated ... no return", seq);");
	  NSDebugMLLog(@"RMC", @"RMC %d invalidated ... no return", seq);
	  tmp = inv;
    NSLog(@"tmp changed to %@;", tmp);
	  inv = nil;
    NSLog(@"inv changed to %@;", inv);
	  [tmp release];
	  NS_VOIDRETURN;
	}

    NSLog(@"Returning from method at line: /* Encode the return value and pass-by-reference values, if there");
      /* Encode the return value and pass-by-reference values, if there
	 are any.  This logic must match exactly that in
    NSLog(@"Returning from method at line: cifframe_build_return(). */");
	 cifframe_build_return(). */
      /* OUT_PARAMETERS should be true here in exactly the same
	 situations as it was true in cifframe_dissect_call(). */

      /* We create a new coder object and encode a flag to
       * say that this is not an exception.
       */
      encoder = [self _newOutRmc: seq generate: 0 reply: NO];
    NSLog(@"encoder changed to %@;", encoder);
      [encoder encodeValueOfObjCType: @encode(BOOL) at: &is_exception];

    NSLog(@"Returning from method at line: /* Only encode return values if there is a non-void return value,");
      /* Only encode return values if there is a non-void return value,
    NSLog(@"Returning from method at line: a non-oneway void return value, or if there are values that were");
	 a non-oneway void return value, or if there are values that were
	 passed by reference. */

      if (YES == is_void)
	{
	  if ((flags & _F_ONEWAY) == 0)
	    {
	      int	dummy = 0;
    NSLog(@"dummy changed to %@;", dummy);

	      [encoder encodeValueOfObjCType: @encode(int) at: (void*)&dummy];
	    }
    NSLog(@"Returning from method at line: /* No return value to encode; do nothing. */");
	  /* No return value to encode; do nothing. */
	}
      else
	{
	  void	*datum;

	  if (*tmptype == _C_PTR)
	    {
	      /* The argument is a pointer to something; increment TYPE
		 so we can see what it is a pointer to. */
	      tmptype++;
	      datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
	    }
	  else
	    {
	      datum = alloca (objc_sizeof_type (tmptype));
    NSLog(@"datum changed to %@;", datum);
	    }
	  [inv getReturnValue: datum];
	  [encoder encodeValueOfObjCType: tmptype at: datum];
	}


    NSLog(@"Returning from method at line: /* Encode the values returned by reference.  Note: this logic");
      /* Encode the values returned by reference.  Note: this logic
    NSLog(@"Returning from method at line: must match exactly the code in cifframe_build_return(); that");
	 must match exactly the code in cifframe_build_return(); that
	 function should decode exactly what we encode here. */

      if (out_parameters)
	{
	  /* Step through all the arguments, finding the ones that were
	     passed by reference. */
	  for (tmptype = skip_argspec (tmptype),
		 argnum = 0,
		 etmptype = skip_argspec (etmptype);
    NSLog(@"etmptype changed to %@;", etmptype);
	       *tmptype != '\0';
	       tmptype = skip_argspec (tmptype),
		 argnum++,
		 etmptype = skip_argspec (etmptype))
	    {
	      /* Get the type qualifiers, like IN, OUT, INOUT, ONEWAY. */
	      flags = objc_get_type_qualifiers(etmptype);
    NSLog(@"flags changed to %@;", flags);
	      /* Skip over the type qualifiers, so now TYPE is pointing directly
		 at the char corresponding to the argument's type. */
	      tmptype = objc_skip_type_qualifiers (tmptype);
    NSLog(@"tmptype changed to %@;", tmptype);

	      /* Decide how, (or whether or not), to encode the argument
		 depending on its FLAGS and TMPTYPE. */
	      if (((flags & _F_OUT) || !(flags & _F_IN))
		&& (*tmptype == _C_PTR || *tmptype == _C_CHARPTR))
		{
		  void	*datum;

		  if (*tmptype == _C_PTR)
		    {
		      /* The argument is a pointer (to a non-char), and the
			 pointer's value is qualified as an OUT parameter, or
			 it not explicitly qualified as an IN parameter, then
			 it is a pass-by-reference argument.*/
		      ++tmptype;
		      [inv getArgument: &datum atIndex: argnum];
		      [encoder encodeValueOfObjCType: tmptype at: datum];
		    }
		  else if (*tmptype == _C_CHARPTR)
		    {
		      datum = alloca (sizeof (char*));
    NSLog(@"datum changed to %@;", datum);
		      [inv getArgument: datum atIndex: argnum];
		      [encoder encodeValueOfObjCType: tmptype at: datum];
		    }
		}
	    }
	}
      tmp = inv;
    NSLog(@"tmp changed to %@;", tmp);
      inv = nil;
    NSLog(@"inv changed to %@;", inv);
      [tmp release];
      tmp = encoder;
    NSLog(@"tmp changed to %@;", tmp);
      encoder = nil;
    NSLog(@"encoder changed to %@;", encoder);
      NSDebugMLLog(@"RMC", @"RMC %d replying with %s and %u out parameters",
	seq, (YES == is_void ? "void result" : "result"), out_parameters);
    NSLog(@"YES changed to %@;", YES);

      [self _sendOutRmc: tmp type: METHOD_REPLY sequence: seq];
    }
  NS_HANDLER
    {
      if (debug_connection > 3)
	NSLog(@"forwarding exception for (%@) - %@", self, localException);

      /* Send the exception back to the client. */
      if (IisValid == YES)
	{
	  BOOL is_exception = YES;
    NSLog(@"is_exception changed to %@;", is_exception);

	  NS_DURING
	    {
	      NSPortCoder	*op;

	      if (inv != nil)
		{
		  [inv release];
		}
	      if (decoder != nil)
		{
		  [self _failInRmc: decoder];
		}
	      if (encoder != nil)
		{
		  [self _failOutRmc: encoder];
		}
	      op = [self _newOutRmc: seq generate: 0 reply: NO];
    NSLog(@"op changed to %@;", op);
	      [op encodeValueOfObjCType: @encode(BOOL)
				     at: &is_exception];
	      [op encodeBycopyObject: localException];
	      [self _sendOutRmc: op type: METHOD_REPLY sequence: seq];
	    }
	  NS_HANDLER
	    {
	      NSLog(@"Exception when sending exception back to client - %@",
		localException);
	    }
	  NS_ENDHANDLER;
	}
    }
  NS_ENDHANDLER;
}

- (void) _service_rootObject: (NSPortCoder*)rmc
    NSLog(@"Entering - (void) _service_rootObject: (NSPortCoder*)rmc");
{
  id		rootObject = rootObjectForInPort(IreceivePort);
    NSLog(@"rootObject changed to %@;", rootObject);
  int		sequence;
  NSPortCoder	*op;

  NSParameterAssert(IreceivePort);
  NSParameterAssert(IisValid);
  NSParameterAssert([rmc connection] == self);

  [rmc decodeValueOfObjCType: @encode(int) at: &sequence];
  [self _doneInRmc: rmc];
  op = [self _newOutRmc: sequence generate: 0 reply: NO];
    NSLog(@"op changed to %@;", op);
  [op encodeObject: rootObject];
  [self _sendOutRmc: op type: ROOTPROXY_REPLY sequence: sequence];
}

- (void) _service_release: (NSPortCoder*)rmc
    NSLog(@"Entering - (void) _service_release: (NSPortCoder*)rmc");
{
  unsigned int	count;
  unsigned int	pos;
  int		sequence;

  NSParameterAssert (IisValid);

  [rmc decodeValueOfObjCType: @encode(int) at: &sequence];
  [rmc decodeValueOfObjCType: @encode(typeof(count)) at: &count];

  for (pos = 0; pos < count; pos++)
    NSLog(@"pos changed to %@;", pos);
    {
      unsigned		target;
      NSDistantObject	*prox;

      [rmc decodeValueOfObjCType: @encode(typeof(target)) at: &target];

      prox = [self includesLocalTarget: target];
    NSLog(@"prox changed to %@;", prox);
      if (prox != 0)
	{
	  if (debug_connection > 3)
	    NSLog(@"releasing object with target (0x%x) on (%@) counter %d",
		target, self, prox->_counter);
	  GS_M_LOCK(IrefGate);
	  NS_DURING
	    {
	      if (--(prox->_counter) == 0)
		{
		  id	rootObject = rootObjectForInPort(IreceivePort);
    NSLog(@"rootObject changed to %@;", rootObject);

		  if (rootObject == prox->_object)
		    {
		      /* Don't deallocate root object ...
		       */
		      prox->_counter = 0;
    NSLog(@"_counter changed to %@;", _counter);
		    }
		  else
		    {
		      [self removeLocalObject: (id)prox];
		    }
		}
	    }
	  NS_HANDLER
	    {
	      GSM_UNLOCK(IrefGate);
	      [localException raise];
	    }
	  NS_ENDHANDLER
	  GSM_UNLOCK(IrefGate);
	}
      else if (debug_connection > 3)
	NSLog(@"releasing object with target (0x%x) on (%@) - nothing to do",
		target, self);
    }
  [self _doneInRmc: rmc];
}

- (void) _service_retain: (NSPortCoder*)rmc
    NSLog(@"Entering - (void) _service_retain: (NSPortCoder*)rmc");
{
  unsigned		target;
  NSPortCoder		*op;
  int			sequence;
  NSDistantObject	*local;
  NSString		*response = nil;
    NSLog(@"response changed to %@;", response);

  NSParameterAssert (IisValid);

  [rmc decodeValueOfObjCType: @encode(int) at: &sequence];
  op = [self _newOutRmc: sequence generate: 0 reply: NO];
    NSLog(@"op changed to %@;", op);

  [rmc decodeValueOfObjCType: @encode(typeof(target)) at: &target];
  [self _doneInRmc: rmc];

  if (debug_connection > 3)
    NSLog(@"looking to retain local object with target (0x%x) on (%@)",
      target, self);

  GS_M_LOCK(IrefGate);
  local = [self locateLocalTarget: target];
    NSLog(@"local changed to %@;", local);
  if (local == nil)
    {
      response = @"target not found anywhere";
    NSLog(@"response changed to %@;", response);
    }
  else
    {
      local->_counter++;	// Vended on connection.
    }
  GSM_UNLOCK(IrefGate);

  [op encodeObject: response];
  [self _sendOutRmc: op type: RETAIN_REPLY sequence: sequence];
}

- (void) _shutdown
    NSLog(@"Entering - (void) _shutdown");
{
  NSParameterAssert(IreceivePort);
  NSParameterAssert (IisValid);
  NS_DURING
    {
      NSPortCoder	*op;
      int		sno;

      op = [self _newOutRmc: 0 generate: &sno reply: NO];
    NSLog(@"op changed to %@;", op);
      [self _sendOutRmc: op type: CONNECTION_SHUTDOWN sequence: sno];
    }
  NS_HANDLER
  NS_ENDHANDLER
}

- (void) _service_shutdown: (NSPortCoder*)rmc
    NSLog(@"Entering - (void) _service_shutdown: (NSPortCoder*)rmc");
{
  NSParameterAssert (IisValid);
  IshuttingDown = YES;		// Prevent shutdown being sent back to other end
    NSLog(@"IshuttingDown changed to %@;", IshuttingDown);
  [self _doneInRmc: rmc];
  [self invalidate];
}

- (void) _service_typeForSelector: (NSPortCoder*)rmc
    NSLog(@"Entering - (void) _service_typeForSelector: (NSPortCoder*)rmc");
{
  NSPortCoder	*op;
  unsigned	target;
  NSDistantObject *p;
  int		sequence;
  id		o;
  SEL		sel;
  const char	*type;
  struct objc_method* m;

  NSParameterAssert(IreceivePort);
  NSParameterAssert (IisValid);

  [rmc decodeValueOfObjCType: @encode(int) at: &sequence];
  op = [self _newOutRmc: sequence generate: 0 reply: NO];
    NSLog(@"op changed to %@;", op);

  [rmc decodeValueOfObjCType: ":" at: &sel];
  [rmc decodeValueOfObjCType: @encode(unsigned) at: &target];
  [self _doneInRmc: rmc];
  p = [self includesLocalTarget: target];
    NSLog(@"p changed to %@;", p);
  o = (p != nil) ? p->_object : nil;
    NSLog(@"o changed to %@;", o);

  /* xxx We should make sure that TARGET is a valid object. */
  /* Not actually a Proxy, but we avoid the warnings "id" would have made. */
  m = GSGetMethod(object_getClass(o), sel, YES, YES);
    NSLog(@"m changed to %@;", m);
  /* Perhaps I need to be more careful in the line above to get the
     version of the method types that has the type qualifiers in it.
     Search the protocols list. */
  if (m)
    type = method_getTypeEncoding(m);
    NSLog(@"type changed to %@;", type);
  else
    type = "";
    NSLog(@"type changed to %@;", type);
  [op encodeValueOfObjCType: @encode(char*) at: &type];
  [self _sendOutRmc: op type: METHODTYPE_REPLY sequence: sequence];
}



/*
 * Check the queue, then try to get it from the network by waiting
 * while we run the NSRunLoop.  Raise exception if we don't get anything
 * before timing out.
 */
- (NSPortCoder*) _getReplyRmc: (int)sn for: (const char*)request
    NSLog(@"Entering - (NSPortCoder*) _getReplyRmc: (int)sn for: (const char*)request");
{
  NSPortCoder		*rmc = nil;
    NSLog(@"rmc changed to %@;", rmc);
  GSIMapNode		node = 0;
    NSLog(@"node changed to %@;", node);
  NSDate		*timeout_date = nil;
    NSLog(@"timeout_date changed to %@;", timeout_date);
  NSTimeInterval	delay_interval = 0.0;
    NSLog(@"delay_interval changed to %@;", delay_interval);
  NSTimeInterval	last_interval;
  NSTimeInterval	maximum_interval;
  NSDate		*delay_date = nil;
    NSLog(@"delay_date changed to %@;", delay_date);
  NSDate		*start_date = nil;
    NSLog(@"start_date changed to %@;", start_date);
  NSRunLoop		*runLoop;
  BOOL			isLocked = NO;
    NSLog(@"isLocked changed to %@;", isLocked);

  if (IisValid == NO)
    {
      [NSException raise: NSObjectInaccessibleException
        format: @"Connection has been invalidated for reply %d (%s)",
        sn, request];
    }

  /*
   * If we have sent out a request on a run loop that we don't already
   * know about, it must be on a new thread - so if we have multipleThreads
   * enabled, we must add the run loop of the new thread so that we can
   * get the reply in this thread.
   */
  runLoop = GSRunLoopForThread(nil);
    NSLog(@"runLoop changed to %@;", runLoop);
  if ([IrunLoops indexOfObjectIdenticalTo: runLoop] == NSNotFound)
    {
      if (ImultipleThreads == YES)
	{
	  [self addRunLoop: runLoop];
	}
      else
	{
	  [NSException raise: NSObjectInaccessibleException
            format: @"Waiting for reply %d (%s) in wrong thread",
            sn, request];
	}
    }

  if (ImultipleThreads == YES)
    {
      /* Since multiple threads are using this connection, another
       * thread may read the reply we are waiting for - so we must
       * break out of the runloop frequently to check.  We do this
       * by setting a small delay and increasing it each time round
       * so that this semi-busy wait doesn't consume too much
       * processor time (I hope).
       * We set an upper limit on the delay to avoid responsiveness
       * problems.
       */
      last_interval = 0.0001;
    NSLog(@"last_interval changed to %@;", last_interval);
      maximum_interval = 1.0;
    NSLog(@"maximum_interval changed to %@;", maximum_interval);
    }
  else
    {
      /* As the connection is single threaded, we can wait indefinitely
       * for a response ... but we recheck every five minutes anyway.
       */
      last_interval = maximum_interval = 300.0;
    NSLog(@"last_interval changed to %@;", last_interval);
    }

  NS_DURING
    {
      BOOL	warned = NO;
    NSLog(@"warned changed to %@;", warned);

      if (debug_connection > 5)
	NSLog(@"Waiting for reply %d (%s) on %@", sn, request, self);
      GS_M_LOCK(IrefGate); isLocked = YES;
    NSLog(@"isLocked changed to %@;", isLocked);
      while (IisValid == YES
	&& (node = GSIMapNodeForKey(IreplyMap, (GSIMapKey)(NSUInteger)sn)) != 0
	&& node->value.obj == dummyObject)
	{
	  NSDate	*limit_date;

	  GSM_UNLOCK(IrefGate); isLocked = NO;
    NSLog(@"isLocked changed to %@;", isLocked);
	  if (start_date == nil)
	    {
	      start_date = [dateClass allocWithZone: NSDefaultMallocZone()];
    NSLog(@"start_date changed to %@;", start_date);
	      start_date = [start_date init];
    NSLog(@"start_date changed to %@;", start_date);
	      timeout_date = [dateClass allocWithZone: NSDefaultMallocZone()];
    NSLog(@"timeout_date changed to %@;", timeout_date);
              // Testplant-MAL-2017.11.14...
              // Fix issue with waiting forever if gpbs crashes within a
              // certain processing window...need a better place to put this...
              [self setReplyTimeout: 5.0];
	      timeout_date = [timeout_date initWithTimeIntervalSinceNow: IreplyTimeout];
    NSLog(@"timeout_date changed to %@;", timeout_date);
	    }
	  RELEASE(delay_date);
	  delay_date = [dateClass allocWithZone: NSDefaultMallocZone()];
    NSLog(@"delay_date changed to %@;", delay_date);
	  if (delay_interval < maximum_interval)
	    {
	      NSTimeInterval	next_interval = last_interval + delay_interval;
    NSLog(@"next_interval changed to %@;", next_interval);

	      last_interval = delay_interval;
    NSLog(@"last_interval changed to %@;", last_interval);
	      delay_interval = next_interval;
    NSLog(@"delay_interval changed to %@;", delay_interval);
	    }
	  delay_date
	    = [delay_date initWithTimeIntervalSinceNow: delay_interval];

	  /*
	   * We must not set a delay date that is further in the future
    NSLog(@"Returning from method at line: * than the timeout date for the response to be returned.");
	   * than the timeout date for the response to be returned.
	   */
	  if ([timeout_date earlierDate: delay_date] == timeout_date)
	    {
	      limit_date = timeout_date;
    NSLog(@"limit_date changed to %@;", limit_date);
	    }
	  else
	    {
	      limit_date = delay_date;
    NSLog(@"limit_date changed to %@;", limit_date);
	    }

	  /*
    NSLog(@"Returning from method at line: * If the runloop returns without having done anything, AND we");
	   * If the runloop returns without having done anything, AND we
	   * were waiting for the final timeout, then we must break out
	   * of the loop.
	   */
	  if (([runLoop runMode: NSConnectionReplyMode
		     beforeDate: limit_date] == NO
	    && (limit_date == timeout_date))
	    || [timeout_date timeIntervalSinceNow] <= 0.0)
	    {
	      GS_M_LOCK(IrefGate); isLocked = YES;
    NSLog(@"isLocked changed to %@;", isLocked);
	      node = GSIMapNodeForKey(IreplyMap, (GSIMapKey)(NSUInteger)sn);
    NSLog(@"node changed to %@;", node);
	      break;
	    }
	  else if (warned == NO && [start_date timeIntervalSinceNow] <= -300.0)
	    {
	      warned = YES;
    NSLog(@"warned changed to %@;", warned);
	      NSLog(@"WARNING ... waiting for reply %u (%s) since %@ on %@",
		sn, request, start_date, self);
	    }
	  GS_M_LOCK(IrefGate); isLocked = YES;
    NSLog(@"isLocked changed to %@;", isLocked);
	}
      if (node == 0)
	{
	  rmc = nil;
    NSLog(@"rmc changed to %@;", rmc);
	}
      else
	{
	  rmc = node->value.obj;
    NSLog(@"rmc changed to %@;", rmc);
	  GSIMapRemoveKey(IreplyMap, (GSIMapKey)(NSUInteger)sn);
	}
      GSM_UNLOCK(IrefGate); isLocked = NO;
    NSLog(@"isLocked changed to %@;", isLocked);
      TEST_RELEASE(start_date);
      TEST_RELEASE(delay_date);
      TEST_RELEASE(timeout_date);
      if (rmc == nil)
	{
	  [NSException raise: NSInternalInconsistencyException
            format: @"no reply available %d (%s)",
            sn, request];
	}
      if (rmc == dummyObject)
	{
	  if (IisValid == YES)
	    {
	      [NSException raise: NSPortTimeoutException
                format: @"timed out waiting for reply %d (%s)",
                sn, request];
	    }
	  else
	    {
	      [NSException raise: NSInvalidReceivePortException
                format: @"invalidated while awaiting reply %d (%s)",
                sn, request];
	    }
	}
    }
  NS_HANDLER
    {
      if (isLocked == YES)
	{
	  GSM_UNLOCK(IrefGate);
	}
      [localException raise];
    }
  NS_ENDHANDLER

  NSDebugMLLog(@"NSConnection", @"Consuming reply %d (%s) on %"PRIxPTR,
    sn, request, (NSUInteger)self);
    NSLog(@"Returning from method at line: return rmc;");
  return rmc;
}

- (void) _doneInReply: (NSPortCoder*)c
    NSLog(@"Entering - (void) _doneInReply: (NSPortCoder*)c");
{
  [self _doneInRmc: c];
  IrepInCount++;
}

- (void) _doneInRmc: (NSPortCoder*) NS_CONSUMED c
    NSLog(@"Entering - (void) _doneInRmc: (NSPortCoder*) NS_CONSUMED c");
{
  GS_M_LOCK(IrefGate);
  if (debug_connection > 5)
    {
      NSLog(@"done rmc %p", c);
    }
  if (cacheCoders == YES && IcachedDecoders != nil)
    {
      [IcachedDecoders addObject: c];
    }
  [c dispatch];	/* Tell NSPortCoder to release the connection.	*/
  RELEASE(c);
  GSM_UNLOCK(IrefGate);
}

/*
 * This method called if an exception occurred, and we don't know
 * whether we have already tidied the NSPortCoder object up or not.
 */
- (void) _failInRmc: (NSPortCoder*)c
    NSLog(@"Entering - (void) _failInRmc: (NSPortCoder*)c");
{
  GS_M_LOCK(IrefGate);
  if (cacheCoders == YES && IcachedDecoders != nil
    && [IcachedDecoders indexOfObjectIdenticalTo: c] == NSNotFound)
    {
      [IcachedDecoders addObject: c];
    }
  if (debug_connection > 5)
    {
      NSLog(@"fail rmc %p", c);
    }
  [c dispatch];	/* Tell NSPortCoder to release the connection.	*/
  RELEASE(c);
  GSM_UNLOCK(IrefGate);
}

/*
 * This method called if an exception occurred, and we don't know
 * whether we have already tidied the NSPortCoder object up or not.
 */
- (void) _failOutRmc: (NSPortCoder*)c
    NSLog(@"Entering - (void) _failOutRmc: (NSPortCoder*)c");
{
  GS_M_LOCK(IrefGate);
  if (cacheCoders == YES && IcachedEncoders != nil
    && [IcachedEncoders indexOfObjectIdenticalTo: c] == NSNotFound)
    {
      [IcachedEncoders addObject: c];
    }
  [c dispatch];	/* Tell NSPortCoder to release the connection.	*/
  RELEASE(c);
  GSM_UNLOCK(IrefGate);
}

- (NSPortCoder*) _newInRmc: (NSMutableArray*)components
    NSLog(@"Entering - (NSPortCoder*) _newInRmc: (NSMutableArray*)components");
{
  NSPortCoder	*coder;
  NSUInteger	count;

  NSParameterAssert(IisValid);

  GS_M_LOCK(IrefGate);
  if (cacheCoders == YES && IcachedDecoders != nil
    && (count = [IcachedDecoders count]) > 0)
    {
      coder = RETAIN([IcachedDecoders objectAtIndex: --count]);
    NSLog(@"coder changed to %@;", coder);
      [IcachedDecoders removeObjectAtIndex: count];
    }
  else
    {
      coder = [recvCoderClass allocWithZone: NSDefaultMallocZone()];
    NSLog(@"coder changed to %@;", coder);
    }
  GSM_UNLOCK(IrefGate);

  coder = [coder initWithReceivePort: IreceivePort
			    sendPort: IsendPort
			  components: components];
    NSLog(@"Returning from method at line: return coder;");
  return coder;
}

/*
 * Create an NSPortCoder object for encoding an outgoing message or reply.
 *
 * sno		Is the seqence number to encode into the coder.
    NSLog(@"Returning from method at line: * ret		If non-null, generate a new sequence number and return it");
 * ret		If non-null, generate a new sequence number and return it
 *		here.  Ignore the sequence number passed in sno.
 * rep		If this flag is YES, add a placeholder to the IreplyMap
 *		so we handle an incoming reply for this sequence number.
 */
- (NSPortCoder*) _newOutRmc: (int)sno generate: (int*)ret reply: (BOOL)rep
    NSLog(@"Entering - (NSPortCoder*) _newOutRmc: (int)sno generate: (int*)ret reply: (BOOL)rep");
{
  NSPortCoder	*coder;
  NSUInteger	count;

  NSParameterAssert(IisValid);

  GS_M_LOCK(IrefGate);
  /*
   * Generate a new sequence number if required.
   */
  if (ret != 0)
    {
      sno = ImessageCount++;
    NSLog(@"sno changed to %@;", sno);
      *ret = sno;
    NSLog(@"ret changed to %@;", ret);
    }
  /*
   * Add a placeholder to the reply map if we expect a reply.
   */
  if (rep == YES)
    {
      GSIMapAddPair(IreplyMap,
	(GSIMapKey)(NSUInteger)sno, (GSIMapVal)dummyObject);
    }
  /*
   * Locate or create an rmc
   */
  if (cacheCoders == YES && IcachedEncoders != nil
    && (count = [IcachedEncoders count]) > 0)
    {
      coder = RETAIN([IcachedEncoders objectAtIndex: --count]);
    NSLog(@"coder changed to %@;", coder);
      [IcachedEncoders removeObjectAtIndex: count];
    }
  else
    {
      coder = [sendCoderClass allocWithZone: NSDefaultMallocZone()];
    NSLog(@"coder changed to %@;", coder);
    }
  GSM_UNLOCK(IrefGate);

  coder = [coder initWithReceivePort: IreceivePort
			    sendPort:IsendPort
			  components: nil];
  [coder encodeValueOfObjCType: @encode(int) at: &sno];
  NSDebugMLLog(@"NSConnection",
    @"Make out RMC %u on %@", sno, self);
    NSLog(@"Returning from method at line: return coder;");
  return coder;
}

- (void) _sendOutRmc: (NSPortCoder*)c type: (int)msgid sequence: (int)sno
    NSLog(@"Entering - (void) _sendOutRmc: (NSPortCoder*)c type: (int)msgid sequence: (int)sno");
{
  NSDate		*limit;
  BOOL			sent = NO;
    NSLog(@"sent changed to %@;", sent);
  BOOL			raiseException = NO;
    NSLog(@"raiseException changed to %@;", raiseException);
  NSMutableArray	*components = [c _components];
    NSLog(@"components changed to %@;", components);

  if (IauthenticateOut == YES
    && (msgid == METHOD_REQUEST || msgid == METHOD_REPLY))
    {
      NSData	*d;

      d = [[self delegate] authenticationDataForComponents: components];
    NSLog(@"d changed to %@;", d);
      if (d == nil)
	{
	  RELEASE(c);
	  [NSException raise: NSGenericException
		      format: @"Bad authentication data provided by delegate"];
	}
      [components addObject: d];
    }

  switch (msgid)
    {
      case PROXY_RETAIN:
      case CONNECTION_SHUTDOWN:
      case METHOD_REPLY:
      case ROOTPROXY_REPLY:
      case METHODTYPE_REPLY:
      case PROXY_RELEASE:
      case RETAIN_REPLY:
	raiseException = NO;
    NSLog(@"raiseException changed to %@;", raiseException);
	break;

      case METHOD_REQUEST:
      case ROOTPROXY_REQUEST:
      case METHODTYPE_REQUEST:
      default:
	raiseException = YES;
    NSLog(@"raiseException changed to %@;", raiseException);
	break;
    }

  NSDebugMLLog(@"NSConnection",
    @"Sending %d (%@) on %@", sno, stringFromMsgType(msgid), self);

  limit = [dateClass dateWithTimeIntervalSinceNow: IrequestTimeout];
    NSLog(@"limit changed to %@;", limit);
  sent = [IsendPort sendBeforeDate: limit
			     msgid: msgid
			components: components
			      from: IreceivePort
			  reserved: [IsendPort reservedSpaceLength]];

  GS_M_LOCK(IrefGate);

  /*
   * We replace the coder we have just used in the cache, and tell it not to
   * retain this connection any more.
   */
  if (cacheCoders == YES && IcachedEncoders != nil)
    {
      [IcachedEncoders addObject: c];
    }
  [c dispatch];	/* Tell NSPortCoder to release the connection.	*/
  RELEASE(c);
  GSM_UNLOCK(IrefGate);

  if (sent == NO)
    {
      NSString	*text = stringFromMsgType(msgid);
    NSLog(@"text changed to %@;", text);

      if ([IsendPort isValid] == NO)
	{
	  text = [text stringByAppendingFormat: @" - port was invalidated"];
    NSLog(@"text changed to %@;", text);
	}
      if (raiseException == YES)
	{
	  [NSException raise: NSPortTimeoutException format: @"%@", text];
	}
      else
	{
	  NSLog(@"Port operation timed out - %@", text);
	}
    }
  else
    {
      switch (msgid)
	{
	  case METHOD_REQUEST:
	    IreqOutCount++;		/* Sent a request.	*/
	    break;
	  case METHOD_REPLY:
	    IrepOutCount++;		/* Sent back a reply. */
	    break;
	  default:
	    break;
	}
    }
}



/* Managing objects and proxies. */
- (void) addLocalObject: (NSDistantObject*)anObj
    NSLog(@"Entering - (void) addLocalObject: (NSDistantObject*)anObj");
{
  static unsigned	local_object_counter = 0;
    NSLog(@"local_object_counter changed to %@;", local_object_counter);
  id			object;
  unsigned		target;
  GSIMapNode    	node;

  GS_M_LOCK(IrefGate);
  NSParameterAssert (IisValid);

  object = anObj->_object;
    NSLog(@"object changed to %@;", object);
  target = anObj->_handle;
    NSLog(@"target changed to %@;", target);

  /*
   * If there is no target allocated to the proxy, we add one.
   */
  if (target == 0)
    {
      anObj->_handle = target = ++local_object_counter;
    NSLog(@"_handle changed to %@;", _handle);
    }

  /*
   * Record the value in the IlocalObjects map, retaining it.
   */
  node = GSIMapNodeForKey(IlocalObjects, (GSIMapKey)object);
    NSLog(@"node changed to %@;", node);
  NSAssert(node == 0, NSInternalInconsistencyException);
    NSLog(@"node changed to %@;", node);
  node = GSIMapNodeForKey(IlocalTargets, (GSIMapKey)(NSUInteger)target);
    NSLog(@"node changed to %@;", node);
  NSAssert(node == 0, NSInternalInconsistencyException);
    NSLog(@"node changed to %@;", node);

  IF_NO_GC([anObj retain];)
  GSIMapAddPair(IlocalObjects, (GSIMapKey)object, (GSIMapVal)((id)anObj));
  GSIMapAddPair(IlocalTargets,
    (GSIMapKey)(NSUInteger)target, (GSIMapVal)((id)anObj));

  if (debug_connection > 2)
    NSLog(@"add local object (%p) target (0x%x) "
	  @"to connection (%@)", object, target, self);

  GSM_UNLOCK(IrefGate);
}

- (NSDistantObject*) retainOrAddLocal: (NSDistantObject*)proxy
    NSLog(@"Entering - (NSDistantObject*) retainOrAddLocal: (NSDistantObject*)proxy");
			    forObject: (id)object
{
  GSIMapNode		node;
  NSDistantObject	*p;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  node = GSIMapNodeForKey(IlocalObjects, (GSIMapKey)object);
    NSLog(@"node changed to %@;", node);
  if (node == 0)
    {
      p = nil;
    NSLog(@"p changed to %@;", p);
    }
  else
    {
      p = RETAIN(node->value.obj);
    NSLog(@"p changed to %@;", p);
      DESTROY(proxy);
    }
  if (p == nil && proxy != nil)
    {
      p = proxy;
    NSLog(@"p changed to %@;", p);
      [self addLocalObject: p];
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return p;");
  return p;
}

- (void) removeLocalObject: (NSDistantObject*)prox
    NSLog(@"Entering - (void) removeLocalObject: (NSDistantObject*)prox");
{
  id		anObj;
  unsigned	target;
  unsigned	val = 0;
    NSLog(@"val changed to %@;", val);
  GSIMapNode	node;

  GS_M_LOCK(IrefGate);
  anObj = prox->_object;
    NSLog(@"anObj changed to %@;", anObj);
  node = GSIMapNodeForKey(IlocalObjects, (GSIMapKey)anObj);
    NSLog(@"node changed to %@;", node);

  /*
   * The NSDistantObject concerned may not belong to this connection,
   * so we need to check that any matching proxy is identical to the
   * argument we were given.
   */
  if (node != 0 && node->value.obj == prox)
    {
      target = prox->_handle;
    NSLog(@"target changed to %@;", target);

      /*
       * If this proxy has been vended onwards to another process
       * which has not myet released it, we need to keep a reference
       * to the local object around for a while in case that other
       * process needs it.
       */
      if ((prox->_counter) != 0)
	{
	  CachedLocalObject	*item;

	  (prox->_counter) = 0;
	  GS_M_LOCK(cached_proxies_gate);
	  if (timer == nil)
	    {
	      timer = [NSTimer scheduledTimerWithTimeInterval: 1.0
		target: connectionClass
		selector: @selector(_timeout:)
		userInfo: nil
		repeats: YES];
	    }
	  item = [CachedLocalObject newWithObject: prox time: 5];
    NSLog(@"item changed to %@;", item);
	  NSMapInsert(targetToCached, (void*)(uintptr_t)target, item);
	  GSM_UNLOCK(cached_proxies_gate);
	  RELEASE(item);
	  if (debug_connection > 3)
	    NSLog(@"placed local object (%p) target (0x%x) in cache",
			anObj, target);
	}

      /*
       * Remove the proxy from IlocalObjects and release it.
       */
      GSIMapRemoveKey(IlocalObjects, (GSIMapKey)anObj);
      RELEASE(prox);

      /*
       * Remove the target info too - no release required.
       */
      GSIMapRemoveKey(IlocalTargets, (GSIMapKey)(NSUInteger)target);

      if (debug_connection > 2)
	NSLog(@"removed local object (%p) target (0x%x) "
	  @"from connection (%@) (ref %d)", anObj, target, self, val);
    }
  GSM_UNLOCK(IrefGate);
}

- (void) _release_target: (unsigned)target count: (unsigned)number
    NSLog(@"Entering - (void) _release_target: (unsigned)target count: (unsigned)number");
{
  NS_DURING
    {
      /*
       *	Tell the remote app that it can release its local objects
       *	for the targets in the specified list since we don't have
       *	proxies for them any more.
       */
      if (IreceivePort != nil && IisValid == YES && number > 0)
	{
	  id		op;
	  unsigned 	i;
	  int		sequence;

	  op = [self _newOutRmc: 0 generate: &sequence reply: NO];
    NSLog(@"op changed to %@;", op);

	  [op encodeValueOfObjCType: @encode(unsigned) at: &number];

	  for (i = 0; i < number; i++)
    NSLog(@"i changed to %@;", i);
	    {
	      [op encodeValueOfObjCType: @encode(unsigned) at: &target];
	      if (debug_connection > 3)
		NSLog(@"sending release for target (0x%x) on (%@)",
		  target, self);
	    }

	  [self _sendOutRmc: op type: PROXY_RELEASE sequence: sequence];
	}
    }
  NS_HANDLER
    {
      if (debug_connection)
        NSLog(@"failed to release targets - %@", localException);
    }
  NS_ENDHANDLER
}

- (NSDistantObject*) locateLocalTarget: (unsigned)target
    NSLog(@"Entering - (NSDistantObject*) locateLocalTarget: (unsigned)target");
{
  NSDistantObject	*proxy = nil;
    NSLog(@"proxy changed to %@;", proxy);
  GSIMapNode		node;

  GS_M_LOCK(IrefGate);

  /*
   * Try a quick lookup to see if the target references a local object
   * belonging to the receiver ... usually it should.
   */
  node = GSIMapNodeForKey(IlocalTargets, (GSIMapKey)(NSUInteger)target);
    NSLog(@"node changed to %@;", node);
  if (node != 0)
    {
      proxy = node->value.obj;
    NSLog(@"proxy changed to %@;", proxy);
    }

  /*
   * If the target doesn't exist in the receiver, but still
   * persists in the cache (ie it was recently released) then
   * we move it back from the cache to the receiver.
   */
  if (proxy == nil)
    {
      CachedLocalObject	*cached;

      GS_M_LOCK(cached_proxies_gate);
      cached = NSMapGet (targetToCached, (void*)(uintptr_t)target);
    NSLog(@"cached changed to %@;", cached);
      if (cached != nil)
	{
	  proxy = [cached obj];
    NSLog(@"proxy changed to %@;", proxy);
	  /*
	   * Found in cache ... add to this connection as the object
	   * is no longer in use by any connection.
	   */
	  ASSIGN(proxy->_connection, self);
	  [self addLocalObject: proxy];
	  NSMapRemove(targetToCached, (void*)(uintptr_t)target);
	  if (debug_connection > 3)
	    NSLog(@"target (0x%x) moved from cache", target);
	}
      GSM_UNLOCK(cached_proxies_gate);
    }

  /*
   * If not found in the current connection or the cache of local references
   * of recently invalidated connections, try all other existing connections.
   */
  if (proxy == nil)
    {
      NSHashEnumerator	enumerator;
      NSConnection	*c;

      GS_M_LOCK(connection_table_gate);
      enumerator = NSEnumerateHashTable(connection_table);
    NSLog(@"enumerator changed to %@;", enumerator);
      while (proxy == nil
	&& (c = (NSConnection*)NSNextHashEnumeratorItem(&enumerator)) != nil)
	{
	  if (c != self && [c isValid] == YES)
	    {
	      GS_M_LOCK(GSIVar(c, _refGate));
	      node = GSIMapNodeForKey(GSIVar(c, _localTargets),
		(GSIMapKey)(NSUInteger)target);
	      if (node != 0)
		{
		  id		local;
		  unsigned	nTarget;

		  /*
		   * We found the local object in use in another connection
		   * so we create a new reference to the same object and
		   * add it to our connection, adjusting the target of the
		   * new reference to be the value we need.
		   *
		   * We don't want to just share the NSDistantObject with
		   * the other connection, since we might want to keep
		   * track of information on a per-connection basis in
		   * order to handle connection shutdown cleanly.
		   */
		  proxy = node->value.obj;
    NSLog(@"proxy changed to %@;", proxy);
		  local = RETAIN(proxy->_object);
    NSLog(@"local changed to %@;", local);
		  proxy = [NSDistantObject proxyWithLocal: local
					       connection: self];
		  nTarget = proxy->_handle;
    NSLog(@"nTarget changed to %@;", nTarget);
		  GSIMapRemoveKey(IlocalTargets,
		    (GSIMapKey)(NSUInteger)nTarget);
		  proxy->_handle = target;
    NSLog(@"_handle changed to %@;", _handle);
		  GSIMapAddPair(IlocalTargets,
		    (GSIMapKey)(NSUInteger)target, (GSIMapVal)((id)proxy));
		}
	      GSM_UNLOCK(GSIVar(c, _refGate));
	    }
	}
      NSEndHashTableEnumeration(&enumerator);
      GSM_UNLOCK(connection_table_gate);
    }

  GSM_UNLOCK(IrefGate);

  if (proxy == nil)
    {
      if (debug_connection > 3)
	NSLog(@"target (0x%x) not found anywhere", target);
    }
    NSLog(@"Returning from method at line: return proxy;");
  return proxy;
}

- (void) vendLocal: (NSDistantObject*)aProxy
    NSLog(@"Entering - (void) vendLocal: (NSDistantObject*)aProxy");
{
  GS_M_LOCK(IrefGate);
  aProxy->_counter++;
  GSM_UNLOCK(IrefGate);
}

- (void) acquireProxyForTarget: (unsigned)target
    NSLog(@"Entering - (void) acquireProxyForTarget: (unsigned)target");
{
  NSDistantObject	*found;
  GSIMapNode		node;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  node = GSIMapNodeForKey(IremoteProxies, (GSIMapKey)(NSUInteger)target);
    NSLog(@"node changed to %@;", node);
  if (node == 0)
    {
      found = nil;
    NSLog(@"found changed to %@;", found);
    }
  else
    {
      found = node->value.obj;
    NSLog(@"found changed to %@;", found);
    }
  GSM_UNLOCK(IrefGate);
  if (found == nil)
    {
      NS_DURING
	{
	  /*
	   * Tell the remote app that it must retain the local object
	   * for the target on this connection.
	   */
	  if (IreceivePort && IisValid)
	    {
	      NSPortCoder	*op;
	      id	ip;
	      id	result;
	      int	seq_num;

	      op = [self _newOutRmc: 0 generate: &seq_num reply: YES];
    NSLog(@"op changed to %@;", op);
	      [op encodeValueOfObjCType: @encode(typeof(target)) at: &target];
	      [self _sendOutRmc: op type: PROXY_RETAIN sequence: seq_num];

	      ip = [self _getReplyRmc: seq_num for: "retain"];
    NSLog(@"ip changed to %@;", ip);
	      [ip decodeValueOfObjCType: @encode(id) at: &result];
	      [self _doneInRmc: ip];
	      if (result != nil)
		NSLog(@"failed to retain target - %@", result);
	      else if (debug_connection > 3)
		NSLog(@"sending retain for target - %u", target);
	    }
	}
      NS_HANDLER
	{
	  NSLog(@"failed to retain target - %@", localException);
	}
      NS_ENDHANDLER
    }
}

- (id) retain
    NSLog(@"Entering - (id) retain");
{
    NSLog(@"Returning from method at line: return [super retain];");
  return [super retain];
}

- (void) removeProxy: (NSDistantObject*)aProxy
    NSLog(@"Entering - (void) removeProxy: (NSDistantObject*)aProxy");
{
  GS_M_LOCK(IrefGate);
  if (IisValid == YES)
    {
      unsigned		target;
      unsigned		count = 1;
    NSLog(@"count changed to %@;", count);
      GSIMapNode	node;

      target = aProxy->_handle;
    NSLog(@"target changed to %@;", target);
      node = GSIMapNodeForKey(IremoteProxies, (GSIMapKey)(NSUInteger)target);
    NSLog(@"node changed to %@;", node);

      /*
       * Only remove if the proxy for the target is the same as the
       * supplied argument.
       */
      if (node != 0 && node->value.obj == aProxy)
	{
	  count = aProxy->_counter;
    NSLog(@"count changed to %@;", count);
	  GSIMapRemoveKey(IremoteProxies, (GSIMapKey)(NSUInteger)target);
	  /*
	   * Tell the remote application that we have removed our proxy and
	   * it can release it's local object.
	   */
	  [self _release_target: target count: count];
	}
    }
  GSM_UNLOCK(IrefGate);
}


/**
 * Private method used only when a remote process/thread has sent us a
 * target which we are decoding into a proxy in this process/thread.
 * <p>The argument aProxy may be nil, in which case an existing proxy
    NSLog(@"Returning from method at line: * matching aTarget is retrieved retained, and returned (this is done");
 * matching aTarget is retrieved retained, and returned (this is done
 * when a proxy target is sent to us by a remote process).
 * </p>
 * <p>If aProxy is not nil, but a proxy with the same target already
    NSLog(@"Returning from method at line: * exists, then aProxy is released and the existing proxy is returned");
 * exists, then aProxy is released and the existing proxy is returned
 * as in the case where aProxy was nil.
 * </p>
 * <p>If aProxy is not nil and there was no prior proxy with the same
    NSLog(@"Returning from method at line: * target, aProxy is added to the receiver and returned.");
 * target, aProxy is added to the receiver and returned.
 * </p>
 */
- (NSDistantObject*) retainOrAddProxy: (NSDistantObject*)aProxy
    NSLog(@"Entering - (NSDistantObject*) retainOrAddProxy: (NSDistantObject*)aProxy");
			    forTarget: (unsigned)aTarget
{
  NSDistantObject	*p;
  GSIMapNode		node;

  /* Don't assert (IisValid); */
  NSParameterAssert(aTarget > 0);
  NSParameterAssert(aProxy == nil
    || object_getClass(aProxy) == distantObjectClass);
  NSParameterAssert(aProxy == nil || [aProxy connectionForProxy] == self);
    NSLog(@"aProxy changed to %@;", aProxy);
  NSParameterAssert(aProxy == nil || aTarget == aProxy->_handle);
    NSLog(@"aProxy changed to %@;", aProxy);

  GS_M_LOCK(IrefGate);
  node = GSIMapNodeForKey(IremoteProxies, (GSIMapKey)(NSUInteger)aTarget);
    NSLog(@"node changed to %@;", node);
  if (node == 0)
    {
      p = nil;
    NSLog(@"p changed to %@;", p);
    }
  else
    {
      p = RETAIN(node->value.obj);
    NSLog(@"p changed to %@;", p);
      DESTROY(aProxy);
    }
  if (p == nil && aProxy != nil)
    {
      p = aProxy;
    NSLog(@"p changed to %@;", p);
      GSIMapAddPair(IremoteProxies, (GSIMapKey)(NSUInteger)aTarget, (GSIMapVal)((id)p));
    }
  /*
   * Whether this is a new proxy or an existing proxy, this method is
   * only called for an object being vended by a remote process/thread.
   * We therefore need to increment the count of the number of times
   * the proxy has been vended.
   */
  if (p != nil)
    {
      p->_counter++;
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return p;");
  return p;
}

- (id) includesLocalObject: (id)anObj
    NSLog(@"Entering - (id) includesLocalObject: (id)anObj");
{
  NSDistantObject	*ret;
  GSIMapNode		node;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  node = GSIMapNodeForKey(IlocalObjects, (GSIMapKey)(NSUInteger)anObj);
    NSLog(@"node changed to %@;", node);
  if (node == 0)
    {
      ret = nil;
    NSLog(@"ret changed to %@;", ret);
    }
  else
    {
      ret = node->value.obj;
    NSLog(@"ret changed to %@;", ret);
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return ret;");
  return ret;
}

- (NSDistantObject*) includesLocalTarget: (unsigned)target
    NSLog(@"Entering - (NSDistantObject*) includesLocalTarget: (unsigned)target");
{
  NSDistantObject	*ret;
  GSIMapNode		node;

  /* Don't assert (IisValid); */
  GS_M_LOCK(IrefGate);
  node = GSIMapNodeForKey(IlocalTargets, (GSIMapKey)(NSUInteger)target);
    NSLog(@"node changed to %@;", node);
  if (node == 0)
    {
      ret = nil;
    NSLog(@"ret changed to %@;", ret);
    }
  else
    {
      ret = node->value.obj;
    NSLog(@"ret changed to %@;", ret);
    }
  GSM_UNLOCK(IrefGate);
    NSLog(@"Returning from method at line: return ret;");
  return ret;
}

/* Prevent trying to encode the connection itself */

- (void) encodeWithCoder: (NSCoder*)anEncoder
    NSLog(@"Entering - (void) encodeWithCoder: (NSCoder*)anEncoder");
{
  [self shouldNotImplement: _cmd];
}
- (id) initWithCoder: (NSCoder*)aDecoder;
    NSLog(@"Entering - (id) initWithCoder: (NSCoder*)aDecoder;");
{
  [self shouldNotImplement: _cmd];
    NSLog(@"Returning from method at line: return self;");
  return self;
}

/*
 *	We register this method for a notification when a port dies.
 *	NB. It is possible that the death of a port could be notified
 *	to us after we are invalidated - in which case we must ignore it.
 */
- (void) _portIsInvalid: (NSNotification*)notification
    NSLog(@"Entering - (void) _portIsInvalid: (NSNotification*)notification");
{
  if (IisValid)
    {
      id port = [notification object];
    NSLog(@"port changed to %@;", port);

      if (debug_connection)
	{
	  NSLog(@"Received port invalidation notification for "
	      @"connection %@\n\t%@", self, port);
	}

      /* We shouldn't be getting any port invalidation notifications,
	  except from our own ports; this is how we registered ourselves
	  with the NSNotificationCenter in
	  +newForInPort: outPort: ancestorConnection. */
      NSParameterAssert (port == IreceivePort || port == IsendPort);
    NSLog(@"port changed to %@;", port);

      [self invalidate];
    }
}

/**
 * On thread exit, we need all connections to be removed from the runloop
 * of the thread or they will retain that and cause a memory leak.
 */
+ (void) _threadWillExit: (NSNotification*)notification
    NSLog(@"Entering + (void) _threadWillExit: (NSNotification*)notification");
{
  NSRunLoop *runLoop = GSRunLoopForThread ([notification object]);
    NSLog(@"runLoop changed to %@;", runLoop);

  if (runLoop != nil)
    {
      NSEnumerator	*enumerator;
      NSConnection	*c;

      GS_M_LOCK (connection_table_gate);
      enumerator = [NSAllHashTableObjects(connection_table) objectEnumerator];
    NSLog(@"enumerator changed to %@;", enumerator);
      GSM_UNLOCK (connection_table_gate);

      /*
       * We enumerate an array copy of the contents of the hash table
       * as we know we can do that safely outside the locked region.
       * The temporary array and the enumerator are autoreleased and
       * will be deallocated with the threads autorelease pool.
       */
      while ((c = [enumerator nextObject]) != nil)
	{
	  [c removeRunLoop: runLoop];
	}
    }
}
@end
