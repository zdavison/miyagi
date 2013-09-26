//
//  Miyagi.h
//  Miyagi
//
//  Created by Zachary Davison on 24/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define JSON(CLASSNAME) \
    @class CLASSNAME; \
    @protocol CLASSNAME; \
    @protocol __MIYAGI__##CLASSNAME \
    @optional \

#define j(JSONKEY,PROPERTYKEY) \
    -(void)__MIYAGI__JSONKEY__##JSONKEY:(void)waxon __MIYAGI__PROPERTYKEY__##PROPERTYKEY:(void)waxoff; \

#define JSOFF(CLASSNAME) \
    @end \
    __attribute__((constructor)) \
    static void __MIYAGI__##CLASSNAME##__inject(){ \
        @protocol(CLASSNAME); \
        Protocol *protocol = @protocol(__MIYAGI__##CLASSNAME); \
        Class cls = objc_lookUpClass(#CLASSNAME); \
        if(!miyagi_classInitialized(cls)){\
            miyagi_injectProtocolRouting(cls,protocol); \
            miyagi_injectConstructor(cls); \
            miyagi_closeClass(cls); \
        } \
    }

@protocol JSON <NSObject>
@optional
-(id)initWithDictionary:(NSDictionary*)dictionary;
@end

void miyagi_injectProtocolRouting(Class cls, Protocol *protocol);
void miyagi_injectConstructor(Class cls);
BOOL miyagi_classInitialized(Class cls);
void miyagi_closeClass(Class cls);

