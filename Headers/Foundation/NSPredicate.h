########## Keysight Technologies Added Changes To Satisfy LGPL 2.x Section 2(a) Requirements ##########
# Committed by: Marcian Lytwyn
# Commit ID: 01b13228d3ecfd3d555d73daf1c448ad809970a9
# Date: 2016-09-13 20:15:05 +0000
--------------------
# Committed by: Frank Le Grand
# Commit ID: 5d77e1e33ac61e7f44ee32860a83fefff83d62c8
# Date: 2013-08-09 14:20:01 +0000
########## End of Keysight Technologies Notice ##########
/* Interface for NSPredicate for GNUStep
   Copyright (C) 2005 Free Software Foundation, Inc.

   Written by:  Dr. H. Nikolaus Schaller
   Created: 2005
   
   This file is part of the GNUstep Base Library.

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

#ifndef __NSPredicate_h_GNUSTEP_BASE_INCLUDE
#define __NSPredicate_h_GNUSTEP_BASE_INCLUDE
#import	<GNUstepBase/GSVersionMacros.h>

#if	OS_API_VERSION(MAC_OS_X_VERSION_10_4, GS_API_LATEST)

#import	<Foundation/NSObject.h>
#import	<Foundation/NSArray.h>
#import	<Foundation/NSDictionary.h>
#import	<Foundation/NSSet.h>
#import <Foundation/NSString.h>

#if	defined(__cplusplus)
extern "C" {
#endif

#if	OS_API_VERSION(MAC_OS_X_VERSION_10_6, GS_API_LATEST)
DEFINE_BLOCK_TYPE(GSBlockPredicateBlock, BOOL, id, GS_GENERIC_CLASS(NSDictionary,NSString*,id)*);
#endif

@interface NSPredicate : NSObject <NSCoding, NSCopying>

+ (NSPredicate *) predicateWithFormat: (NSString *)format, ...;
+ (NSPredicate *) predicateWithFormat: (NSString *)format
			argumentArray: (NSArray *)args;
+ (NSPredicate *) predicateWithFormat: (NSString *)format
			    arguments: (va_list)args;
+ (NSPredicate *) predicateWithValue: (BOOL)value;
#if	OS_API_VERSION(MAC_OS_X_VERSION_10_6, GS_API_LATEST)
+ (NSPredicate *) predicateWithBlock: (GSBlockPredicateBlock)block;
#endif
- (BOOL) evaluateWithObject: (id)object;
- (NSString *) predicateFormat;
- (NSPredicate *) predicateWithSubstitutionVariables:
  (GS_GENERIC_CLASS(NSDictionary,NSString*,id)*)variables;
#if OS_API_VERSION(MAC_OS_X_VERSION_10_5, GS_API_LATEST)
- (BOOL) evaluateWithObject: (id)object
	  substitutionVariables: 
	  (GS_GENERIC_CLASS(NSDictionary,NSString*,id)*)variables;
#endif
@end

@interface NSArray (NSPredicate)
/** Evaluate each object in the array using the specified predicate and
 * return an array containing all the objects which evaluate to YES.
 */
- (NSArray *) filteredArrayUsingPredicate: (NSPredicate *)predicate;
@end

@interface NSMutableArray (NSPredicate)
/** Evaluate each object in the array using the specified predicate and
 * remove each objects which evaluates to NO.
 */
- (void) filterUsingPredicate: (NSPredicate *)predicate;
@end

@interface NSSet (NSPredicate)
/** Evaluate each object in the set using the specified predicate and
 * return an set containing all the objects which evaluate to YES.
 */
- (NSSet *) filteredSetUsingPredicate: (NSPredicate *)predicate;
@end

@interface NSMutableSet (NSPredicate)
/** Evaluate each object in the set using the specified predicate and
 * remove each objects which evaluates to NO.
 */
- (void) filterUsingPredicate: (NSPredicate *)predicate;
@end

#if	defined(__cplusplus)
}
#endif

#endif	/* 100400 */
#endif /* __NSPredicate_h_GNUSTEP_BASE_INCLUDE */
