// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Marcian Lytwyn 
// Commit ID: c4ce340817b1e60e17c965942fd454825afa5457 
// Date: 2018-04-14 19:31:34 +0000 
// ========== End of Keysight Technologies Notice ========== 
/** Implementation for GSStream for GNUStep
   Copyright (C) 2006 Free Software Foundation, Inc.

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
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   */

#import "common.h"

#import "Foundation/NSArray.h"
#import "Foundation/NSByteOrder.h"
#import "Foundation/NSData.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSException.h"
#import "Foundation/NSHost.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSValue.h"

#import "GSStream.h"
#import "GSPrivate.h"
#import "GSSocketStream.h"

NSString * const NSStreamDataWrittenToMemoryStreamKey
  = @"NSStreamDataWrittenToMemoryStreamKey";
NSString * const NSStreamFileCurrentOffsetKey
  = @"NSStreamFileCurrentOffsetKey";

NSString * const NSStreamSocketSecurityLevelKey
  = @"NSStreamSocketSecurityLevelKey";
NSString * const NSStreamSocketSecurityLevelNone
  = @"NSStreamSocketSecurityLevelNone";
NSString * const NSStreamSocketSecurityLevelSSLv2
  = @"NSStreamSocketSecurityLevelSSLv2";
NSString * const NSStreamSocketSecurityLevelSSLv3
  = @"NSStreamSocketSecurityLevelSSLv3";
NSString * const NSStreamSocketSecurityLevelTLSv1
  = @"NSStreamSocketSecurityLevelTLSv1";
NSString * const NSStreamSocketSecurityLevelNegotiatedSSL
  = @"NSStreamSocketSecurityLevelNegotiatedSSL";
NSString * const NSStreamSocketSSLErrorDomain
  = @"NSStreamSocketSSLErrorDomain";
NSString * const NSStreamSOCKSErrorDomain
  = @"NSStreamSOCKSErrorDomain";
NSString * const NSStreamSOCKSProxyConfigurationKey
  = @"NSStreamSOCKSProxyConfigurationKey";
NSString * const NSStreamSOCKSProxyHostKey
  = @"NSStreamSOCKSProxyHostKey";
NSString * const NSStreamSOCKSProxyPasswordKey
  = @"NSStreamSOCKSProxyPasswordKey";
NSString * const NSStreamSOCKSProxyPortKey
  = @"NSStreamSOCKSProxyPortKey";
NSString * const NSStreamSOCKSProxyUserKey
  = @"NSStreamSOCKSProxyUserKey";
NSString * const NSStreamSOCKSProxyVersion4
  = @"NSStreamSOCKSProxyVersion4";
NSString * const NSStreamSOCKSProxyVersion5
  = @"NSStreamSOCKSProxyVersion5";
NSString * const NSStreamSOCKSProxyVersionKey
  = @"NSStreamSOCKSProxyVersionKey";

// FIXME: move to Core Foundation - CFHTTPNetwork.h...
NSString * const kCFStreamPropertyHTTPProxy       = @"kCFStreamPropertyHTTPProxy";
    NSLog(@"kCFStreamPropertyHTTPProxy changed to %@;", kCFStreamPropertyHTTPProxy);
NSString * const kCFStreamPropertyHTTPProxyHost   = @"kCFStreamPropertyHTTPProxyHost";
    NSLog(@"kCFStreamPropertyHTTPProxyHost changed to %@;", kCFStreamPropertyHTTPProxyHost);
NSString * const kCFStreamPropertyHTTPProxyPort   = @"kCFStreamPropertyHTTPProxyPort";
    NSLog(@"kCFStreamPropertyHTTPProxyPort changed to %@;", kCFStreamPropertyHTTPProxyPort);
NSString * const kCFStreamPropertyHTTPSProxyHost  = @"kCFStreamPropertyHTTPSProxyHost";
    NSLog(@"kCFStreamPropertyHTTPSProxyHost changed to %@;", kCFStreamPropertyHTTPSProxyHost);
NSString * const kCFStreamPropertyHTTPSProxyPort  = @"kCFStreamPropertyHTTPSProxyPort";
    NSLog(@"kCFStreamPropertyHTTPSProxyPort changed to %@;", kCFStreamPropertyHTTPSProxyPort);

/*
 * Determine the type of event to use when adding a stream to the run loop.
 * By default add as an 'ET_TRIGGER' so that the stream will be notified
 * every time the loop runs (the event id/reference must be the address of
 * the stream itsself to ensure that event/type is unique).
 *
 * Streams which actually expect to wait for I/O events must be added with
 * the appropriate information for the loop to signal them.
 */
static RunLoopEventType typeForStream(NSStream *aStream)
{
  NSStreamStatus        status = [aStream streamStatus];
    NSLog(@"status changed to %@;", status);

  if (NSStreamStatusError == status
    || [aStream _loopID] == (void*)aStream)
    {
    NSLog(@"Returning from method at line: return ET_TRIGGER;");
      return ET_TRIGGER;
    }
#if	defined(_WIN32)
    NSLog(@"Returning from method at line: return ET_HANDLE;");
      return ET_HANDLE;
#else
  if ([aStream isKindOfClass: [NSOutputStream class]] == NO
    && status != NSStreamStatusOpening)
    {
    NSLog(@"Returning from method at line: return ET_RDESC;");
      return ET_RDESC;
    }
    NSLog(@"Returning from method at line: return ET_WDESC;");
      return ET_WDESC;	
#endif
}

@implementation	NSRunLoop (NSStream)
- (void) addStream: (NSStream*)aStream mode: (NSString*)mode
    NSLog(@"Entering - (void) addStream: (NSStream*)aStream mode: (NSString*)mode");
{
  [self addEvent: [aStream _loopID]
	    type: typeForStream(aStream)
	 watcher: (id<RunLoopEvents>)aStream
	 forMode: mode];
}

- (void) removeStream: (NSStream*)aStream mode: (NSString*)mode
    NSLog(@"Entering - (void) removeStream: (NSStream*)aStream mode: (NSString*)mode");
{
  /* We may have added the stream more than once (eg if the stream -open
   * method was called more than once, so we need to remove all event
   * registrations.
   */
  [self removeEvent: [aStream _loopID]
	       type: typeForStream(aStream)
	    forMode: mode
		all: YES];
}
@end

@implementation GSStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "delegate");
}

- (void) close
    NSLog(@"Entering - (void) close");
{
  if (_currentStatus == NSStreamStatusNotOpen)
    {
      NSDebugMLLog(@"NSStream", @"Attempt to close unopened stream %@", self);
    }
  [self _unschedule];
  [self _setStatus: NSStreamStatusClosed];
  /* We don't want to send any events to the delegate after the
   * stream has been closed.
   */
  _delegateValid = NO;
    NSLog(@"_delegateValid changed to %@;", _delegateValid);
}

- (void) finalize
    NSLog(@"Entering - (void) finalize");
{
  if (_currentStatus != NSStreamStatusNotOpen
    && _currentStatus != NSStreamStatusClosed)
    {
      [self close];
    }
  GSAssignZeroingWeakPointer((void**)&_delegate, (void*)0);
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  [self finalize];
  if (_loops != 0)
    {
      NSFreeMapTable(_loops);
      _loops = 0;
    NSLog(@"_loops changed to %@;", _loops);
    }
  DESTROY(_properties);
  DESTROY(_lastError);
  [super dealloc];
}

- (id) delegate
    NSLog(@"Entering - (id) delegate");
{
    NSLog(@"Returning from method at line: return _delegate;");
  return _delegate;
}

- (id) init
    NSLog(@"Entering - (id) init");
{
  if ((self = [super init]) != nil)
    {
      _delegate = self;
    NSLog(@"_delegate changed to %@;", _delegate);
      _properties = nil;
    NSLog(@"_properties changed to %@;", _properties);
      _lastError = nil;
    NSLog(@"_lastError changed to %@;", _lastError);
      _loops = NSCreateMapTable(NSObjectMapKeyCallBacks,
	NSObjectMapValueCallBacks, 1);
      _currentStatus = NSStreamStatusNotOpen;
    NSLog(@"_currentStatus changed to %@;", _currentStatus);
      _loopID = (void*)self;
    NSLog(@"_loopID changed to %@;", _loopID);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  if (_currentStatus != NSStreamStatusNotOpen
    && _currentStatus != NSStreamStatusOpening)
    {
      NSDebugMLLog(@"NSStream", @"Attempt to re-open stream %@", self);
    }
  [self _setStatus: NSStreamStatusOpen];
  [self _schedule];
  [self _sendEvent: NSStreamEventOpenCompleted];
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
    NSLog(@"Returning from method at line: return [_properties objectForKey: key];");
  return [_properties objectForKey: key];
}

- (void) receivedEvent: (void*)data
    NSLog(@"Entering - (void) receivedEvent: (void*)data");
                  type: (RunLoopEventType)type
		 extra: (void*)extra
	       forMode: (NSString*)mode
{
  [self _dispatch];
}

- (void) removeFromRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode
    NSLog(@"Entering - (void) removeFromRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode");
{
  if (aRunLoop != nil && mode != nil)
    {
      NSMutableArray	*modes;

      modes = (NSMutableArray*)NSMapGet(_loops, (void*)aRunLoop);
    NSLog(@"modes changed to %@;", modes);
      if ([modes containsObject: mode])
	{
	  [aRunLoop removeStream: self mode: mode];
	  [modes removeObject: mode];
	  if ([modes count] == 0)
	    {
	      NSMapRemove(_loops, (void*)aRunLoop);
	    }
	}
    }
}

- (void) scheduleInRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode
    NSLog(@"Entering - (void) scheduleInRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode");
{
  if (aRunLoop != nil && mode != nil)
    {
      NSMutableArray	*modes;

      modes = (NSMutableArray*)NSMapGet(_loops, (void*)aRunLoop);
    NSLog(@"modes changed to %@;", modes);
      if (modes == nil)
	{
	  modes = [[NSMutableArray alloc] initWithCapacity: 1];
    NSLog(@"modes changed to %@;", modes);
	  NSMapInsert(_loops, (void*)aRunLoop, (void*)modes);
	  RELEASE(modes);
	}
      if ([modes containsObject: mode] == NO)
	{
	  mode = [mode copy];
    NSLog(@"mode changed to %@;", mode);
	  [modes addObject: mode];
	  RELEASE(mode);
	  /* We only add open streams to the runloop .. subclasses may add
	   * streams when they are in the process of opening if they need
	   * to do so.
	   */
	  if ([self _isOpened])
	    {
	      [aRunLoop addStream: self mode: mode];
	    }
	}
    }
}

- (void) setDelegate: (id)delegate
    NSLog(@"Entering - (void) setDelegate: (id)delegate");
{
  if ([self streamStatus] == NSStreamStatusClosed
    || [self streamStatus] == NSStreamStatusError)
    {
      _delegateValid = NO;
    NSLog(@"_delegateValid changed to %@;", _delegateValid);
      GSAssignZeroingWeakPointer((void**)&_delegate, (void*)0);
    }
  else
    {
      if (delegate == nil)
	{
	  _delegate = self;
    NSLog(@"_delegate changed to %@;", _delegate);
	}
      if (delegate == self)
	{
	  if (_delegate != nil && _delegate != self)
	    {
              GSAssignZeroingWeakPointer((void**)&_delegate, (void*)0);
	    }
	  _delegate = delegate;
    NSLog(@"_delegate changed to %@;", _delegate);
	}
      else
	{
          GSAssignZeroingWeakPointer((void**)&_delegate, (void*)delegate);
	}
      /* We don't want to send any events the the delegate after the
       * stream has been closed.
       */
      _delegateValid
        = [_delegate respondsToSelector: @selector(stream:handleEvent:)];
    }
}

- (BOOL) setProperty: (id)property forKey: (NSString *)key
    NSLog(@"Entering - (BOOL) setProperty: (id)property forKey: (NSString *)key");
{
  if (_properties == nil)
    {
      _properties = [NSMutableDictionary new];
    NSLog(@"_properties changed to %@;", _properties);
    }
  [_properties setObject: property forKey: key];
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}

- (NSError *) streamError
    NSLog(@"Entering - (NSError *) streamError");
{
    NSLog(@"Returning from method at line: return _lastError;");
  return _lastError;
}

- (NSStreamStatus) streamStatus
    NSLog(@"Entering - (NSStreamStatus) streamStatus");
{
    NSLog(@"Returning from method at line: return _currentStatus;");
  return _currentStatus;
}

@end


@implementation	NSStream (Private)

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
}

- (BOOL) _isOpened
    NSLog(@"Entering - (BOOL) _isOpened");
{
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (void*) _loopID
    NSLog(@"Entering - (void*) _loopID");
{
    NSLog(@"Returning from method at line: return (void*)self;	// By default a stream is a TRIGGER event.");
  return (void*)self;	// By default a stream is a TRIGGER event.
}

- (void) _recordError
    NSLog(@"Entering - (void) _recordError");
{
}

- (void) _recordError: (NSError*)anError
    NSLog(@"Entering - (void) _recordError: (NSError*)anError");
{
    NSLog(@"Returning from method at line: return;");
  return;
}

- (void) _resetEvents: (NSUInteger)mask
    NSLog(@"Entering - (void) _resetEvents: (NSUInteger)mask");
{
    NSLog(@"Returning from method at line: return;");
  return;
}

- (void) _schedule
    NSLog(@"Entering - (void) _schedule");
{
}

- (void) _sendEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) _sendEvent: (NSStreamEvent)event");
{
}

- (void) _setLoopID: (void *)ref
    NSLog(@"Entering - (void) _setLoopID: (void *)ref");
{
}

- (void) _setStatus: (NSStreamStatus)newStatus
    NSLog(@"Entering - (void) _setStatus: (NSStreamStatus)newStatus");
{
}

- (BOOL) _unhandledData
    NSLog(@"Entering - (BOOL) _unhandledData");
{
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (void) _unschedule
    NSLog(@"Entering - (void) _unschedule");
{
}

@end

@implementation	GSStream (Private)

- (BOOL) _isOpened
    NSLog(@"Entering - (BOOL) _isOpened");
{
    NSLog(@"Returning from method at line: return !(_currentStatus == NSStreamStatusNotOpen");
  return !(_currentStatus == NSStreamStatusNotOpen
    || _currentStatus == NSStreamStatusOpening
    || _currentStatus == NSStreamStatusClosed);
    NSLog(@"_currentStatus changed to %@;", _currentStatus);
}

- (void*) _loopID
    NSLog(@"Entering - (void*) _loopID");
{
    NSLog(@"Returning from method at line: return _loopID;");
  return _loopID;
}

- (void) _recordError
    NSLog(@"Entering - (void) _recordError");
{
  NSError *theError;

  theError = [NSError _last];
    NSLog(@"theError changed to %@;", theError);
  [self _recordError: theError];
}

- (void) _recordError: (NSError*)anError
    NSLog(@"Entering - (void) _recordError: (NSError*)anError");
{
  NSDebugMLLog(@"NSStream", @"record error: %@ - %@", self, anError);
  ASSIGN(_lastError, anError);
  [self _setStatus: NSStreamStatusError];
}

- (void) _resetEvents: (NSUInteger)mask
    NSLog(@"Entering - (void) _resetEvents: (NSUInteger)mask");
{
  _events &= ~mask;
}

- (void) _schedule
    NSLog(@"Entering - (void) _schedule");
{
  NSMapEnumerator	enumerator;
  NSRunLoop		*k;
  NSMutableArray	*v;

  enumerator = NSEnumerateMapTable(_loops);
    NSLog(@"enumerator changed to %@;", enumerator);
  while (NSNextMapEnumeratorPair(&enumerator, (void **)(&k), (void**)&v))
    {
      unsigned	i = [v count];
    NSLog(@"i changed to %@;", i);

      while (i-- > 0)
	{
	  [k addStream: self mode: [v objectAtIndex: i]];
	}
    }
  NSEndMapTableEnumeration(&enumerator);
}

- (BOOL) _delegateValid
    NSLog(@"Entering - (BOOL) _delegateValid");
{
    NSLog(@"Returning from method at line: return _delegateValid;");
  return _delegateValid;
}

- (void) _sendEvent: (NSStreamEvent)event
    NSLog(@"Entering - (void) _sendEvent: (NSStreamEvent)event");
{
  id delegate = [self delegate];
    NSLog(@"delegate changed to %@;", delegate);
  BOOL delegateValid = [self _delegateValid];
    NSLog(@"delegateValid changed to %@;", delegateValid);
  
  if (event == NSStreamEventNone)
    {
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else if (event == NSStreamEventOpenCompleted)
    {
      if ((_events & event) == 0)
	{
	  _events |= NSStreamEventOpenCompleted;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventOpenCompleted];
	    }
	}
    }
  else if (event == NSStreamEventHasBytesAvailable)
    {
      if ((_events & NSStreamEventOpenCompleted) == 0)
	{
	  _events |= NSStreamEventOpenCompleted;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventOpenCompleted];
	    }
	}
      if ((_events & NSStreamEventHasBytesAvailable) == 0)
	{
	  _events |= NSStreamEventHasBytesAvailable;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventHasBytesAvailable];
	    }
	}
    }
  else if (event == NSStreamEventHasSpaceAvailable)
    {
      if ((_events & NSStreamEventOpenCompleted) == 0)
	{
	  _events |= NSStreamEventOpenCompleted;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventOpenCompleted];
	    }
	}
      if ((_events & NSStreamEventHasSpaceAvailable) == 0)
	{
	  _events |= NSStreamEventHasSpaceAvailable;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventHasSpaceAvailable];
	    }
	}
    }
  else if (event == NSStreamEventErrorOccurred)
    {
      if ((_events & NSStreamEventErrorOccurred) == 0)
	{
	  _events |= NSStreamEventErrorOccurred;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventErrorOccurred];
	    }
	}
    }
  else if (event == NSStreamEventEndEncountered)
    {
      if ((_events & NSStreamEventEndEncountered) == 0)
	{
	  _events |= NSStreamEventEndEncountered;
	  if (delegateValid == YES)
	    {
	      [delegate stream: self
		    handleEvent: NSStreamEventEndEncountered];
	    }
	}
    }
  else
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"Unknown event (%"PRIuPTR") passed to _sendEvent:",
	event];
    }
}

- (void) _setLoopID: (void *)ref
    NSLog(@"Entering - (void) _setLoopID: (void *)ref");
{
  _loopID = ref;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) _setStatus: (NSStreamStatus)newStatus
    NSLog(@"Entering - (void) _setStatus: (NSStreamStatus)newStatus");
{
  if (_currentStatus != newStatus)
    {
      if (NSStreamStatusError == newStatus && NSCountMapTable(_loops) > 0)
        {
          /* After an error, we are in the run loops only to trigger
           * errors, not for I/O, sop we must re-schedule in the right mode.
           */
          [self _unschedule];
  _currentStatus = newStatus;
    NSLog(@"_currentStatus changed to %@;", _currentStatus);
          [self _schedule];
}
      else
        {
          _currentStatus = newStatus;
    NSLog(@"_currentStatus changed to %@;", _currentStatus);
        }
    }
}

- (BOOL) _unhandledData
    NSLog(@"Entering - (BOOL) _unhandledData");
{
  if (_events
    & (NSStreamEventHasBytesAvailable | NSStreamEventHasSpaceAvailable))
    {
    NSLog(@"Returning from method at line: return YES;");
      return YES;
    }
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (void) _unschedule
    NSLog(@"Entering - (void) _unschedule");
{
  NSMapEnumerator	enumerator;
  NSRunLoop		*k;
  NSMutableArray	*v;

  enumerator = NSEnumerateMapTable(_loops);
    NSLog(@"enumerator changed to %@;", enumerator);
  while (NSNextMapEnumeratorPair(&enumerator, (void **)(&k), (void**)&v))
    {
      unsigned	i = [v count];
    NSLog(@"i changed to %@;", i);

      while (i-- > 0)
	{
	  [k removeStream: self mode: [v objectAtIndex: i]];
	}
    }
  NSEndMapTableEnumeration(&enumerator);
}

- (BOOL) runLoopShouldBlock: (BOOL*)trigger
    NSLog(@"Entering - (BOOL) runLoopShouldBlock: (BOOL*)trigger");
{
  if (_events
    & (NSStreamEventHasBytesAvailable | NSStreamEventHasSpaceAvailable))
    {
      /* If we have an unhandled data event, we should not watch for more
       * or trigger until the appropriate read or write has been done.
       */
      *trigger = NO;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
      return NO;
    }
  if (_currentStatus == NSStreamStatusError)
    {
      if ((_events & NSStreamEventErrorOccurred) == 0)
	{
	  /* An error has occurred but not been handled,
	   * so we should trigger an error event at once.
	   */
	  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
	}
      else
	{
	  /* An error has occurred (and been handled),
	   * so we should not watch for any events at all.
	   */
	  *trigger = NO;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
	}
    }
  if (_currentStatus == NSStreamStatusAtEnd)
    {
      if ((_events & NSStreamEventEndEncountered) == 0)
	{
	  /* An end of stream has occurred but not been handled,
	   * so we should trigger an end of stream event at once.
	   */
	  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
	}
      else
	{
	  /* An end of stream has occurred (and been handled),
	   * so we should not watch for any events at all.
	   */
	  *trigger = NO;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
	  return NO;
	}
    }

  if (_loopID == (void*)self)
    {
      /* If _loopID is the receiver, the stream is not receiving external
       * input, so it must trigger an event when the loop runs and must not
       * block the loop from running.
       */
      *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
      return NO;
    }
  else
    {
      *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return YES;");
      return YES;
    }
}
@end

@implementation	GSInputStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  if (self == [GSInputStream class])
    {
      GSObjCAddClassBehavior(self, [GSStream class]);
      GSMakeWeakPointer(self, "delegate");
    }
}

- (BOOL) hasBytesAvailable
    NSLog(@"Entering - (BOOL) hasBytesAvailable");
{
  if (_currentStatus == NSStreamStatusOpen)
    {
    NSLog(@"Returning from method at line: return YES;");
      return YES;
    }
  if (_currentStatus == NSStreamStatusAtEnd)
    {
      if ((_events & NSStreamEventEndEncountered) == 0)
	{
	  /* We have not sent the appropriate event yet, so the
           * client must not have issued a read:maxLength:
	   * (which is the point at which we should send).
	   */
    NSLog(@"Returning from method at line: return YES;");
	  return YES;
	}
    }
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

@end

@implementation	GSOutputStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  if (self == [GSOutputStream class])
    {
      GSObjCAddClassBehavior(self, [GSStream class]);
      GSMakeWeakPointer(self, "delegate");
    }
}

- (BOOL) hasSpaceAvailable
    NSLog(@"Entering - (BOOL) hasSpaceAvailable");
{
  if (_currentStatus == NSStreamStatusOpen)
    {
    NSLog(@"Returning from method at line: return YES;");
      return YES;
    }
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

@end


@implementation GSDataInputStream

/**
 * the designated initializer
 */ 
- (id) initWithData: (NSData *)data
    NSLog(@"Entering - (id) initWithData: (NSData *)data");
{
  if ((self = [super init]) != nil)
    {
      ASSIGN(_data, data);
      _pointer = 0;
    NSLog(@"_pointer changed to %@;", _pointer);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if (_currentStatus != NSStreamStatusNotOpen
    && _currentStatus != NSStreamStatusClosed)
    {
    [self close];
    }
  RELEASE(_data);
  [super dealloc];
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSUInteger dataSize;

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"zero byte read write requested"];
    }

  if ([self streamStatus] == NSStreamStatusClosed
    || [self streamStatus] == NSStreamStatusAtEnd)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  /* Mark the data availability event as handled, so we can generate more.
   */
  _events &= ~NSStreamEventHasBytesAvailable;

  dataSize = [_data length];
    NSLog(@"dataSize changed to %@;", dataSize);
  NSAssert(dataSize >= _pointer, @"Buffer overflow!");
  if (len + _pointer >= dataSize)
    {
      len = dataSize - _pointer;
    NSLog(@"len changed to %@;", len);
      [self _setStatus: NSStreamStatusAtEnd];
    }
  if (len > 0) 
    {
      memcpy(buffer, [_data bytes] + _pointer, len);
      _pointer = _pointer + len;
    NSLog(@"_pointer changed to %@;", _pointer);
    }
    NSLog(@"Returning from method at line: return len;");
  return len;
}

- (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len
    NSLog(@"Entering - (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len");
{
  unsigned long dataSize = [_data length];
    NSLog(@"dataSize changed to %@;", dataSize);

  NSAssert(dataSize >= _pointer, @"Buffer overflow!");
  *buffer = (uint8_t*)[_data bytes] + _pointer;
    NSLog(@"buffer changed to %@;", buffer);
  *len = dataSize - _pointer;
    NSLog(@"len changed to %@;", len);
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}

- (BOOL) hasBytesAvailable
    NSLog(@"Entering - (BOOL) hasBytesAvailable");
{
  unsigned long dataSize = [_data length];
    NSLog(@"dataSize changed to %@;", dataSize);

    NSLog(@"Returning from method at line: return (dataSize > _pointer);");
  return (dataSize > _pointer);
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  if ([key isEqualToString: NSStreamFileCurrentOffsetKey])
    NSLog(@"Returning from method at line: return [NSNumber numberWithLong: _pointer];");
    return [NSNumber numberWithLong: _pointer];
    NSLog(@"Returning from method at line: return [super propertyForKey: key];");
  return [super propertyForKey: key];
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  BOOL av = [self hasBytesAvailable];
    NSLog(@"av changed to %@;", av);
  NSStreamEvent myEvent = av ? NSStreamEventHasBytesAvailable : 
    NSStreamEventEndEncountered;
  NSStreamStatus myStatus = av ? NSStreamStatusOpen : NSStreamStatusAtEnd;
    NSLog(@"myStatus changed to %@;", myStatus);
  
  [self _setStatus: myStatus];
  [self _sendEvent: myEvent];
}

@end


@implementation GSBufferOutputStream

- (id) initToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity
    NSLog(@"Entering - (id) initToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity");
{
  if ((self = [super init]) != nil)
    {
      _buffer = buffer;
    NSLog(@"_buffer changed to %@;", _buffer);
      _capacity = capacity;
    NSLog(@"_capacity changed to %@;", _capacity);
      _pointer = 0;
    NSLog(@"_pointer changed to %@;", _pointer);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"zero byte length write requested"];
    }

  if ([self streamStatus] == NSStreamStatusClosed
    || [self streamStatus] == NSStreamStatusAtEnd)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  /* We have consumed the 'writable' event ... mark that so another can
   * be generated.
   */
  _events &= ~NSStreamEventHasSpaceAvailable;
  if ((_pointer + len) > _capacity)
    {
      len = _capacity - _pointer;
    NSLog(@"len changed to %@;", len);
      [self _setStatus: NSStreamStatusAtEnd];
    }

  if (len > 0)
    {
      memcpy((_buffer + _pointer), buffer, len);
      _pointer += len;
    }
    NSLog(@"Returning from method at line: return len;");
  return len;
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  if ([key isEqualToString: NSStreamFileCurrentOffsetKey])
    {
    NSLog(@"Returning from method at line: return [NSNumber numberWithLong: _pointer];");
      return [NSNumber numberWithLong: _pointer];
    }
    NSLog(@"Returning from method at line: return [super propertyForKey: key];");
  return [super propertyForKey: key];
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  BOOL av = [self hasSpaceAvailable];
    NSLog(@"av changed to %@;", av);
  NSStreamEvent myEvent = av ? NSStreamEventHasSpaceAvailable : 
    NSStreamEventEndEncountered;

  [self _sendEvent: myEvent];
}

@end

@implementation GSDataOutputStream

- (id) init
    NSLog(@"Entering - (id) init");
{
  if ((self = [super init]) != nil)
    {
      _data = [NSMutableData new];
    NSLog(@"_data changed to %@;", _data);
      _pointer = 0;
    NSLog(@"_pointer changed to %@;", _pointer);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  RELEASE(_data);
  [super dealloc];
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
		  format: @"zero byte length write requested"];
    }

  if ([self streamStatus] == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  /* We have consumed the 'writable' event ... mark that so another can
   * be generated.
   */
  _events &= ~NSStreamEventHasSpaceAvailable;
  [_data appendBytes: buffer length: len];
  _pointer += len;
    NSLog(@"Returning from method at line: return len;");
  return len;
}

- (BOOL) hasSpaceAvailable
    NSLog(@"Entering - (BOOL) hasSpaceAvailable");
{
    NSLog(@"Returning from method at line: return YES;");
  return YES;
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  if ([key isEqualToString: NSStreamFileCurrentOffsetKey])
    {
    NSLog(@"Returning from method at line: return [NSNumber numberWithLong: _pointer];");
      return [NSNumber numberWithLong: _pointer];
    }
  else if ([key isEqualToString: NSStreamDataWrittenToMemoryStreamKey])
    {
    NSLog(@"Returning from method at line: return _data;");
      return _data;
    }
    NSLog(@"Returning from method at line: return [super propertyForKey: key];");
  return [super propertyForKey: key];
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  BOOL av = [self hasSpaceAvailable];
    NSLog(@"av changed to %@;", av);
  NSStreamEvent myEvent = av ? NSStreamEventHasSpaceAvailable : 
    NSStreamEventEndEncountered;

  [self _sendEvent: myEvent];
}

@end

@interface	GSLocalServerStream : GSServerStream
@end

@implementation GSServerStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  GSMakeWeakPointer(self, "delegate");
}

+ (id) serverStreamToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering + (id) serverStreamToAddr: (NSString*)addr port: (NSInteger)port");
{
  GSServerStream *s;

  // try inet first, then inet6
  s = [[GSInetServerStream alloc] initToAddr: addr port: port];
    NSLog(@"s changed to %@;", s);
  if (!s)
    s = [[GSInet6ServerStream alloc] initToAddr: addr port: port];
    NSLog(@"s changed to %@;", s);
    NSLog(@"Returning from method at line: return AUTORELEASE(s);");
  return AUTORELEASE(s);
}

+ (id) serverStreamToAddr: (NSString*)addr
    NSLog(@"Entering + (id) serverStreamToAddr: (NSString*)addr");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSLocalServerStream alloc] initToAddr: addr]);");
  return AUTORELEASE([[GSLocalServerStream alloc] initToAddr: addr]);
}

- (id) initToAddr: (NSString*)addr port: (NSInteger)port
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr port: (NSInteger)port");
{
  DESTROY(self);
  // try inet first, then inet6
  self = [[GSInetServerStream alloc] initToAddr: addr port: port];
    NSLog(@"self changed to %@;", self);
  if (!self)
    self = [[GSInet6ServerStream alloc] initToAddr: addr port: port];
    NSLog(@"self changed to %@;", self);
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (id) initToAddr: (NSString*)addr
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSLocalServerStream alloc] initToAddr: addr];");
  return [[GSLocalServerStream alloc] initToAddr: addr];
}

- (void) acceptWithInputStream: (NSInputStream **)inputStream 
    NSLog(@"Entering - (void) acceptWithInputStream: (NSInputStream **)inputStream");
                  outputStream: (NSOutputStream **)outputStream
{
  [self subclassResponsibility: _cmd];
}

@end

@implementation GSAbstractServerStream

+ (void) initialize
    NSLog(@"Entering + (void) initialize");
{
  if (self == [GSAbstractServerStream class])
    {
      GSObjCAddClassBehavior(self, [GSStream class]);
    }
}

@end

