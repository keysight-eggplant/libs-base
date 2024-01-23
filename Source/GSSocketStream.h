########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Royal Stewart
# Commit ID: eda52e8c89838cc3a2e7eff6e0c58386d4d5e271
# Date: 2023-07-07 15:18:16 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 12bffe289dc1f19c7376050adb74eab778cd824b
# Date: 2023-06-29 17:31:36 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 8e217285d9599107c898c47714252bbd945b083e
# Date: 2023-06-29 16:59:32 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 21cafb25e397f3928e62eb5de24075336701f82d
# Date: 2023-06-29 16:23:59 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 2be4b3b4c8e6889aeb21119558593364f9d772ba
# Date: 2023-06-29 16:23:39 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: e61f09225356946164ea5e3b031249ac08efae4e
# Date: 2023-06-29 16:22:40 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 3ab20a0623bec6dc32373991a7f4819455166dd8
# Date: 2023-06-28 21:39:34 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 4012f41e7b754d554b145e1ad4a050d35c109cc4
# Date: 2023-06-28 15:18:35 +0000
--------------------
# Committed by: Royal Stewart
# Commit ID: 0c614b579e32e888f598f381682908cbb5ce1236
# Date: 2023-06-28 15:14:13 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: f1c772c2f5e0bcc744f459b4037e8607ec4c03f1
# Date: 2020-06-09 17:14:59 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 36f527303dd69064d2bf95c6606ab69374ab1cf7
# Date: 2016-09-17 00:21:01 +0000
########## End of Keysight Technologies Notice ##########
#ifndef	INCLUDED_GSSOCKETSTREAM_H
#define	INCLUDED_GSSOCKETSTREAM_H

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

/* You should have included GSStream.h before this */

#import "GSNetwork.h"

typedef	union {
  struct sockaddr_storage	s;
  struct sockaddr_in	i4;
#ifdef	AF_INET6
  struct sockaddr_in6	i6;
#endif
#ifndef	_WIN32
  struct sockaddr_un	u;
#endif
} sockaddr_any;

#define	SOCKIVARS \
{ \
  id            _sibling;       /* For bidirectional traffic.  	*/\
  BOOL          _passive;       /* YES means already connected. */\
  BOOL		_closing;	/* Must close on next failure.	*/\
  SOCKET        _sock;          /* Needed for ms-windows.       */\
  id            _handler;       /* TLS/SOCKS handler.           */\
  sockaddr_any	_address;	/* Socket address info.		*/\
}

/* The semi-abstract GSSocketStream class is not intended to be subclassed
 * but is used to add behaviors to other socket based classes.
 */
@interface GSSocketStream : GSStream
SOCKIVARS

/**
 * get the sockaddr
 */
- (struct sockaddr_storage*) _address;

/**
 * set the sockaddr
 */
- (void) _setAddress: (struct sockaddr_storage*)address;

/**
 * setter for closing flag ... the remote end has stopped either sending
 * or receiving, so any I/O operation which would block means that the
 * connection is no longer operable in that direction.
 */
- (void) _setClosing: (BOOL)passive;

/*
 * Set the handler for this stream.
 */
- (void) _setHandler: (id)h;

/**
 * setter for passive (the underlying socket connection is already open and
 * doesw not need to be re-opened).
 */
- (void) _setPassive: (BOOL)passive;

/**
 * setter for sibling
 */
- (void) _setSibling: (GSSocketStream*)sibling;

/*
 * Set the socket used for this stream.
 */
- (void) _setSock: (SOCKET)sock;

/*
 * Set the socket address from string information.
 */
- (BOOL) _setSocketAddress: (NSString*)address
                      port: (NSInteger)port
                    family: (NSInteger)family;

/* Return the socket
 */
- (SOCKET) _sock;

@end

/**
 * The abstract subclass of NSInputStream that reads from a socket.
 * It inherits from GSInputStream and adds behaviors from GSSocketStream
 * so it must have the same instance variable layout as GSSocketStream.
 */
@interface GSSocketInputStream : GSInputStream
SOCKIVARS
@end
@interface GSSocketInputStream (AddedBehaviors)
- (struct sockaddr_storage*) _address;
- (void) _setAddress: (struct sockaddr_storage*)address;
- (NSInteger) _read: (uint8_t *)buffer maxLength: (NSUInteger)len;
- (void) _setClosing: (BOOL)passive;
- (void) _setHandler: (id)h;
- (void) _setPassive: (BOOL)passive;
- (void) _setSibling: (GSSocketStream*)sibling;
- (void) _setSock: (SOCKET)sock;
- (BOOL) _setSocketAddress: (NSString*)address
                      port: (NSInteger)port
                    family: (NSInteger)family;
- (SOCKET) _sock;
@end

@interface GSInetInputStream : GSSocketInputStream

/**
 * the designated initializer
 */
- (id) initToAddr: (NSString*)addr port: (NSInteger)port;

@end


@interface GSInet6InputStream : GSSocketInputStream

/**
 * the designated initializer
 */
- (id) initToAddr: (NSString*)addr port: (NSInteger)port;

@end

/**
 * The abstract subclass of NSOutputStream that writes to a socket.
 * It inherits from GSOutputStream and adds behaviors from GSSocketStream
 * so it must have the same instance variable layout as GSSocketStream.
 */
@interface GSSocketOutputStream : GSOutputStream
SOCKIVARS
@end
@interface GSSocketOutputStream (AddedBehaviors)
- (struct sockaddr_storage*) _address;
- (void) _setAddress: (struct sockaddr_storage*)address;
- (void) _setClosing: (BOOL)passive;
- (void) _setHandler: (id)h;
- (void) _setPassive: (BOOL)passive;
- (void) _setSibling: (GSSocketStream*)sibling;
- (void) _setSock: (SOCKET)sock;
- (BOOL) _setSocketAddress: (NSString*)address
                      port: (NSInteger)port
                    family: (NSInteger)family;
- (SOCKET) _sock;
- (NSInteger) _write: (const uint8_t *)buffer maxLength: (NSUInteger)len;
@end

@interface GSInetOutputStream : GSSocketOutputStream

/**
 * the designated initializer
 */
- (id) initToAddr: (NSString*)addr port: (NSInteger)port;

@end

@interface GSInet6OutputStream : GSSocketOutputStream

/**
 * the designated initializer
 */
- (id) initToAddr: (NSString*)addr port: (NSInteger)port;

@end


/**
 * The subclass of NSStream that accepts connections from a socket.
 * It inherits from GSAbstractServerStream and adds behaviors from
 * GSSocketStream so it must have the same instance variable layout
 * as GSSocketStream.
 */
@interface GSSocketServerStream : GSAbstractServerStream
SOCKIVARS

/**
 * Return the class of the inputStream associated with this
 * type of serverStream.
 */
- (Class) _inputStreamClass;

/**
 * Return the class of the outputStream associated with this
 * type of serverStream.
 */
- (Class) _outputStreamClass;

@end
@interface GSSocketServerStream (AddedBehaviors)
- (struct sockaddr_storage*) _address;
- (void) _setAddress: (struct sockaddr_storage*)address;
- (void) _setClosing: (BOOL)passive;
- (void) _setHandler: (id)h;
- (void) _setPassive: (BOOL)passive;
- (void) _setSibling: (GSSocketStream*)sibling;
- (void) _setSock: (SOCKET)sock;
- (BOOL) _setSocketAddress: (NSString*)address
                      port: (NSInteger)port
                    family: (NSInteger)family;
- (SOCKET) _sock;
@end

@interface GSInetServerStream : GSSocketServerStream
@end

@interface GSInet6ServerStream : GSSocketServerStream
@end

#endif

