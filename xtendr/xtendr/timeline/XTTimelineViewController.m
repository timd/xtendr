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
#import "XTProfileController.h"

#import "XTNewPostViewController.h"
#import "XTProfileViewController.h"

#import "UIImageView+NetworkLoad.h"

#import "XTPostController.h"

@interface XTTimelineViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property(weak)	IBOutlet UIView					*headerView;
@property(weak) IBOutlet UILabel				*releaseToRefreshLabel;
@property(weak) IBOutlet UIImageView			*headerBackgroundView;
@property(weak) IBOutlet UIActivityIndicatorView *headerActivityIndicator;
@property(weak) IBOutlet UILabel				*lastRefreshLabel;

@property(weak) IBOutlet UIButton				*quickReplyButton;

@property(assign) BOOL							inDrag;
@property(assign) BOOL							refreshOnRelease;

@property(strong) UITableView					*tableView;
@property(strong) UIButton						*addPostButton;
@property(strong) UIImageView					*addPostOverlayImageView;

@property(weak) TMHTTPRequest					*loadRequest;

@property(strong)	NSString					*firstID;
@property(strong)	NSString					*lastID;
@property(assign)	NSUInteger					lastLoadCount;

@property(strong)	NSFetchedResultsController	*fetchedResultsController;

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

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(profileRefreshed:)
												 name:kXTProfileRefreshedNotification
											   object:nil];


	// Create and configure a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post"
                                              inManagedObjectContext:[XTAppDelegate sharedInstance].managedObjectContext];

    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intid" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

	// limit to those entities that belong to the particular item
	// TODO: FIX THIS THIS
    NSPredicate *predicate;

	if(self.timelineMode == kGlobalTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted != %@", [NSNumber numberWithBool:YES]];
	}
	else if(self.timelineMode == kMyTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted == %@ AND is_mystream == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]];
	}
	else if(self.timelineMode == kMentionsTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted == %@ AND is_mention == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]];
	}

	DLog(@"predicate: %@", predicate);

    [fetchRequest setPredicate:predicate];

	[fetchRequest setFetchLimit:100];

    // Create and initialize the fetchedResultsController.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[XTAppDelegate sharedInstance].managedObjectContext
                                                                          sectionNameKeyPath:nil /* one section */
                                                                                   cacheName:nil];

    self.fetchedResultsController.delegate = self;

    NSError *error;
    [self.fetchedResultsController performFetch:&error];

	/*
	 //DONT DO THIS YET
	if(self.fetchedResultsController.fetchedObjects && self.fetchedResultsController.fetchedObjects.count)
	{
		Post * firstPost = [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		self.firstID = firstPost.id;
	}
	 */

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

	[self.headerBackgroundView loadFromURL:[XTProfileController sharedInstance].profileUser.cover_image.url
						  placeholderImage:nil
								 fromCache:[XTAppDelegate sharedInstance].userCoverArtCache];

	[self.tableView reloadData];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];

	DLog(@"mode: %d, [sectionInfo numberOfObjects] = %d", self.timelineMode, [sectionInfo numberOfObjects]);

	return [sectionInfo numberOfObjects];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Post * post = [self.fetchedResultsController objectAtIndexPath:indexPath];

	return [XTTimelineCell cellHeightForPost:post];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	Post * post = [self.fetchedResultsController objectAtIndexPath:indexPath];

	XTTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timelineCell"];

	cell.post = post;
	cell.faceTapBlock = ^(Post * post)
	{
		XTProfileViewController * pvc = [[XTProfileViewController alloc] initWithUserID:post.userid];
		[self.navigationController pushViewController:pvc animated:YES];
	};

	cell.quickReplyBlock = ^(Post * post)
	{
		XTNewPostViewController * npvc = [[XTNewPostViewController alloc] init];
		npvc.replyToPost = post;
		
		[self presentViewController:[[UINavigationController alloc] initWithRootViewController:npvc]
						   animated:YES
						 completion:nil];
	};
	
	return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row > self.lastLoadCount - 10)
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
/*
 BRAIN DUMP:
 
 FIRST: 
 
 see if there are objects from the FRC and get the newest ID = topFRCID

 So we get here and we load some posts (100),
 
 so then we need to do the following
 self.firstpost = results[0]
 
 if(result[last].id < topFRCID)
	// we have an overlap; great we're sorted
 else
	self.lastpost = result[last]

 
 */
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

	[params setObject:[NSNumber numberWithUnsignedInteger:100]
			   forKey:@"count"];

	DLog(@"params = %@", params);

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
										 if(temp.count)
										 {
											 DLog(@"Got %d posts", temp.count);
											 [[XTPostController sharedInstance] addPostArray:temp
																				fromMyStream:self.timelineMode == kMyTimelineMode
																				fromMentions:self.timelineMode == kMentionsTimelineMode];

											 self.firstID	= [[temp objectAtIndex:0] objectForKey:@"id"];

											 if(!self.lastID)
												 self.lastID	= [[temp lastObject] objectForKey:@"id"];

											 self.lastLoadCount = temp.count;

											 [self doTestFetch];
										 }
										 else
										 {
											 DLog(@"Nothing new");
										 }


										 //TODO: detect a discontinuity please
										 /*
										 if(self.posts)
										 {
											 if(temp.count)
											 {
												 // so what we need to do, is detect if the new posts we just got
												 // ARE NOT continuous with the old set of posts
												 // we do not want to end up in a situation where we have
												 // posts 100-80 then 70-40 then 25-0 - that is a disconinuous list!

												 NSString * tempLast = [[temp lastObject] objectForKey:@"id"];
												 // temp value would be 80 in this case
												 // first value would be 70
												 
												 if(self.firstID.integerValue < (tempLast.integerValue-1))
												 {
													 // discontinuation detected.
													 // TODO: deal with this.
													 self.lastID = tempLast;
												 }

												 self.posts = [temp arrayByAddingObjectsFromArray:self.posts];
											 }
										 }
										 else
										 {
											 self.posts = temp;
											 self.lastID = [[temp lastObject] objectForKey:@"id"];
										 }
										 [self.tableView reloadData];
 */

										 self.lastRefreshLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Refresh: %@", @""), [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];

									 }
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {
									 self.loadRequest = nil;
									 [self.headerActivityIndicator stopAnimating];

									 DLog(@"login F: %@", operation.responseString);
								 }];
}

-(void)loadNewerPosts
{
	
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

	[params setObject:[NSNumber numberWithBool:100]
			   forKey:@"count"];

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
															if(temp && temp.count)
															{
																[[XTPostController sharedInstance] addPostArray:responseObject
																								   fromMyStream:self.timelineMode == kMyTimelineMode
																								   fromMentions:self.timelineMode == kMentionsTimelineMode];
																
																self.lastID = [[temp lastObject] objectForKey:@"id"];
																self.lastLoadCount += temp.count;
															}
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
			if(rect.size.height > 200)
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

	XTNewPostViewController * npvc = [[XTNewPostViewController alloc] init];

	[self presentViewController:[[UINavigationController alloc] initWithRootViewController:npvc]
					   animated:YES
					 completion:nil];
}

-(void)profileRefreshed:(NSNotification*)note
{
	[self.headerBackgroundView loadFromURL:[XTProfileController sharedInstance].profileUser.cover_image.url
						  placeholderImage:nil
								 fromCache:[XTAppDelegate sharedInstance].userCoverArtCache];
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

#pragma mark - fetched results stuff

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    //Lets the tableview know we're potentially doing a bunch of updates.
	DLog(@"controllerWillChangeContent");
    //[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    //We're finished updating the tableview's data.
	DLog(@"controllerDidChangeContent");
    //[self.tableView endUpdates];
	[self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
/*
    UITableView *tableView = self.tableView;
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
			[tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
 */
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

-(void)doTestFetch
{
	return;
	
	if(self.timelineMode != kGlobalTimelineMode)
		return;

	// Create and configure a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post"
                                              inManagedObjectContext:[XTAppDelegate sharedInstance].managedObjectContext];

    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"intid" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

	// limit to those entities that belong to the particular item
	// TODO: FIX THIS THIS
	/*
    NSPredicate *predicate;

	if(self.timelineMode == kGlobalTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted == %@", [NSNumber numberWithBool:NO]];
	}
	else if(self.timelineMode == kMyTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted == %@ AND is_mystream == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]];
	}
	else if(self.timelineMode == kMentionsTimelineMode)
	{
		predicate = [NSPredicate predicateWithFormat:@"is_deleted == %@ AND is_mention == %@", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]];
	}

	DLog(@"predicate: %@", predicate);
	 [fetchRequest setPredicate:predicate];
	 */


	[fetchRequest setFetchLimit:10];

	NSError * err;
	NSArray * objects = [[XTAppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest
																						   error:&err];


	for (Post * post in objects) {
		DLog(@"%@: %@", post.id, post.text);
	}
}

@end
