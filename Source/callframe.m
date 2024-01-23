########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 8f41bfbd73662058764c587fc1bad329e8e3f4a7
# Date: 2020-06-05 13:56:15 -0400
--------------------
# Committed by: Marcian Lytwyn
# Commit ID: 3047907edbc861099fe405a1b33bbc190621a63f
# Date: 2016-09-13 22:29:24 +0000
########## End of Keysight Technologies Notice ##########
/** callframe.m - Wrapper/Objective-C interface for ffcall function interface

   Copyright (C) 2000, Free Software Foundation, Inc.

   Written by:  Adam Fedor <fedor@gnu.org>
   Created: Nov 2000

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

#ifdef HAVE_MALLOC_H
#include <malloc.h>
#endif
#ifdef HAVE_ALLOCA_H
#include <alloca.h>
#endif

#include "callframe.h"
#import "Foundation/NSException.h"
#import "Foundation/NSData.h"
#import "GSInvocation.h"

#if defined(ALPHA) || (defined(MIPS) && (_MIPS_SIM == _ABIN32))
typedef long long smallret_t;
#else
typedef int smallret_t;
#endif

callframe_t *
callframe_from_signature (NSMethodSignature *info, void **retval)
{
  unsigned      size = sizeof(callframe_t);
  unsigned      align = __alignof(double);
  unsigned      offset = 0;
  unsigned	numargs = [info numberOfArguments];
  void          *buf;
  int           i;
  callframe_t   *cframe;

  if (numargs > 0)
    {
      if (size % align != 0)
        {
          size += align - (size % align);
        }
      offset = size;
      size += numargs * sizeof(void*);
      if (size % align != 0)
        {
          size += (align - (size % align));
        }
      for (i = 0; i < numargs; i++)
        {
	  const char	*type = [info getArgumentTypeAtIndex: i];

	  type = objc_skip_type_qualifiers (type);
          size += objc_sizeof_type (type);
          if (size % align != 0)
            {
              size += (align - size % align);
            }
        }
    }

  /*
   * If we need space allocated to store a return value,
   * make room for it at the end of the callframe so we
   * only need to do a single malloc.
   */
  if (retval)
    {
      const char	*type;
      unsigned		full = size;
      unsigned		pos;
      unsigned		ret;

      type = [info methodReturnType];
      type = objc_skip_type_qualifiers (type);
      if (full % align != 0)
	{
	  full += (align - full % align);
	}
      if (full % 8 != 0)
	{
	  full += (8 - full % 8);
	}
      pos = full;
      ret = MAX(objc_sizeof_type (type), sizeof(double));
      /* The addition of a constant '8' is a fudge applied simply because
       * some return values write beynd the end of the memory if the buffer
       * is sized exactly ... don't know why.
       */
      full += ret + 8;
      cframe = buf = NSZoneCalloc(NSDefaultMallocZone(), full, 1);
      if (cframe)
	{
	  *retval = buf + pos;
	}
    }
  else
    {
      cframe = buf = NSZoneCalloc(NSDefaultMallocZone(), size, 1);
    }

  if (cframe)
    {
      cframe->nargs = numargs;
      cframe->args = buf + offset;
      offset += numargs * sizeof(void*);
      if (offset % align != 0)
        {
          offset += align - (offset % align);
        }
      for (i = 0; i < cframe->nargs; i++)
        {
	  const char	*type = [info getArgumentTypeAtIndex: i];

          cframe->args[i] = buf + offset;

	  type = objc_skip_type_qualifiers (type);
          offset += objc_sizeof_type (type);

          if (offset % align != 0)
            {
              offset += (align - offset % align);
            }
        }
    }

  return cframe;
}

void
callframe_set_arg(callframe_t *cframe, int index, void *buffer, int size)
{
  if (index < 0 || index >= cframe->nargs)
     return;
  memcpy(cframe->args[index], buffer, size);
}

void
callframe_get_arg(callframe_t *cframe, int index, void *buffer, int size)
{
  if (index < 0 || index >= cframe->nargs)
     return;
  memcpy(buffer, cframe->args[index], size);
}

void *
callframe_arg_addr(callframe_t *cframe, int index)
{
  if (index < 0 || index >= cframe->nargs)
     return NULL;
  return cframe->args[index];
}

