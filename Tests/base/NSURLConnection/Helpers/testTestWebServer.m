########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
/**
 *
 *  Author: Sergei Golovin <Golovin.SV@gmail.com>
 *
 *  Runs two TestWebServer instances to check how the class TestWebServer
 *  behaves. Visit http://localhost:54321/index to see all supported resources.
 *  
 *  If you visit the main TestWebServer instance with the following command:
 *
 *       wget  -O - --user=login --password=password http://localhost:54321/301 2>&1
 *
 *  you should get a session log like this:
 *
 *       --2014-08-13 12:08:01--  http://localhost:54321/301
 *       Resolving localhost (localhost)... 127.0.0.1
 *       Connecting to localhost (localhost)|127.0.0.1|:54321... connected.
 *       HTTP request sent, awaiting response... 401 Unauthorized
 *       Reusing existing connection to localhost:54321.
 *       HTTP request sent, awaiting response... 301 Moved Permanently
 *       Location: http://127.0.0.1:54322/ [following]
 *       --2014-08-13 12:08:01--  http://127.0.0.1:54322/
 *       Connecting to 127.0.0.1:54322... connected.
 *       HTTP request sent, awaiting response... 401 Unauthorized
 *       Reusing existing connection to 127.0.0.1:54322.
 *       HTTP request sent, awaiting response... 204 No Content
 *       Length: 0
 *       Saving to: ‘STDOUT’
 *
 *            0K                                                        0.00 =0s
 *
 *       2014-08-13 12:08:01 (0.00 B/s) - written to stdout [0/0]
 *
 */
#import <Foundation/Foundation.h>
#import "TestWebServer.h"
#import "NSURLConnectionTest.h"

#define TIMING 0.1

int main(int argc, char **argv, char **env)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSFileManager *fm;
  NSBundle *bundle;
  BOOL loaded;
  NSString *helperPath;

  fm = [NSFileManager defaultManager];
  helperPath = [[fm currentDirectoryPath]
		 stringByAppendingString: @"/TestConnection.bundle"];
  bundle = [NSBundle bundleWithPath: helperPath];
  loaded = [bundle load];

  if(loaded)
    {
      TestWebServer *server1;
      TestWebServer *server2;
      Class testClass;
      BOOL debug = YES;
      NSDictionary *d;

      testClass = [bundle principalClass]; // NSURLConnectionTest
      d = [NSDictionary dictionaryWithObjectsAndKeys:
			  //			  @"https", @"Protocol",
			nil];
      server1 = [[[testClass testWebServerClass] alloc] initWithAddress: @"localhost"
								   port: @"54321"
								   mode: NO
								  extra: d];
      [server1 setDebug: debug];
      [server1 start: d]; // 127.0.0.1:54321 HTTP

      server2 = [[[testClass testWebServerClass] alloc] initWithAddress: @"localhost"
								   port: @"54322"
								   mode: NO
								  extra: d];
      [server2 setDebug: debug];
      [server2 start: d]; // 127.0.0.1:54322 HTTP
      
      while(YES)
	{
	  [[NSRunLoop currentRunLoop]
      		runUntilDate: [NSDate dateWithTimeIntervalSinceNow: TIMING]];
	}
      //      [server1 stop];
      //      DESTROY(server1);
      //      [server2 stop];
      //      DESTROY(server2);

    }
  else
    {
      [NSException raise: NSInternalInconsistencyException
		  format: @"can't load bundle TestConnection"];
    }


  DESTROY(arp);

  return 0;
}
