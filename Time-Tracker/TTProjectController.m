//
//  TTProjectController.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.16.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectController.h"
#import "Stack.h"
#import "WorkPeriod.h"

@implementation TTProjectController

+ (TTProjectController *)sharedInstance
{
    static TTProjectController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTProjectController alloc] init];
    });
    return sharedInstance;
}


- (Project *)addProjectWithTitle:(NSString *)title;
{
    Project *project = [NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
    project.title = title;
    
    [self synchronize];
    
    return project;
}


- (void)removeProject:(Project *)project
{
    [project.managedObjectContext deleteObject:project];
    
    [self synchronize];
}

- (NSArray *)projects
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Project"];
    NSArray *projects = [[Stack sharedInstance].managedObjectContext executeFetchRequest:request error:nil];
    
    return projects;
}

- (void)synchronize
{
    [[Stack sharedInstance].managedObjectContext save:nil];
}

- (void)addWorkPeriodWithStartDate:(NSDate *)start endDate:(NSDate *)end memo:(NSString *)memo project:(Project *)project
{
    WorkPeriod *workPeriod = [NSEntityDescription insertNewObjectForEntityForName:@"WorkPeriod" inManagedObjectContext:[Stack sharedInstance].managedObjectContext];
    workPeriod.startDate = start;
    workPeriod.endDate = end;
    workPeriod.memo = memo;
    workPeriod.project = project;
    
    [self synchronize];
}

@end
