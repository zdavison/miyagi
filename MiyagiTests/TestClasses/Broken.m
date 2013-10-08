//
//  Broken.m
//  Miyagi
//
//  Created by Zachary Davison on 25/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "Broken.h"

@implementation Broken

-(id)initWithDictionary:(NSDictionary *)dictionary{
    return self;
}

-(NSString*)overridenGetter{
    return [@"prepended_by_getter_" stringByAppendingString:(_overridenGetter) ?: @""];
}

-(void)setUrl:(NSString *)url{
    _url = [url stringByAppendingString:@"_appended_by_setter"];
}

-(NSDictionary*)JSON{
    return @{@"fromUserCode": @"userValue"};
}

@end
