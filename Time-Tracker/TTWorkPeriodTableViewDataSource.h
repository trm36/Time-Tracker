//
//  TTWorkPeriodTableViewDataSource.h
//  Time-Tracker
//
//  Created by Taylor Mott on 10.21.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"

@interface TTWorkPeriodTableViewDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *workPeriods;

@end
