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

NSDictionary* aBasicJSON(){
    return @{
      @"id": @42,
      @"JSONname": @"Jimmy Basic",
      @"JSONbool": @YES,
      @"JSONarray": @[@1,@2,@3],
      @"JSONmap": @{@"key": @"value"}
    };
}

Basic* aBasicObject(){
    __block Basic *basic = [[Basic alloc] init];
    basic.uid = @42;
    basic.name = @"Jimmy Basic";
    basic.boolean = @YES;
    basic.stringArray = @[@1,@2,@3];
    basic.stringMap = @{@"key": @"value"};
    
    return basic;
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

describe(@"Nested (depth == 1) JSON", ^{
    context(@"given valid values", ^{
        
        __block NSDictionary *json =
        @{
          @"id": @1,
          @"JSONchild":
              @{
                @"id": @2
               },
          @"JSONbasic": aBasicJSON(),
          @"JSONchildrenArray": @[aBasicJSON()],
          @"JSONchildrenMap": @{@"basic": aBasicJSON()}
        };
        
        Basic *basic = aBasicObject();
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

describe(@"Nested (depth > 1) JSON", ^{
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
          @"id": @1,
          @"url": @"http://someURL",
          @"array": @[@{@"id":@2}],
          @"doesntExist": @"Hello World",
          @"jsonOverride": @"override",
          @"integer": @1,
          @"nullValue": [NSNull null]
        };
        
        __block Broken *broken = [[Broken alloc] initWithDictionary:json];;
        
        it(@"should parse NSNull correctly", ^{
            [[broken.nullValue should] beNil];
        });
        
        it(@"should handle getter/setter overrides correctly", ^{
            [[broken.url should] equal:@"http://someURL_appended_by_setter"];
            [[broken.overridenGetter should] equal:@"prepended_by_getter_override"];
        });
        
        it(@"should detect the Miyagi'd collection type regardless of order", ^{
            Broken *child = broken.objectProtocolFirst.firstObject;
            [[child.uid should] equal:@2];
        });
    });
});

describe(@"Simple Cocoa Objects", ^{
    context(@"with valid properties", ^{
        
        __block Basic *basic = [[Basic alloc] init];
        basic.uid = @1;
        basic.name = @"Already Initialized";
        basic.boolean = @YES;
        basic.stringArray = @[@1,@2];
        basic.stringMap = @{@"key": @"value"};
        
        NSDictionary *json = [basic JSON];
        
        [[theValue(json.allKeys.count) should] equal:theValue(@5)];
        
        for(id value in json.allValues){
            [[value shouldNot] beNil];
        }
        
        [[json[@"id"] should] equal:@1];
        [[json[@"JSONname"] should] equal:@"Already Initialized"];
        [[json[@"JSONbool"] should] equal:@YES];
        [[json[@"JSONarray"] should] equal:@[@1,@2]];
        [[json[@"JSONmap"] should] equal:@{@"key": @"value"}];
    });
});

describe(@"Nested (depth == 1) Cocoa Objects", ^{
    context(@"with valid properties", ^{
        
        __block Nested *simpleNested = [[Nested alloc] init];
        simpleNested.uid = @2;
        
        __block Nested *nested = [[Nested alloc] init];
        nested.uid = @1;
        nested.basic = aBasicObject();
        nested.child = simpleNested;
        nested.childrenArray = (NSArray<Basic>*)@[aBasicObject()];
        nested.childrenMap =(NSDictionary<Basic>*) @{@"key": aBasicObject()};
        
        NSDictionary *json = [nested JSON];
        
        it(@"should have the correct amount of keys", ^{
            [[theValue(json.allKeys.count) should] equal:theValue(5)];
        });
        
        it(@"should parse correctly", ^{
            [[json[@"id"] should] equal:@1];
            [[json[@"JSONbasic"] should] equal:[aBasicObject() JSON]];
            [[json[@"JSONchild"] should] equal:[simpleNested JSON]];
            [[json[@"JSONchildrenArray"] should] equal:@[[aBasicObject() JSON]]];
            [[json[@"JSONchildrenMap"] should] equal:@{@"key": aBasicObject()}];
        });
    });
});

describe(@"Nested (depth > 1)", ^{
    context(@"with valid properties", ^{
        
        __block ComplexNested *foetus = [[ComplexNested alloc] init];
        foetus.uid = @4;
        
        __block ComplexNested *toddler = [[ComplexNested alloc] init];
        toddler.uid = @3;
        toddler.childrenArray = (NSArray<ComplexNested>*)@[foetus];
        
        __block ComplexNested *child = [[ComplexNested alloc] init];
        child.uid = @2;
        child.child = toddler;
        
        __block ComplexNested *parent = [[ComplexNested alloc] init];
        parent.uid = @1;
        parent.child = child;
        parent.childrenMap = (NSDictionary<ComplexNested>*)@{@"child": child};
        
        NSDictionary *json = [parent JSON];
        
        it(@"should parse correctly", ^{
            NSDictionary *child = json[@"JSONchild"];
            NSDictionary *toddler = child[@"JSONchild"];
            NSArray *children = toddler[@"JSONchildrenArray"];
            NSDictionary *foetus = children.firstObject;
            
            [[json should] beNonNil];
            [[child should] beNonNil];
            [[toddler should] beNonNil];
            [[foetus should] beNonNil];
            
            [[json[@"id"] should] equal:@1];
            [[child[@"id"] should] equal:@2];
            [[toddler[@"id"] should] equal:@3];
            [[foetus[@"id"] should] equal:@4];
        });
    });
});

SPEC_END