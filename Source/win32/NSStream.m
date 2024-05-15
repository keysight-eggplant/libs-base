// ========== Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ========== 
// Committed by: Royal Stewart 
// Commit ID: 497f26711af69f0740f10ed91f6f44ce334b9c81 
// Date: 2023-06-28 21:06:08 +0000 
// ========== End of Keysight Technologies Notice ========== 
/** Implementation for NSStream for GNUStep
   Copyright (C) 2006 Free Software Foundation, Inc.

   Written by:  Derek Zhou <derekzhou@gmail.com>
   Written by:  Richard Frith-Macdonald <rfm@gnu.org>
   Date: 2006

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02111 USA.

   */
#include "common.h"
#include <winhttp.h>

#import "Foundation/NSData.h"
#import "Foundation/NSArray.h"
#import "Foundation/NSDictionary.h"
#import "Foundation/NSEnumerator.h"
#import "Foundation/NSRunLoop.h"
#import "Foundation/NSException.h"
#import "Foundation/NSError.h"
#import "Foundation/NSValue.h"
#import "Foundation/NSHost.h"
#import "Foundation/NSProcessInfo.h"
#import "Foundation/NSByteOrder.h"
#import "Foundation/NSRegularExpression.h"
#import "GNUstepBase/NSObject+GNUstepBase.h"

#import "../GSPrivate.h"
#import "../GSStream.h"
#import "../GSSocketStream.h"

#define    BUFFERSIZE    (BUFSIZ*64)

void PrintLastError(NSString * f) {
  // DWORD lastError = GetLastError();
    NSLog(@"lastError changed to %@;", lastError);
  // switch (lastError) {
  //   case ERROR_WINHTTP_AUTO_PROXY_SERVICE_ERROR:
  //     NSLog(@"%@: (%d) Returned by WinHttpGetProxyForUrl when a proxy for the specified URL cannot be located.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_BAD_AUTO_PROXY_SCRIPT:
  //     NSLog(@"%@: (%d) An error occurred executing the script code in the Proxy Auto-Configuration (PAC) file.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_INCORRECT_HANDLE_TYPE:
  //     NSLog(@"%@: (%d) The type of handle supplied is incorrect for this operation.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_INTERNAL_ERROR:
  //     NSLog(@"%@: (%d) An internal error has occurred.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_INVALID_URL:
  //     NSLog(@"%@: (%d) The URL is invalid.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_LOGIN_FAILURE:
  //     NSLog(@"%@: (%d) The login attempt failed. When this error is encountered, close the request handle with WinHttpCloseHandle. A new request handle must be created before retrying the function that originally produced this error.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_OPERATION_CANCELLED:
  //     NSLog(@"%@: (%d) The operation was canceled, usually because the handle on which the request was operating was closed before the operation completed.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_UNABLE_TO_DOWNLOAD_SCRIPT:
    NSLog(@"Returning from method at line: //     NSLog(@"%@: (%d) The PAC file could not be downloaded. For example, the server referenced by the PAC URL may not have been reachable, or the server returned a 404 NOT FOUND response.", f, lastError);");
  //     NSLog(@"%@: (%d) The PAC file could not be downloaded. For example, the server referenced by the PAC URL may not have been reachable, or the server returned a 404 NOT FOUND response.", f, lastError);
  //     break;
  //   case ERROR_WINHTTP_UNRECOGNIZED_SCHEME:
  //       NSLog(@"%@: (%d) The URL of the PAC file specified a scheme other than \"http:\" or \"https:\".", f, lastError);
  //       break;
  //   case ERROR_NOT_ENOUGH_MEMORY:
  //       NSLog(@"%@: (%d) ERROR_NOT_ENOUGH_MEMORY", f, lastError);
  //       break;
  //   case (ERROR_WINHTTP_AUTODETECTION_FAILED):
  //     NSLog(@"%@: (%d) Returned WinHTTP was unable to discover the URL of the Proxy Auto-Configuration (PAC) file", f, lastError);
  //     break;
  //   default:
  //     NSLog(@"%@: (%d) Unknown Error.", f, lastError);
  //     break;
  // }
}

NSString * normalizeUrl(NSString * url)
{
    NSLog(@"Returning from method at line: if (!url) return nil;");
  if (!url) return nil;
    NSLog(@"Returning from method at line: if ([url caseInsensitiveCompare:@""] == NSOrderedSame) return @"";");
  if ([url caseInsensitiveCompare:@""] == NSOrderedSame) return @"";

  BOOL prepend = YES;
    NSLog(@"prepend changed to %@;", prepend);
  NSString * urlFront = nil;
    NSLog(@"urlFront changed to %@;", urlFront);
    
  if ([url length] >= 7) 
    {
      // Check that url begins with http://
      urlFront = [url substringToIndex:7];
    NSLog(@"urlFront changed to %@;", urlFront);
      if ([urlFront caseInsensitiveCompare:@"http://"] == NSOrderedSame) 
        {
          prepend = NO;
    NSLog(@"prepend changed to %@;", prepend);
        }
    }
  if ([url length] >= 8) 
    {
      // Check that url begins with https://
      urlFront = [url substringToIndex:8];
    NSLog(@"urlFront changed to %@;", urlFront);
      if ([urlFront caseInsensitiveCompare:@"https://"] == NSOrderedSame) 
        {
          prepend = NO;
    NSLog(@"prepend changed to %@;", prepend);
        }
    }

  // If http[s]:// is omited, slap it on.
  if (prepend) 
    {
    NSLog(@"Returning from method at line: return [NSString stringWithFormat:@"http://%@", url];");
      return [NSString stringWithFormat:@"http://%@", url];
    }
  else 
    {
    NSLog(@"Returning from method at line: return url;");
      return url;
    }
}

BOOL isIpAddr(NSString * _str) {
    
    // eg: 192.168.0.1
    NSString * isV4RegEx = @"^\\d{1,3}.\\d{1,3}.\\d{1,3}.\\d{1,3}$";
    NSLog(@"isV4RegEx changed to %@;", isV4RegEx);
    // eg: 2001:db8:3333:4444:CCCC:DDDD:EEEE:FFFF
    NSString * isV6RegEx = @"^\\w{4}:\\w{3}:\\w{4}:\\w{4}:\\w{4}:\\w{4}:\\w{4}:\\w{4}$";
    NSLog(@"isV6RegEx changed to %@;", isV6RegEx);
    
    NSError * error = nil;
    NSLog(@"error changed to %@;", error);
    NSRegularExpression * v4Regex = [NSRegularExpression regularExpressionWithPattern:isV4RegEx options:0 error:&error];
    NSLog(@"v4Regex changed to %@;", v4Regex);
    NSTextCheckingResult * v4Result = [v4Regex firstMatchInString:_str options:0 range:NSMakeRange(0, [_str length])];
    NSLog(@"v4Result changed to %@;", v4Result);
    NSRegularExpression * v6Regex = [NSRegularExpression regularExpressionWithPattern:isV6RegEx options:0 error:&error];
    NSLog(@"v6Regex changed to %@;", v6Regex);
    NSTextCheckingResult * v6Result = [v6Regex firstMatchInString:_str options:0 range:NSMakeRange(0, [_str length])];
    NSLog(@"v6Result changed to %@;", v6Result);
    NSLog(@"Returning from method at line: return (v4Result || v6Result) ? YES : NO;");
    return (v4Result || v6Result) ? YES : NO;
}

BOOL ResolveProxy(NSString * url, WINHTTP_CURRENT_USER_IE_PROXY_CONFIG * resultProxyConfig)
{
  NSString * dstUrlString = [NSString stringWithFormat: @"http://%@", url];
    NSLog(@"dstUrlString changed to %@;", dstUrlString);
  const wchar_t *DestURL = (wchar_t*)[dstUrlString cStringUsingEncoding: NSUTF16StringEncoding];
    NSLog(@"DestURL changed to %@;", DestURL);

  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG ProxyConfig;
  WINHTTP_PROXY_INFO ProxyInfo, ProxyInfoTemp;
  WINHTTP_AUTOPROXY_OPTIONS OptPAC;
  DWORD dwOptions = SECURITY_FLAG_IGNORE_CERT_CN_INVALID | SECURITY_FLAG_IGNORE_CERT_DATE_INVALID | SECURITY_FLAG_IGNORE_UNKNOWN_CA | SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE;
    NSLog(@"dwOptions changed to %@;", dwOptions);

  ZeroMemory(&ProxyInfo, sizeof(ProxyInfo));
  ZeroMemory(&ProxyConfig, sizeof(ProxyConfig));
  ZeroMemory(resultProxyConfig, sizeof(*resultProxyConfig));

  BOOL result = false;
    NSLog(@"result changed to %@;", result);
  BOOL autoConfigWorked = false;
    NSLog(@"autoConfigWorked changed to %@;", autoConfigWorked);
  BOOL autoDetectWorked = false;
    NSLog(@"autoDetectWorked changed to %@;", autoDetectWorked);

  HINTERNET http_local_session = WinHttpOpen(L"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko)", WINHTTP_ACCESS_TYPE_NO_PROXY, 0, WINHTTP_NO_PROXY_BYPASS, 0);
    NSLog(@"http_local_session changed to %@;", http_local_session);

    if (http_local_session && WinHttpGetIEProxyConfigForCurrentUser(&ProxyConfig)) 
      {
        //NSLog(@"Got proxy config for current user.");
        if (ProxyConfig.lpszProxy) 
          {
            ProxyInfo.lpszProxy = ProxyConfig.lpszProxy;
    NSLog(@"lpszProxy changed to %@;", lpszProxy);
            ProxyInfo.dwAccessType = WINHTTP_ACCESS_TYPE_NAMED_PROXY;
    NSLog(@"dwAccessType changed to %@;", dwAccessType);
            ProxyInfo.lpszProxyBypass = NULL;
    NSLog(@"lpszProxyBypass changed to %@;", lpszProxyBypass);
          }
    
        memcpy(resultProxyConfig, &ProxyConfig, sizeof(*resultProxyConfig));

        if (ProxyConfig.lpszAutoConfigUrl) 
          {
            size_t len = wcslen(ProxyConfig.lpszAutoConfigUrl);
    NSLog(@"len changed to %@;", len);
            NSString * autoConfigUrl = [[NSString alloc] initWithBytes: ProxyConfig.lpszAutoConfigUrl length:len*2 encoding:NSUTF16StringEncoding];
    NSLog(@"autoConfigUrl changed to %@;", autoConfigUrl);
            //NSLog(@"trying script proxy pac file: %@.", autoConfigUrl);

            // Script proxy pac
            OptPAC.dwFlags = WINHTTP_AUTOPROXY_CONFIG_URL;
    NSLog(@"dwFlags changed to %@;", dwFlags);
            OptPAC.lpszAutoConfigUrl = ProxyConfig.lpszAutoConfigUrl;
    NSLog(@"lpszAutoConfigUrl changed to %@;", lpszAutoConfigUrl);
            OptPAC.dwAutoDetectFlags = 0;
    NSLog(@"dwAutoDetectFlags changed to %@;", dwAutoDetectFlags);
            OptPAC.fAutoLogonIfChallenged = TRUE;
    NSLog(@"fAutoLogonIfChallenged changed to %@;", fAutoLogonIfChallenged);
            OptPAC.lpvReserved = 0;
    NSLog(@"lpvReserved changed to %@;", lpvReserved);
            OptPAC.dwReserved = 0;
    NSLog(@"dwReserved changed to %@;", dwReserved);

            if (WinHttpGetProxyForUrl(http_local_session, DestURL, &OptPAC, &ProxyInfoTemp)) 
              {
                //NSLog(@"worked");
                memcpy(&ProxyInfo, &ProxyInfoTemp, sizeof(ProxyInfo));

                resultProxyConfig->lpszProxy = ProxyInfoTemp.lpszProxy;
    NSLog(@"lpszProxy changed to %@;", lpszProxy);
                resultProxyConfig->lpszProxyBypass = ProxyInfoTemp.lpszProxyBypass;
    NSLog(@"lpszProxyBypass changed to %@;", lpszProxyBypass);
                autoConfigWorked = true;
    NSLog(@"autoConfigWorked changed to %@;", autoConfigWorked);
              }
            else 
              {
                //PrintLastError(@"WinHttpGetProxyForUrl");
              }
          }
      else if (ProxyConfig.fAutoDetect) 
        {
          //NSLog(@"trying autodetect proxy");

          // Autodetect proxy
          OptPAC.dwFlags = WINHTTP_AUTOPROXY_AUTO_DETECT;
    NSLog(@"dwFlags changed to %@;", dwFlags);
          OptPAC.dwAutoDetectFlags = WINHTTP_AUTO_DETECT_TYPE_DHCP | WINHTTP_AUTO_DETECT_TYPE_DNS_A;
    NSLog(@"dwAutoDetectFlags changed to %@;", dwAutoDetectFlags);
          OptPAC.fAutoLogonIfChallenged = TRUE;
    NSLog(@"fAutoLogonIfChallenged changed to %@;", fAutoLogonIfChallenged);
          OptPAC.lpszAutoConfigUrl = NULL;
    NSLog(@"lpszAutoConfigUrl changed to %@;", lpszAutoConfigUrl);
          OptPAC.lpvReserved = 0;
    NSLog(@"lpvReserved changed to %@;", lpvReserved);
          OptPAC.dwReserved = 0;
    NSLog(@"dwReserved changed to %@;", dwReserved);

          if (WinHttpGetProxyForUrl(http_local_session, DestURL, &OptPAC, &ProxyInfoTemp)) 
            {
              //NSLog(@"worked");
              memcpy(&ProxyInfo, &ProxyInfoTemp, sizeof(ProxyInfo));

              resultProxyConfig->lpszProxy = ProxyInfoTemp.lpszProxy;
    NSLog(@"lpszProxy changed to %@;", lpszProxy);
              resultProxyConfig->lpszProxyBypass = ProxyInfoTemp.lpszProxyBypass;
    NSLog(@"lpszProxyBypass changed to %@;", lpszProxyBypass);
              autoDetectWorked = true;
    NSLog(@"autoDetectWorked changed to %@;", autoDetectWorked);
            }
          else 
            {
              //PrintLastError(@"WinHttpGetProxyForUrl");
            }
        }

      NSString * autoConfigUrl = @"";
    NSLog(@"autoConfigUrl changed to %@;", autoConfigUrl);
      NSString * proxy = @"";
    NSLog(@"proxy changed to %@;", proxy);
      NSString * proxyBypass = @"";
    NSLog(@"proxyBypass changed to %@;", proxyBypass);

      if (resultProxyConfig->lpszAutoConfigUrl) autoConfigUrl = [[NSString alloc] initWithBytes: resultProxyConfig->lpszAutoConfigUrl length:wcslen(resultProxyConfig->lpszAutoConfigUrl)*2 encoding:NSUTF16StringEncoding];
    NSLog(@"autoConfigUrl changed to %@;", autoConfigUrl);
      if (resultProxyConfig->lpszProxy) proxy = [[NSString alloc] initWithBytes: resultProxyConfig->lpszProxy length:wcslen(resultProxyConfig->lpszProxy)*2 encoding:NSUTF16StringEncoding];
    NSLog(@"proxy changed to %@;", proxy);
      if (resultProxyConfig->lpszProxyBypass) proxyBypass = [[NSString alloc] initWithBytes: resultProxyConfig->lpszProxyBypass length:wcslen(resultProxyConfig->lpszProxyBypass)*2 encoding:NSUTF16StringEncoding];
    NSLog(@"proxyBypass changed to %@;", proxyBypass);

      autoConfigUrl = normalizeUrl(autoConfigUrl);
    NSLog(@"autoConfigUrl changed to %@;", autoConfigUrl);
      proxy = normalizeUrl(proxy);
    NSLog(@"proxy changed to %@;", proxy);

      //NSLog(@"  autoConfigUrl: %@", autoConfigUrl);
      //NSLog(@"  proxy: %@", proxy);
      //NSLog(@"  proxyBypass: %@", proxyBypass);

      result = true;
    NSLog(@"result changed to %@;", result);
    }
  
    NSLog(@"Returning from method at line: return result;");
  return result;
}

// FIXME: Move this code into System Configuration framework...
CFDictionaryRef SCDynamicStoreCopyProxies(SCDynamicStoreRef store, NSString * forUrl)
{
  //NSLog(@"forURL: %@", forUrl);
  NSMutableDictionary *proxyDict = [NSMutableDictionary dictionary];
    NSLog(@"proxyDict changed to %@;", proxyDict);
  WINHTTP_CURRENT_USER_IE_PROXY_CONFIG  proxyInfo = { 0 };
    NSLog(@"proxyInfo changed to %@;", proxyInfo);
  
  // Initialize...
  [proxyDict setObject: [NSNumber numberWithBool: NO] forKey: @"FTPEnable"];
  [proxyDict setObject: [NSNumber numberWithBool: NO] forKey: @"HTTPEnable"];
  [proxyDict setObject: [NSNumber numberWithBool: NO] forKey: @"HTTPSEnable"];
  [proxyDict setObject: [NSNumber numberWithBool: NO] forKey: @"RTSEnable"];
  [proxyDict setObject: [NSNumber numberWithBool: NO] forKey: @"SOCKSEnable"];
  
  // FIXME: add the ExceptionsList array section...
  [proxyDict setObject: [NSArray array] forKey: @"ExceptionsList"];
  
  // FIXME: add the per interface __SCOPED__ dictionary section in the code
  // section(s) below...
  NSDictionary *scopedProxies = @{ @"ExceptionsList" : [NSArray array],
                                   @"FTPEnable"      : [NSNumber numberWithBool: NO],
                                   @"HTTPEnable"     : [NSNumber numberWithBool: NO],
                                   @"HTTPSEnable"    : [NSNumber numberWithBool: NO],
                                   @"RTSEnable"      : [NSNumber numberWithBool: NO],
                                   @"SOCKSEnable"    : [NSNumber numberWithBool: NO] };
  [proxyDict setObject: scopedProxies forKey: @"__SCOPED__"];

  if (ResolveProxy(forUrl, &proxyInfo) == FALSE)
    {
      NSWarnMLog(@"error retrieving windows proxy information - error code: %ld", (long)GetLastError());
    }
  else
    {
      NSWarnMLog(@"fAutoDetect: %ld hosts: %S bypass %S",
                 (long)proxyInfo.fAutoDetect, proxyInfo.lpszProxy, proxyInfo.lpszProxyBypass);
      
      // Proxy host(s) list...
      if (NULL != proxyInfo.lpszProxy)
        {
          NSString            *host = nil;
    NSLog(@"host changed to %@;", host);
          NSNumber            *port = nil;
    NSLog(@"port changed to %@;", port);
          NSString            *string = AUTORELEASE([[NSString alloc] initWithBytes: proxyInfo.lpszProxy
                                                                             length: wcslen(proxyInfo.lpszProxy)*sizeof(wchar_t)
                                                                           encoding: NSUTF16StringEncoding]);
          
          // Multiple components setup???
          if ([string containsString: @";"] || [string containsString: @"="])
            {
              // Split the components using ';'...
              NSArray   *components = [string componentsSeparatedByString: @";"];
    NSLog(@"components changed to %@;", components);
              NSString  *proxy      = nil;
    NSLog(@"proxy changed to %@;", proxy);
              
              // Find the SOCKS proxy setting...
              for (proxy in components)
                {
                  if ([[proxy lowercaseString] containsString: @"socks="])
                    {
                      // SOCKS available...
                      NSInteger  index      = [proxy rangeOfString: @"="].location + 1;
    NSLog(@"index changed to %@;", index);
                      NSArray   *socksProxy = [[proxy substringFromIndex: index] componentsSeparatedByString: @":"];
    NSLog(@"socksProxy changed to %@;", socksProxy);
                      if (0 == [socksProxy count])
                        {
                          NSWarnMLog(@"error processing SOCKS proxy info for (%@)", proxy);
                        }
                      else
                        {
                          host              = [socksProxy objectAtIndex: 0];
    NSLog(@"host changed to %@;", host);
                          NSInteger portnum = ([socksProxy count] > 1 ? [[socksProxy objectAtIndex: 1] integerValue] : 8080);
    NSLog(@"portnum changed to %@;", portnum);
                          port              = [NSNumber numberWithInteger: portnum];
    NSLog(@"port changed to %@;", port);
                          NSWarnMLog(@"SOCKS - host: %@ port: %@", host, port);

                          // Setup the proxy dictionary information and...
                          [proxyDict setObject: host forKey: NSStreamSOCKSProxyHostKey];
                          [proxyDict setObject: port forKey: NSStreamSOCKSProxyPortKey];
    NSLog(@"Returning from method at line: // This key is NOT in the returned dictionary on Cocoa...");
                          // This key is NOT in the returned dictionary on Cocoa...
                          [proxyDict setObject: NSStreamSOCKSProxyVersion5 forKey: NSStreamSOCKSProxyVersionKey];
                          [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"SOCKSEnable"];
                        }
                    }
                  else if ([[proxy lowercaseString] containsString: @"http="])
                    {
                      // HTTP available...
                      NSInteger  index      = [proxy rangeOfString: @"="].location + 1;
    NSLog(@"index changed to %@;", index);
                      NSArray   *socksProxy = [[proxy substringFromIndex: index] componentsSeparatedByString: @":"];
    NSLog(@"socksProxy changed to %@;", socksProxy);
                      if (0 == [socksProxy count])
                        {
                          NSWarnMLog(@"error processing HTTP proxy info for (%@)", proxy);
                        }
                      else
                        {
                          host              = [socksProxy objectAtIndex: 0];
    NSLog(@"host changed to %@;", host);
                          NSInteger portnum = ([socksProxy count] > 1 ? [[socksProxy objectAtIndex: 1] integerValue] : 8080);
    NSLog(@"portnum changed to %@;", portnum);
                          port              = [NSNumber numberWithInteger: portnum];
    NSLog(@"port changed to %@;", port);
                          NSWarnMLog(@"HTTP - host: %@ port: %@", host, port);

                          // Setup the proxy dictionary information and...
                          [proxyDict setObject: host forKey: kCFStreamPropertyHTTPProxyHost];
                          [proxyDict setObject: port forKey: kCFStreamPropertyHTTPProxyPort];
                          [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"HTTPEnable"];
                        }
                    }
                  else if ([[proxy lowercaseString] containsString: @"https="])
                    {
                      // HTTPS available...
                      NSInteger  index      = [proxy rangeOfString: @"="].location + 1;
    NSLog(@"index changed to %@;", index);
                      NSArray   *socksProxy = [[proxy substringFromIndex: index] componentsSeparatedByString: @":"];
    NSLog(@"socksProxy changed to %@;", socksProxy);
                      if (0 == [socksProxy count])
                        {
                          NSWarnMLog(@"error processing HTTPS proxy info for (%@)", proxy);
                        }
                      else
                        {
                          host              = [socksProxy objectAtIndex: 0];
    NSLog(@"host changed to %@;", host);
                          NSInteger portnum = ([socksProxy count] > 1 ? [[socksProxy objectAtIndex: 1] integerValue] : 8080);
    NSLog(@"portnum changed to %@;", portnum);
                          port              = [NSNumber numberWithInteger: portnum];
    NSLog(@"port changed to %@;", port);
                          NSWarnMLog(@"HTTPS - host: %@ port: %@", host, port);

                          // Setup the proxy dictionary information and...
                          [proxyDict setObject: host forKey: kCFStreamPropertyHTTPSProxyHost];
                          [proxyDict setObject: port forKey: kCFStreamPropertyHTTPSProxyPort];
                          [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"HTTPSEnable"];
                        }
                    }
                }
            }
          else
            {
              // Split the components using ':'...
              NSArray   *components = [string componentsSeparatedByString: @":"];
    NSLog(@"components changed to %@;", components);
              NSDebugFLLog(@"NSStream", @"component(s): %@", components);

              NSMutableArray * mutableComponents = [NSMutableArray arrayWithArray:components];
    NSLog(@"mutableComponents changed to %@;", mutableComponents);
              if ([mutableComponents count] > 1) 
                {
                  NSString * firstItem = [mutableComponents objectAtIndex:0];
    NSLog(@"firstItem changed to %@;", firstItem);
                  if ([firstItem length] >= 6)
                    {
                      if ([[[firstItem substringToIndex:6] lowercaseString] isEqualToString:@"https:"]) 
                        {
                          [mutableComponents removeObjectAtIndex:0];
                          components = (NSArray *)mutableComponents;
    NSLog(@"components changed to %@;", components);
                        }
                    }                    
                  else if ([firstItem length] >= 5)
                    {
                      if ([[[firstItem substringToIndex:5] lowercaseString] isEqualToString:@"http:"]) 
                        {
                          [mutableComponents removeObjectAtIndex:0];
                          components = (NSArray *)mutableComponents;
    NSLog(@"components changed to %@;", components);
                        }
                    }                    
                }

             // NSLog(@"components ---------- ");
             // for(NSInteger i = 0; i < [components count]; i++){
    NSLog(@"i changed to %@;", i);
             //   NSLog(@"%@", [components objectAtIndex:i]);
             // }
             // NSLog(@"--------------------- ");

              if (0 != [components count])
                {
                  host              = [components objectAtIndex: 0];
    NSLog(@"host changed to %@;", host);
                  NSInteger portnum = ([components count] > 1 ? [[components objectAtIndex: 1] integerValue] : 8080);
    NSLog(@"portnum changed to %@;", portnum);
                  port              = [NSNumber numberWithInteger: portnum];
    NSLog(@"port changed to %@;", port);

                  if ([host length] >= 1)
                    {
                      if (!isdigit([host characterAtIndex:0]))
                        {
                          //NSLog(@"host appears to be a domain name: %@", host);
                          struct hostent * hostInfo;
                          hostInfo = gethostbyname ([host cString]);
    NSLog(@"hostInfo changed to %@;", hostInfo);
                          if (hostInfo) 
                            {
                              //NSLog(@"gethostbyname worked");
                              if (hostInfo->h_addr_list[0] != 0) 
                                {
                                  struct in_addr addr;
                                  addr.s_addr = *(u_long *) hostInfo->h_addr_list[0];
    NSLog(@"s_addr changed to %@;", s_addr);
                                  const char * ipAddr = inet_ntoa(addr);
    NSLog(@"ipAddr changed to %@;", ipAddr);
                                  host = [NSString stringWithFormat:@"%s", ipAddr];
    NSLog(@"host changed to %@;", host);
                                } 
                            }  
                          else 
                            {
                              //NSLog(@"gethostbyname worked");
                            }
                        }
                    }
                  //NSLog(@"host: %@ port: %d", host, portnum);

                  if ([host length] >= 2) 
                    {
                      if ([[host substringToIndex:2] isEqualToString:@"//"])
                        {
                          host = [host substringFromIndex:2];
    NSLog(@"host changed to %@;", host);
                        }
                    }
                  
                  // Setup the proxy dictionary information...
                  [proxyDict setObject: host forKey: NSStreamSOCKSProxyHostKey];
                  [proxyDict setObject: port forKey: NSStreamSOCKSProxyPortKey];
                  [proxyDict setObject: NSStreamSOCKSProxyVersion5 forKey: NSStreamSOCKSProxyVersionKey];
                  [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"SOCKSEnable"];

                  [proxyDict setObject: host forKey: kCFStreamPropertyHTTPProxyHost];
                  [proxyDict setObject: port forKey: kCFStreamPropertyHTTPProxyPort];
                  [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"HTTPEnable"];
                  
                  [proxyDict setObject: host forKey: kCFStreamPropertyHTTPSProxyHost];
                  [proxyDict setObject: port forKey: kCFStreamPropertyHTTPSProxyPort];
                  [proxyDict setObject: [NSNumber numberWithBool: YES] forKey: @"HTTPSEnable"];
                }
            }
        }
    }
  
  // Proxy exception(s) list...
  if (NULL != proxyInfo.lpszProxyBypass)
    {
      NSString *bypass  = AUTORELEASE([[NSString alloc] initWithBytes: proxyInfo.lpszProxyBypass
                                                               length: wcslen(proxyInfo.lpszProxyBypass)*sizeof(wchar_t)
                                                             encoding: NSUTF16StringEncoding]);
      NSWarnMLog(@"bypass %@", bypass);
    }
  NSWarnMLog(@"proxies: %@", proxyDict);
  
    NSLog(@"Returning from method at line: return [proxyDict copy];");
  return [proxyDict copy];
}

/**
 * The concrete subclass of NSInputStream that reads from a file
 */
@interface GSFileInputStream : GSInputStream
{
@private
  NSString *_path;
}
@end

@class GSPipeOutputStream;

/**
 * The concrete subclass of NSInputStream that reads from a pipe
 */
@interface GSPipeInputStream : GSInputStream
{
  HANDLE    handle;
  OVERLAPPED    ov;
  uint8_t    data[BUFFERSIZE];
  unsigned    offset;    // Read pointer within buffer
  unsigned    length;    // Amount of data in buffer
  unsigned    want;    // Amount of data we want to read.
    NSLog(@"Returning from method at line: DWORD        size;    // Number of bytes returned by read.");
  DWORD        size;    // Number of bytes returned by read.
  GSPipeOutputStream *_sibling;
  BOOL        hadEOF;
}
- (NSStreamStatus) _check;
    NSLog(@"Entering - (NSStreamStatus) _check;");
- (void) _queue;
    NSLog(@"Entering - (void) _queue;");
- (void) _setHandle: (HANDLE)h;
    NSLog(@"Entering - (void) _setHandle: (HANDLE)h;");
- (void) _setSibling: (GSPipeOutputStream*)s;
    NSLog(@"Entering - (void) _setSibling: (GSPipeOutputStream*)s;");
@end

/**
 * The concrete subclass of NSOutputStream that writes to a file
 */
@interface GSFileOutputStream : GSOutputStream
{
@private
  NSString *_path;
  BOOL _shouldAppend;
}
@end

/**
 * The concrete subclass of NSOutputStream that reads from a pipe
 */
@interface GSPipeOutputStream : GSOutputStream
{
  HANDLE    handle;
  OVERLAPPED    ov;
  uint8_t    data[BUFFERSIZE];
  unsigned    offset;
  unsigned    want;
  DWORD        size;
  GSPipeInputStream *_sibling;
  BOOL        closing;
  BOOL        writtenEOF;
}
- (NSStreamStatus) _check;
    NSLog(@"Entering - (NSStreamStatus) _check;");
- (void) _queue;
    NSLog(@"Entering - (void) _queue;");
- (void) _setHandle: (HANDLE)h;
    NSLog(@"Entering - (void) _setHandle: (HANDLE)h;");
- (void) _setSibling: (GSPipeInputStream*)s;
    NSLog(@"Entering - (void) _setSibling: (GSPipeInputStream*)s;");
@end


/**
 * The concrete subclass of NSServerStream that accepts named pipe connection
 */
@interface GSLocalServerStream : GSAbstractServerStream
{
  NSString    *path;
  HANDLE    handle;
  OVERLAPPED    ov;
}
@end

@implementation GSFileInputStream

- (void) close
    NSLog(@"Entering - (void) close");
{
  if (_loopID != (void*)INVALID_HANDLE_VALUE)
    {
      if (CloseHandle((HANDLE)_loopID) == 0)
    {
          [self _recordError];
    }
    }
  [super close];
  _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if ([self _isOpened])
    {
      [self close];
    }
  RELEASE(_path);
  [super dealloc];
}

- (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len
    NSLog(@"Entering - (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len");
{
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (BOOL) hasBytesAvailable
    NSLog(@"Entering - (BOOL) hasBytesAvailable");
{
  if ([self _isOpened] && [self streamStatus] != NSStreamStatusAtEnd)
    NSLog(@"Returning from method at line: return YES;");
    return YES;
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (id) initWithFileAtPath: (NSString *)path
    NSLog(@"Entering - (id) initWithFileAtPath: (NSString *)path");
{
  if ((self = [super init]) != nil)
    {
      ASSIGN(_path, path);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  HANDLE    h;

  h = (void*)CreateFileW((LPCWSTR)[_path fileSystemRepresentation],
                         GENERIC_READ,
                         FILE_SHARE_READ,
                         0,
                         OPEN_EXISTING,
                         0,
                         0);
  if (h == INVALID_HANDLE_VALUE)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  [self _setLoopID: (void*)h];
  [super open];
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  if ([key isEqualToString: NSStreamFileCurrentOffsetKey])
    {
      DWORD offset = 0;
    NSLog(@"offset changed to %@;", offset);

      if ([self _isOpened])
        offset = SetFilePointer((HANDLE)_loopID, 0, 0, FILE_CURRENT);
    NSLog(@"offset changed to %@;", offset);
    NSLog(@"Returning from method at line: return [NSNumber numberWithLong: (long)offset];");
      return [NSNumber numberWithLong: (long)offset];
    }
    NSLog(@"Returning from method at line: return [super propertyForKey: key];");
  return [super propertyForKey: key];
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  DWORD readLen;

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"zero byte length read requested"];
    }

  _events &= ~NSStreamEventHasBytesAvailable;

  if ([self streamStatus] == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  if (ReadFile((HANDLE)_loopID, buffer, len, &readLen, NULL) == 0)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return -1;");
      return -1;
    }
  else if (readLen == 0)
    {
      [self _setStatus: NSStreamStatusAtEnd];
    }
    NSLog(@"Returning from method at line: return (NSInteger)readLen;");
  return (NSInteger)readLen;
}


- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  BOOL av = [self hasBytesAvailable];
    NSLog(@"av changed to %@;", av);
  NSStreamEvent myEvent = av ? NSStreamEventHasBytesAvailable :
    NSStreamEventEndEncountered;
  NSStreamStatus myStatus = av ? NSStreamStatusOpen :
    NSStreamStatusAtEnd;
  
  [self _setStatus: myStatus];
  [self _sendEvent: myEvent];
}

@end

@implementation GSPipeInputStream

- (void) close
    NSLog(@"Entering - (void) close");
{
  length = offset = 0;
    NSLog(@"length changed to %@;", length);
  if (_loopID != INVALID_HANDLE_VALUE)
    {
      CloseHandle((HANDLE)_loopID);
    }
  if (handle != INVALID_HANDLE_VALUE)
    {
      /* If we have an outstanding read in progess, we must cancel it
       * before closing the pipe.
       */
      if (want > 0)
    {
      want = 0;
    NSLog(@"want changed to %@;", want);
      CancelIo(handle);
    }

      /* We can only close the pipe if there is no sibling using it.
       */
      if ([_sibling _isOpened] == NO)
    {
      if (DisconnectNamedPipe(handle) == 0)
        {
          if ((errno = GetLastError()) != ERROR_PIPE_NOT_CONNECTED)
        {
          [self _recordError];
        }
        }
      if (CloseHandle(handle) == 0)
        {
          [self _recordError];
        }
    }
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
    }
  [super close];
  _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);

}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if ([self _isOpened])
    {
      [self close];
    }
  [_sibling _setSibling: nil];
  _sibling = nil;
    NSLog(@"_sibling changed to %@;", _sibling);
  [super dealloc];
}

- (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len
    NSLog(@"Entering - (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len");
{
  if (offset < length)
    {
      *buffer  = data + offset;
    NSLog(@"buffer changed to %@;", buffer);
      *len = length - offset;
    NSLog(@"len changed to %@;", len);
    }
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (id) init
    NSLog(@"Entering - (id) init");
{
  if ((self = [super init]) != nil)
    {
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
      _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  if (_loopID == (void*)INVALID_HANDLE_VALUE)
    {
      _loopID = (void*)CreateEvent(NULL, FALSE, FALSE, NULL);
    NSLog(@"_loopID changed to %@;", _loopID);
    }
  [super open];
  [self _queue];
}

- (NSStreamStatus) _check
    NSLog(@"Entering - (NSStreamStatus) _check");
{
  // Must only be called when current status is NSStreamStatusReading.

  if (GetOverlappedResult(handle, &ov, &size, TRUE) == 0)
    {
      if ((errno = GetLastError()) == ERROR_HANDLE_EOF
    || errno == ERROR_PIPE_NOT_CONNECTED
    || errno == ERROR_BROKEN_PIPE)
    {
      /*
       * Got EOF, but we don't want to register it until a
       * -read:maxLength: is called.
       */
      offset = length = want = 0;
    NSLog(@"offset changed to %@;", offset);
      [self _setStatus: NSStreamStatusOpen];
      hadEOF = YES;
    NSLog(@"hadEOF changed to %@;", hadEOF);
    }
      else if (errno != ERROR_IO_PENDING)
    {
      /*
       * Got an error ... record it.
       */
      want = 0;
    NSLog(@"want changed to %@;", want);
      [self _recordError];
    }
    }
  else if (size == 0)
    {
      length = want = 0;
    NSLog(@"length changed to %@;", length);
      [self _setStatus: NSStreamStatusOpen];
      hadEOF = YES;
    NSLog(@"hadEOF changed to %@;", hadEOF);
    }
  else
    {
      /*
       * Read completed and some data was read.
       */
      length = size;
    NSLog(@"length changed to %@;", length);
      [self _setStatus: NSStreamStatusOpen];
    }
    NSLog(@"Returning from method at line: return [self streamStatus];");
  return [self streamStatus];
}

- (void) _queue
    NSLog(@"Entering - (void) _queue");
{
  if (hadEOF == NO && [self streamStatus] == NSStreamStatusOpen)
    {
      int    rc;

      want = sizeof(data);
    NSLog(@"want changed to %@;", want);
      ov.Offset = 0;
    NSLog(@"Offset changed to %@;", Offset);
      ov.OffsetHigh = 0;
    NSLog(@"OffsetHigh changed to %@;", OffsetHigh);
      ov.hEvent = (HANDLE)_loopID;
    NSLog(@"hEvent changed to %@;", hEvent);
      rc = ReadFile(handle, data, want, &size, &ov);
    NSLog(@"rc changed to %@;", rc);
      if (rc != 0)
    {
      // Read succeeded
      want = 0;
    NSLog(@"want changed to %@;", want);
      length = size;
    NSLog(@"length changed to %@;", length);
      if (length == 0)
        {
          hadEOF = YES;
    NSLog(@"hadEOF changed to %@;", hadEOF);
        }
    }
      else if ((errno = GetLastError()) == ERROR_HANDLE_EOF
    || errno == ERROR_PIPE_NOT_CONNECTED
        || errno == ERROR_BROKEN_PIPE)
    {
      hadEOF = YES;
    NSLog(@"hadEOF changed to %@;", hadEOF);
    }
      else if (errno != ERROR_IO_PENDING)
    {
          [self _recordError];
    }
      else
    {
      [self _setStatus: NSStreamStatusReading];
    }
    }
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSStreamStatus myStatus;

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"zero byte length read requested"];
    }

  _events &= ~NSStreamEventHasBytesAvailable;

  myStatus = [self streamStatus];
    NSLog(@"myStatus changed to %@;", myStatus);
  if (myStatus == NSStreamStatusReading)
    {
      myStatus = [self _check];
    NSLog(@"myStatus changed to %@;", myStatus);
    }
  if (myStatus == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  if (offset == length)
    {
      if (myStatus == NSStreamStatusError)
    {
    NSLog(@"Returning from method at line: return -1;    // Waiting for read.");
      return -1;    // Waiting for read.
    }
      if (myStatus == NSStreamStatusOpen)
    {
      /*
       * There is no buffered data and no read in progress,
       * so we must be at EOF.
       */
      [self _setStatus: NSStreamStatusAtEnd];
    }
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  /*
    NSLog(@"Returning from method at line: * We already have data buffered ... return some or all of it.");
   * We already have data buffered ... return some or all of it.
   */
  if (len > (length - offset))
    {
      len = length - offset;
    NSLog(@"len changed to %@;", len);
    }
  memcpy(buffer, data + offset, len);
  offset += len;
  if (offset == length)
    {
      length = 0;
    NSLog(@"length changed to %@;", length);
      offset = 0;
    NSLog(@"offset changed to %@;", offset);
      if (myStatus == NSStreamStatusOpen)
    {
          [self _queue];    // Queue another read
    }
    }
    NSLog(@"Returning from method at line: return len;");
  return len;
}

- (void) _setHandle: (HANDLE)h
    NSLog(@"Entering - (void) _setHandle: (HANDLE)h");
{
  handle = h;
    NSLog(@"handle changed to %@;", handle);
}

- (void) _setSibling: (GSPipeOutputStream*)s
    NSLog(@"Entering - (void) _setSibling: (GSPipeOutputStream*)s");
{
  _sibling = s;
    NSLog(@"_sibling changed to %@;", _sibling);
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  NSStreamEvent myEvent;
  NSStreamStatus oldStatus = [self streamStatus];
    NSLog(@"oldStatus changed to %@;", oldStatus);
  NSStreamStatus myStatus = oldStatus;
    NSLog(@"myStatus changed to %@;", myStatus);

  if (myStatus == NSStreamStatusReading
    || myStatus == NSStreamStatusOpening)
    {
      myStatus = [self _check];
    NSLog(@"myStatus changed to %@;", myStatus);
    }

  if (myStatus == NSStreamStatusAtEnd)
    {
      myEvent = NSStreamEventEndEncountered;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if (myStatus == NSStreamStatusError)
    {
      myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if (oldStatus == NSStreamStatusOpening)
    {
      myEvent = NSStreamEventOpenCompleted;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else
    {
      myEvent = NSStreamEventHasBytesAvailable;
    NSLog(@"myEvent changed to %@;", myEvent);
    }

  [self _sendEvent: myEvent];
}

- (BOOL) runLoopShouldBlock: (BOOL*)trigger
    NSLog(@"Entering - (BOOL) runLoopShouldBlock: (BOOL*)trigger");
{
  NSStreamStatus myStatus = [self streamStatus];
    NSLog(@"myStatus changed to %@;", myStatus);

  if ([self _unhandledData] == YES || myStatus == NSStreamStatusError)
    {
      *trigger = NO;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
      return NO;
    }
  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
  if (myStatus == NSStreamStatusReading)
    {
    NSLog(@"Returning from method at line: return YES;    // Need to wait for I/O");
      return YES;    // Need to wait for I/O
    }
    NSLog(@"Returning from method at line: return NO;        // Need to signal for an event");
  return NO;        // Need to signal for an event
}
@end


@implementation GSFileOutputStream

- (void) close
    NSLog(@"Entering - (void) close");
{
  if (_loopID != (void*)INVALID_HANDLE_VALUE)
    {
      if (CloseHandle((HANDLE)_loopID) == 0)
    {
          [self _recordError];
    }
    }
  [super close];
  _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if ([self _isOpened])
    {
      [self close];
    }
  RELEASE(_path);
  [super dealloc];
}

- (id) initToFileAtPath: (NSString *)path append: (BOOL)shouldAppend
    NSLog(@"Entering - (id) initToFileAtPath: (NSString *)path append: (BOOL)shouldAppend");
{
  if ((self = [super init]) != nil)
    {
      ASSIGN(_path, path);
      _shouldAppend = shouldAppend;
    NSLog(@"_shouldAppend changed to %@;", _shouldAppend);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  HANDLE    h;

  h = (void*)CreateFileW((LPCWSTR)[_path fileSystemRepresentation],
                         GENERIC_WRITE,
                         FILE_SHARE_WRITE,
                         0,
                         OPEN_ALWAYS,
                         0,
                         0);
  if (h == INVALID_HANDLE_VALUE)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return;");
      return;
    }
  else if (_shouldAppend == NO)
    {
      if (SetEndOfFile(h) == 0)    // Truncate to current file pointer (0)
    {
          [self _recordError];
          CloseHandle(h);
    NSLog(@"Returning from method at line: return;");
      return;
    }
    }
  [self _setLoopID: (void*)h];
  [super open];
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  if ([key isEqualToString: NSStreamFileCurrentOffsetKey])
    {
      DWORD offset = 0;
    NSLog(@"offset changed to %@;", offset);

      if ([self _isOpened])
        offset = SetFilePointer((HANDLE)_loopID, 0, 0, FILE_CURRENT);
    NSLog(@"offset changed to %@;", offset);
    NSLog(@"Returning from method at line: return [NSNumber numberWithLong: (long)offset];");
      return [NSNumber numberWithLong: (long)offset];
    }
    NSLog(@"Returning from method at line: return [super propertyForKey: key];");
  return [super propertyForKey: key];
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  DWORD writeLen;

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"zero byte length write requested"];
    }

  _events &= ~NSStreamEventHasSpaceAvailable;

  if ([self streamStatus] == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  if (_shouldAppend == YES)
    {
      SetFilePointer((HANDLE)_loopID, 0, 0, FILE_END);
    }
  if (WriteFile((HANDLE)_loopID, buffer, len, &writeLen, NULL) == 0)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return -1;");
      return -1;
    }
    NSLog(@"Returning from method at line: return (NSInteger)writeLen;");
  return (NSInteger)writeLen;
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  BOOL av = [self hasSpaceAvailable];
    NSLog(@"av changed to %@;", av);
  NSStreamEvent myEvent = av ? NSStreamEventHasSpaceAvailable :
    NSStreamEventEndEncountered;

  [self _sendEvent: myEvent];
}

@end

@implementation GSPipeOutputStream

- (void) close
    NSLog(@"Entering - (void) close");
{
  /* If we have a write in progress, we must wait for it to complete,
   * so we just set a flag to close as soon as the write finishes.
   */
  if ([self streamStatus] == NSStreamStatusWriting)
    {
      closing = YES;
    NSLog(@"closing changed to %@;", closing);
    NSLog(@"Returning from method at line: return;");
      return;
    }

  /* Where we have a sibling, we can't close the pipe handle, so the
   * only way to tell the remote end we have finished is to write a
   * zero length packet to it.
   */
  if ([_sibling _isOpened] == YES && writtenEOF == NO)
    {
      int    rc;

      writtenEOF = YES;
    NSLog(@"writtenEOF changed to %@;", writtenEOF);
      ov.Offset = 0;
    NSLog(@"Offset changed to %@;", Offset);
      ov.OffsetHigh = 0;
    NSLog(@"OffsetHigh changed to %@;", OffsetHigh);
      ov.hEvent = (HANDLE)_loopID;
    NSLog(@"hEvent changed to %@;", hEvent);
      size = 0;
    NSLog(@"size changed to %@;", size);
      rc = WriteFile(handle, "", 0, &size, &ov);
    NSLog(@"rc changed to %@;", rc);
      if (rc == 0)
    {
      if ((errno = GetLastError()) == ERROR_IO_PENDING)
        {
          [self _setStatus: NSStreamStatusWriting];
    NSLog(@"Returning from method at line: return;        // Wait for write to complete");
          return;        // Wait for write to complete
        }
      [self _recordError];    // Failed to write EOF
    }
    }

  offset = want = 0;
    NSLog(@"offset changed to %@;", offset);
  if (_loopID != INVALID_HANDLE_VALUE)
    {
      CloseHandle((HANDLE)_loopID);
    }
  if (handle != INVALID_HANDLE_VALUE)
    {
      if ([_sibling _isOpened] == NO)
    {
      if (DisconnectNamedPipe(handle) == 0)
        {
          if ((errno = GetLastError()) != ERROR_PIPE_NOT_CONNECTED)
        {
          [self _recordError];
        }
          [self _recordError];
        }
      if (CloseHandle(handle) == 0)
        {
          [self _recordError];
        }
    }
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
    }

  [super close];
  _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if ([self _isOpened])
    {
      [self close];
    }
  [_sibling _setSibling: nil];
  _sibling = nil;
    NSLog(@"_sibling changed to %@;", _sibling);
  [super dealloc];
}

- (id) init
    NSLog(@"Entering - (id) init");
{
  if ((self = [super init]) != nil)
    {
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
      _loopID = (void*)INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  if (_loopID == (void*)INVALID_HANDLE_VALUE)
    {
      _loopID = (void*)CreateEvent(NULL, FALSE, FALSE, NULL);
    NSLog(@"_loopID changed to %@;", _loopID);
    }
  [super open];
}

- (void) _queue
    NSLog(@"Entering - (void) _queue");
{
  NSStreamStatus myStatus = [self streamStatus];
    NSLog(@"myStatus changed to %@;", myStatus);

  if (myStatus == NSStreamStatusOpen)
    {
      while (offset < want)
    {
      int    rc;

      ov.Offset = 0;
    NSLog(@"Offset changed to %@;", Offset);
      ov.OffsetHigh = 0;
    NSLog(@"OffsetHigh changed to %@;", OffsetHigh);
      ov.hEvent = (HANDLE)_loopID;
    NSLog(@"hEvent changed to %@;", hEvent);
      size = 0;
    NSLog(@"size changed to %@;", size);
      rc = WriteFile(handle, data + offset, want - offset, &size, &ov);
    NSLog(@"rc changed to %@;", rc);
      if (rc != 0)
        {
          offset += size;
          if (offset == want)
        {
          offset = want = 0;
    NSLog(@"offset changed to %@;", offset);
        }
        }
      else if ((errno = GetLastError()) == ERROR_IO_PENDING)
        {
          [self _setStatus: NSStreamStatusWriting];
          break;
        }
      else
        {
          [self _recordError];
          break;
        }
    }
    }
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  NSStreamStatus myStatus = [self streamStatus];
    NSLog(@"myStatus changed to %@;", myStatus);

  if (buffer == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"null pointer for buffer"];
    }
  if (len == 0)
    {
      [NSException raise: NSInvalidArgumentException
          format: @"zero byte length write requested"];
    }

  _events &= ~NSStreamEventHasSpaceAvailable;

  if (myStatus == NSStreamStatusWriting)
    {
      myStatus = [self _check];
    NSLog(@"myStatus changed to %@;", myStatus);
    }
  if (myStatus == NSStreamStatusClosed)
    {
    NSLog(@"Returning from method at line: return 0;");
      return 0;
    }

  if ((myStatus != NSStreamStatusOpen && myStatus != NSStreamStatusWriting))
    {
    NSLog(@"Returning from method at line: return -1;");
      return -1;
    }

  if (len > (sizeof(data) - offset))
    {
      len = sizeof(data) - offset;
    NSLog(@"len changed to %@;", len);
    }
  if (len > 0)
    {
      memcpy(data + offset, buffer, len);
      want = offset + len;
    NSLog(@"want changed to %@;", want);
      [self _queue];
    }
    NSLog(@"Returning from method at line: return len;");
  return len;
}

- (NSStreamStatus) _check
    NSLog(@"Entering - (NSStreamStatus) _check");
{
  // Must only be called when current status is NSStreamStatusWriting.
  if (GetOverlappedResult(handle, &ov, &size, TRUE) == 0)
    {
      errno = GetLastError();
    NSLog(@"errno changed to %@;", errno);
      if (errno != ERROR_IO_PENDING)
    {
          offset = 0;
    NSLog(@"offset changed to %@;", offset);
          want = 0;
    NSLog(@"want changed to %@;", want);
          [self _recordError];
    }
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
      offset += size;
      if (offset < want)
    {
      [self _queue];
    }
      else
    {
      offset = want = 0;
    NSLog(@"offset changed to %@;", offset);
    }
    }
  if (closing == YES && [self streamStatus] != NSStreamStatusWriting)
    {
      [self close];
    }
    NSLog(@"Returning from method at line: return [self streamStatus];");
  return [self streamStatus];
}

- (void) _setHandle: (HANDLE)h
    NSLog(@"Entering - (void) _setHandle: (HANDLE)h");
{
  handle = h;
    NSLog(@"handle changed to %@;", handle);
}

- (void) _setSibling: (GSPipeInputStream*)s
    NSLog(@"Entering - (void) _setSibling: (GSPipeInputStream*)s");
{
  _sibling = s;
    NSLog(@"_sibling changed to %@;", _sibling);
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  NSStreamEvent myEvent;
  NSStreamStatus oldStatus = [self streamStatus];
    NSLog(@"oldStatus changed to %@;", oldStatus);
  NSStreamStatus myStatus = oldStatus;
    NSLog(@"myStatus changed to %@;", myStatus);

  if (myStatus == NSStreamStatusWriting
    || myStatus == NSStreamStatusOpening)
    {
      myStatus = [self _check];
    NSLog(@"myStatus changed to %@;", myStatus);
    }

  if (myStatus == NSStreamStatusAtEnd)
    {
      myEvent = NSStreamEventEndEncountered;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if (myStatus == NSStreamStatusError)
    {
      myEvent = NSStreamEventErrorOccurred;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else if (oldStatus == NSStreamStatusOpening)
    {
      myEvent = NSStreamEventOpenCompleted;
    NSLog(@"myEvent changed to %@;", myEvent);
    }
  else
    {
      myEvent = NSStreamEventHasSpaceAvailable;
    NSLog(@"myEvent changed to %@;", myEvent);
    }

  [self _sendEvent: myEvent];
}

- (BOOL) runLoopShouldBlock: (BOOL*)trigger
    NSLog(@"Entering - (BOOL) runLoopShouldBlock: (BOOL*)trigger");
{
  NSStreamStatus myStatus = [self streamStatus];
    NSLog(@"myStatus changed to %@;", myStatus);

  if ([self _unhandledData] == YES || myStatus == NSStreamStatusError)
    {
      *trigger = NO;
    NSLog(@"trigger changed to %@;", trigger);
    NSLog(@"Returning from method at line: return NO;");
      return NO;
    }
  *trigger = YES;
    NSLog(@"trigger changed to %@;", trigger);
  if (myStatus == NSStreamStatusWriting)
    {
    NSLog(@"Returning from method at line: return YES;");
      return YES;
    }
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}
@end

@implementation NSStream

+ (void) getStreamsToHost: (NSHost *)host
    NSLog(@"Entering + (void) getStreamsToHost: (NSHost *)host");
                     port: (NSInteger)port
              inputStream: (NSInputStream **)inputStream
             outputStream: (NSOutputStream **)outputStream
{
  NSString *address = host ? (id)[host address] : (id)@"127.0.0.1";
    NSLog(@"address changed to %@;", address);
  GSSocketStream *ins = nil;
    NSLog(@"ins changed to %@;", ins);
  GSSocketStream *outs = nil;
    NSLog(@"outs changed to %@;", outs);
  int sock;

  ins = (GSSocketStream*)AUTORELEASE([[GSInetInputStream alloc] initToAddr: address port: port]);
    NSLog(@"ins changed to %@;", ins);
  outs = (GSSocketStream*)AUTORELEASE([[GSInetOutputStream alloc] initToAddr: address port: port]);
    NSLog(@"outs changed to %@;", outs);

  //IPv6
  if(!ins)
  {
    #if defined(AF_INET6)
    ins = (GSSocketStream*)AUTORELEASE([[GSInet6InputStream alloc] initToAddr: address port: port]);
    NSLog(@"ins changed to %@;", ins);
    outs = (GSSocketStream*)AUTORELEASE([[GSInet6OutputStream alloc] initToAddr: address port: port]);
    NSLog(@"outs changed to %@;", outs);
    #endif
  }
  
#if 0 // TESTPLANT-MAL-03132018: This bypasses the GSSOCKS processing...
  sock = socket(PF_INET, SOCK_STREAM, 0);
    NSLog(@"sock changed to %@;", sock);

  /*
   * Windows only permits a single event to be associated with a socket
   * at any time, but the runloop system only allows an event handle to
   * be added to the loop once, and we have two streams.
   * So we create two events, one for each stream, so that we can have
   * both streams scheduled in the run loop, but we make sure that the
   * _dispatch method in each stream actually handles things for both
   * streams so that whichever stream gets signalled, the correct
   * actions are taken.
   */
  NSAssert(sock != INVALID_SOCKET, @"Cannot open socket");
  [ins _setSock: sock];
  [outs _setSock: sock];
#endif
  
  // Setup proxy information...
  NSString * hostName = [[host name] retain];
    NSLog(@"hostName changed to %@;", hostName);
  NSDictionary *proxyDict = SCDynamicStoreCopyProxies(NULL, hostName);
    NSLog(@"proxyDict changed to %@;", proxyDict);
  [hostName release];

  // and if available...
  if ([proxyDict count])
    {
      // store in the streams...
      if ([[proxyDict objectForKey: @"SOCKSEnable"] boolValue])
        {
          NSDictionary *proxy = @{ NSStreamSOCKSProxyHostKey : [proxyDict objectForKey: NSStreamSOCKSProxyHostKey],
                                   NSStreamSOCKSProxyPortKey : [proxyDict objectForKey: NSStreamSOCKSProxyPortKey]};
          
          [ins setProperty: proxy forKey: NSStreamSOCKSProxyConfigurationKey];
          [outs setProperty: proxy forKey: NSStreamSOCKSProxyConfigurationKey];
        }
      if ([[proxyDict objectForKey: @"HTTPEnable"] boolValue])
        {
          NSDictionary *proxy = @{ kCFStreamPropertyHTTPProxyHost : [proxyDict objectForKey: kCFStreamPropertyHTTPProxyHost],
                                   kCFStreamPropertyHTTPProxyPort : [proxyDict objectForKey: kCFStreamPropertyHTTPProxyPort]};
          
          [ins setProperty: proxy forKey: kCFStreamPropertyHTTPProxy];
          [outs setProperty: proxy forKey: kCFStreamPropertyHTTPProxy];
        }
      if ([[proxyDict objectForKey: @"HTTPSEnable"] boolValue])
        {
          [ins setProperty: [proxyDict objectForKey: kCFStreamPropertyHTTPSProxyHost] forKey: kCFStreamPropertyHTTPSProxyHost];
          [ins setProperty: [proxyDict objectForKey: kCFStreamPropertyHTTPSProxyHost] forKey: kCFStreamPropertyHTTPSProxyHost];
          [outs setProperty: [proxyDict objectForKey: kCFStreamPropertyHTTPSProxyPort] forKey: kCFStreamPropertyHTTPSProxyPort];
          [outs setProperty: [proxyDict objectForKey: kCFStreamPropertyHTTPSProxyPort] forKey: kCFStreamPropertyHTTPSProxyPort];
        }
    }
  
  // SCDynamicStoreCopyProxies creates a copy so we need to release...
  [proxyDict release];
  
  if (inputStream)
    {
      [ins _setSibling: outs];
      *inputStream = (NSInputStream*)ins;
    NSLog(@"inputStream changed to %@;", inputStream);
    }
  if (outputStream)
    {
      [outs _setSibling: ins];
      *outputStream = (NSOutputStream*)outs;
    NSLog(@"outputStream changed to %@;", outputStream);
    }
    NSLog(@"Returning from method at line: return;");
  return;
}

+ (void) getLocalStreamsToPath: (NSString *)path
    NSLog(@"Entering + (void) getLocalStreamsToPath: (NSString *)path");
                   inputStream: (NSInputStream **)inputStream
                  outputStream: (NSOutputStream **)outputStream
{
  const unichar *name;
  GSPipeInputStream *ins = nil;
    NSLog(@"ins changed to %@;", ins);
  GSPipeOutputStream *outs = nil;
    NSLog(@"outs changed to %@;", outs);
  SECURITY_ATTRIBUTES saAttr;
  HANDLE handle;

  if ([path length] == 0)
    {
      NSDebugMLog(@"address nil or empty");
      goto done;
    }
  if ([path length] > 240)
    {
      NSDebugMLog(@"address (%@) too long", path);
      goto done;
    }
  if ([path rangeOfString: @"\\"].length > 0)
    {
      NSDebugMLog(@"illegal backslash in (%@)", path);
      goto done;
    }
  if ([path rangeOfString: @"/"].length > 0)
    {
      NSDebugMLog(@"illegal slash in (%@)", path);
      goto done;
    }

  /*
   * We allocate a new within the local pipe area
   */
  name = (const unichar *)[[@"\\\\.\\pipe\\GSLocal" stringByAppendingString: path]
    fileSystemRepresentation];

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    NSLog(@"nLength changed to %@;", nLength);
  saAttr.bInheritHandle = FALSE;
    NSLog(@"bInheritHandle changed to %@;", bInheritHandle);
  saAttr.lpSecurityDescriptor = NULL;
    NSLog(@"lpSecurityDescriptor changed to %@;", lpSecurityDescriptor);

  handle = CreateFileW(name,
                       GENERIC_WRITE|GENERIC_READ,
                       0,
                       &saAttr,
                       OPEN_EXISTING,
                       FILE_FLAG_OVERLAPPED,
                       NULL);
  if (handle == INVALID_HANDLE_VALUE)
    {
      [NSException raise: NSInternalInconsistencyException
          format: @"Unable to open named pipe '%@'... %@",
    path, [NSError _last]];
    }

  // the type of the stream does not matter, since we are only using the fd
  ins = AUTORELEASE([GSPipeInputStream new]);
    NSLog(@"ins changed to %@;", ins);
  outs = AUTORELEASE([GSPipeOutputStream new]);
    NSLog(@"outs changed to %@;", outs);

  [ins _setHandle: handle];
  [ins _setSibling: outs];
  [outs _setHandle: handle];
  [outs _setSibling: ins];

done:
  if (inputStream)
    {
      *inputStream = ins;
    NSLog(@"inputStream changed to %@;", inputStream);
    }
  if (outputStream)
    {
      *outputStream = outs;
    NSLog(@"outputStream changed to %@;", outputStream);
    }
}

+ (void) pipeWithInputStream: (NSInputStream **)inputStream
    NSLog(@"Entering + (void) pipeWithInputStream: (NSInputStream **)inputStream");
                outputStream: (NSOutputStream **)outputStream
{
  const unichar *name;
  GSPipeInputStream *ins = nil;
    NSLog(@"ins changed to %@;", ins);
  GSPipeOutputStream *outs = nil;
    NSLog(@"outs changed to %@;", outs);
  SECURITY_ATTRIBUTES saAttr;
  HANDLE readh;
  HANDLE writeh;
  HANDLE event;
  OVERLAPPED ov;
  int rc;

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    NSLog(@"nLength changed to %@;", nLength);
  saAttr.bInheritHandle = FALSE;
    NSLog(@"bInheritHandle changed to %@;", bInheritHandle);
  saAttr.lpSecurityDescriptor = NULL;
    NSLog(@"lpSecurityDescriptor changed to %@;", lpSecurityDescriptor);

  /*
   * We have to use a named pipe since windows anonymous pipes do not
   * support asynchronous I/O!
   * We allocate a name known to be unique.
   */
  name = (const unichar *)[[@"\\\\.\\pipe\\" stringByAppendingString:
    [[NSProcessInfo processInfo] globallyUniqueString]]
    fileSystemRepresentation];
  readh = CreateNamedPipeW(name,
    PIPE_ACCESS_INBOUND | FILE_FLAG_OVERLAPPED,
    PIPE_TYPE_BYTE,
    1,
    BUFSIZ*64,
    BUFSIZ*64,
    100000,
    &saAttr);

  NSAssert(readh != INVALID_HANDLE_VALUE, @"Cannot create pipe");

  // Start async connect
  event = CreateEvent(NULL, NO, NO, NULL);
    NSLog(@"event changed to %@;", event);
  ov.Offset = 0;
    NSLog(@"Offset changed to %@;", Offset);
  ov.OffsetHigh = 0;
    NSLog(@"OffsetHigh changed to %@;", OffsetHigh);
  ov.hEvent = event;
    NSLog(@"hEvent changed to %@;", hEvent);
  ConnectNamedPipe(readh, &ov);

  writeh = CreateFileW(name,
                       GENERIC_WRITE,
                       0,
                       &saAttr,
                       OPEN_EXISTING,
                       FILE_FLAG_OVERLAPPED,
                       NULL);
  if (writeh == INVALID_HANDLE_VALUE)
    {
      CloseHandle(event);
      CloseHandle(readh);
      [NSException raise: NSInternalInconsistencyException
          format: @"Unable to create/open write pipe"];
    }

  rc = WaitForSingleObject(event, 10);
    NSLog(@"rc changed to %@;", rc);
  CloseHandle(event);

  if (rc != WAIT_OBJECT_0)
    {
      CloseHandle(readh);
      CloseHandle(writeh);
      [NSException raise: NSInternalInconsistencyException
          format: @"Unable to create/open read pipe"];
    }

  // the type of the stream does not matter, since we are only using the fd
  ins = AUTORELEASE([GSPipeInputStream new]);
    NSLog(@"ins changed to %@;", ins);
  outs = AUTORELEASE([GSPipeOutputStream new]);
    NSLog(@"outs changed to %@;", outs);

  [ins _setHandle: readh];
  [outs _setHandle: writeh];
  if (inputStream)
    *inputStream = ins;
    NSLog(@"inputStream changed to %@;", inputStream);
  if (outputStream)
    *outputStream = outs;
    NSLog(@"outputStream changed to %@;", outputStream);
}

- (void) close
    NSLog(@"Entering - (void) close");
{
  [self subclassResponsibility: _cmd];
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  [self subclassResponsibility: _cmd];
}

- (void) setDelegate: (id)delegate
    NSLog(@"Entering - (void) setDelegate: (id)delegate");
{
  [self subclassResponsibility: _cmd];
}

- (id) delegate
    NSLog(@"Entering - (id) delegate");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}

- (BOOL) setProperty: (id)property forKey: (NSString *)key
    NSLog(@"Entering - (BOOL) setProperty: (id)property forKey: (NSString *)key");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (id) propertyForKey: (NSString *)key
    NSLog(@"Entering - (id) propertyForKey: (NSString *)key");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}

- (void) scheduleInRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode
    NSLog(@"Entering - (void) scheduleInRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode");
{
  [self subclassResponsibility: _cmd];
}

- (void) removeFromRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode;
    NSLog(@"Entering - (void) removeFromRunLoop: (NSRunLoop *)aRunLoop forMode: (NSString *)mode;");
{
  [self subclassResponsibility: _cmd];
}

- (NSError *) streamError
    NSLog(@"Entering - (NSError *) streamError");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return nil;");
  return nil;
}

- (NSStreamStatus) streamStatus
    NSLog(@"Entering - (NSStreamStatus) streamStatus");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return 0;");
  return 0;
}

@end

@implementation NSInputStream

+ (id) inputStreamWithData: (NSData *)data
    NSLog(@"Entering + (id) inputStreamWithData: (NSData *)data");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSDataInputStream alloc] initWithData: data]);");
  return AUTORELEASE([[GSDataInputStream alloc] initWithData: data]);
}

+ (id) inputStreamWithFileAtPath: (NSString *)path
    NSLog(@"Entering + (id) inputStreamWithFileAtPath: (NSString *)path");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSFileInputStream alloc] initWithFileAtPath: path]);");
  return AUTORELEASE([[GSFileInputStream alloc] initWithFileAtPath: path]);
}

+ (id)inputStreamWithURL:(NSURL *)url
    NSLog(@"Entering + (id)inputStreamWithURL:(NSURL *)url");
{
    NSLog(@"Returning from method at line: return [self inputStreamWithFileAtPath:[url path]];");
  return [self inputStreamWithFileAtPath:[url path]];
}

- (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len
    NSLog(@"Entering - (BOOL) getBuffer: (uint8_t **)buffer length: (NSUInteger *)len");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (BOOL) hasBytesAvailable
    NSLog(@"Entering - (BOOL) hasBytesAvailable");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (id) initWithData: (NSData *)data
    NSLog(@"Entering - (id) initWithData: (NSData *)data");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSDataInputStream alloc] initWithData: data];");
  return [[GSDataInputStream alloc] initWithData: data];
}

- (id) initWithFileAtPath: (NSString *)path
    NSLog(@"Entering - (id) initWithFileAtPath: (NSString *)path");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSFileInputStream alloc] initWithFileAtPath: path];");
  return [[GSFileInputStream alloc] initWithFileAtPath: path];
}

- (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) read: (uint8_t *)buffer maxLength: (NSUInteger)len");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return -1;");
  return -1;
}

@end

@implementation NSOutputStream

+ (id) outputStreamToMemory
    NSLog(@"Entering + (id) outputStreamToMemory");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSDataOutputStream alloc] init]);");
  return AUTORELEASE([[GSDataOutputStream alloc] init]);
}

+ (id) outputStreamToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity
    NSLog(@"Entering + (id) outputStreamToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSBufferOutputStream alloc]");
  return AUTORELEASE([[GSBufferOutputStream alloc]
    initToBuffer: buffer capacity: capacity]);
}

+ (id) outputStreamToFileAtPath: (NSString *)path append: (BOOL)shouldAppend
    NSLog(@"Entering + (id) outputStreamToFileAtPath: (NSString *)path append: (BOOL)shouldAppend");
{
    NSLog(@"Returning from method at line: return AUTORELEASE([[GSFileOutputStream alloc]");
  return AUTORELEASE([[GSFileOutputStream alloc]
    initToFileAtPath: path append: shouldAppend]);
}

- (BOOL) hasSpaceAvailable
    NSLog(@"Entering - (BOOL) hasSpaceAvailable");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return NO;");
  return NO;
}

- (id) initToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity
    NSLog(@"Entering - (id) initToBuffer: (uint8_t *)buffer capacity: (NSUInteger)capacity");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSBufferOutputStream alloc] initToBuffer: buffer capacity: capacity];");
  return [[GSBufferOutputStream alloc] initToBuffer: buffer capacity: capacity];
}

- (id) initToFileAtPath: (NSString *)path append: (BOOL)shouldAppend
    NSLog(@"Entering - (id) initToFileAtPath: (NSString *)path append: (BOOL)shouldAppend");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSFileOutputStream alloc] initToFileAtPath: path");
  return [[GSFileOutputStream alloc] initToFileAtPath: path
                           append: shouldAppend];
}

- (id) initToMemory
    NSLog(@"Entering - (id) initToMemory");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return [[GSDataOutputStream alloc] init];");
  return [[GSDataOutputStream alloc] init];
}

- (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len
    NSLog(@"Entering - (NSInteger) write: (const uint8_t *)buffer maxLength: (NSUInteger)len");
{
  [self subclassResponsibility: _cmd];
    NSLog(@"Returning from method at line: return -1;");
  return -1;
}

@end


@implementation GSLocalServerStream

- (id) init
    NSLog(@"Entering - (id) init");
{
  DESTROY(self);
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (id) initToAddr: (NSString*)addr
    NSLog(@"Entering - (id) initToAddr: (NSString*)addr");
{
  if ([addr length] == 0)
    {
      NSDebugMLog(@"address nil or empty");
      DESTROY(self);
    }
  if ([addr length] > 246)
    {
      NSDebugMLog(@"address (%@) too long", addr);
      DESTROY(self);
    }
  if ([addr rangeOfString: @"\\"].length > 0)
    {
      NSDebugMLog(@"illegal backslash in (%@)", addr);
      DESTROY(self);
    }
  if ([addr rangeOfString: @"/"].length > 0)
    {
      NSDebugMLog(@"illegal slash in (%@)", addr);
      DESTROY(self);
    }

  if ((self = [super init]) != nil)
    {
      path = RETAIN([@"\\\\.\\pipe\\GSLocal" stringByAppendingString: addr]);
    NSLog(@"path changed to %@;", path);
      _loopID = INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
    }
    NSLog(@"Returning from method at line: return self;");
  return self;
}

- (void) dealloc
    NSLog(@"Entering - (void) dealloc");
{
  if ([self _isOpened])
    {
      [self close];
    }
  RELEASE(path);
  [super dealloc];
}

- (void) open
    NSLog(@"Entering - (void) open");
{
  SECURITY_ATTRIBUTES saAttr;
  BOOL alreadyConnected = NO;
    NSLog(@"alreadyConnected changed to %@;", alreadyConnected);

  NSAssert(handle == INVALID_HANDLE_VALUE, NSInternalInconsistencyException);
    NSLog(@"handle changed to %@;", handle);

  saAttr.nLength = sizeof(SECURITY_ATTRIBUTES);
    NSLog(@"nLength changed to %@;", nLength);
  saAttr.bInheritHandle = FALSE;
    NSLog(@"bInheritHandle changed to %@;", bInheritHandle);
  saAttr.lpSecurityDescriptor = NULL;
    NSLog(@"lpSecurityDescriptor changed to %@;", lpSecurityDescriptor);

  handle = CreateNamedPipeW((LPCWSTR)[path fileSystemRepresentation],
                            PIPE_ACCESS_DUPLEX | FILE_FLAG_OVERLAPPED,
                            PIPE_TYPE_MESSAGE,
                            PIPE_UNLIMITED_INSTANCES,
                            BUFSIZ*64,
                            BUFSIZ*64,
                            100000,
                            &saAttr);
  if (handle == INVALID_HANDLE_VALUE)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return;");
      return;
    }

  if ([self _loopID] == INVALID_HANDLE_VALUE)
    {
      /* No existing event to use ..,. create a new one.
       */
      [self _setLoopID: CreateEvent(NULL, NO, NO, NULL)];
    }
  ov.Offset = 0;
    NSLog(@"Offset changed to %@;", Offset);
  ov.OffsetHigh = 0;
    NSLog(@"OffsetHigh changed to %@;", OffsetHigh);
  ov.hEvent = [self _loopID];
    NSLog(@"hEvent changed to %@;", hEvent);
  if (ConnectNamedPipe(handle, &ov) == 0)
    {
      errno = GetLastError();
    NSLog(@"errno changed to %@;", errno);
      if (errno == ERROR_PIPE_CONNECTED)
    {
      alreadyConnected = YES;
    NSLog(@"alreadyConnected changed to %@;", alreadyConnected);
    }
      else if (errno != ERROR_IO_PENDING)
    {
      [self _recordError];
    NSLog(@"Returning from method at line: return;");
      return;
    }
    }

  if ([self _isOpened] == NO)
    {
      [super open];
    }
  if (alreadyConnected == YES)
    {
      [self _setStatus: NSStreamStatusOpen];
    }
}

- (void) close
    NSLog(@"Entering - (void) close");
{
  if (_loopID != INVALID_HANDLE_VALUE)
    {
      CloseHandle((HANDLE)_loopID);
    }
  if (handle != INVALID_HANDLE_VALUE)
    {
      CancelIo(handle);
      if (CloseHandle(handle) == 0)
    {
      [self _recordError];
    }
      handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
    }
  [super close];
  _loopID = INVALID_HANDLE_VALUE;
    NSLog(@"_loopID changed to %@;", _loopID);
}

- (void) acceptWithInputStream: (NSInputStream **)inputStream
    NSLog(@"Entering - (void) acceptWithInputStream: (NSInputStream **)inputStream");
                  outputStream: (NSOutputStream **)outputStream
{
  GSPipeInputStream *ins = nil;
    NSLog(@"ins changed to %@;", ins);
  GSPipeOutputStream *outs = nil;
    NSLog(@"outs changed to %@;", outs);

  _events &= ~NSStreamEventHasBytesAvailable;

  // the type of the stream does not matter, since we are only using the fd
  ins = AUTORELEASE([GSPipeInputStream new]);
    NSLog(@"ins changed to %@;", ins);
  outs = AUTORELEASE([GSPipeOutputStream new]);
    NSLog(@"outs changed to %@;", outs);

  [ins _setHandle: handle];
  [outs _setHandle: handle];

  handle = INVALID_HANDLE_VALUE;
    NSLog(@"handle changed to %@;", handle);
  [self open];    // Re-open to accept more

  if (inputStream)
    {
      [ins _setSibling: outs];
      *inputStream = ins;
    NSLog(@"inputStream changed to %@;", inputStream);
    }
  if (outputStream)
    {
      [outs _setSibling: ins];
      *outputStream = outs;
    NSLog(@"outputStream changed to %@;", outputStream);
    }
}

- (void) _dispatch
    NSLog(@"Entering - (void) _dispatch");
{
  DWORD        size;

  if (GetOverlappedResult(handle, &ov, &size, TRUE) == 0)
    {
      [self _recordError];
      [self _sendEvent: NSStreamEventErrorOccurred];
    }
  else
    {
      [self _setStatus: NSStreamStatusOpen];
      [self _sendEvent: NSStreamEventHasBytesAvailable];
    }
}

@end

