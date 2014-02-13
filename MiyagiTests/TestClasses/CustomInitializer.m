//
//  NotAnNSObject.m
//  Miyagi
//
//  Created by Zachary Davison on 13/02/2014.
//  Copyright (c) 2014 thingsdoer. All rights reserved.
//

#import "CustomInitializer.h"

@implementation CustomInitializer

+ (SEL)initSelector{
    return @selector(initWithCustomProperty:);
}

+ (NSArray*)initParameters{
    return @[@"Custom Property"];
}

- (id)initWithCustomProperty:(NSString*)customProperty{
    if(self = [super init]){
        _customProperty = customProperty;
    }
    return self;
}

@end
