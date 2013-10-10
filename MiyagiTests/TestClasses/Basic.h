//
//  Basic.h
//  Miyagi
//
//  Created by Zachary Davison on 24/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(Basic)
    j(id, uid)
    j(JSONname, name)
    j(JSONbool, boolean)
    j(JSONarray, stringArray)
    j(JSONmap, stringMap)
JSOFF(Basic)

@interface Basic : NSObject <JSON>

@property(nonatomic,copy)NSNumber *uid;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSNumber *boolean;
@property(nonatomic,strong)NSArray *stringArray;
@property(nonatomic,strong)NSDictionary *stringMap;

@end
