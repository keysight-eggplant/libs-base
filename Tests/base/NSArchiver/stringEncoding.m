// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Frank Le Grand 
// Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8 
// Date: 2013-08-09 14:20:01 +0000 
// ========== End of Keysight Technologies Notice ========== 
#import <Foundation/Foundation.h>
#import "Testing.h"
#import "ObjectTesting.h"

int main(int argc, const char **argv)
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
  const unichar EszettChar = 0x00df;
  NSString *EszettStr = [[[NSString alloc] initWithCharacters: &EszettChar
       	                                               length: 1] autorelease];

  {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject: EszettStr];
    NSString *unarchivedString = [NSKeyedUnarchiver unarchiveObjectWithData: data];

    PASS_EQUAL(unarchivedString, EszettStr,
	 "'eszett' character roundtrip to binary plist seems to work.");
  }

  {
    NSString *plist1String = [NSKeyedUnarchiver unarchiveObjectWithFile: @"eszett1.plist"];
    
    PASS_EQUAL(plist1String, EszettStr,
	 "'eszett' character read from OSX binary plist");
  }

  {
    NSString *plist2String = [NSKeyedUnarchiver unarchiveObjectWithFile: @"eszett2.plist"];
    
    PASS_EQUAL(plist2String, EszettStr,
	 "'eszett' character read from GNUstep binary plist");
  }

  [pool release];
  return 0;
}
