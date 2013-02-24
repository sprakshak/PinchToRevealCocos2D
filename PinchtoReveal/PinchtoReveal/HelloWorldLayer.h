//
//  HelloWorldLayer.h
//  PinchtoReveal
//
//  Created by Rakshak   on 21/02/13.
//  Copyright VR Playing Games  2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer<UIGestureRecognizerDelegate>
{
    /* WHEN WE PINCH THE IMAGE WILL BE DIVIDED IN TWO PARTS,
     HENCE WE SET UP POINTERS TO THE TWO SECTIONS 
     ONCE WE BEGIN TO PERFORM THE PINCH GESTURE */
    CCSprite *leftPortionOfImage,*rightPortionOfImage;
    
    // STORE A REFRENCE TO THE POSITION OF THE LEFT AND RIGHT PORTION OF THE COVER IMAGE
    float previousLeftPoint,previousRightPoint,velocityOfGesture;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
