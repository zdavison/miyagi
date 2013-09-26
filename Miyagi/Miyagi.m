//
//  Miyagi.m
//  Miyagi
//
//  Created by Zachary Davison on 24/09/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "Miyagi.h"
#import <objc/message.h>

#pragma mark - Statics

static const char* JSONTypes[] = {
    "NSString",
    "NSNumber",
    "NSNull",
    "NSDictionary",
    "NSArray"
};

#pragma mark - Helpers

BOOL miyagi_isValidType(const char *typeName){
    
    if(!typeName){
        return NO;
    }
    
    // check basic supported JSON types
    int count = sizeof(JSONTypes) / sizeof(JSONTypes[0]);
    for(int i=0; i<count; i++){
        if(strcmp(typeName, JSONTypes[i]) == 0){
            return YES;
        }
    }
    
    // check Miyagi types
    Class cls = objc_lookUpClass(typeName);
    if(class_conformsToProtocol(cls, @protocol(JSON))){
        return YES;
    }
    
    return NO;
}

NSString *miyagi_nondestructive_upcase(NSString *input){
    NSString *upcasedChar = [input substringToIndex:1].capitalizedString;
    return [input stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:upcasedChar];
}

#pragma mark - Private

NSString *miyagi_parseJSONKey(NSString *signature){
    NSRange prefixRange = [signature rangeOfString:@"__MIYAGI__JSONKEY__"];
    int start = prefixRange.location + prefixRange.length;
    int end = [signature rangeOfString:@":"].location;
    NSRange keyRange = NSMakeRange(start, end - start);
    return [signature substringWithRange:keyRange];
}

NSString *miyagi_parsePROPERTYKey(NSString *signature){
    NSRange prefixRange = [signature rangeOfString:@"__MIYAGI__PROPERTYKEY__"];
    int start = prefixRange.location + prefixRange.length;
    int end = signature.length - 1;
    NSRange keyRange = NSMakeRange(start, end - start);
    return [signature substringWithRange:keyRange];
}

NSArray *miyagi_parseProtocolNames(NSString *attributeString){
    
    // trim everything before the first protocol, so we dont get any weird class collisions
    NSMutableArray *protocols = [NSMutableArray array];
    int start = [attributeString rangeOfString:@"<"].location;
    
    // if we dont have any protocols, just return an empty array
    if(start == NSNotFound){
        return [NSArray array];
    }
    
    NSString *trimmedString = [attributeString substringFromIndex:start];
    NSCharacterSet *splitCharacters = [NSCharacterSet characterSetWithCharactersInString:@"<>"];
    
    // get potential protocols
    NSArray *components = [trimmedString componentsSeparatedByCharactersInSet:splitCharacters];
    
    for(NSString *string in components){
        Protocol *protocol = objc_getProtocol(string.UTF8String);
        
        // add valid protocols
        if(protocol){
            [protocols addObject:string];
        }
    }
    
    return protocols;
}

NSString *miyagi_parseTypeName(NSString *attributeString){
    int start = 3;
    int end = [attributeString rangeOfString:@"<"].location;
    if(end == NSNotFound){
        end = [attributeString rangeOfString:@"\","].location;
    }
    
    // detecting basic types and other screwups
    if(end == NSNotFound){
        return nil;
    }
    
    return [attributeString substringWithRange:NSMakeRange(start, end - start)];
}

Class miyagi_validClassFromName(NSString *name){
    
    Class cls = NSClassFromString(name);
    if(cls && class_conformsToProtocol(cls, @protocol(JSON))){
        return cls;
    }
    
    return nil;
}

id miyagi_transformCollection(id value, NSArray *validProtocolNames){
    
    // arrays
    if([value isKindOfClass:[NSArray class]]){
        NSMutableArray *transformed = [NSMutableArray array];
        
        for(NSString *protocolName in validProtocolNames){
            Class cls = miyagi_validClassFromName(protocolName);
            if(cls){
                for(NSDictionary *object in (NSArray*)value){
                    id instance = [[cls alloc] initWithDictionary:object];
                    [transformed addObject:instance];
                }
                return transformed;
            }
        }
    }
    
    // dictionaries
    else if([value isKindOfClass:[NSDictionary class]]){
        NSMutableDictionary *transformed = [NSMutableDictionary dictionary];
        
        for(NSString *protocolName in validProtocolNames){
            Class cls = miyagi_validClassFromName(protocolName);
            if(cls){
                for(NSString *key in [(NSDictionary*)value allKeys]){
                    id object = [value objectForKey:key];
                    id instance = object;
                    if([object isKindOfClass:[NSDictionary class]]){
                        instance = [[cls alloc] initWithDictionary:object];
                    }
                    [transformed setObject:instance forKey:key];
                }
                return transformed;
            }
        }
    }
    
    return value;
}

id miyagi_constructor(id self, SEL _cmd, NSDictionary *dictionary){
                //                      struct objc_super supes = { self, [self superclass] };
    if(self){   //TODO: should this be 'if(self ==  objc_msgSendSuper(&supes, @selector(init)))' ??
        for(NSString *jsonKey in dictionary.allKeys){
            
            id value = [dictionary valueForKey:jsonKey];
            NSString *propKey = [@"__MIYAGI__" stringByAppendingString:jsonKey];
            
            objc_property_t property = class_getProperty([self class], propKey.UTF8String);
            
            // if the property doesnt exist, carry on.
            if(!property){
                continue;
            }
            
            // parse out the 'types' of the collection (eg: NSArray<MyModel>)
            const char *attributes = property_getAttributes(property);
            NSString *attributeString = [NSString stringWithUTF8String:attributes];
            NSArray *protocolNames = miyagi_parseProtocolNames(attributeString);
        
            // transform our value, if it's a collection
            if([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]){
                value = miyagi_transformCollection(value, protocolNames);
            }
            
            // check if our value is a miyagi'd class
            NSString *typeName = miyagi_parseTypeName(attributeString);
            Class type = NSClassFromString(typeName);
            if(type && class_conformsToProtocol(type, @protocol(JSON))){
                value = [[type alloc] initWithDictionary:value];
            }
            
            [self setValue:value forKey:propKey];
        }
    }
    return self;
}

#pragma mark - Public

void miyagi_injectProtocolRouting(Class cls, Protocol *protocol){

    unsigned int methodCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for(int i=0; i<methodCount; i++){
        // get names of source/target properties
        NSString *name = NSStringFromSelector(methods[i].name);
        NSString *propKey = miyagi_parsePROPERTYKey(name);
        NSString *jsonKey = [@"__MIYAGI__" stringByAppendingString:miyagi_parseJSONKey(name)];
        
        // get source property attributes
        objc_property_t property = class_getProperty(cls, propKey.UTF8String);
        if(!property){
            [NSException raise:@"MIYAGINonExistantPropertyException" format:@"The property %@ does not exist on class %@",propKey,NSStringFromClass(cls)];
        }
        unsigned int attributeCount;
        objc_property_attribute_t *attributes = property_copyAttributeList(property, &attributeCount);
        
        // add property
        class_addProperty(cls, jsonKey.UTF8String, attributes, attributeCount);
        
        // ensure property is valid
        NSString *attributeString = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSString *propertyTypeName = miyagi_parseTypeName(attributeString);
        if(!miyagi_isValidType(propertyTypeName.UTF8String)){
            [NSException raise:@"MIYAGIInvalidTypeException" format:@"The property %@ is of invalid type '%@', is it a basic datatype? (BOOL,int,float...)",propKey,propertyTypeName];
        }
        
        // add getters/setters
        NSString *jsonSetterName = [NSString stringWithFormat:@"set%@:",jsonKey];
        NSString *propSetterName = [NSString stringWithFormat:@"set%@:",miyagi_nondestructive_upcase(propKey)];
        
        SEL getterSEL = NSSelectorFromString(jsonKey);
        SEL setterSEL = NSSelectorFromString(jsonSetterName);
        
        IMP getterIMP = class_getMethodImplementation(cls, NSSelectorFromString(propKey));
        IMP setterIMP = class_getMethodImplementation(cls, NSSelectorFromString(propSetterName));
        
        class_addMethod(cls, getterSEL, getterIMP, "@@:");
        class_addMethod(cls, setterSEL, setterIMP, "v@:@");
        
        free(attributes);
    }
    free(methods);
}

void miyagi_injectConstructor(Class cls){
    
    SEL initSEL = NSSelectorFromString(@"initWithDictionary:");
    
    // check if we have a user implementation of initWithDictionary:
    Method constructor = class_getInstanceMethod(cls, initSEL);
    if(constructor){
        // if so, we need to inject our behaviour before the users init
        Method m = class_getInstanceMethod(cls, initSEL);
        IMP oldIMP = class_getMethodImplementation(cls, initSEL);
        IMP newIMP = imp_implementationWithBlock(^(id self, NSDictionary *dictionary){
            miyagi_constructor(self, nil, dictionary);
            return oldIMP(self, nil, dictionary);
        });
        method_setImplementation(m, newIMP);
    }else{
        // otherwise just add the method
        class_addMethod(cls, initSEL, (IMP)miyagi_constructor, "@@:@");
    }
}

NSMutableDictionary *initializedClasses = nil;

BOOL miyagi_classInitialized(Class cls){
    
    // initialize our class list if not set already
    if(!initializedClasses){
        initializedClasses = [NSMutableDictionary dictionary];
    }
    
    if([initializedClasses objectForKey:NSStringFromClass(cls)]){
        return YES;
    }
    
    return NO;
}

void miyagi_closeClass(Class cls){
    [initializedClasses setObject:cls forKey:NSStringFromClass(cls)];
}

