//
//  Miyagi+Private.h
//  Miyagi
//
//  Created by Zachary Davison on 15/10/2013.
//  Copyright (c) 2013 thingsdoer. All rights reserved.
//

#import "Miyagi.h"

NSArray* miyagi_transformArray(NSArray *input, NSArray *validProtocolNames, miyagi_transformationType transformationType);
NSDictionary* miyagi_transformDictionary(NSDictionary *input, NSArray *validProtocolNames, miyagi_transformationType transformationType);