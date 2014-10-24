//
//  TTProjectTableViewDataSource.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.19.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectTableViewDataSource.h"
#import "TTProjectController.h"
#import "Project.h"
#import "WorkPeriod.h"

static NSString *CELL = @"cell";

@implementation TTProjectTableViewDataSource

- (void)registerTableView:(UITableView *)tableView
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CELL];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [TTProjectController sharedInstance].projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL];
    }
    
    Project *project = [TTProjectController sharedInstance].projects[indexPath.row];
    
    //Check if string is empty or only has white space
    if ([[project.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0)
    {
        cell.textLabel.text = @"(untitled)";
        cell.textLabel.textColor = [UIColor grayColor];
    }
    else
    {
        cell.textLabel.text = project.title;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = [self minutesAndSecondsFromWorkPeriods:project.workPeriod];

    return cell;
}

- (NSString *)minutesAndSecondsFromWorkPeriods:(NSSet *)workPeriods
{
    NSEnumerator *enumerator = [workPeriods objectEnumerator];
    WorkPeriod *period;
    NSTimeInterval totalSeconds = 0;
    
    while (period = [enumerator nextObject])
    {
        totalSeconds += [period.endDate timeIntervalSinceDate:period.startDate];
    }
    
    NSString *time;
    NSUInteger minutes = totalSeconds / 60;
    NSUInteger seconds = totalSeconds - (minutes * 60);
    if (seconds < 10)
    {
        time =[NSString stringWithFormat:@"%ld:0%ld", minutes, seconds];
    }
    else
    {
        time = [NSString stringWithFormat:@"%ld:%ld", minutes, seconds];
    }
    
    return time;
}

@end


