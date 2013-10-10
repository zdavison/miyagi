//
//  ComplexNested.h
//  Miyagi
//
//  Created by Zachary Davison on 25/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(ComplexNested)
    j(id, uid)
    j(JSONchild, child)
    j(JSONchildrenArray, childrenArray)
    j(JSONchildrenMap, childrenMap)
JSOFF(ComplexNested)

@interface ComplexNested : NSObject <JSON>

@property(nonatomic,copy)NSNumber *uid;
@property(nonatomic,strong)ComplexNested *child;
@property(nonatomic,strong)NSArray<ComplexNested> *childrenArray;
@property(nonatomic,strong)NSDictionary<ComplexNested> *childrenMap;

@end
