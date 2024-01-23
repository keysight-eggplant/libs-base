########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 8f41bfbd73662058764c587fc1bad329e8e3f4a7
# Date: 2020-06-05 13:56:15 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 3047907edbc861099fe405a1b33bbc190621a63f
# Date: 2016-09-13 22:29:24 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/* cifframe - Wrapper/Objective-C interface for ffi function interface

   Copyright (C) 1999, Free Software Foundation, Inc.
   
   Written by:  Adam Fedor <fedor@gnu.org>
   Created: Feb 2000
   
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

#ifndef cifframe_h_INCLUDE
#define cifframe_h_INCLUDE

#include <ffi.h>

#if	defined(_WIN32)
/*
 * Avoid conflicts when other headers try to define UINT32 and UINT64
 */
#if	defined(UINT32)
#undef UINT32
#endif
#if	defined(UINT64)
#undef UINT64
#endif
#endif

#import "Foundation/NSMethodSignature.h"
#import "GNUstepBase/DistributedObjects.h"
#import "GSPrivate.h"

typedef struct _cifframe_t {
  ffi_cif cif;
  int nargs;
  ffi_type **arg_types;
  void **values;
} cifframe_t;

@class	NSMutableData;

extern NSMutableData *cifframe_from_signature (NSMethodSignature *info);

extern GSCodeBuffer* cifframe_closure (NSMethodSignature *sig, void (*func)());

extern void cifframe_set_arg(cifframe_t *cframe, int index, void *buffer, 
			     int size);
extern void cifframe_get_arg(cifframe_t *cframe, int index, void *buffer,
			     int size);
extern void *cifframe_arg_addr(cifframe_t *cframe, int index);
extern BOOL cifframe_decode_arg (const char *type, void* buffer);
extern BOOL cifframe_encode_arg (const char *type, void* buffer);

#endif
