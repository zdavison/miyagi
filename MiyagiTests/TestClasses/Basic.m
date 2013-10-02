//
//  Basic.m
//  Miyagi
//
//  Created by Zachary Davison on 24/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "Basic.h"

@implementation Basic

-(BOOL)isEqual:(Basic*)object{
    if([object isKindOfClass:[Basic class]]){
        BOOL equal =    ([self.uid isEqual:object.uid]) &&
                        ([self.name isEqualToString:object.name]) &&
                        ([self.boolean isEqualToNumber:object.boolean]) &&
                        ([self.stringArray isEqualToArray:object.stringArray]) &&
                        ([self.stringMap isEqualToDictionary:object.stringMap]);
        return equal;
    }
    return NO;
}

@end