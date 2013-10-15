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

NSString* miyagi_nondestructiveCapitalize(NSString *input){
    NSString *upcasedChar = [input substringToIndex:1].capitalizedString;
    return [input stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:upcasedChar];
}

NSDictionary* miyagi_combineDictionaries(NSDictionary *first, NSDictionary *second){
    NSMutableDictionary *finalDictionary = [NSMutableDictionary dictionaryWithDictionary:first];
    for(NSString *key in second){
        id value = [second valueForKey:key];
        [finalDictionary setValue:value forKey:key];
    }
    return finalDictionary;
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
    NSUInteger start = [attributeString rangeOfString:@"<"].location;
    
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
    NSUInteger start = 3;
    NSUInteger end = [attributeString rangeOfString:@"<"].location;
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

NSArray* miyagi_transformArray(NSArray *input, NSArray *validProtocolNames, miyagi_transformationType transformationType){
    
    NSMutableArray *transformed = [NSMutableArray array];
    
    for(NSString *protocolName in validProtocolNames){
        Class cls = miyagi_validClassFromName(protocolName);
        if(cls){
            for(id object in (NSArray*)input){
                id instance = nil;
                if(transformationType == miyagi_transformationTypeToObject){
                    instance = [[cls alloc] initWithDictionary:object];
                }else{
                    instance = [object JSON];
                }
                [transformed addObject:instance];
            }
            return transformed;
        }
    }
    
    return input;
}

NSDictionary* miyagi_transformDictionary(NSDictionary *input, NSArray *validProtocolNames, miyagi_transformationType transformationType){
    
    NSMutableDictionary *transformed = [NSMutableDictionary dictionary];
    
    for(NSString *protocolName in validProtocolNames){
        Class cls = miyagi_validClassFromName(protocolName);
        if(cls){
            for(NSString *key in [(NSDictionary*)input allKeys]){
                id object = [input objectForKey:key];
                id instance = object;
                if([object isKindOfClass:[NSDictionary class]]){
                    if(transformationType ==  miyagi_transformationTypeToObject){
                        instance = [[cls alloc] initWithDictionary:object];
                    }else{
                        instance = [object JSON];
                    }
                }
                [transformed setObject:instance forKey:key];
            }
            return transformed;
        }
    }
    
    return input;
}

id miyagi_transformCollection(id input, NSArray *validProtocolNames, miyagi_transformationType transformationType){
    
    // arrays
    if([input isKindOfClass:[NSArray class]]){
        return miyagi_transformArray(input, validProtocolNames, transformationType);
    }
    
    // dictionaries
    else if([input isKindOfClass:[NSDictionary class]]){
        return miyagi_transformDictionary(input, validProtocolNames, transformationType);
    }
    
    return input;
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
                value = miyagi_transformCollection(value, protocolNames, miyagi_transformationTypeToObject);
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

NSDictionary* miyagi_toJSONFromClass(id self, SEL _cmd, Class cls){
    
    // if we dont have a specific target class, default to [self class]
    if(!cls){
        cls = [self class];
    }

    // get miyagimethods
    NSString *protocolName = [@"__MIYAGI__" stringByAppendingString:NSStringFromClass(cls)];
    Protocol *protocol = NSProtocolFromString(protocolName);
    
    unsigned int methodCount;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    
    // return value
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    
    // populate dictionary
    for(int i=0; i<methodCount; i++){
        // get names of source/target properties
        NSString *name = NSStringFromSelector(methods[i].name);
        NSString *propKey = miyagi_parsePROPERTYKey(name);
        NSString *jsonKey = miyagi_parseJSONKey(name);
        
        id value = [self valueForKey:propKey];
        
        objc_property_t property = class_getProperty(cls, propKey.UTF8String);
        
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
            value = miyagi_transformCollection(value, protocolNames, miyagi_transformationTypeToJSON);
        }
        
        // recurse if a child conforms to JSON
        if([value conformsToProtocol:@protocol(JSON)]){
            value = [value JSON];
        }
        
        // set our value, if it isn't nil
        if(value){
            [json setObject:value forKey:jsonKey];
        }
        
    }
    
    // recurse upwards, if our superclass is also a Miyagi'd class
    Class superClass = class_getSuperclass(cls);
    if(class_conformsToProtocol(superClass, @protocol(JSON))){
        NSDictionary *superJSON = miyagi_toJSONFromClass(self, _cmd, superClass);
        NSDictionary *combinedJSON = miyagi_combineDictionaries(superJSON, json);
        json = [NSMutableDictionary dictionaryWithDictionary:combinedJSON];
    }
    
    return json;
}

NSDictionary* miyagi_toJSON(id self, SEL _cmd){
    return miyagi_toJSONFromClass(self, _cmd, [self class]);
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
        NSString *propSetterName = [NSString stringWithFormat:@"set%@:",miyagi_nondestructiveCapitalize(propKey)];
        
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
        IMP oldIMP = class_getMethodImplementation(cls, initSEL);
        IMP newIMP = imp_implementationWithBlock(^(id self, NSDictionary *dictionary){
            miyagi_constructor(self, nil, dictionary);
            return oldIMP(self, nil, dictionary);
        });
        method_setImplementation(constructor, newIMP);
    }else{
        // otherwise just add the method
        class_addMethod(cls, initSEL, (IMP)miyagi_constructor, "@@:@");
    }
}

void miyagi_injectToJSON(Class cls){
    
    SEL jsonSEL = NSSelectorFromString(@"JSON");
    
    // check if we have a user implementation of JSON
    Method toJSON = class_getInstanceMethod(cls, jsonSEL);
    if(toJSON){
        // if so, we need to inject our behaviour before the users init
        IMP oldIMP = class_getMethodImplementation(cls, jsonSEL);
        IMP newIMP = imp_implementationWithBlock(^(id self){
            NSDictionary *miyagiJSON = miyagi_toJSON(self, nil);
            NSDictionary *userJSON = oldIMP(self, nil);
            return miyagi_combineDictionaries(miyagiJSON, userJSON);
        });
        method_setImplementation(toJSON, newIMP);
    }else{
        // otherwise just add the method
        class_addMethod(cls, jsonSEL, (IMP)miyagi_toJSON, "@@");
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

