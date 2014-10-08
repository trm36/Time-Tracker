//
//  TTProjectListViewController.m
//  Time-Tracker
//
//  Created by Taylor Mott on 10.8.14.
//  Copyright (c) 2014 DevMountain. All rights reserved.
//

#import "TTProjectListViewController.h"
#import "TTProjectViewController.h"

@interface TTProjectListViewController ()

@end

@implementation TTProjectListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Time Tracker";
    
    UIBarButtonItem *newProjectButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewProject)];
    self.navigationItem.rightBarButtonItem = newProjectButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) createNewProject
{
    TTProjectViewController *projectViewController = [TTProjectViewController new];
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
