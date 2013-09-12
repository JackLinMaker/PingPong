//
//  PaddlesViewController.m
//  Paddles
//
//  Created by 林光海 on 13-9-11.
//  Copyright (c) 2013年 林光海. All rights reserved.
//

#import "PaddlesViewController.h"

#define MAX_SCORE       3

#define SOUND_WALL      0
#define SOUND_PADDLE    1
#define SOUND_SCORE     2

@interface PaddlesViewController ()

@end

@implementation PaddlesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSounds];
	[self newGame];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [self viewWillDisappear:animated];
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
    [_viewScore1 release];
    [_viewScore2 release];
    
    for(int i = 0; i < 3; i++)
    {
        AudioServicesDisposeSystemSoundID(sounds[i]);
    }
    [super dealloc];
}
- (void)viewDidUnload {
    [self setViewPaddle1:nil];
    [self setViewPaddle2:nil];
    [self setViewPuck:nil];
    [self setViewScore1:nil];
    [self setViewScore2:nil];
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

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        //NSLog(@"Shake Began");
        [self pause];
        [self resume];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shake Ended");
    }

}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shake Cancelled");
    }

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

- (void)displayMessage:(NSString *)msg
{
    if(alert)
        return;
    // stop animation timer
    [self stop];
    
    alert = [[UIAlertView alloc] initWithTitle:@"Game" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // message dismissed so reset our game and start animation
    alert = nil;
    
    // check if we should start a new game
    if([self gameOver])
    {
        [self newGame];
        return;
    }
    
    //reset round
    [self reset];
    // start animation
    [self start];
}

- (void)newGame
{
    [self reset];
    _viewScore1.text = [NSString stringWithFormat:@"0"];
    _viewScore2.text = [NSString stringWithFormat:@"0"];
    
    // present message to start game
    [self displayMessage:@"Ready to play?"];
}

- (void)animate
{
    _viewPuck.center = CGPointMake(_viewPuck.center.x + dx * speed, _viewPuck.center.y + dy * speed);
    if([self checkPuckCollision:CGRectMake(-10, 0, 20, 480) DirX:fabsf(dx) DirY:0])
    {
        [self playSound:SOUND_WALL];
    }
    
    if([self checkPuckCollision:CGRectMake(310, 0, 20, 480) DirX:-fabsf(dx) DirY:0])
    {
        [self playSound:SOUND_WALL];
    }
    if([self checkPuckCollision:_viewPaddle1.frame DirX:(_viewPuck.center.x - _viewPaddle1.center.x) / 32.0 DirY:1])
    {
        [self increateSpeed];
        [self playSound:SOUND_PADDLE];
    }
    
    
    if([self checkPuckCollision:_viewPaddle2.frame DirX:(_viewPuck.center.x - _viewPaddle2.center.x) / 32.0 DirY:-1])
    {
        [self increateSpeed];
        [self playSound:SOUND_PADDLE];
    }
    
    if([self checkGoal])
    {
        [self playSound:SOUND_SCORE];
    }
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

- (BOOL)checkGoal
{
    if(_viewPuck.center.y < 0 || _viewPuck.center.y >= 480)
    {
        // get integer value from score label
        int s1 = [_viewScore1.text intValue];
        int s2 = [_viewScore2.text intValue];
        
        if(_viewPuck.center.y < 0)
        {
            ++s2;
        }
        else
        {
            ++s1;
        }
        
        // update score labels
        _viewScore1.text = [NSString stringWithFormat:@"%u", s1];
        _viewScore2.text = [NSString stringWithFormat:@"%u", s2];
        
        // check for winner
        if([self gameOver] == 1)
        {
            // player 1 win
            [self displayMessage:@"Player 1 has won!"];
            
        }
        else if([self gameOver] == 2)
        {
            // player 2 win
            [self displayMessage:@"Player 2 has won!"];
        }
        else
        {
            // reset round
            [self reset];
        }
        // return true for goal
        return YES;
    }
    return NO;
}

- (int)gameOver
{
    if([_viewScore1.text intValue] >= MAX_SCORE) return 1;
    if([_viewScore2.text intValue] >= MAX_SCORE) return 2;
    return 0;
}

- (void)increateSpeed
{
    speed += 0.5;
    if(speed > 10) speed = 10;
}

- (void)pause
{
    [self stop];
}

- (void)resume
{
    [self displayMessage:@"Game Paused"];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)loadSound:(NSString *)name Slot:(int)slot
{
    if(sounds[slot] != 0)
        return;
    // create pathname to sound file
    NSString *sndPath = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3" inDirectory:@"/"];
    // create system sound id into our sound slot
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:sndPath], &sounds[slot]);
}

- (void)initSounds
{
    [self loadSound:@"wall" Slot:SOUND_WALL];
    [self loadSound:@"paddle" Slot:SOUND_PADDLE];
    [self loadSound:@"score" Slot:SOUND_SCORE];
}

- (void)playSound:(int)slot
{
    AudioServicesPlaySystemSound(sounds[slot]);
}
@end
