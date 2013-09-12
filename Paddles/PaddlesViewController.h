//
//  PaddlesViewController.h
//  Paddles
//
//  Created by 林光海 on 13-9-11.
//  Copyright (c) 2013年 林光海. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface PaddlesViewController : UIViewController
{
    UITouch *touch1;
    UITouch *touch2;
    float dx;
    float dy;
    float speed;
    NSTimer *timer;
    UIAlertView * alert;
    SystemSoundID sounds[3];
}
@property (retain, nonatomic) IBOutlet UIView *viewPaddle1;
@property (retain, nonatomic) IBOutlet UIView *viewPaddle2;

@property (retain, nonatomic) IBOutlet UIView *viewPuck;
@property (retain, nonatomic) IBOutlet UILabel *viewScore1;
@property (retain, nonatomic) IBOutlet UILabel *viewScore2;

- (void)resume;
- (void)pause;

@end
