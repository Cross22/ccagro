#import "MainScene.h"
#import "SoftBubble.h"
@implementation MainScene {
    CCPhysicsNode* _physicsRoot;
    CCNode* _scroller;
    CCNode* _world;
    SoftBubble* _bubble;
}

// Similar to viewDidLoad:
-(void)onEnter {
    [super onEnter];
    _physicsRoot.debugDraw= YES;
    _physicsRoot.collisionDelegate= self;
    
    _bubble= [[SoftBubble alloc] initWithImageNamed:@"BubbleGum.png"];
    [_physicsRoot addChild:_bubble];
    
    // place 50% in parent
    _bubble.position= [_bubble convertPositionToPoints:ccp(0.5,0.5)
                                                  type:CCPositionTypeNormalized];
    _bubble.contentSize= (CGSize){ _bubble.contentSize.width/2, _bubble.contentSize.height/2 };
    [_bubble enablePhysics];
    
    // camera should follow player
    CCActionFollow* followMe= [CCActionFollow actionWithTarget:_bubble
                                                 worldBoundary:_world.boundingBox];
    [_scroller runAction:followMe];
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
