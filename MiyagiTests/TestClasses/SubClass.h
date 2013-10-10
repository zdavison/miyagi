//
//  SubClass.h
//  Miyagi
//
//  Created by Zachary Davison on 08/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "ParentClass.h"

JSON(SubClass)
    j(JSONsubName, subName)
JSOFF(SubClass)

@interface SubClass : ParentClass

@property(nonatomic,copy)NSString *subName;

@end
