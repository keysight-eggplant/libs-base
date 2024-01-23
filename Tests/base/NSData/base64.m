########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: d52d9af274eb4b80e693cd0904b737ec7b6587d1
# Date: 2015-07-07 22:31:41 +0000
########## End of Keysight Technologies Notice ##########
#import <Foundation/Foundation.h>

#import "Testing.h"

int main()
{
  NSAutoreleasePool   *arp = [NSAutoreleasePool new];
  NSData        *data;
  NSData        *ref;
  NSString      *str1;
  NSString      *str2;
  NSString      *strEnc;

  PASS_EXCEPTION([[NSData alloc] initWithBase64EncodedString: nil options: 0],
    NSInvalidArgumentException, "nil argument causes exception");

  data = [[NSData alloc] initWithBase64EncodedString: @"" options: 0];
  ref = [NSData data];
  PASS_EQUAL(data, ref, "base64 decoding vector 1")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zg==" options: 0];
  ref = [NSData dataWithBytes: "f" length: 1];
  PASS_EQUAL(data, ref, "base64 decoding vector 2")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm8=" options: 0];
  ref = [NSData dataWithBytes: "fo" length: 2];
  PASS_EQUAL(data, ref, "base64 decoding vector 3")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9v" options: 0];
  ref = [NSData dataWithBytes: "foo" length: 3];
  PASS_EQUAL(data, ref, "base64 decoding vector 4")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYg==" options: 0];
  ref = [NSData dataWithBytes: "foob" length: 4];
  PASS_EQUAL(data, ref, "base64 decoding vector 5")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYmE=" options: 0];
  ref = [NSData dataWithBytes: "fooba" length: 5];
  PASS_EQUAL(data, ref, "base64 decoding vector 6")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYmE==" options: 0];
  ref = [NSData dataWithBytes: "fooba" length: 5];
  PASS_EQUAL(data, ref, "base64 decoding vector 6 with 1 extra padding")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYmE====="
    options: 0];
  ref = [NSData dataWithBytes: "fooba" length: 5];
  PASS_EQUAL(data, ref, "base64 decoding vector 6 with 4 extra padding")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYmFy" options: 0];
  ref = [NSData dataWithBytes: "foobar" length: 6];
  PASS_EQUAL(data, ref, "base64 decoding vector 7")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9vYmFy====="
    options: 0];
  ref = [NSData dataWithBytes: "foobar\0" length: 7];
  PASS_EQUAL(data, ref, "base64 decoding excess padding gives single nul byte")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9v YmFy" options: 0];
  PASS_EQUAL(data, nil, "base64 decoding with space returns nil")
  [data release];

  data = [[NSData alloc] initWithBase64EncodedString: @"Zm9v YmFy"
    options: NSDataBase64DecodingIgnoreUnknownCharacters];
  ref = [NSData dataWithBytes: "foobar" length: 6];
  PASS_EQUAL(data, ref, "base64 decoding vector 8")
  [data release];

  str1 = @"In principio creavit Deus caelum et terram.\nTerra autem erat inanis et vacua, et tenebrae super faciem abyssi, et spiritus Dei ferebatur super aquas.\nDixitque Deus: \"Fiat lux\". Et facta est lux.";
  data = [str1 dataUsingEncoding: NSASCIIStringEncoding];
  strEnc = [data base64EncodedStringWithOptions:0];
  data = [[NSData alloc] initWithBase64EncodedString: strEnc options: 0];
  str2 = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
  PASS_EQUAL(str1, str2, "Encode / Decode no lines")
  [str2 release];

  str1 = @"In principio creavit Deus caelum et terram.\nTerra autem erat inanis et vacua, et tenebrae super faciem abyssi, et spiritus Dei ferebatur super aquas.\nDixitque Deus: \"Fiat lux\". Et facta est lux.";
  data = [str1 dataUsingEncoding: NSASCIIStringEncoding];
  strEnc = [data base64EncodedStringWithOptions: (NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed)];
  data = [[NSData alloc] initWithBase64EncodedString: strEnc
    options: NSDataBase64DecodingIgnoreUnknownCharacters];
  str2 = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
  PASS_EQUAL(str1, str2, "Encode / Decode 64 - LF")
  [str2 release];

  str1 = @"In principio creavit Deus caelum et terram.\nTerra autem erat inanis et vacua, et tenebrae super faciem abyssi, et spiritus Dei ferebatur super aquas.\nDixitque Deus: \"Fiat lux\". Et facta est lux.";
  data = [str1 dataUsingEncoding: NSASCIIStringEncoding];
  strEnc = [data base64EncodedStringWithOptions: (NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed)];
  data = [[NSData alloc] initWithBase64EncodedString: strEnc
    options: NSDataBase64DecodingIgnoreUnknownCharacters];
  str2 = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
  PASS_EQUAL(str1, str2, "Encode / Decode 76 - LF")
  [str2 release];

  str1 = @"In principio creavit Deus caelum et terram.\nTerra autem erat inanis et vacua, et tenebrae super faciem abyssi, et spiritus Dei ferebatur super aquas.\nDixitque Deus: \"Fiat lux\". Et facta est lux.";
  data = [str1 dataUsingEncoding: NSASCIIStringEncoding];
  strEnc = [data base64EncodedStringWithOptions: (NSDataBase64Encoding64CharacterLineLength | NSDataBase64EncodingEndLineWithCarriageReturn)];
  data = [[NSData alloc] initWithBase64EncodedString: strEnc
    options: NSDataBase64DecodingIgnoreUnknownCharacters];
  str2 = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
  PASS_EQUAL(str1, str2, "Encode / Decode 64 - CR")
  [str2 release];

  str1 = @"In principio creavit Deus caelum et terram.\nTerra autem erat inanis et vacua, et tenebrae super faciem abyssi, et spiritus Dei ferebatur super aquas.\nDixitque Deus: \"Fiat lux\". Et facta est lux.";
  data = [str1 dataUsingEncoding: NSASCIIStringEncoding];
  strEnc = [data base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength];
  data = [[NSData alloc] initWithBase64EncodedString: strEnc
    options: NSDataBase64DecodingIgnoreUnknownCharacters];
  str2 = [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding];
  PASS_EQUAL(str1, str2, "Encode / Decode 64 - implicit CR LF")
  [str2 release];

  [arp release]; arp = nil;
  return 0;
}
