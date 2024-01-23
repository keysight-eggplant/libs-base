########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 61e39b584c8bcbb531df4560875c052bc30ebd46
# Date: 2015-06-16 19:12:49 +0000
########## End of Keysight Technologies Notice ##########
/** DLL entry routine
   Copyright (C) 1996, 1997 Free Software Foundation, Inc.

   Original Author:  Scott Christley <scottc@net-community.com>
   Created: 1996

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

/* Only if using Microsoft's tools and libraries */
#ifdef __MS_WIN32__
#include <stdio.h>
WINBOOL WINAPI _CRT_INIT(HINSTANCE hinstDLL, DWORD fdwReason,
			  LPVOID lpReserved);

// Global errno isn't defined in Microsoft's thread safe C library
void errno()
{}

int _MB_init_runtime()
{
    return 0;
}
#endif /* __MS_WIN32__ */

// Testplant-MAL-2015-07-07
#if defined(__WIN32__)
#include <winsock2.h>
#endif

void
gnustep_base_socket_init()
{
  /* Start of sockets so we can get host name and other info */
  static WSADATA wsaData;
  if (WSAStartup(MAKEWORD(2,0), &wsaData))
    {
      NSLog(@"Error: Could not startup Windows Sockets.\n");
    }
}

//
// DLL entry function for GNUstep Base Library
// This function gets called everytime a process/thread attaches to DLL
//
// Testplant-MAL-2015-07-07
WINBOOL WINAPI
DllMain(HINSTANCE hInst, DWORD ul_reason_for_call, LPVOID lpReserved)
{
  switch(ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
      {
#ifdef __MS_WIN32__
	/* Initialize the Microsoft C stdio DLL */
	_CRT_INIT(hInst, ul_reason_for_call, lpReserved);

#endif /* __MS_WIN32__ */

	// Initialize Windows Sockets
	gnustep_base_socket_init();
	break;
      }

    case DLL_PROCESS_DETACH:
      {
	break;
      }

    case DLL_THREAD_ATTACH:
      {
#ifdef __MS_WIN32__
	/* Initialize C stdio DLL */
	_CRT_INIT(hInst, ul_reason_for_call, lpReserved);
#endif /* __MS_WIN32__ */

	break;
      }

    case DLL_THREAD_DETACH:
      {
	break;
      }
    }

  return TRUE;
}

/*
  This section terminates the list of imports under GCC. If you do not
  include this then you will have problems when linking with DLLs.
  */
asm (".section .idata$3\n" ".long 0,0,0,0,0,0,0,0");
