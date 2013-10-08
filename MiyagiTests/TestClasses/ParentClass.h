//
//  ParentClass.h
//  Miyagi
//
//  Created by Zachary Davison on 08/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(ParentClass)
  j(JSONname, name);
JSOFF(ParentClass)

@interface ParentClass : NSObject<JSON>

@property(nonatomic,copy)NSString *name;

@end
