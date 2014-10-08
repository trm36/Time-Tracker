//
//  TRMTimer.h
//  The Pomodoro
//
//  Created by Taylor Mott on 9.23.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRMTimer : NSObject

@property (nonatomic, readonly) NSTimeInterval seconds;

- (id)init;
- (TRMTimer *)initAsCountupTimer:(BOOL)isCountupTimer;

+ (TRMTimer *)sharedInstance;

- (void)setTimer:(NSTimeInterval)seconds;
- (void)startTimer;
- (void)stopTimer;
- (void)clearTimer;

@end
