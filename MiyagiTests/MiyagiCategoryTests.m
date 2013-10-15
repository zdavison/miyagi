#import <Kiwi/Kiwi.h>
#import "Miyagi.h"
#import "Basic.h"

SPEC_BEGIN(MiyagiCategorySpec)

describe(@"JSON Arrays", ^{
  context(@"with valid objects", ^{
    
    __block NSArray *json = @[@{@"JSONname": @"Object 1"},@{@"JSONname":@"Object 2"}];
    
    it(@"should parse correctly", ^{
      NSArray *objects = [NSArray arrayOfObjectsFromJSON:json ofClass:[Basic class]];
      
      [[objects should] haveCountOf:2];
      Basic *firstObject = objects[0];
      Basic *secondObject = objects[1];
      
      [[firstObject.name should] equal:@"Object 1"];
      [[secondObject.name should] equal:@"Object 2"];
    });
                        
  });
});

describe(@"JSON Dictionary", ^{
  context(@"with valid objects", ^{
    
    __block NSDictionary *json = @{@"object": @{@"JSONname": @"Object 1"}};
    
    it(@"should parse correctly", ^{
      NSDictionary *dictionary = [NSDictionary dictionaryOfObjectsFromJSON:json ofClass:[Basic class]];
      
      Basic *object = dictionary[@"object"];
      
      [[object.name should] equal:@"Object 1"];
    });
    
  });
});

SPEC_END