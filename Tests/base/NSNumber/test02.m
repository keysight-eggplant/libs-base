########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSPropertyList.h>
#import <Foundation/NSValue.h>
#import <Foundation/NSDecimalNumber.h>

#include <stdlib.h>
#include <limits.h>

int main()
{
  START_SET("NSDecimalNumber")
    NSDecimalNumberHandler      *handler;
    NSDecimalNumber             *n1;
    NSDecimalNumber             *n2;
    NSString                    *s1;
    NSString                    *s2;

    handler = [NSDecimalNumberHandler alloc];
    handler = [[handler initWithRoundingMode: NSRoundPlain
                                       scale: 2
                            raiseOnExactness: NO
                             raiseOnOverflow: NO
                            raiseOnUnderflow: NO
                         raiseOnDivideByZero: NO] autorelease];

    s1 = [NSString stringWithFormat: @"%0.2f", 0.009];
    n1 = [NSDecimalNumber decimalNumberWithString: @"0.009"];
    n2 = [n1 decimalNumberByRoundingAccordingToBehavior: handler];
    s2 = [n2 description];
    PASS_EQUAL(s2, s1, "rounding 0.009");

    s1 = [NSString stringWithFormat: @"%0.2f", 0.019];
    n1 = [NSDecimalNumber decimalNumberWithString: @"0.019"];
    n2 = [n1 decimalNumberByRoundingAccordingToBehavior: handler];
    s2 = [n2 description];
    PASS_EQUAL(s2, s1, "rounding 0.019");

    handler = [NSDecimalNumberHandler alloc];
    handler = [[handler initWithRoundingMode: NSRoundPlain
                                       scale: 3
                            raiseOnExactness: NO
                             raiseOnOverflow: NO
                            raiseOnUnderflow: NO
                         raiseOnDivideByZero: NO] autorelease];

    s1 = [NSString stringWithFormat: @"%0.3f", 0.0009];
    n1 = [NSDecimalNumber decimalNumberWithString: @"0.0009"];
    n2 = [n1 decimalNumberByRoundingAccordingToBehavior: handler];
    s2 = [n2 description];
    PASS_EQUAL(s2, s1, "rounding 0.0009");

    s1 = [NSString stringWithFormat: @"%0.3f", 0.0019];
    n1 = [NSDecimalNumber decimalNumberWithString: @"0.0019"];
    n2 = [n1 decimalNumberByRoundingAccordingToBehavior: handler];
    s2 = [n2 description];
    PASS_EQUAL(s2, s1, "rounding 0.0019");

  END_SET("NSDecimalNumber")

  return 0;
}
