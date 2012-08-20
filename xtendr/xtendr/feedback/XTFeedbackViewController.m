//
//  XTFeedbackViewController.m
//  xtendr
//
//  Created by Tony Million on 20/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTFeedbackViewController.h"
#import "XTNewPostViewController.h"

@interface XTFeedbackViewController ()

@end

@implementation XTFeedbackViewController

-(id)init
{
	return [self initWithStyle:UITableViewStyleGrouped];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Feedback", @"");
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
	if(section == 0)
		return 1;
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
		return NSLocalizedString(@"Feedback via app.net lets everyone get involved!", @"");

	if(section == 1)
		return NSLocalizedString(@"Follow me for live xtendr updates!", @"");
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
	if(!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			cell.textLabel.text = NSLocalizedString(@"Send feedback via app.net", @"");
		}
		if(indexPath.row == 1)
		{
			cell.textLabel.text = NSLocalizedString(@"Feedback via email", @"");
		}
	}
	else if(indexPath.section == 1)
	{
		cell.textLabel.text = NSLocalizedString(@"follow @tonymillion", @"");
	}


    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			//TODO: bring up post composer prepopulated with @"@tonymillion #xtendr "
			XTNewPostViewController *npvc = [[XTNewPostViewController alloc] init];
			npvc.prepopulateText = @"@tonymillion #xtendrfeature ";

			[self presentViewController:[[UINavigationController alloc] initWithRootViewController:npvc]
							   animated:YES
							 completion:nil];

		}
		if(indexPath.row == 1)
		{
			//TODO: bring up email feedback thing
		}
	}

	if(indexPath.section==1)
	{
		[[XTHTTPClient sharedClient] postPath:@"users/7833/follow"
								   parameters:nil
									  success:^(TMHTTPRequest *operation, id responseObject) {
										  DLog(@"Follow success");
									  }
									  failure:^(TMHTTPRequest *operation, NSError *error) {
										  DLog(@"Follow fail: %@", operation.responseString);
									  }];
	}

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
