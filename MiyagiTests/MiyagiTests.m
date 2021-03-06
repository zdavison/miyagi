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
#import "ParentClass.h"
#import "SubClass.h"
#import "CustomInitializer.h"
#import "BrokenCustomInitializer.h"

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

describe(@"Weird/Abnormal ('Broken') classes", ^{
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
        
        it(@"should serialize to JSON including the users 'JSON' method and all Miyagi mapped keys", ^{
            NSDictionary *json = [broken JSON];
            
            [[theValue(json.allKeys.count) should] equal:theValue(5)];
            [[json[@"fromUserCode"] should] equal:@"userValue"];
        });
        
        it(@"should handle user 'initWithDictionary:' implementations", ^{
            [[broken.notSetFromJSON should] equal:@"initWithDictionary user code"];
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
      
        it(@"should have the correct amount of keys", ^{
          [[theValue(json.allKeys.count) should] equal:theValue(5)];
        });
      
        it(@"should serialize into JSON correctly", ^{
          [[json[@"id"] should] equal:@1];
          [[json[@"JSONname"] should] equal:@"Already Initialized"];
          [[json[@"JSONbool"] should] equal:@YES];
          [[json[@"JSONarray"] should] equal:@[@1,@2]];
          [[json[@"JSONmap"] should] equal:@{@"key": @"value"}];
        });
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
        
        it(@"should serialize into JSON correctly", ^{
            [[json[@"id"] should] equal:@1];
            [[json[@"JSONbasic"] should] equal:[aBasicObject() JSON]];
            [[json[@"JSONchild"] should] equal:[simpleNested JSON]];
            [[json[@"JSONchildrenArray"] should] equal:@[[aBasicObject() JSON]]];
            [[json[@"JSONchildrenMap"] should] equal:@{@"key": aBasicObject()}];
        });
    });
});

describe(@"Nested (depth > 1) Cocoa Objects", ^{
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
      
        it(@"should have the correct amount of keys", ^{
          [[theValue(json.allKeys.count) should] equal:theValue(3)];
        });
      
        it(@"should serialize into JSON correctly", ^{
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

describe(@"Subclasses", ^{
  context(@"with valid properties", ^{
      
    context(@"when parsing into an object", ^{
        NSDictionary *json = @{
                               @"JSONname":@"Parent",
                               @"JSONsubName":@"Sub"
                               };
        
        __block SubClass *subclass = [[SubClass alloc] initWithDictionary:json];
        
        it(@"should parse superclass properties correctly", ^{
            [[subclass.name should] equal:@"Parent"];
        });
        
        it(@"should parse subclass properties correctly", ^{
            [[subclass.subName should] equal:@"Sub"];
        });
    });
      
    context(@"when serializing to JSON", ^{
        
        __block SubClass *subclass = [[SubClass alloc] init];
        subclass.name = @"Parent";
        subclass.subName = @"Sub";
        
        NSDictionary *json = [subclass JSON];
        
        it(@"should have the correct amount of keys", ^{
            [[theValue(json.allKeys.count) should] equal:theValue(2)];
        });
        
        it(@"should serialize into JSON correctly", ^{
            [[json[@"JSONname"] should] equal:@"Parent"];
            [[json[@"JSONsubName"] should] equal:@"Sub"];
        });
    });
  });
});

describe(@"Exceptions", ^{
  context(@"should be raised", ^{
    
    it(@"when invalid types are passed to initWithDictionary:", ^{
      NSArray *array = @[@1];
      [[theBlock(^{
        Basic *basic = [[Basic alloc] initWithDictionary:(NSDictionary*)array];
        basic = nil;
      }) should] raiseWithName:@"MIYAGIInvalidClassException"];
    });
    
  });
});

describe(@"Objects", ^{
    context(@"given valid values", ^{
        
         __block NSDictionary *json = @{@"JSONname": @"Jimmy Testerson"};
        
        it(@"should be able to call 'setupWithDictionary:' at any time", ^{
            
            Basic *object = [[Basic alloc] init];
            [[object.name should] beNil];
            [object setupWithDictionary:json];
            [[object.name should] equal:@"Jimmy Testerson"];
            
        });
    });
});

describe(@"Nested classes with custom initializers", ^{
    
        context(@"given valid values", ^{
            
            __block NSDictionary *json = @{
                                           @"JSONname": @"Jimmy Testerson",
                                           @"JSONnested": @{
                                                   @"JSONname": @"Jimmy Nested"
                                                   }
                                           };
            context(@"with a valid protocol implementation", ^{
                it(@"should be able to initialize", ^{
                
                    CustomInitializer *custom = [[CustomInitializer alloc] initWithDictionary:json];
                    [[custom.name should] equal:@"Jimmy Testerson"];
                    [[custom.nestedObject.name should] equal:@"Jimmy Nested"];
                    [[custom.nestedObject.customProperty should] equal:@"Custom Property"];
                
                });
            });
            
            context(@"with an invalid protocol implementation", ^{
                it(@"should raise the appropriate error messages", ^{
                    
                    [[theBlock(^{
                        BrokenCustomInitializer *broken = [[BrokenCustomInitializer alloc] initWithDictionary:json];
                        broken = nil;
                    }) should] raiseWithName:@"MIYAGIInitializerException"];
                });
            });
    });
    
});

SPEC_END