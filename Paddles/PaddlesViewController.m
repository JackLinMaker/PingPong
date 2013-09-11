//
//  PaddlesViewController.m
//  Paddles
//
//  Created by 林光海 on 13-9-11.
//  Copyright (c) 2013年 林光海. All rights reserved.
//

#import "PaddlesViewController.h"

@interface PaddlesViewController ()

@end

@implementation PaddlesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self reset];
    [self start];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_viewPaddle1 release];
    [_viewPaddle2 release];
    [_viewPuck release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setViewPaddle1:nil];
    [self setViewPaddle2:nil];
    [self setViewPuck:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch * touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(touch1 == nil && touchPoint.y < 240)
        {
            touch1 = touch;
            _viewPaddle1.center = CGPointMake(touchPoint.x, _viewPaddle1.center.y);
        }
        else if(touch2 == nil && touchPoint.y >= 240)
        {
            touch2 = touch;
            _viewPaddle2.center = CGPointMake(touchPoint.x, _viewPaddle2.center.y);
        }
    }
   
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        CGPoint touchPoint = [touch locationInView:self.view];
        if(touch == touch1)
        {
            _viewPaddle1.center = CGPointMake(touchPoint.x, _viewPaddle1.center.y);
        }else if(touch == touch2)
        {
            _viewPaddle2.center = CGPointMake(touchPoint.x, _viewPaddle2.center.y);
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches)
    {
        if(touch == touch1)
            touch1 = nil;
        else if(touch == touch2)
            touch2 = nil;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

- (void)reset
{
    // set direction of ball to either left or right direction
    if((arc4random() % 2 ) == 0)
        dx = -1;
    else
        dx = 1;
    
    if(dy != 0)
    {
        dy = -dy;
    }
    else if((arc4random() % 2) == 0)
    {
        dy = -1;
    }
    else
    {
        dy = 1;
    }
    
    _viewPuck.center = CGPointMake(15 + arc4random() % (320 - 30), 240);
    speed = 2;
}

- (void)start
{
    if(timer == nil)
    {
        timer = [[NSTimer scheduledTimerWithTimeInterval:1.0/60.0 target:self selector:@selector(animate) userInfo:NULL repeats:true] retain];
        
    }
    _viewPuck.hidden = NO;
}

- (void)stop
{
    if(timer != nil)
    {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    _viewPuck.hidden = YES;
}

- (void)animate
{
    _viewPuck.center = CGPointMake(_viewPuck.center.x + dx * speed, _viewPuck.center.y + dy * speed);
    [self checkPuckCollision:CGRectMake(-10, 0, 20, 480) DirX:fabsf(dx) DirY:0];
    [self checkPuckCollision:CGRectMake(310, 0, 20, 480) DirX:-fabsf(dx) DirY:0];
    [self checkPuckCollision:_viewPaddle1.frame DirX:(_viewPuck.center.x - _viewPaddle1.center.x) / 32.0 DirY:1];
    [self checkPuckCollision:_viewPaddle2.frame DirX:(_viewPuck.center.x - _viewPaddle2.center.x) / 32.0 DirY:-1];

}

- (BOOL)checkPuckCollision:(CGRect)rect DirX:(float)x DirY:(float)y
{
    // check if the puck intersects with rectangle
    if(CGRectIntersectsRect(_viewPuck.frame, rect))
    {
        if(x != 0) dx = x;
        if(y != 0) dy = y;
        return YES;
    }
    return NO;
}
@end
