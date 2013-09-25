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
    j(url,url)
    j(array, objectProtocolFirst)
JSOFF(Broken)

@interface Broken : NSObject <JSON>

@property(nonatomic,strong)NSString *url;
@property(nonatomic,strong)NSArray<NSObject,Broken> *objectProtocolFirst;

@end
