//
//  Food.h
//  softbody
//
//  Created by Marco Grubert on 5/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"
#import "Attractor.h"

@interface Food : CCSprite<Attractor>
-(float) radius;
-(float) force;

@end
