//
//  TTWorkPeriodTableViewDataSource.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.21.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTWorkPeriodTableViewDataSource.h"
/*
#import "TTProjectTableViewDataSource.h"
#import "TTProjectController.h"
#import "Project.h"*/
#import "WorkPeriod.h"

static NSString *CELL = @"cell";

@implementation TTWorkPeriodTableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.workPeriods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL];
    }
    
    WorkPeriod *workPeriod = self.workPeriods[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", workPeriod.startDate, workPeriod.endDate];
    cell.detailTextLabel.text = workPeriod.memo;
    
    return cell;
}

@end

