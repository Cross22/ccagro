//
//  Attractor.h
//  softbody
//
//  Created by Marco Grubert on 5/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#pragma once

@protocol Attractor <NSObject>

-(CGPoint) position;
-(float) radius;
-(float) force;

@end