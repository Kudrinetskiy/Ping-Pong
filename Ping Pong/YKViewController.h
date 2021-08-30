//
//  YKViewController.h
//  Ping Pong
//
//  Created by admin on 14.07.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *redBoard;
@property (weak, nonatomic) IBOutlet UIImageView *yellowBoard;
@property (weak, nonatomic) IBOutlet UIImageView *ball;
@property (weak, nonatomic) IBOutlet UIButton *imageNewGame;
@property (weak, nonatomic) IBOutlet UILabel *yellowScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *redScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *crazyMode;

- (IBAction)beginGame:(id)sender;
- (IBAction)dragBoard:(UIPanGestureRecognizer *)sender;

@end
