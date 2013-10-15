//
//  NSArray+Miyagi.m
//  Miyagi
//
//  Created by Zachary Davison on 15/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "NSArray+Miyagi.h"
#import "Miyagi+Private.h"
#import "Miyagi.h"

@implementation NSArray (Miyagi)

+(NSArray*)arrayOfObjectsFromJSON:(NSArray*)json ofClass:(Class)cls{
  return miyagi_transformArray(json, @[NSStringFromClass(cls)], miyagi_transformationTypeToObject);
}

@end
