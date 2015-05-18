//
//  SoftBubble.h
//  softbody
//
//  Created by Grubert, Marco on 5/17/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface SoftBubble : CCSprite
- (void)enablePhysics;
- (void) applyForce:(CGPoint)force;
- (void) setPosition:(CGPoint)position;
@end
