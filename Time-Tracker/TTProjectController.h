//
//  TTProjectController.h
//  Time-Tracker
//
//  Created by Taylor Mott on 10.16.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@interface TTProjectController : NSObject

+ (TTProjectController *)sharedInstance;
- (Project *)addProjectWithTitle:(NSString *)title;
- (void)removeProject:(Project *)project;
- (NSArray *)projects;
- (void)synchronize;
- (void)addWorkPeriodWithStartDate:(NSDate *)start endDate:(NSDate *)end memo:(NSString *)memo project:(Project *)project;

@end
