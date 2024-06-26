// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Doug Simons 
// Commit ID: 5297e7b07c5b2b32498b296056094330fa0dab63 
// Date: 2017-01-24 16:49:44 +0000 
// ========== End of Keysight Technologies Notice ========== 
/* objc-load - Dynamically load in Obj-C modules (Classes, Categories)

   Copyright (C) 1995, 1996, 1997 Free Software Foundation, Inc.

   Written by:  Adam Fedor, Pedja Bogdanovich

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

/* PS: Unloading modules is not implemented.  */

#import "common.h"
#include <stdio.h>

#if defined(NeXT_RUNTIME)
# include <objc/objc-load.h>
#endif

#ifdef __GNUSTEP_RUNTIME__
# include <objc/hooks.h>
#endif

#if defined(__CYGWIN__)
# include <windows.h>
#endif

#include "objc-load.h"
#import "Foundation/NSException.h"

#import "GSPrivate.h"

/* include the interface to the dynamic linker */
#include "dynamic-load.h"

/* dynamic_loaded is YES if the dynamic loader was sucessfully initialized. */
static BOOL	dynamic_loaded;

/* Our current callback function */
static void (*_objc_load_load_callback)(Class, struct objc_category *) = 0;

/* Check to see if there are any undefined symbols. Print them out.
*/
static int
objc_check_undefineds(FILE *errorStream)
{
  int count = __objc_dynamic_undefined_symbol_count();

  if (count != 0)
    {
      int  i;
      char **undefs;

      undefs = __objc_dynamic_list_undefined_symbols();
      if (errorStream)
	{
	  fprintf(errorStream, "Undefined symbols:\n");
	}
      for (i = 0; i < count; i++)
	{
	  if (errorStream)
	    {
	      fprintf(errorStream, "  %s\n", undefs[i]);
	    }
	}
      return 1;
    }
  return 0;
}

/* Initialize for dynamic loading */
static int
objc_initialize_loading(FILE *errorStream)
{
  NSString	*path;
#if     defined(_WIN32) || defined(__CYGWIN__)
  const unichar *fsPath;
#else  
  const char *fsPath;
#endif  

  dynamic_loaded = NO;
  path = GSPrivateExecutablePath();

  NSDebugFLLog(@"NSBundle",
    @"Debug (objc-load): initializing dynamic loader for %@", path);

  fsPath = [[path stringByDeletingLastPathComponent] fileSystemRepresentation];
  
  if (__objc_dynamic_init(fsPath))
    {
      if (errorStream)
	{
	  __objc_dynamic_error(errorStream,
           "Error (objc-load): Cannot initialize dynamic linker");
	}
      return 1;
    }
  else
    {
      dynamic_loaded = YES;
    }

  return 0;
}

/* A callback received from the Object initializer (_objc_exec_class).
   Do what we need to do and call our own callback.
*/
static void
objc_load_callback(Class class, struct objc_category * category)
{
  if (_objc_load_load_callback)
    {
      _objc_load_load_callback(class, category);
    }
}

#if	defined(_WIN32) || defined(__CYGWIN__)
#define	FSCHAR	unichar
#else
#define	FSCHAR	char
#endif

long
GSPrivateLoadModule(NSString *filename, FILE *errorStream,
  void (*loadCallback)(Class, struct objc_category *),
  void **header, NSString *debugFilename)
{
#ifdef NeXT_RUNTIME
  int errcode;
  dynamic_loaded = YES;
  return objc_loadModule([filename fileSystemRepresentation],
    loadCallback, &errcode);
#else
  dl_handle_t handle;
  void __objc_resolve_class_links(void);
#if !defined(__ELF__) && !defined(CON_AUTOLOAD)
  typedef void (*void_fn)();
  void_fn *ctor_list;
  int i;
#endif

  if (!dynamic_loaded)
    {
      if (objc_initialize_loading(errorStream))
	{
	  return 1;
	}
    }

  _objc_load_load_callback = loadCallback;
  _objc_load_callback = objc_load_callback;

  /* Link in the object file */
  NSDebugFLLog(@"NSBundle", @"Debug (objc-load): Linking file %@\n", filename);
#ifdef __MINGW__
  handle = LoadLibraryExW((FSCHAR*)[filename fileSystemRepresentation], 0, LOAD_WITH_ALTERED_SEARCH_PATH);
#else
  handle = __objc_dynamic_link((FSCHAR*)[filename fileSystemRepresentation],
    1, (FSCHAR*)[debugFilename fileSystemRepresentation]);
#endif
  if (handle == 0)
    {
      if (errorStream)
	{
	  __objc_dynamic_error(errorStream, "Error (objc-load)");
	}
      _objc_load_load_callback = 0;
      _objc_load_callback = 0;
      return 1;
    }

  /* If there are any undefined symbols, we can't load the bundle */
  if (objc_check_undefineds(errorStream))
    {
      __objc_dynamic_unlink(handle);
      _objc_load_load_callback = 0;
      _objc_load_callback = 0;
      return 1;
    }

#if !defined(__ELF__) && !defined(CON_AUTOLOAD)
  /* Get the constructor list and load in the objects */
  ctor_list = (void_fn *)__objc_dynamic_find_symbol(handle, CTOR_LIST);
  if (!ctor_list)
    {
      if (errorStream)
	{
	  fprintf(errorStream,
	    "Error (objc-load): Cannot load objects (no CTOR list)\n");
	}
      _objc_load_load_callback = 0;
      _objc_load_callback = 0;
      return 1;
    }

  NSDebugFLLog(@"NSBundle",
    @"Debug (objc-load): %d modules\n", (int)ctor_list[0]);
  for (i = 1; ctor_list[i]; i++)
    {
      NSDebugFLLog(@"NSBundle",
	@"Debug (objc-load): Invoking CTOR %p\n", ctor_list[i]);
      ctor_list[i]();
    }
#endif /* not __ELF__ */

#if !defined(__GNUSTEP_RUNTIME__) && !defined(__GNU_LIBOBJC__)
  __objc_resolve_class_links(); /* fill in subclass_list and sibling_class */
#endif
  _objc_load_callback = 0;
  _objc_load_load_callback = 0;
  return 0;
#endif /* not NeXT_RUNTIME */
}

long
GSPrivateUnloadModule(FILE *errorStream,
  void (*unloadCallback)(Class, struct objc_category *))
{
  if (!dynamic_loaded)
    {
      return 1;
    }

  if (errorStream)
    {
      fprintf(errorStream, "Warning: unloading modules not implemented\n");
    }
  return 0;
}


#if defined(_WIN32) || defined(__CYGWIN__)
// FIXME: We can probably get rid of this now - MinGW should include a working
// dladdr() wrapping this function, so we no longer need a Windows-only code
// path
NSString *
GSPrivateSymbolPath(Class theClass, Category *theCategory)
{
  unichar buf[MAX_PATH];
  NSString *s = nil;
  MEMORY_BASIC_INFORMATION memInfo;
  NSCAssert(!theCategory, @"GSPrivateSymbolPath doesn't support categories");

  VirtualQueryEx(GetCurrentProcess(), theClass, &memInfo, sizeof(memInfo));
  if (GetModuleFileNameW(memInfo.AllocationBase, buf, sizeof(buf)))
    {
#ifdef __CYGWIN__
#warning Under Cygwin, we may want to use cygwin_conv_path() to get the unix path back?
#endif
      s = [NSString stringWithCharacters: buf length: wcslen(buf)];
    }
  return s;
}
#elif LINKER_GETSYMBOL 
NSString *GSPrivateSymbolPath(Class theClass, Category *theCategory)
{
	void *addr = (NULL == theCategory) ? (void*)theClass : (void*)theCategory;
	Dl_info info;
	// This is correct: dladdr() does the opposite thing to all other UNIX
	// functions.
	if (0 == dladdr(addr, &info))
	{
		return nil;
	}
	return [NSString stringWithUTF8String: info.dli_fname];
}
#else
NSString *
GSPrivateSymbolPath(Class theClass, Category *theCategory)
{
  const char *ret;
  char        buf[125], *p = buf;
  const char *className = class_getName(theClass);
  int         len = strlen(className);

  if (theCategory == NULL)
    {
      if (len + sizeof(char)*19 > sizeof(buf))
	{
	  p = malloc(len + sizeof(char)*19);

	  if (p == NULL)
	    {
	      fprintf(stderr, "Unable to allocate memory !!");
	      return nil;
	    }
	}

      memcpy(p, "__objc_class_name_", sizeof(char)*18);
	  memcpy(&p[18*sizeof(char)], className, strlen(className) + 1);
    }
  else
    {
      len += strlen(theCategory->category_name);

      if (len + sizeof(char)*23 > sizeof(buf))
	{
	  p = malloc(len + sizeof(char)*23);

	  if (p == NULL)
	    {
	      fprintf(stderr, "Unable to allocate memory !!");
	      return nil;
	    }
	}

      memcpy(p, "__objc_category_name_", sizeof(char)*21);
      memcpy(&p[21*sizeof(char)], theCategory->class_name,
	     strlen(theCategory->class_name) + 1);
      memcpy(&p[strlen(p)], "_", 2*sizeof(char));
      memcpy(&p[strlen(p)], theCategory->category_name,
	     strlen(theCategory->category_name) + 1);
    }

  ret = __objc_dynamic_get_symbol_path(0, p);

  if (p != buf)
    {
      free(p);
    }

  if (ret)
    {
      return [NSString stringWithUTF8String: ret];
    }

  return nil;
}
#endif
