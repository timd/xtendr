//
//  XTNoCredentialsViewController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTNoCredentialsViewController.h"

#import "XTSignInViewController.h"

@interface XTNoCredentialsViewController ()

@end

@implementation XTNoCredentialsViewController

-(id)init
{
	return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Hello!", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if(indexPath.section == 0)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"signInCell"];

		if(!cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"signInCell"];
		}

		cell.textLabel.text = NSLocalizedString(@"Sign In", @"");
	}
	else if(indexPath.section == 1)
	{
		cell = [tableView dequeueReusableCellWithIdentifier:@"signUpCell"];

		if(!cell)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										  reuseIdentifier:@"signUpCell"];
		}

		cell.textLabel.text = NSLocalizedString(@"Sign Up", @"");

	}
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	if(indexPath.section == 0)
	{
		XTSignInViewController	*signinVC = [[XTSignInViewController alloc] init];

		signinVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

		[self presentViewController:[[UINavigationController alloc] initWithRootViewController:signinVC]
						   animated:YES
						 completion:^{	}];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
