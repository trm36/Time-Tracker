//
//  Project.h
//  Time-Tracker
//
//  Created by Taylor Mott on 10.18.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WorkPeriod;

@interface Project : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *workPeriod;
@end

@interface Project (CoreDataGeneratedAccessors)

- (void)addWorkPeriodObject:(WorkPeriod *)value;
- (void)removeWorkPeriodObject:(WorkPeriod *)value;
- (void)addWorkPeriod:(NSSet *)values;
- (void)removeWorkPeriod:(NSSet *)values;

@end
