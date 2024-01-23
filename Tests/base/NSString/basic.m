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
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
  uint8_t       bytes[256];
  unichar	u0 = 'a';
  unichar	u1 = 0xfe66;
  int           i = 256;
  char          buf[32];
  NSString	*s;
  NSString *testObj = [NSString stringWithCString: "Hello\n"];

  while (i-- > 0)
    {
      bytes[i] = (uint8_t)i;
    }

  test_alloc(@"NSString");
  test_NSObject(@"NSString",[NSArray arrayWithObject:testObj]);
  test_NSCoding([NSArray arrayWithObject:testObj]);
  test_keyed_NSCoding([NSArray arrayWithObject:testObj]);
  test_NSCopying(@"NSString", @"NSMutableString", 
                 [NSArray arrayWithObject:testObj], NO, NO);
  test_NSMutableCopying(@"NSString", @"NSMutableString",
  			[NSArray arrayWithObject:testObj]);

  /* Test non-ASCII strings.  */
  testObj = [@"\"\\U00C4\\U00DF\"" propertyList];
  test_NSMutableCopying(@"NSString", @"NSMutableString",
  			[NSArray arrayWithObject:testObj]);

  PASS([(s = [[NSString alloc] initWithCharacters: &u0 length: 1])
    isKindOfClass: [NSString class]]
    && ![s isKindOfClass: [NSMutableString class]],
    "initWithCharacters:length: creates mutable string for ascii");

  PASS([(s = [[NSString alloc] initWithCharacters: &u1 length: 1])
    isKindOfClass: [NSString class]]
    && ![s isKindOfClass: [NSMutableString class]],
    "initWithCharacters:length: creates mutable string for unicode");

  PASS_EXCEPTION([[NSString alloc] initWithString: nil];,
  		 NSInvalidArgumentException,
		 "NSString -initWithString: does not allow nil argument");

  PASS([@"he" getCString: buf maxLength: 2 encoding: NSASCIIStringEncoding]==NO,
    "buffer exact length fails");
  PASS([@"hell" getCString: buf maxLength: 5 encoding: NSASCIIStringEncoding],
    "buffer length+1 works");
  PASS(strcmp(buf, "hell") == 0, "getCString:maxLength:encoding");

  PASS([(s = [[NSString alloc] initWithBytes: bytes
                                      length: 256
                                    encoding: NSISOLatin1StringEncoding])
    isKindOfClass: [NSString class]]
    && ![s isKindOfClass: [NSMutableString class]],
    "can create latin1 string with 256 values");

  PASS([(s = [[NSString alloc] initWithBytes: bytes
                                      length: 128
                                    encoding: NSASCIIStringEncoding])
    isKindOfClass: [NSString class]]
    && ![s isKindOfClass: [NSMutableString class]],
    "can create ascii string with 128 values");

  PASS(nil == [[NSString alloc] initWithBytes: bytes
                                       length: 256
                                     encoding: NSASCIIStringEncoding],
    "reject 8bit characters in ascii");

  [arp release]; arp = nil;
  return 0;
}
