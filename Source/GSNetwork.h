########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: dec601d5798e1f52294b472060c21f21aad89671
# Date: 2018-03-13 19:14:12 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 36f527303dd69064d2bf95c6606ab69374ab1cf7
# Date: 2016-09-17 00:21:01 +0000
########## End of Keysight Technologies Notice ##########
#ifndef INCLUDED_GSNETWORK_H
#define INCLUDED_GSNETWORK_H    1

/* GSNetwork.h - This collects the system header files needed for
   networking code.  In future it may also contain internal wrappers
   to standardise networking operations.

   Copyright (C) 2008, Free Software Foundation, Inc.
   
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Created: Jan 2008
   
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

#include <sys/types.h>
#include <sys/stat.h>

#if	defined(HAVE_SYS_FCNTL_H)
#  include	<sys/fcntl.h>
#elif	defined(HAVE_FCNTL_H)
#  include	<fcntl.h>
#endif


#if     defined(_WIN32)

#if     defined(__WIN64__)
#include <winsock2.h>
#endif

#include <io.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#if     !defined(EAFNOSUPPORT)
#define EAFNOSUPPORT WSAEAFNOSUPPORT
#endif
#define BADSOCKET(X)    ((X) == INVALID_SOCKET)
#define GSNETERROR      WSAGetLastError() 
#define GSWOULDBLOCK    (GSNETERROR == WSAEWOULDBLOCK || GSNETERROR == WSAEINPROGRESS)

#else

#include <sys/socket.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#ifndef	AF_LOCAL
#define	AF_LOCAL	AF_UNIX
#endif
#ifndef	PF_LOCAL
#define	PF_LOCAL	PF_UNIX
#endif

#define SOCKET  int     /* Socket type  */
#define INVALID_SOCKET  -1
#define BADSOCKET(X)    ((X) < 0)
#define GSNETERROR      errno
#define GSWOULDBLOCK    (EINPROGRESS == errno\
 || EALREADY == errno\
 || EINTR == errno\
 || EAGAIN == errno)

#endif  /* _WIN32 */

/* The backlog argument to the listen() system call.
 * Systems should silently truncate the backlog if they don't support one
 * as large as we set, so it makes sense to set a large value in order to
 * support high volume applications.
 */
#define	GSBACKLOG	10000

#ifndef INADDRSZ
#define INADDRSZ        4
#endif

#ifndef IN6ADDRSZ
#define IN6ADDRSZ       16
#endif

#if     !defined(HAVE_SOCKLEN_T)
#  if   !defined(socklen_t)
#    define	socklen_t	uint32_t
#  endif
#endif

#import "GSPrivate.h" 

NSString*
GSPrivateSockaddrHost(struct sockaddr *addr) GS_ATTRIB_PRIVATE;

unsigned
GSPrivateSockaddrLength(struct sockaddr *addr) GS_ATTRIB_PRIVATE;

NSString*
GSPrivateSockaddrName(struct sockaddr *addr) GS_ATTRIB_PRIVATE;

uint16_t
GSPrivateSockaddrPort(struct sockaddr *addr) GS_ATTRIB_PRIVATE;

BOOL
GSPrivateSockaddrSetup(NSString *machine, uint16_t port, NSString *service,
  NSString *protocol, struct sockaddr *sin) GS_ATTRIB_PRIVATE;

#endif
