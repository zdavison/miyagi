//
//  BrokenCustomInitializer.m
//  Miyagi
//
//  Created by Zachary Davison on 13/02/2014.
//  Copyright (c) 2014 thingsdoer. All rights reserved.
//

#import "BrokenCustomInitializer.h"

@implementation BrokenCustomInitializer

+ (SEL)initSelector{
    return @selector(initWithCustomProperty:);
}

- (id)initWithCustomProperty:(NSString*)customProperty{
    if(self = [super init]){
        _customProperty = customProperty;
    }
    return self;
}

@end
