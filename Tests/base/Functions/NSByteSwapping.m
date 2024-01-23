########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 916b60ebf4dcf52cea4b7f6c82043ec5a4d008a4
# Date: 2016-10-03 12:51:49 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
#import <Foundation/Foundation.h>
#import "Testing.h"

int main()
{ 
  NSAutoreleasePool   *pool = [NSAutoreleasePool new];
  float flt=M_PI;
  double dbl=M_PI;

  PASS(NSSwapShort(0x1234) == (unsigned short)0x3412, "NSSwapShort works");

  if (sizeof(long) == 4)
    {
      PASS(NSSwapLong(0x12345678L) == 0x78563412UL, "NSSwapLong works");
    }
  else if (sizeof(long) == 8)
    {
      PASS(NSSwapLongLong(0x123456789abcdef0LL) == 0xf0debc9a78563412LL,
        "NSSwapLongLong works");
    }

  if (sizeof(long long) == 8)
    {
      PASS(NSSwapLongLong(0x123456789abcdef0LL) == 0xf0debc9a78563412LL,
        "NSSwapLongLong works");
    }

  PASS(NSSwapBigFloatToHost(*((NSSwappedFloat *)&flt))
    == ((NSHostByteOrder() == NS_LittleEndian)
    ? (float)-40331460896358400.0
    : (float)M_PI),
    "NSSwapBigFloatToHost works");

  PASS(NSSwapLittleFloatToHost(*((NSSwappedFloat *)&flt))
    == ((NSHostByteOrder() == NS_BigEndian)
    ? (float)-40331460896358400.0
    : (float)M_PI),
    "NSSwapLittleFloatToHost works");

  PASS(NSSwapBigDoubleToHost(*((NSSwappedDouble *)&dbl))
    == ((NSHostByteOrder() == NS_LittleEndian)
    ? 3.20737563067636581208678536384e-192
    : M_PI),
    "NSSwapBigDoubleToHost works");

  PASS(NSSwapLittleDoubleToHost(*((NSSwappedDouble *)&dbl))
    == ((NSHostByteOrder() == NS_BigEndian)
    ? 3.20737563067636581208678536384e-192
    : M_PI),
    "NSSwapLittleDoubleToHost wworks");

  [pool release]; pool = nil;
 
  return 0;
}
