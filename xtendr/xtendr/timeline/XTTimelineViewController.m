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

#import "XTNewPostViewController.h"

NSString * lorem = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam ut aliquam risus. Aliquam erat volutpat. Ut nibh leo, vulputate nec sollicitudin vitae, fringilla at odio. Phasellus lacinia auctor nullam.";

NSString * username = @"tonymillion";

@interface XTTimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property(weak)	IBOutlet UIView			*headerView;
@property(weak) IBOutlet UILabel		*releaseToRefreshLabel;

@property(weak) IBOutlet UIActivityIndicatorView *headerActivityIndicator;
@property(weak) IBOutlet UILabel		*lastRefreshLabel;

@property(assign) BOOL					inDrag;
@property(assign) BOOL					refreshOnRelease;

@property(strong) UITableView			*tableView;
@property(strong) UIButton				*addPostButton;
@property(strong) UIImageView			*addPostOverlayImageView;

@property(strong) NSArray				*posts;

@property(weak) TMHTTPRequest			*loadRequest;

@property(strong)	NSString			*firstID;
@property(strong)	NSString			*lastID;


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

	[[NSBundle mainBundle] loadNibNamed:@"XTTimelineHeader"
                                  owner:self
                                options:nil];

	self.releaseToRefreshLabel.alpha = 0;

	self.tableView.tableHeaderView = self.headerView;


	self.addPostButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.addPostButton.frame = CGRectMake(4,
										  self.view.bounds.size.height - 52,
										  48,
										  48);
	self.addPostButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

	[self.addPostButton setImage:[UIImage imageNamed:@"addpostbutton"] forState:UIControlStateNormal];

	[self.addPostButton addTarget:self
						   action:@selector(addPost:)
				 forControlEvents:UIControlEventTouchUpInside];

	[self.view addSubview:self.addPostButton];



	self.addPostOverlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addplus"]];
	self.addPostOverlayImageView.contentMode = UIViewContentModeCenter;
	self.addPostOverlayImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;


	[self.view addSubview:self.addPostOverlayImageView];
	[self.view bringSubviewToFront:self.addPostOverlayImageView];

	self.addPostOverlayImageView.frame = CGRectMake(4,
													self.view.bounds.size.height - 54,
													48,
													48);

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self loadPosts];
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

	/*
	 */

	NSDictionary * user = [post objectForKey:@"user"];

	NSString * text = [post objectForKey:@"text"];
	if ([post objectForKey:@"is_deleted"]) {
		if([[post objectForKey:@"is_deleted"] boolValue])
		{
			text = @"DELETED";
		}
	}


	return [XTTimelineCell cellHeightForText:text
								withUsername:[user objectForKey:@"username"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary * post = [self.posts objectAtIndex:indexPath.row];
	NSDictionary * user = [post objectForKey:@"user"];
	NSString * avatarURL = [[user objectForKey:@"avatar_image"] objectForKey:@"url"];

	XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCell"];


	NSString * text = [post objectForKey:@"text"];

	if ([post objectForKey:@"is_deleted"]) {
		if([[post objectForKey:@"is_deleted"] boolValue])
		{
			text = @"DELETED";
		}
	}


	// Configure the cell...
	//cell.timelineEntry = entry;

	[cell setPostText:text
			 username:[user objectForKey:@"username"]
		   pictureURL:avatarURL];

	return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row > self.posts.count - 10)
	{
		[self loadMorePosts];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - network stuff

-(void)loadPosts
{
	if(self.loadRequest)
	{
		DLog(@"load already in progress!");
		return;
	}
	
	DLog(@"loadPosts");

	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
	if(self.firstID)
	{
		[params setObject:self.firstID
				   forKey:@"since_id"];
	}

	NSString * path;
	if(self.timelineMode == kMyTimelineMode)
	{
		path = @"posts/stream";
	}
	else if(self.timelineMode == kGlobalTimelineMode)
	{
		path = @"posts/stream/global";
	}
	else if(self.timelineMode == kMentionsTimelineMode)
	{
		path = @"users/me/mentions";
	}

	[self.headerActivityIndicator startAnimating];
	self.lastRefreshLabel.text = NSLocalizedString(@"Refresh In Progress", @"");

	self.loadRequest = [[XTHTTPClient sharedClient] getPath:path
							  parameters:params
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 self.loadRequest = nil;
									 [self.headerActivityIndicator stopAnimating];
									 //DLog(@"login S: %@", responseObject);
									 if(responseObject && [responseObject isKindOfClass:[NSArray class]])
									 {
										 NSArray * temp = responseObject;
										 if(self.posts)
										 {
											 if(temp.count)
											 {
												 self.posts = [temp arrayByAddingObjectsFromArray:self.posts];
												 self.firstID = [[temp objectAtIndex:0] objectForKey:@"id"];
											 }
										 }
										 else
										 {
											 self.posts = temp;
											 self.lastID = [[temp lastObject] objectForKey:@"id"];
										 }
										 [self.tableView reloadData];

										 self.lastRefreshLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Refresh: %@", @""), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];

									 }
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {
									 self.loadRequest = nil;
									 [self.headerActivityIndicator stopAnimating];

									 DLog(@"login F: %@", operation.responseString);
								 }];
}

-(void)loadMorePosts
{
	if(self.loadRequest)
	{
		DLog(@"load already in progress!");
		return;
	}

	DLog(@"loadMorePosts");

	if(!self.lastID)
	{
		DLog(@"LastID not valid");
		
		return;
	}

	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
	if(self.lastID)
	{
		DLog(@"lastID = %@", self.lastID);
		[params setObject:self.lastID
				   forKey:@"before_id"];
	}

	NSString * path;
	if(self.timelineMode == kMyTimelineMode)
	{
		path = @"posts/stream";
	}
	else if(self.timelineMode == kGlobalTimelineMode)
	{
		path = @"posts/stream/global";
	}
	else if(self.timelineMode == kMentionsTimelineMode)
	{
		path = @"users/me/mentions";
	}

	[self.headerActivityIndicator startAnimating];
	self.lastRefreshLabel.text = NSLocalizedString(@"Refresh In Progress", @"");

	self.loadRequest = [[XTHTTPClient sharedClient] getPath:path
												 parameters:params
													success:^(TMHTTPRequest *operation, id responseObject) {
														self.loadRequest = nil;
														[self.headerActivityIndicator stopAnimating];
														//DLog(@"login S: %@", responseObject);
														if(responseObject && [responseObject isKindOfClass:[NSArray class]])
														{
															NSArray * temp = responseObject;
															if(self.posts)
															{
																self.posts = [self.posts arrayByAddingObjectsFromArray:temp];
																self.lastID = [[temp lastObject] objectForKey:@"id"];
															}
															
															[self.tableView reloadData];
														}
													}
													failure:^(TMHTTPRequest *operation, NSError *error) {
														self.loadRequest = nil;
														[self.headerActivityIndicator stopAnimating];
														
														DLog(@"login F: %@", operation.responseString);
													}];

}

-(void)setTimelineMode:(NSInteger)timelineMode
{
	_timelineMode = timelineMode;

	if(_timelineMode == kMyTimelineMode)
	{
		self.title = NSLocalizedString(@"My Stream", @"");
	}
	else if(_timelineMode == kGlobalTimelineMode)
	{
		self.title = NSLocalizedString(@"Global Stream", @"");
	}
	else if(_timelineMode == kMentionsTimelineMode)
	{
		self.title = NSLocalizedString(@"Mentions", @"");
	}
}

#pragma mark - View Scrolling header thing

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.inDrag = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	self.inDrag = NO;
	[UIView animateWithDuration:0.4
					 animations:^{
						 self.releaseToRefreshLabel.alpha = 0;

					 }];

	if(self.refreshOnRelease)
	{
		[self loadPosts];
	}

	self.refreshOnRelease = NO;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(scrollView.contentOffset.y < 0)
	{
		CGFloat extra = abs(scrollView.contentOffset.y);

		CGRect rect = self.headerView.frame;
		rect.origin.y = MIN(0, scrollView.contentOffset.y);
		rect.size.height = 100 + extra;
		self.headerView.frame = rect;

		if(self.inDrag)
		{
			if(rect.size.height > 160)
			{
				[UIView animateWithDuration:0.4
								 animations:^{
									 self.releaseToRefreshLabel.alpha = 1;
									 
								 }];
				self.refreshOnRelease = YES;
			}
			else
			{
				[UIView animateWithDuration:0.4
								 animations:^{
									 self.releaseToRefreshLabel.alpha = 0;

								 }];
				self.refreshOnRelease = NO;

			}
		}
	}
}

-(IBAction)addPost:(id)sender
{
	DLog(@"AddPost");

	XTNewPostViewController*npvc = [[XTNewPostViewController alloc] init];

	[self presentViewController:[[UINavigationController alloc] initWithRootViewController:npvc]
					   animated:YES
					 completion:nil];
}

@end
