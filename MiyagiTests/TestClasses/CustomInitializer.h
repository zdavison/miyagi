//
//  NotAnNSObject.h
//  Miyagi
//
//  Created by Zachary Davison on 13/02/2014.
//  Copyright (c) 2014 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(CustomInitializer)
    j(JSONname, name)
    j(JSONnested, nestedObject)
JSOFF(CustomInitializer)

@interface CustomInitializer : NSObject <JSON>

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *customProperty;
@property(nonatomic,strong)CustomInitializer *nestedObject;

- (id)initWithCustomProperty:(NSString*)customProperties;

@end
