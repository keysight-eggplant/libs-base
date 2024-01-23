########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 01b13228d3ecfd3d555d73daf1c448ad809970a9
# Date: 2016-09-13 20:15:05 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/* Common information for all objc runtime tests.
 */
#include <stdlib.h>
#include <objc/objc.h>

#if __GNU_LIBOBJC__
# include <objc/runtime.h>
# include <objc/message.h>
#else
# include <objc/objc-api.h>
#endif

#include <objc/Object.h>

#ifdef __GNUSTEP_RUNTIME__
#include <objc/hooks.h>
#endif

/* Provide an implementation of NXConstantString for an old libobjc when
   built stand-alone without an NXConstantString implementation.  */
#if !defined(NeXT_RUNTIME) && !defined(__GNUSTEP_RUNTIME__)
@implementation NXConstantString
- (const char*) cString
{
  return 0;
}
- (unsigned int) length
{
  return 0;
}
@end
#endif

#if     !defined(__APPLE__)

#if HAVE_OBJC_ROOT_CLASS_ATTRIBUTE
#define GS_OBJC_ROOT_CLASS __attribute__((objc_root_class))
#else
#define GS_OBJC_ROOT_CLASS
#endif

/* Provide dummy implementations for NSObject and NSConstantString
 * for libobjc2 which needs them.
 */
GS_OBJC_ROOT_CLASS @interface NSObject
{ 
 id isa;
}
@end
@implementation NSObject
+ (id)new
{
  NSObject *obj = calloc(sizeof(id), 1);
  obj->isa = self;
  return obj;
}
#if defined(NeXT_RUNTIME)
/* The Apple runtime always calls this method */
+ (void)initialize { }
#endif
@end

@interface NSConstantString : NSObject
@end
@implementation NSConstantString
@end
#endif  /* __APPLE__ */

