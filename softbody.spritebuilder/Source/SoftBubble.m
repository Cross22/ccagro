//
//  SoftBubble2.m
//
//
//  Created by Pontus Armini on 2015-04-12.
//
//

#import "SoftBubble.h"
#import "cocos2d.h"
#import "CCTexture_Private.h"
#import "CCSprite_Private.h"
#import "Attractor.h"

static const int MAX_SEGMENTS = 20;
static const float PHYSICS_BODY_RADIUS = 1;
static const float INNER_STIFFNESS = 50;//1500;
static const float INNER_DAMPING = 20;
static const float OUTER_STIFFNESS = 50;//1000;
static const float OUTER_DAMPING = 20;//50;


@implementation SoftBubble {
    ccVertex2F vertices[MAX_SEGMENTS+2];
    ccTex2F texCoords[MAX_SEGMENTS+2];
    ccColor4F texColor;
    float bubbleRadius;
    uint32_t score;
}

-(uint32_t)numSegments {
    // Must be even number!
    assert(MAX_SEGMENTS%2==0);
    // TODO: Make score dependent
    return MAX_SEGMENTS;
}


- (void)enablePhysics
{
    // Bubble radius is the the texture half-width
    bubbleRadius = self.contentSize.width/2;
    
    // Main body at the center of the bubble
    self.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:PHYSICS_BODY_RADIUS
                                                   andCenter:CGPointMake(bubbleRadius, bubbleRadius)];
    self.physicsBody.allowsRotation = false;
    self.physicsBody.collisionMask= @[];
    
    // Distance between main body and outer children
    float childDist = bubbleRadius - PHYSICS_BODY_RADIUS;
    
    // Create child bodies connected to the main body with inner springs
    const uint32_t numSegments= [self numSegments];
    for(int i=0; i<numSegments; i++) {
        float childAngle = i * 2 * M_PI / numSegments;
        
        CCNode *child = [CCNode node];
        child.physicsBody = [CCPhysicsBody bodyWithCircleOfRadius:PHYSICS_BODY_RADIUS
                                                        andCenter:CGPointZero];
        child.physicsBody.allowsRotation = false;
        child.position = ccp(bubbleRadius + childDist * cosf(childAngle),
                             bubbleRadius + childDist * sinf(childAngle));
        [self addChild:child];
        CCPhysicsJoint* j;
        j=[CCPhysicsJoint connectedSpringJointWithBodyA:self.physicsBody
                                                bodyB:child.physicsBody
                                              anchorA:CGPointMake(bubbleRadius, bubbleRadius)
                                              anchorB:CGPointZero
                                           restLength:childDist
                                            stiffness:INNER_STIFFNESS damping:INNER_DAMPING];
        j.collideBodies= NO;
        // try maintaining angle
//        j= [CCPhysicsJoint connectedPivotJointWithBodyA:self.physicsBody
//                                                  bodyB:child.physicsBody
//                                                anchorA:self.anchorPointInPoints];
//        j.collideBodies= NO;
//        [CCPhysicsJoint connectedRotarySpringJointWithBodyA:self.physicsBody bodyB:child.physicsBody restAngle:childAngle stiffness:OUTER_STIFFNESS damping:OUTER_DAMPING];

    }
    

    // Connect child bodies together with outer springs
    for(int i=0; i<numSegments; i++) {
//        CCNode *previous = i==0 ? self.children[numSegments-1] : self.children[i-1];
        CCNode *previous = self.children[ (i+1)%numSegments ];
        CCNode *child = self.children[i];
        CGPoint dist= ccpSub(child.position, previous.position);
        [CCPhysicsJoint connectedSpringJointWithBodyA:child.physicsBody
                                                bodyB:previous.physicsBody
                                              anchorA:CGPointZero
                                              anchorB:CGPointZero
                                           restLength: ccpLength(dist)
//                                           restLength:childDist*2*M_PI/numSegments
                                            stiffness:OUTER_STIFFNESS
                                              damping:OUTER_DAMPING];
    }
    //Setting up the color. This will render the original colors of the texture
    texColor = ccc4f(1.0, 1.0, 1.0, 1.0);
    //Setting up the vertices
    [self updateVertices];
    //Setting up the texture coordinates
    [self setUpTexCoords];
}

-(void)updateVertices
{
    vertices[0] = (ccVertex2F){bubbleRadius, bubbleRadius};

    const uint32_t numSegments= [self numSegments];
    for (int i = 0; i < numSegments; i++) {
        CCNode *child = self.children[i];
        vertices[i+1] = (ccVertex2F){
            child.position.x + PHYSICS_BODY_RADIUS * (child.position.x-bubbleRadius)/bubbleRadius,
            child.position.y + PHYSICS_BODY_RADIUS * (child.position.y-bubbleRadius)/bubbleRadius
        };
    }
    vertices[numSegments+1] = vertices[1];
}
-(void)setUpTexCoords
{
    const uint32_t numSegments= [self numSegments];
    
    float deltaAngle = (2.f * M_PI) / numSegments;
    
    texCoords[0] = (ccTex2F){0.5f, 0.5f};
    for (int i = 0; i < numSegments; i++) {
        GLfloat coordAngle = M_PI + (deltaAngle * i);
        texCoords[i+1] = (ccTex2F){0.5 + cosf(coordAngle)*0.5, 0.5 + sinf(coordAngle)*0.5};
    }
    texCoords[numSegments+1] = texCoords[1];
    
}
// Helper taken from CCMotionStreak (https://github.com/cocos2d/cocos2d-spritebuilder/blob/v3.4/cocos2d/CCMotionStreak.m)
static inline CCVertex
MakeVertex(ccVertex2F v, ccTex2F texCoord, ccColor4F color, GLKMatrix4 transform)
{
    return (CCVertex){
        GLKMatrix4MultiplyVector4(transform, GLKVector4Make(v.x, v.y, 0.0f, 1.0f)),
        GLKVector2Make(texCoord.u, texCoord.v), GLKVector2Make(0.0f, 0.0f),
        GLKVector4Make(color.r, color.g, color.b, color.a)
    };
}
// Map the texture on the physics bodies with a triangle fan

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform {
    
    [self updateVertices];
    const uint32_t numSegments= [self numSegments];
    
    //Create buffer
    CCRenderBuffer buffer = [renderer enqueueTriangles:numSegments andVertexes:numSegments+2 withState:self.renderState globalSortOrder:0];
    
    //Output Vertices
    for (int i = 0; i < numSegments+2; i++)
    {
        CCRenderBufferSetVertex(buffer, i, MakeVertex(vertices[i], texCoords[i], texColor, *transform));
    }
    //Output triangles
    for (int i = 0; i < numSegments; i++)
    {
        CCRenderBufferSetTriangle(buffer, i, 0, i+1, i+2);
    }
    
}

// apply to center and all exterior bodies
-(void) applyForce:(CGPoint)force {
    [self.physicsBody applyForce:force];
    for (CCNode* n in self.children) {
        [n.physicsBody applyForce:force];
    }
}

-(void) applyForceFromAttractor:(id<Attractor>) attractor {
    // move children with an attracting/repelling force
    for (CCNode* n in self.children) {
        [n position];
        [n positionInPoints];
        
        CGPoint dist= ccpSub(n.position, [attractor position]);
        float len=ccpLength(dist);
        if (len<=0)
            continue;
        CGFloat scale= 10*fmaxf(0, 20-len);
        dist= ccpMult(dist, scale/len);
        [n.physicsBody applyForce:dist];
    }
}

// offset center mass and all external masses
-(void) setPosition: (CGPoint)newPosition
{
    CGPoint delta= ccpSub(newPosition, self.position);
    for (CCNode* n in self.children) {
        n.position= ccpAdd(n.position, delta);
    }
    // now move center
    [super setPosition:newPosition];
}

- (void)applyDamping:(CCTime)delta {
    //linear damping
    const float FRAME_DURATION= 1/60.0f;
    const float scaledDamping= 1.0f - 0.01f* (delta/FRAME_DURATION);
    self.physicsBody.velocity= ccpMult(self.physicsBody.velocity, scaledDamping);
    for (CCNode* n in self.children) {
        n.physicsBody.velocity= ccpMult(n.physicsBody.velocity, scaledDamping);
    }
}

- (void)update:(CCTime)delta {
    [self applyDamping:delta];
}

@end