//
//  TTProjectListViewController.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.8.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectListViewController.h"
#import "TTProjectViewController.h"
#import "TTProjectTableViewDataSource.h"
#import "TTProjectController.h"

@interface TTProjectListViewController () <UITableViewDelegate>

@property (strong, nonatomic) UITableView *projectTable;
@property (strong, nonatomic) TTProjectTableViewDataSource *dataSource;

@end

@implementation TTProjectListViewController

- (void)setupUI
{
    UIBarButtonItem *newProjectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewProject)];
    self.navigationItem.rightBarButtonItem = newProjectButton;
    
    self.projectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.projectTable.delegate = self;
    self.dataSource = [TTProjectTableViewDataSource new];
    self.projectTable.dataSource = self.dataSource;
    [self.view addSubview:self.projectTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Time Tracker";
    
    [self setupUI];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.projectTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createNewProject
{
    TTProjectViewController *projectViewController = [TTProjectViewController new];
    [self.navigationController pushViewController:projectViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTProjectViewController *projectViewController = [TTProjectViewController new];
    projectViewController.project = [TTProjectController sharedInstance].projects[indexPath.row];
    [self.navigationController pushViewController:projectViewController animated:YES];
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
