//
//  XTTimelineViewController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTTimelineViewController.h"

#import "XTTimelineCell.h"

#import "XTHTTPClient.h"

NSString * lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ut aliquam risus. Aliquam erat volutpat. Ut nibh leo, vulputate nec sollicitudin vitae, fringilla at odio. Phasellus lacinia auctor nullam.";

NSString * username = @"tonymillion";

@interface XTTimelineViewController () <UITableViewDataSource, UITableViewDelegate>


@property(strong) UITableView			*tableView;
@property(strong) UIButton				*addPostButton;
@property(strong) UIImageView			*addPostOverlayImageView;

@property(strong) NSArray				*posts;

@end

@implementation XTTimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Timeline", @"");
		self.tabBarItem.tag = TIMELINE_VIEW_TAG;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view.backgroundColor = [UIColor blackColor];


	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	self.tableView.dataSource	= self;
	self.tableView.delegate		= self;

	self.tableView.backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:@"timelineback"]];
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;
	[self.view addSubview:self.tableView];

    [self.tableView registerNib:[UINib nibWithNibName:@"XTTimelineCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"timelineCell"];


	self.addPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.addPostButton.frame = CGRectMake(4,
										  self.view.bounds.size.height - 52,
										  48,
										  48);
	self.addPostButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

	[self.addPostButton setImage:[UIImage imageNamed:@"addpostbutton"] forState:UIControlStateNormal];

	[self.view addSubview:self.addPostButton];

	
	self.addPostOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4,
																				 self.view.bounds.size.height - 52,
																				 48,
																				 48)];
	self.addPostOverlayImageView.image = [UIImage imageNamed:@"addplus"];
	self.addPostOverlayImageView.contentMode = UIViewContentModeCenter;

	[self.view addSubview:self.addPostOverlayImageView];
	[self.view bringSubviewToFront:self.addPostOverlayImageView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[[XTHTTPClient sharedClient] getPath:@"posts/stream"
							  parameters:nil
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 //DLog(@"login S: %@", responseObject);
									 if(responseObject && [responseObject isKindOfClass:[NSArray class]])
									 {
										 self.posts = responseObject;
										 [self.tableView reloadData];
									 }
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {
									 DLog(@"login F: %@", operation.responseString);
								 }];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.posts.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
	NSDictionary * user = [post objectForKey:@"user"];

	DLog(@"post = %@", post);

	return [XTTimelineCell cellHeightForText:[post objectForKey:@"text"]
								withUsername:[user objectForKey:@"username"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCell"];

	// Configure the cell...
	//cell.timelineEntry = entry;
	NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
	NSDictionary * user = [post objectForKey:@"user"];
	//DLog(@"post = %@", post);

	[cell setPostText:[post objectForKey:@"text"]
			 username:[user objectForKey:@"username"]];

	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
