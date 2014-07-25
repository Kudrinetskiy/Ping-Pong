//
//  YKViewController.m
//  Ping Pong
//
//  Created by admin on 14.07.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "YKViewController.h"

#define PLUS_MINUS_ONE (arc4random_uniform(2) - 0.5) * 2
#define GAMESPEED 8

@interface YKViewController () {
    NSTimer * gameLoopTimer;
    CGFloat xAxisBallSpeed;
    CGFloat yAxisBallSpeed;
    CGFloat draggingSpeed;
    CGFloat speedGrowth;
    BOOL isNewXOffsetRequired;
    NSInteger yellowScore;
    NSInteger redScore;
}

@end

@implementation YKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    speedGrowth = -2;
    yellowScore = 0;
    redScore = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beginGame:(id)sender
{
    self.imageNewGame.hidden = YES;
    self.yellowScoreLabel.hidden = YES;
    self.redScoreLabel.hidden = YES;
    xAxisBallSpeed = PLUS_MINUS_ONE * (1 + arc4random_uniform(4));
    yAxisBallSpeed = -GAMESPEED;
    isNewXOffsetRequired = YES;
    gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)gameLoop
{
    CGFloat ballPositionX = self.ball.center.x;
    CGFloat ballPositionY = self.ball.center.y;
    
    if ([self ballRunsOutOfGame:ballPositionY]) {
        return;
    }
    
    [self ballReboundsOffSide:ballPositionX];
    
    if ([self ballIntersectsBoard:self.redBoard]) {
        yAxisBallSpeed = fabsf(yAxisBallSpeed);
        [self reboundBoard:self.redBoard];
    }
    
    if ([self ballIntersectsBoard:self.yellowBoard]) {
        yAxisBallSpeed = -fabsf(yAxisBallSpeed);
        
        // add horizontal force to the ball when player hits it
        xAxisBallSpeed += draggingSpeed;

        [self clampBallSpeed:&xAxisBallSpeed];
        [self reboundBoard:self.yellowBoard];
    }
    
    [self moveBallWithX:ballPositionX y:ballPositionY];
    
    if (ballPositionY < [UIScreen mainScreen].bounds.size.height * 0.6 && yAxisBallSpeed < 0) {
        if (fabsf(self.redBoard.center.x - self.ball.center.x) > GAMESPEED) {
            [self AIMoveRedBoard];
        }
        else {
            speedGrowth = -2; // reset acceleration
        }
    }
    else {
        speedGrowth = -2;
    }
}

- (void)AIMoveRedBoard
{
    CGFloat redBoardX = self.redBoard.center.x;
    
    speedGrowth += 0.5;
    
    if (redBoardX > self.ball.center.x) {
        redBoardX -= fabsf(xAxisBallSpeed) / 2 + speedGrowth;
    }
    else {
        redBoardX += fabsf(xAxisBallSpeed) / 2 + speedGrowth;
    }
    
    self.redBoard.center = CGPointMake(redBoardX, self.redBoard.center.y);
    
    [self clampBoardX:self.redBoard];
}

- (IBAction)dragBoard:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView: self.view];
    self.yellowBoard.center = CGPointMake(self.yellowBoard.center.x + translation.x,
                                          self.yellowBoard.center.y);
    [self clampBoardX:self.yellowBoard];
    draggingSpeed = translation.x / 2;
    [sender setTranslation: CGPointZero inView: self.view];

//    [self makeBallCrazy];
}

-(void)makeBallCrazy
{
    xAxisBallSpeed += PLUS_MINUS_ONE * 2;
    [self clampBallSpeed:&xAxisBallSpeed];
}

- (void)moveBallWithX:(CGFloat)x y:(CGFloat)y
{
    self.ball.center = CGPointMake(x + xAxisBallSpeed, y + yAxisBallSpeed);
}

- (BOOL)ballIntersectsBoard:(UIImageView *)board
{
    CGRect boardCollisionRect = board.frame;
    
    // correct bounding rect sides
    boardCollisionRect.size.width -= 12;
    boardCollisionRect.origin.x += 6;
    
    return CGRectIntersectsRect(self.ball.frame, boardCollisionRect);
}

- (void)reboundBoard:(UIImageView *)board
{
    [UIView animateWithDuration:0.05 animations:^{
        board.center = CGPointMake(board.center.x,
                                   board.center.y - 5 * fabsf(yAxisBallSpeed) / yAxisBallSpeed);
    } completion:^(BOOL finished) {
        board.center = CGPointMake(board.center.x,
                                   board.center.y + 5 * fabsf(yAxisBallSpeed) / yAxisBallSpeed);
    }];
}

- (void)clampBallSpeed:(CGFloat *)speed
{
    if (*speed < -GAMESPEED) {
        *speed = -GAMESPEED;
    }
    if (*speed > -1 && *speed < 0) {
        *speed = -1;
    }
    if (*speed >= 0 && *speed < 1) {
        *speed = 1;
    }
    if (*speed > GAMESPEED) {
        *speed = GAMESPEED;
    }
}

- (void)clampBoardX:(UIImageView *)board
{
    board.center = CGPointMake(fminf(fmaxf(board.center.x, 35), 285),
                               board.center.y);
}

- (BOOL)ballReboundsOffSide:(CGFloat)ballX
{
    if (ballX < 12) {
        xAxisBallSpeed = fabsf(xAxisBallSpeed) + PLUS_MINUS_ONE;
        return YES;
    }
    
    if (ballX > 308) {
        xAxisBallSpeed = -fabsf(xAxisBallSpeed) + PLUS_MINUS_ONE;
        return YES;
    }
    
    return NO;
}

- (BOOL)ballRunsOutOfGame:(CGFloat)ballY
{
    if (ballY < -10) {
        yellowScore++;
        self.yellowScoreLabel.text = [NSString stringWithFormat:@"%d", yellowScore];
        [self gameOver];
        return YES;
    }
    
    if (ballY > 578) {
        redScore++;
        self.redScoreLabel.text = [NSString stringWithFormat:@"%d", redScore];
        [self gameOver];
        return YES;
    }
    
    return NO;
}

- (void)gameOver
{
    [gameLoopTimer invalidate];
    self.ball.center = CGPointMake(162, 286);
    self.yellowScoreLabel.hidden = NO;
    self.redScoreLabel.hidden = NO;
    self.imageNewGame.hidden = NO;
}

@end
