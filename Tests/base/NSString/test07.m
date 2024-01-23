########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
#import "ObjectTesting.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSString.h>

int main()
{
  NSAutoreleasePool	*arp = [NSAutoreleasePool new];
  unichar		u = 0x00a3;	// Pound sign
  NSString		*s;
  double 		d;

  PASS([@"12" intValue] == 12, "simple intValue works");
  PASS([@"-12" intValue] == -12, "negative intValue works");
  PASS([@"+12" intValue] == 12, "positive intValue works");
  PASS([@"1.6" intValue] == 1, "intValue ignores trailing data");
  PASS([@"                                12" intValue] == 12,
    "intValue with leading space works");

  d = [@"1.2" doubleValue];
  PASS(d > 1.199999 && d < 1.200001, "simple doubleValue works");
  PASS([@"1.9" doubleValue] == 90 / 100.0 + 1.0, "precise doubleValue works");
  d = [@"-1.2" doubleValue];
  PASS(d < -1.199999 && d > -1.200001, "negative doubleValue works");
  d = [@"+1.2" doubleValue];
  PASS(d > 1.199999 && d < 1.200001, "positive doubleValue works");
  d = [@"+1.2 x" doubleValue];
  PASS(d > 1.199999 && d < 1.200001, "doubleValue ignores trailing data");
  d = [@"                                1.2" doubleValue];
  PASS(d > 1.199999 && d < 1.200001, "doubleValue with leading space works");

  s = @"50.6468746467461646";
  sscanf([s UTF8String], "%lg", &d);
  PASS(EQ([s doubleValue], d), "50.6468746467461646 -doubleValue OK");

  s = @"50.64687464674616461";
  sscanf([s UTF8String], "%lg", &d);
  PASS(EQ([s doubleValue], d), "50.64687464674616461 -doubleValue OK");

  s = @"0.646874646746164616898211";
  sscanf([s UTF8String], "%lg", &d);
  PASS(EQ([s doubleValue], d), "0.646874646746164616898211 -doubleValue OK");

  s = @"502.646874646746164";
  sscanf([s UTF8String], "%lg", &d);
  PASS(EQ([s doubleValue], d), "502.646874646746164 -doubleValue OK");

  s = @"502.6468746467461646";
  sscanf([s UTF8String], "%lg", &d);
  PASS(EQ([s doubleValue], d), "502.6468746467461646 -doubleValue OK");

  s = [NSString stringWithCharacters: &u length: 1];
  PASS_EQUAL(s, @"£", "UTF-8 string literal matches 16bit unicode string");

  [arp release]; arp = nil;
  return 0;
}
