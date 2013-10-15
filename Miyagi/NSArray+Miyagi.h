//
//  NSArray+Miyagi.h
//  Miyagi
//
//  Created by Zachary Davison on 15/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Miyagi)

+(NSArray*)arrayOfObjectsFromJSON:(NSArray*)json ofClass:(Class)cls;

@end
