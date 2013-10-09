miyagi [![Build Status](https://travis-ci.org/zdavison/miyagi.png?branch=master)](https://travis-ci.org/zdavison/miyagi)
======

Zen-like JSON <-> Object marshalling

![JSON,JSOFF!](http://www.cazejefitness.com/mr-miyagi-smiling.jpg)

## Installation

Via `cocoapods` : `pod miyagi`

## Overview

`miyagi` lets you spec JSON mappings in a way similar to [jackson-annotations](https://github.com/FasterXML/jackson-annotations).
Freeing you from writing JSON mapping code anywhere in your application. A `miyagi`-fied class could look like this: 

```smalltalk
JSON(MyClass)
    j(myJsonKey, name);
    j(myJsonKey2, boolean);
JSOFF(MyClass)

@interface Basic : NSObject <JSON>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSNumber *boolean;

@end
```

All you need to do is place the `JSON/JSOFF` syntax at the top of your file, 
with a `j(key,property)` mapping for each property you'd like to map, then adopt the `<JSON>` protocol.
Afterwards, you can call `initWithDictionary:` to create an instance from a JSON dictionary 
(returned from your favourite JSON parser), and `JSON` to serialize the object back to a JSON dictionary.


## Why `miyagi`?

I was unhappy with almost every marshalling implementation I had seen, almost all of them were `almost` there,
but none quite crossed the line and became a really nice solution to use, all had caveats, so here's why I
think `miyagi` is cool.

* Write no initialization code.
* JSON spec visible alongside your properties, in your header.
* `@properties` don't need to match JSON keys.
* No need to subclass anything.
* Lightweight implementation (2 files, <500 lines).

## Usage

- __Specification:__

Define your JSON mappings in your header file, above your interface, like so:

```smalltalk
JSON(MyClass)
    j(myJsonKey, name);
    j(myJsonKey2, boolean);
JSOFF(MyClass)
```

Your properties will be invisibly mapped to the keys. You can overrided property names as normal, 
and `miyagi` injection will occur __before__ your code executes. There is no need to call `super`!
(So variables will already have been injected in overriden methods)

- __From JSON:__

```smalltalk
MyObject *object = [[MyObject alloc] initWithDictionary:jsonDictionary];
```

After calling `initWithDictionary:`, your object will have been mapped. You can implement this method
in your class, without calling `super`, and injection will occur __before__ your code executes.

- __To JSON:__

```smalltalk
NSDictionary *json = [object JSON];
```

You can call `JSON` to generate an `NSDictionary` from your object, mapped in reverse using your mappings.
You can implement this method in your class, without calling `super`, and injection will occur __before__ your code executes.
The `NSDictionary` returned will be merged with the `miyagi` `NSDictionary`, with your keys overwriting `miyagi`s in 
the event of a collision.

__Example:__
```smalltalk
-(NSDictionary*)JSON{
    return @{@"myKey": @"myValue"};
    // your returned dictionary will be merged into the JSON dictionary.
}
```

## Supported Types

`miyagi` supports the following types:

JSON               | Objective-C
-------------------|-------------
`null`             | `NSNull`
`true` and `false` | `NSNumber`
Number             | `NSNumber`
String             | `NSString`
Array              | `NSArray`
Object             | `NSDictionary`

## Collections

`miyagi` supports collection marshalling using 'fake protocols' in the same way as [JSONModel](https://github.com/icanzilb/JSONModel), 
essentially giving you similar syntax to typed collections in other languages like Java.

It looks like this:

```smalltalk
@property(nonatomic,strong)NSArray<MyClass>      *array;
@property(nonatomic,strong)NSDictionary<MyClass> *map;
```

## Immediate //TODO:

* More edge case coverage!
* More tests!

## How can I help?

Write tests! Even if they don't pass, I'll look at valid JSON spec tests and make them work. :)

## Thanks

Thanks to [Mobile Travel Technologies Ltd.](http://mttnow.com), for letting me develop some of this on company time.


