//
//  TTProjectViewController.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.8.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectViewController.h"
#import "TRMTimer.h"
#import "WorkPeriod.h"
#import "TTProjectController.h"
#import "TTWorkPeriodTableViewDataSource.h"

CGFloat const NAV_BAR_HEIGHT = 64;
CGFloat const MARGIN = 15;
CGFloat const SPACING = 8;
CGFloat const PROJECT_TITLE_HEIGHT = 35;
CGFloat const TIMER_TITLE_LABEL_HEIGHT = 15;
CGFloat const TIMER_HEIGHT = 55;
CGFloat const TOOLBAR_HEIGHT = 44;

@interface TTProjectViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField                       *projectTitle;
@property (strong, nonatomic) UILabel                           *projectTimerLabel;
@property (strong, nonatomic) UILabel                           *workPeriodTimerLabel;
@property (strong, nonatomic) UITableView                       *workPeriodTableView;
@property (strong, nonatomic) TRMTimer                          *projectTimer;
@property (strong, nonatomic) TRMTimer                          *workPeriodTimer;
@property (strong, nonatomic) NSDate                            *currentWorkPeriodStartDate;
@property (strong, nonatomic) TTWorkPeriodTableViewDataSource   *workPeriodTableViewDataSource;

@end

@implementation TTProjectViewController

- (void)setUpUI
{
    CGFloat totalHeight = NAV_BAR_HEIGHT + SPACING;
    
    //PROJECT TITLE TEXT FIELD
    self.projectTitle = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, self.view.frame.size.width - 2 * MARGIN, PROJECT_TITLE_HEIGHT)];
    //self.projectTitle.text = self.project.title;
    self.projectTitle.placeholder = @"Project Title";
    self.projectTitle.delegate = self;
    [self.view addSubview:self.projectTitle];
    totalHeight = totalHeight + PROJECT_TITLE_HEIGHT + SPACING;
    
    //PROJECT TIME LABEL
    UILabel *totalProjectTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_TITLE_LABEL_HEIGHT)];
    totalProjectTimeTitleLabel.text = @"Total Project Time";
    [self.view addSubview:totalProjectTimeTitleLabel];
    
    //WORK PERIOD TIME LABEL
    UILabel *currentWorkPeriodTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + ((self.view.frame.size.width - 2 * MARGIN) / 2), totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_TITLE_LABEL_HEIGHT)];
    currentWorkPeriodTimeTitleLabel.text = @"Current Work Period Time";
    [self.view addSubview:currentWorkPeriodTimeTitleLabel];
    totalHeight = totalHeight + TIMER_TITLE_LABEL_HEIGHT + SPACING;
    
    //PROJECT TIMER LABEL
    self.projectTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_HEIGHT)];
    self.projectTimerLabel.text = [self minutesAndSecondsFromSeconds:[self calculateTotalSeconds]];
    [self.view addSubview:self.projectTimerLabel];
    
    //WORK PERIOD TIMER LABEL
    self.workPeriodTimerLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + ((self.view.frame.size.width - 2 * MARGIN) / 2), totalHeight, (self.view.frame.size.width - 2 * MARGIN) / 2, TIMER_HEIGHT)];
    self.workPeriodTimerLabel.text = @"0:00";
    [self.view addSubview:self.workPeriodTimerLabel];
    totalHeight = totalHeight + TIMER_HEIGHT + SPACING;
    
    //TOOLBAR
    self.navigationController.toolbarHidden = NO;
    UIBarButtonItem *addPeriodButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPeriodButtonPressed)];
    addPeriodButton.enabled = NO;
    UIBarButtonItem *clockInButton = [[UIBarButtonItem alloc] initWithTitle:@"Clock In" style:UIBarButtonItemStylePlain target:self action:@selector(clockInButtonPressed)];
    UIBarButtonItem *clockOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Clock Out" style:UIBarButtonItemStylePlain target:self action:@selector(clockOutButtonPressed)];
    UIBarButtonItem *reportButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(reportButtonPressed)];
    reportButton.enabled = NO;
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:addPeriodButton, flexSpace, clockInButton, flexSpace, clockOutButton, flexSpace, reportButton, nil];
    [self setToolbarItems:toolbarItems];
    
    
    //WORK PERIOD TABLE VIEW
    self.workPeriodTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, totalHeight, self.view.frame.size.width, self.view.frame.size.height - totalHeight - TOOLBAR_HEIGHT)];
    self.workPeriodTableViewDataSource = [TTWorkPeriodTableViewDataSource new];
    self.workPeriodTableView.dataSource = self.workPeriodTableViewDataSource;
    [self.view addSubview:self.workPeriodTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //SETUP UI
    [self setUpUI];
    
    //SETUP TIMERS
    self.projectTimer = [[TRMTimer alloc] initAsCountupTimer:YES];
    self.workPeriodTimer = [[TRMTimer alloc] initAsCountupTimer:YES];
    
    [self.projectTimer setTimer:[self calculateTotalSeconds]];
    [self updateProjectTimeLabel];
    
    [self.workPeriodTimer setTimer:0];
    [self updateWorkPeriodTimeLabel];
    
    [self registerForNotifications];
    
    //SETUP or LOAD PROJECT
    [self loadProject];
    
    self.currentWorkPeriodStartDate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadProject
{
    if (self.project == nil)
    {
        self.project = [[TTProjectController sharedInstance] addProjectWithTitle:self.projectTitle.text];
    }
    else
    {
        self.projectTitle.text = self.project.title;
        NSTimeInterval totalTime = [self calculateTotalSeconds];
        [self.projectTimer setTimer:totalTime];
        self.projectTimerLabel.text = [self minutesAndSecondsFromSeconds:totalTime];
    }
    
    [self reloadWorkPeriodTableView];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    [self save];
    
    return YES;
}

- (void)save
{
    [self hideKeyboard];
    self.project.title = self.projectTitle.text;
    [[TTProjectController sharedInstance] synchronize];
    NSLog(@"%@: Saved to core data", [NSDate date]);
}

- (void)hideKeyboard
{
    [self.projectTitle resignFirstResponder];
}

#pragma mark - Toolbar Button Methods

- (void)clockInButtonPressed
{
    if (!self.currentWorkPeriodStartDate)
    {
        self.currentWorkPeriodStartDate = [NSDate date];
        [self.projectTimer startTimer];
        [self.workPeriodTimer startTimer];
    }
}
- (void)clockOutButtonPressed
{
    if(self.currentWorkPeriodStartDate)
    {
        [[TTProjectController sharedInstance] addWorkPeriodWithStartDate:self.currentWorkPeriodStartDate
                                                                 endDate:[NSDate date]
                                                                    memo:@""
                                                                 project:self.project];
        self.currentWorkPeriodStartDate = nil;
        [self.projectTimer stopTimer];
        [self.projectTimer setTimer:[self calculateTotalSeconds]];
        [self updateProjectTimeLabel];
        [self.workPeriodTimer clearTimer];
        
        [self reloadWorkPeriodTableView];
    }
}

- (void)reportButtonPressed
{
}

- (void)addPeriodButtonPressed
{
}

- (void)reloadWorkPeriodTableView
{
    self.workPeriodTableViewDataSource.workPeriods = self.project.workPeriod.allObjects;
    [self.workPeriodTableView reloadData];
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
