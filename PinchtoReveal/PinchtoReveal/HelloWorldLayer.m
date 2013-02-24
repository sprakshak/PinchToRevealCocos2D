//
//  HelloWorldLayer.m
//  PinchtoReveal
//
//  Created by Rakshak   on 21/02/13.
//  Copyright VR Playing Games 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CCNode+SFGestureRecognizers.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        velocityOfGesture = 0;
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        // THIS IS THE IMAGE THAT GETS REVEALED AS WE PINCH THE COVER
		CCSprite *underlyingImage = [CCSprite spriteWithFile:@"Background2.jpeg"];
        [self addChild:underlyingImage];
        underlyingImage.position = ccp(size.width/2, size.height/2);
        
        
        // THIS IS THE IMAGE WE WILL SPLIT BY PINCHING
		CCSprite *coveringImage = [CCSprite spriteWithFile:@"Background.jpeg"];
        coveringImage.tag = 1;
        coveringImage.isTouchEnabled = YES; //NEEDED TO DETECT PINCH GESTURE
        [self addChild:coveringImage z:1];
        coveringImage.position = ccp(size.width/2, size.height/2);
		
        // ADD SWIPE GESTURE
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [coveringImage addGestureRecognizer:pinchGestureRecognizer];
        pinchGestureRecognizer.delegate = self;
        [pinchGestureRecognizer release];
	}
	return self;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    //1
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        // WHEN TOUCH BEGINS , WE NOTE THE TOUCH POINT
        // BASED ON THIS TOUCH POINT WE SPLIT THE IMAGE INTO TWO PORTIONS
        CGPoint touchPoint = [pinchGestureRecognizer locationInView:pinchGestureRecognizer.view];
        if (!leftPortionOfImage && !rightPortionOfImage) {
            
            //HIDE THE COVER IMAGE
            CCSprite *coverImage = (CCSprite*)[self getChildByTag:1];
            coverImage.opacity = 0;

            // THIS RECTANGLE REPRESENTS THE PORTION OF THE IMAGE WE ARE ASSIGNING AS THE LEFT PORTION
            CGRect leftRect = CGRectMake(0, 0, touchPoint.x, [CCDirector sharedDirector].winSize.height);
            
            // THIS RECTANGLE REPRESENTS THE PORTION OF THE IMAGE WE ARE ASSIGNING AS THE RIGHT PORTION
            CGRect rightRect = CGRectMake(touchPoint.x, 0, [CCDirector sharedDirector].winSize.width-touchPoint.x, [CCDirector sharedDirector].winSize.height);
            
            leftPortionOfImage = [CCSprite spriteWithFile:@"Background.jpeg" rect:leftRect];
            leftPortionOfImage.position = ccp(leftPortionOfImage.contentSize.width/2, leftPortionOfImage.contentSize.height/2);
            [self addChild:leftPortionOfImage];
            
            rightPortionOfImage = [CCSprite spriteWithFile:@"Background.jpeg" rect:rightRect];
            rightPortionOfImage.position = ccp([CCDirector sharedDirector].winSize.width - rightPortionOfImage.contentSize.width/2, rightPortionOfImage.contentSize.height/2);
            [self addChild:rightPortionOfImage];
        }
        
        // STORE A REFRENCE TO THE STARTING POINT
        previousLeftPoint = touchPoint.x;
        previousRightPoint = touchPoint.x;
    }
    
    // WHEN NUMBER OF FINGERS ON SCREEN BECOMES TWO
    if ([pinchGestureRecognizer numberOfTouches] == 2) {
        
        float leftPoint = [pinchGestureRecognizer locationOfTouch:0 inView:pinchGestureRecognizer.view].x;
        float rightPoint = [pinchGestureRecognizer locationOfTouch:1 inView:pinchGestureRecognizer.view].x;

        // In case the first touch point was to the right, relative to the second touch, then we swap
        if (leftPoint > rightPoint) {
            float tmp = rightPoint;
            rightPoint = leftPoint;
            leftPoint = tmp;
        }
        
        leftPortionOfImage.position = ccp(leftPortionOfImage.position.x - (previousLeftPoint - leftPoint), leftPortionOfImage.position.y);
        rightPortionOfImage.position = ccp(rightPortionOfImage.position.x + (rightPoint - previousRightPoint), rightPortionOfImage.position.y);
        
        previousLeftPoint = leftPoint;
        previousRightPoint = rightPoint;
    }
    
    //3
    // WHEN WE HAVE ENDED THE PINCH GESTURE WE CHECK WHETHER THE TOUCH POINTS WERE APPROACHING EACH OTHER (a closing pich gesture) or THE TOUCH POINTS WERE MOVING AWAY (a opening pinch gesture)
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        const CGFloat velocity = pinchGestureRecognizer.velocity;
        CCCallFunc *callback = [CCCallFunc actionWithTarget:self selector:@selector(removePortions)];
        velocityOfGesture = velocity;       
        if (velocity < 0) {
            NSLog(@"Closing Gesture");
            
            [leftPortionOfImage runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:0.3f position:ccp(leftPortionOfImage.contentSize.width/2, leftPortionOfImage.position.y)] two:callback]];
            
            [rightPortionOfImage runAction:[CCMoveTo actionWithDuration:0.3f position:ccp([CCDirector sharedDirector].winSize.width - rightPortionOfImage.contentSize.width/2, rightPortionOfImage.position.y)]];
            
        } else {
            NSLog(@"Opening gesture");
            [leftPortionOfImage runAction:[CCSequence actionOne:[CCMoveTo actionWithDuration:0.3f position:ccp(-leftPortionOfImage.contentSize.width, leftPortionOfImage.position.y)] two:callback]];
            [rightPortionOfImage runAction:[CCMoveTo actionWithDuration:0.3f position:ccp([CCDirector sharedDirector].winSize.width + rightPortionOfImage.contentSize.width, rightPortionOfImage.position.y)]];
        }
    }
}

-(void) removePortions {
    
    // WE REMOVE THE SECTIONS ONCE GESTURE COMPLETES SO THAT
    // ONCE WE RE INTIATE THE GESTURES THE PORTIONS CAN BE SET UP AGAIN
    [leftPortionOfImage removeFromParentAndCleanup:YES];
    [rightPortionOfImage removeFromParentAndCleanup:YES];
    leftPortionOfImage = nil;
    rightPortionOfImage = nil;
    
    if (velocityOfGesture < 0) {
        //SHOWS WE WERE TRYING TO BRING THE TWO SPLIT SECTIONS BACK TOGETHER.
        //HENCE SHOW THE COVER IMAGE (as it was hidden earlier during the start of the pinch gesture)
        CCSprite *coverImage = (CCSprite*)[self getChildByTag:1];
        coverImage.opacity = 255;
        
        //RESET VELOCITY
        velocityOfGesture = 0;
    }
}

@end
