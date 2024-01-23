########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
#if     defined(GNUSTEP_BASE_LIBRARY)
#import <Foundation/Foundation.h>
#import <GNUstepBase/GSMime.h>
#import "Testing.h"

int main()
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
  GSMimeParser *parser = [GSMimeParser mimeParser];
  NSStringEncoding enc = [GSMimeDocument encodingFromCharset: @"utf-8"];
  NSData *data;
  GSMimeDocument *doc = [[parser mimeDocument] retain];
  GSMimeHeader  *hdr;
  NSString      *val;
  NSString      *raw;

  PASS_EQUAL([GSMimeDocument encodeBase64String: @""],
    @"", "base64 encoding vector 1")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"f"],
    @"Zg==", "base64 encoding vector 2")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"fo"],
    @"Zm8=", "base64 encoding vector 3")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"foo"],
    @"Zm9v", "base64 encoding vector 4")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"foob"],
    @"Zm9vYg==", "base64 encoding vector 5")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"fooba"],
    @"Zm9vYmE=", "base64 encoding vector 6")
  PASS_EQUAL([GSMimeDocument encodeBase64String: @"foobar"],
    @"Zm9vYmFy", "base64 encoding vector 7")

  PASS_EQUAL([GSMimeDocument decodeBase64String: @""],
    @"", "base64 decoding vector 1")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zg=="],
    @"f", "base64 decoding vector 2")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zm8="],
    @"fo", "base64 decoding vector 3")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zm9v"],
    @"foo", "base64 decoding vector 4")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zm9vYg=="],
    @"foob", "base64 decoding vector 5")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zm9vYmE="],
    @"fooba", "base64 decoding vector 6")
  PASS_EQUAL([GSMimeDocument decodeBase64String: @"Zm9vYmFy"],
    @"foobar", "base64 decoding vector 7")

  data = [@"Content-type: application/xxx\r\n" dataUsingEncoding: enc];
  PASS([parser parse:data] && [parser isInHeaders] && (doc != nil),
       "can parse one header");

  PASS([doc contentType] == nil, "First Header not complete until next starts");

  data = [@"Content-id: <" dataUsingEncoding:enc];
  PASS([parser parse: data] &&
       [parser isInHeaders],
       "Adding partial headers is ok");

  PASS([[doc contentType] isEqual: @"application"] &&
       [[doc contentSubtype] isEqual:@"xxx"],"Parsed first header as expected");

  data = [@"hello>\r\n" dataUsingEncoding: enc];
  PASS([parser parse: data] &&
       [parser isInHeaders],
       "Completing partial header is ok");

  PASS([doc contentID] == nil, "Partial header not complete until next starts");

  data = [@"Folded\r\n : testing\r\n" dataUsingEncoding:enc];
  PASS([parser parse:data] && [parser isInHeaders], "Folded header is ok");
  
  PASS([@"<hello>" isEqual: [doc contentID]],"Parsed partial header as expected %s",[[doc contentID] cString]);
 
  PASS([doc headerNamed: @"Folded"] == nil,"Folded header not complete until next starts");

  data = [@"\r" dataUsingEncoding:enc];
  PASS([parser parse:data] && [parser isInHeaders], "partial end-of-line is ok");

  PASS([[[doc headerNamed:@"Folded"] value] isEqual: @"testing"],"Parsed folded header as expected %s",[[[doc headerNamed:@"Folded"] value] cString]);

  data = [@"\n" dataUsingEncoding:enc];
  PASS([parser parse:data] && ![parser isInHeaders], "completing end-of-line is ok");
  
  doc = [GSMimeDocument documentWithContent:[@"\"\\UFE66???\"" propertyList]
  					type:@"text/plain"
					name:nil];
  [doc rawMimeData];
  PASS([[[doc headerNamed:@"content-type"] parameterForKey:@"charset"] isEqual:@"utf-8"],"charset is inferred");

  
  val = @"by mail.turbocat.net (Postfix, from userid 1002) id 90885422ECBF; Sat, 22 Dec 2007 15:40:10 +0100 (CET)";
  raw = @"Received: by mail.turbocat.net (Postfix, from userid 1002) id 90885422ECBF;\r\n\tSat, 22 Dec 2007 15:40:10 +0100 (CET)\r\n";
  hdr = [[GSMimeHeader alloc] initWithName: @"Received" value: val];
  data = [hdr rawMimeDataPreservingCase: YES];
//NSLog(@"Header: '%*.*s'", [data length], [data length], [data bytes]);
  PASS([data isEqual: [raw dataUsingEncoding: NSASCIIStringEncoding]],
    "raw mime data for long header is OK");
  
  data = [NSData dataWithContentsOfFile: @"HTTP1.dat"];
  parser = [GSMimeParser mimeParser];
  PASS ([parser parse: data] == NO, "can parse HTTP 200 reponse in one go");
  PASS ([parser isComplete], "parse is complete");

  data = [NSData dataWithContentsOfFile: @"HTTP2.dat"];
  parser = [GSMimeParser mimeParser];
  PASS ([parser parse: data] == NO, "can parse HTTP chunked in one go");
  PASS ([parser isComplete], "parse is complete");
  PASS ([parser isComplete], "parse is complete");

  PASS_EQUAL([[parser mimeDocument] convertToText],
    @"This is the data in the first chunk\r\nand this is the second one\r\n"
    @"consequence", "content correct");

  [arp release]; arp = nil;
  return 0;
}
#else
int main(int argc,char **argv)
{
  return 0;
}
#endif
