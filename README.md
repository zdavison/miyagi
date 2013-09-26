miyagi
======

JSON Marshalling, the simplest way.

![JSON,JSOFF!](http://www.cazejefitness.com/mr-miyagi-smiling.jpg)

## Warning

This is still very much in alpha development, so if you stumbled across this, welcome, 
feel free to play around, but probably don't use it in production yet. This is also why it's not in `cocoapods` yet.

## Installation

Copy `Miyagi.h` and `Miyagi.m` into you project, then import `Miyagi.h`.

## Overview

`miyagi` lets you spec JSON mappings in a way similar to [jackson-annotations](https://github.com/FasterXML/jackson-annotations).
Freeing you from writing JSON mapping code anywhere in your application. A `miyagi`-fied class could look like this: 

```objective-c
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
(returned from your favourite JSON parser)

## Supported Types

`miyagi` supports the following types:

JSON               | Objective-C
-------------------|-------------
`null`             | [`NSNull`][NSNull]
`true` and `false` | [`NSNumber`][NSNumber]
Number             | [`NSNumber`][NSNumber]
String             | [`NSString`][NSString]
Array              | [`NSArray`][NSArray]
Object             | [`NSDictionary`][NSDictionary]

## Collections

`miyagi` supports collection marshalling using 'fake protocols' in the same way as `JSONModel`(https://github.com/icanzilb/JSONModel), 
essentially giving you similar syntax to typed collections in other languages like Java.

It looks like this:

```objective-c
@property(nonatomic,strong)NSArray<MyClass>      *array;
@property(nonatomic,strong)NSDictionary<MyClass> *map;
```

## Why `miyagi`?

I was unhappy with almost every marshalling implementation I had seen, almost all of them were `almost` there,
but none quite crossed the line and became a really nice solution to use, all had caveats, so here's why I
think `miyagi` is cool.

* Write no initialization code.
* JSON spec visible alongside your properties, in your header.
* `@properties` don't need to match JSON keys.
* No need to subclass anything.
* Lightweight implementation (2 files, <500 lines).

## How it works

`miyagi` uses a couple of macros to do its work. It creates fake protocols for each adopting class, 
and stores source/destination keys in smart-named method names. Dynamically, at runtime, these
fake protocols inject their payloads into your classes, and create 'routing' properties, copying your
method implementations for your setters/getters and targeting the same `ivar` (So you can override get/set 
and have your JSON get/set function the same way). It then injects the `initWithDictionary:` constructor
into the class (making sure to preserve any existing code you have in that method, if implemented).

Feel free to examine the code and contribute!

## Immediate //TODO:

* toJSON()
* More tests (primarily around bad data).

## How can I help?

Write tests! Even if they don't pass, I'll look at valid JSON spec tests and make them work. :)


