#import "MainScene.h"
#import "SoftBubble.h"
#import "Food.h"

@implementation MainScene {
    CCPhysicsNode* _physicsRoot;
    CCNode* _scroller;
    CCNode* _world;
    SoftBubble* _bubble;
    Food* _food;
}

// Similar to viewDidLoad:
-(void)onEnter {
    [super onEnter];
    _physicsRoot.debugDraw= YES;
    _physicsRoot.collisionDelegate= self;
    
    // Propagate scale to content size
    _bubble.contentSize= (CGSize){ _bubble.contentSize.width*_bubble.scale,
        _bubble.contentSize.height*_bubble.scale };
    _bubble.scale=1;
    [_bubble enablePhysics];
    
    // camera should follow player
    CCActionFollow* followMe= [CCActionFollow actionWithTarget:_bubble
                                                 worldBoundary:_world.boundingBox];
    [_scroller runAction:followMe];
}

-(void)update:(CCTime)delta
{
    [_bubble applyForceFromAttractor:_food];
}

-(void) onRight {
    [_bubble applyForce:ccp(1*1000,0)];
}
-(void) onLeft {
    [_bubble applyForce:ccp(-1*1000,0)];
}
-(void) onUp {
    [_bubble applyForce:ccp(0,1*1000)];
}
-(void) onDown {
    [_bubble applyForce:ccp(0,-1*1000)];
}

@end
