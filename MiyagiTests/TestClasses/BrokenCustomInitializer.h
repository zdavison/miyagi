//
//  BrokenCustomInitializer.h
//  Miyagi
//
//  Created by Zachary Davison on 13/02/2014.
//  Copyright (c) 2014 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(BrokenCustomInitializer)
    j(JSONnested, nestedObject)
JSOFF(BrokenCustomInitializer)

@interface BrokenCustomInitializer : NSObject <JSON>

@property(nonatomic,strong)NSString *customProperty;
@property(nonatomic,strong)BrokenCustomInitializer *nestedObject;

@end
