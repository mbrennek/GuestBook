//
//  Event.h
//  GuestBook
//
//  Created by Matt Brenneke on 1/21/12.
//  Copyright 2013 Matt Brenneke. All rights reserved.
//  Release under the MIT license.  See the LICENSE file in top directory of this project.
//

@import Foundation;
@import CoreData;

@class Signature;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *time;
@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSSet *signatures;

@property (nonatomic, readonly) NSArray *sortedSignatures;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addSignaturesObject:(Signature *)value;

- (void)removeSignaturesObject:(Signature *)value;

- (void)addSignatures:(NSSet *)values;

- (void)removeSignatures:(NSSet *)values;

@end

@interface Event (Formatter)

@property (nonatomic, readonly) NSDateFormatter *formatEventDate;

@end
