//
//  MiyagiTests.m
//  MiyagiTests
//
//  Created by Zachary Davison on 24/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Miyagi.h"
#import "Basic.h"
#import "Nested.h"
#import "ComplexNested.h"
#import "Broken.h"

NSDictionary* aBasic(){
    return @{
      @"id": @42,
      @"JSONname": @"Jimmy Basic",
      @"JSONbool": @YES,
      @"JSONarray": @[@1,@2,@3],
      @"JSONmap": @{@"key": @"value"}
    };
}

SPEC_BEGIN(MiyagiSpec)

describe(@"Basic JSON", ^{
    context(@"given valid values", ^{
        
        __block NSDictionary *json =
        @{
          @"id": @42,
          @"JSONname": @"Jimmy Basic",
          @"JSONbool": @YES,
          @"JSONarray": @[@1,@2,@3],
          @"JSONmap": @{@"key": @"value"}
        };
        Basic *basic = [[Basic alloc] initWithDictionary:json];
        
        it(@"should parse correctly", ^{
            [[basic.uid should]         equal:@42];
            [[basic.name should]        equal:@"Jimmy Basic"];
            [[basic.boolean should]     equal:@YES];
            [[basic.stringArray should] equal:@[@1,@2,@3]];
            [[basic.stringMap should]   equal:@{@"key": @"value"}];
        });
    });
    
    context(@"given incorrectly typed values", ^{
        
        __block NSDictionary *dictionary =
        @{
          @"id": @"NotNSNumber",
          @"JSONname": @42,
          @"JSONbool": @"NotNSNumber",
          @"JSONarray": @"NotNSArray",
          @"JSONmap": @"NotNSDictionary"
          };
        Basic *basic = [[Basic alloc] initWithDictionary:dictionary];
        
        // currently, it's your responsibility to type your properties properly.
        // we could co-erce in future, or raise exceptions?
        
        it(@"should parse correctly", ^{
            [[basic.uid should]         equal:@"NotNSNumber"];
            [[basic.name should]        equal:@42];
            [[basic.boolean should]     equal:@"NotNSNumber"];
            [[basic.stringArray should] equal:@"NotNSArray"];
            [[basic.stringMap should]   equal:@"NotNSDictionary"];
        });
    });
});

describe(@"Nested (depth:1) JSON", ^{
    context(@"given valid values", ^{
        
        __block NSDictionary *json =
        @{
          @"id": @1,
          @"JSONchild":
              @{
                @"id": @2
               },
          @"JSONbasic": aBasic(),
          @"JSONchildrenArray": @[aBasic()],
          @"JSONchildrenMap": @{@"basic": aBasic()}
        };
        
        Basic *basic = [[Basic alloc] initWithDictionary:aBasic()];
        Nested *nested = [[Nested alloc] initWithDictionary:json];
        
        it(@"should parse correctly", ^{
            [[nested.uid should] equal:@1];
            [[nested.child.uid should] equal:@2];
            [[nested.basic.uid should] equal:@42];
            [[nested.basic.name should] equal:@"Jimmy Basic"];
            [[nested.childrenArray should] equal:@[basic]];
            [[nested.childrenMap should] equal:@{@"basic": basic}];
        });
    });
});

describe(@"Nested (depth:4) JSON", ^{
    context(@"given valid values", ^{
        
        __block NSDictionary *json =
        @{
          @"id": @1,
          @"JSONchild":
              @{
                  @"id": @2,
                  @"JSONchild": @{@"id": @3}
               },
          @"JSONchildrenArray": @[@{
                                      @"id": @4,
                                      @"JSONchild": @{@"id": @5}
                                 }],
          @"JSONchildrenMap": @{@"6": @{@"id": @6},
                                @"7": @{@"id": @7}}
          };
        
        ComplexNested *nested = [[ComplexNested alloc] initWithDictionary:json];
        
        it(@"should parse correctly", ^{
            [[nested.uid should] equal:@1];
            [[nested.child.uid should] equal:@2];
            [[nested.child.child.uid should] equal:@3];
            ComplexNested *arrayChild = nested.childrenArray.firstObject;
            [[arrayChild.uid should] equal:@4];
            [[arrayChild.child.uid should] equal:@5];
            
            ComplexNested *mapChild1 = [nested.childrenMap objectForKey:@"6"];
            ComplexNested *mapChild2 = [nested.childrenMap objectForKey:@"7"];
            [[mapChild1.uid should] equal:@6];
            [[mapChild2.uid should] equal:@7];
        });
    });
});

describe(@"Incorrect classes", ^{
    context(@"given valid values", ^{
        
        __block NSDictionary *json =
        @{
          @"url": @"http://someURL",
          @"array": @[@{@"url":@"http://i.am.a.child"}],
          @"doesntExist": @"Hello World",
          @"integer": @1
        };
        
        __block Broken *broken;
        
        it(@"should detect the Miyagi'd collection type regardless of order", ^{
            broken =  [[Broken alloc] initWithDictionary:json];
            Broken *child = broken.objectProtocolFirst.firstObject;
            [[child.url should] equal:@"http://i.am.a.child"];
        });
    });
});

SPEC_END