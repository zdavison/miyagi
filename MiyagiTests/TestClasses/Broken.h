//
//  Broken.h
//  Miyagi
//
//  Created by Zachary Davison on 25/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Miyagi.h"

JSON(Broken)
    j(id,uid)
    j(url,url)
    j(array, objectProtocolFirst)
    j(jsonOverride, overridenGetter)
    j(null, nullValue)
JSOFF(Broken)

@interface Broken : NSObject <JSON>

@property(nonatomic,strong)NSNumber *uid;
@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSString *overridenGetter;
@property(nonatomic,strong)NSArray<NSObject,Broken> *objectProtocolFirst;
@property(nonatomic,strong)NSString *nullValue;
@property(nonatomic,strong)NSString *notSetFromJSON;

@end
