//
//  TTProjectViewController.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.8.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectViewController.h"
#import "TRMTimer.h"

CGFloat const NAV_BAR_HEIGHT = 64;
CGFloat const MARGIN = 15;
CGFloat const SPACING = 8;
CGFloat const PROJECT_TITLE_HEIGHT = 35;
CGFloat const TIMER_TITLE_LABEL_HEIGHT = 15;
CGFloat const TIMER_HEIGHT = 55;

@interface TTProjectViewController ()

@property (strong, nonatomic) UITextField   *projectTitle;
@property (strong, nonatomic) UILabel       *projectTimerLabel;
@property (strong, nonatomic) UILabel       *workPeriodTimerLabel;
@property (strong, nonatomic) UITableView   *workPeriodTableView;
@property (strong, nonatomic) TRMTimer      *projectTimer;
@property (strong, nonatomic) TRMTimer      *workPeriodTimer;
@property (strong, nonatomic) NSDate        *currentWorkPeriodStartDate;

@end

@implementation TTProjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //SETUP UI
    CGFloat totalHeight = NAV_BAR_HEIGHT + SPACING;
    
    self.projectTitle = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, self.view.frame.size.width - 2 * MARGIN, PROJECT_TITLE_HEIGHT)];
    //self.projectTitle.text = self.project.title;
    self.projectTitle.placeholder = @"Project Title";
    [self.view addSubview:self.projectTitle];
    totalHeight = totalHeight + PROJECT_TITLE_HEIGHT + SPACING;
    
    UILabel *totalProjectTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_TITLE_LABEL_HEIGHT)];
    totalProjectTimeTitleLabel.text = @"Total Project Time";
    [self.view addSubview:totalProjectTimeTitleLabel];
    
    UILabel *currentWorkPeriodTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + ((self.view.frame.size.width - 2 * MARGIN) / 2), totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_TITLE_LABEL_HEIGHT)];
    currentWorkPeriodTimeTitleLabel.text = @"Current Work Period Time";
    [self.view addSubview:currentWorkPeriodTimeTitleLabel];
    totalHeight = totalHeight + TIMER_TITLE_LABEL_HEIGHT + SPACING;
    
    self.projectTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_HEIGHT)];
    self.projectTimerLabel.text = [self minutesAndSecondsFromSeconds:[self calculateTotalSeconds]];
    [self.view addSubview:self.projectTimerLabel];
    
    self.workPeriodTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + ((self.view.frame.size.width - 2 * MARGIN) / 2), totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_HEIGHT)];
    self.workPeriodTimerLabel.text = @"0:00";
    [self.view addSubview:self.workPeriodTimerLabel];
    totalHeight = totalHeight + TIMER_HEIGHT + SPACING;
    
    
    
    //UIToolbar *toolbar = [[UIToolbar alloc] init];
    //toolbar.barPosition = UIBarPositionBottom;
    
    
    //SETUP TIMERS
    self.projectTimer = [[TRMTimer alloc] initAsCountupTimer:YES];
    self.workPeriodTimer = [[TRMTimer alloc] initAsCountupTimer:YES];
    
    [self.projectTimer setTimer:[self calculateTotalSeconds]];
    [self updateProjectTimeLabel];
    
    [self.workPeriodTimer setTimer:0];
    [self updateWorkPeriodTimeLabel];
    
    self.currentWorkPeriodStartDate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

- (NSString *)minutesAndSecondsFromSeconds:(NSTimeInterval)totalSeconds
{
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

- (NSTimeInterval)calculateTotalSeconds
{
    NSEnumerator *enumerator = [self.project.workPeriod objectEnumerator];
    WorkPeriod *period;
    NSTimeInterval totalTime = 0;
    
    while (period = [enumerator nextObject])
    {
        totalTime += [period.endDate timeIntervalSinceDate:period.startDate];
    }
    
    return totalTime;
}

- (void)updateProjectTimeLabel
{
    self.projectTimerLabel.text = [self minutesAndSecondsFromSeconds:self.projectTimer.seconds];
}

- (void)updateWorkPeriodTimeLabel
{
    self.workPeriodTimerLabel.text = [self minutesAndSecondsFromSeconds:self.workPeriodTimer.seconds];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProjectTimeLabel) name:@"secondTick" object:self.projectTimer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWorkPeriodTimeLabel) name:@"secondTick" object:self.workPeriodTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateWorkPeriodTimeLabel) name:@"timerCleared" object:self.workPeriodTimer];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"secondTick" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"timerCleared" object:nil];
}

#pragma mark - Toolbar Button Methods

- (void)clockInButton
{
    if (!self.currentWorkPeriodStartDate)
    {
        self.currentWorkPeriodStartDate = [NSDate date];
        [self.projectTimer startTimer];
        [self.workPeriodTimer startTimer];
    }
}
- (void)clockOutButton
{
    if(self.currentWorkPeriodStartDate)
    {
        WorkPeriod *workPeriod = [WorkPeriod new];
        workPeriod.startDate = self.currentWorkPeriodStartDate;
        workPeriod.endDate = [NSDate date];
        workPeriod.project = self.project;
        [self.project addWorkPeriodObject:workPeriod];
        self.currentWorkPeriodStartDate = nil;
        [self.projectTimer stopTimer];
        [self.projectTimer setTimer:[self calculateTotalSeconds]];
        [self updateProjectTimeLabel];
        [self.workPeriodTimer clearTimer];
    }
}

- (void)reportButton
{
}

- (void)addButton
{
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
