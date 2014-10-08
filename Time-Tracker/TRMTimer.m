//
//  TRMTimer.m
//  The Pomodoro
//
//  Created by Taylor Mott on 9.23.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TRMTimer.h"

NSString * const SECOND_TICK_NOTIFICATION = @"second tick";

NSString * const TimerCompleteNotification = @"timer complete";

@interface TRMTimer()

@property (assign, nonatomic) NSTimeInterval seconds;
@property (assign, nonatomic) BOOL on;
@property (assign, nonatomic) BOOL isCountupTimer;

@end

@implementation TRMTimer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.isCountupTimer = NO;
    }
    
    return self;
}

- (id)initAsCountupTimer:(BOOL)isCountupTimer
{
    self = [super init];
    
    if (self)
    {
        self.isCountupTimer = isCountupTimer;
    }
    
    return self;
}

+ (TRMTimer *)sharedInstance
{
    static TRMTimer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      sharedInstance = [TRMTimer new];
                   });
    
    return sharedInstance;
}

- (void)setTimer:(NSTimeInterval)seconds
{
    self.seconds = seconds;
}

- (void)startTimer
{
    self.on = YES;
    [self checkActive];
}

- (void)stopTimer
{
    if (self.on)
    {
        self.on = NO;
        [TRMTimer cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)clearTimer
{
    if (self.on)
    {
        [TRMTimer cancelPreviousPerformRequestsWithTarget:self];
        self.on = NO;
    }
    self.seconds = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timerCleared" object:self];
}

- (void)checkActive
{
    [TRMTimer cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.on && !self.isCountupTimer)
    {
        [self decrementSecond];
        [self performSelector:@selector(checkActive) withObject:self afterDelay:1];
    }
    if (self.on && self.isCountupTimer)
    {
        [self incrementSecond];
        [self performSelector:@selector(checkActive) withObject:self afterDelay:1];
    }
    
}

- (void)decrementSecond
{
    if (self.seconds > 0)
    {
        self.seconds = self.seconds - 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"secondTick" object:self];
    }
    
    if (self.seconds == 0)
    {
        [self timerComplete];
    }
}

- (void)incrementSecond
{
    self.seconds++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"secondTick" object:self];
}

- (void)timerComplete
{
    self.on = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"timerComplete" object:self];
}

@end
