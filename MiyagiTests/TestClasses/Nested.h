//
//  Nested.h
//  Miyagi
//
//  Created by Zachary Davison on 25/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"
#import "Basic.h"

JSON(Nested)
    j(id, uid);
    j(JSONchild, child);
    j(JSONbasic, basic);
    j(JSONchildrenArray, childrenArray);
    j(JSONchildrenMap, childrenMap);
JSOFF(Nested)

@interface Nested : NSObject <JSON>

@property(nonatomic,strong)NSNumber             *uid;
@property(nonatomic,strong)Nested               *child;
@property(nonatomic,strong)Basic                *basic;
@property(nonatomic,strong)NSArray<Basic>      *childrenArray;
@property(nonatomic,strong)NSDictionary<Basic> *childrenMap;

@end
