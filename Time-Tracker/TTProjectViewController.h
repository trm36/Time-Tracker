//
//  TTProjectViewController.h
//  Time-Tracker
//
//  Created by Taylor Mott on 10.8.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"
#import "WorkPeriod.h"

@interface TTProjectViewController : UIViewController

@property (strong, nonatomic) Project *project;

@end
