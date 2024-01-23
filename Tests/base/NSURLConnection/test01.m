########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
/**
 *  The test makes connections to not-listening services.
 *  One for HTTP and one for HTTPS.
 *  The NSURLConnection delegate is supposed to catch an
 *  error in that two cases and sets it's ivars accordingly.
 */

#import <Foundation/Foundation.h>
#import "Testing.h"

@interface Delegate : NSObject
{
  BOOL _done;
  NSError *_error;
}
- (void) reset;
- (NSError *) error;
- (BOOL) done;
- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error;
@end

@implementation Delegate

- (void) reset
{
  _done = NO;
  _error = nil;
}

- (NSError *) error
{
  return _error;
}

- (BOOL) done
{
  return _done;
}

- (void) connection: (NSURLConnection *)connection
   didFailWithError: (NSError *)error
{
  _error = error;
  _done = YES;
}

@end

int main(int argc, char **argv, char **env)
{
  NSAutoreleasePool *arp = [NSAutoreleasePool new];
  NSTimeInterval timing;
  NSTimeInterval duration;

  NSString *urlString;
  NSURLRequest *req;
  Delegate *del;

  duration = 0.0;
  timing = 0.1;
  urlString = @"http://127.0.0.1:19750";
  req = [NSURLRequest requestWithURL: [NSURL URLWithString: urlString]];
  del = [[Delegate new] autorelease];
  [del reset];
  [NSURLConnection connectionWithRequest: req
				delegate: del];
  while (![del done] && duration < 3.0)
    {
      [[NSRunLoop currentRunLoop]
        runUntilDate: [NSDate dateWithTimeIntervalSinceNow: timing]];
      duration += timing;
    }
  PASS([del done] && nil != [del error],
    "connection to dead(not-listening) HTTP service");

  duration = 0.0;
  urlString = @"https://127.0.0.1:19750";
  req = [NSURLRequest requestWithURL: [NSURL URLWithString: urlString]];
  [NSURLConnection connectionWithRequest: req
				delegate: del];
  [del reset];
  while (![del done] && duration < 3.0)
    {
      [[NSRunLoop currentRunLoop]
        runUntilDate: [NSDate dateWithTimeIntervalSinceNow: timing]];
      duration += timing;
    }
  PASS([del done] && nil != [del error],
    "connection to dead(not-listening) HTTPS service");

  [arp release]; arp = nil;

  return 0;
}
