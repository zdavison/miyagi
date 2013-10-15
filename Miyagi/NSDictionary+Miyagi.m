//
//  NSDictionary+Miyagi.m
//  Miyagi
//
//  Created by Zachary Davison on 15/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "NSDictionary+Miyagi.h"
#import "Miyagi+Private.h"
#import "Miyagi.h"

@implementation NSDictionary (Miyagi)

+(NSDictionary*)dictionaryOfObjectsFromJSON:(NSDictionary*)json ofClass:(Class)cls{
  return miyagi_transformDictionary(json, @[NSStringFromClass(cls)], miyagi_transformationTypeToObject);
}

@end
