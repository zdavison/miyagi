//
//  workspace.m
//  Miyagi
//
//  Created by Zachary Davison on 26/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#include <stdio.h>
#import "Miyagi.h"

//JSON(Basic)
//j(id, uid);
//j(JSONname, name);
//j(JSONbool, boolean);
//j(JSONarray, stringArray);
//j(JSONmap, stringMap);
//JSOFF(Basic)

@class Basic;
@protocol Basic;
@protocol __MIYAGI__Basic
@optional
    -(void)__MIYAGI__JSONKEY__id:(void)waxon __MIYAGI__PROPERTYKEY__uid:(void)waxoff;;
    -(void)__MIYAGI__JSONKEY__JSONname:(void)waxon __MIYAGI__PROPERTYKEY__name:(void)waxoff;;
    -(void)__MIYAGI__JSONKEY__JSONbool:(void)waxon __MIYAGI__PROPERTYKEY__boolean:(void)waxoff;;
    -(void)__MIYAGI__JSONKEY__JSONarray:(void)waxon __MIYAGI__PROPERTYKEY__stringArray:(void)waxoff;;
    -(void)__MIYAGI__JSONKEY__JSONmap:(void)waxon __MIYAGI__PROPERTYKEY__stringMap:(void)waxoff;;
@end

__attribute__((constructor))
static void __MIYAGI__Basic__inject(){
    @protocol(Basic);
    Protocol *protocol = @protocol(__MIYAGI__Basic);
    Class cls = objc_lookUpClass("Basic");
    if(!miyagi_classInitialized(cls)){
        miyagi_injectProtocolRouting(cls,protocol);
        miyagi_injectConstructor(cls);
        miyagi_injectToJSON(cls);
        miyagi_closeClass(cls);
    }
}
