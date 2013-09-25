//
//  Nested.m
//  Miyagi
//
//  Created by Zachary Davison on 25/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "Nested.h"

@implementation Nested

-(BOOL)isEqual:(Nested*)object{
    if([object isKindOfClass:[Nested class]]){
        BOOL equal =    ([self.uid isEqual:object.uid]) &&
                        ([self.child isEqual:object.child]) &&
                        ([self.basic isEqual:object.basic]) &&
                        ([self.childrenArray isEqualToArray:object.childrenArray]) &&
                        ([self.childrenMap isEqualToDictionary:object.childrenMap]);
        return equal;
    }
    return NO;
}

@end


