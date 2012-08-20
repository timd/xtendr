//
//  XTProfileViewController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "XTUserController.h"
#import	"XTImageObject.h"

#import	"UIImageView+NetworkLoad.h"

#import "User+coolstuff.h"

@interface XTProfileViewController () <NSFetchedResultsControllerDelegate>

@property(weak) IBOutlet UIView			*headerView;
@property(weak) IBOutlet UIImageView	*headerBackgroundImageView;
@property(weak) IBOutlet UIImageView	*userImageView;
@property(weak) IBOutlet UILabel		*userNameLabel;
@property(weak) IBOutlet UILabel		*userPostCountLabel;

@property(copy) NSString						*internalUserID;
@property(strong) NSFetchedResultsController	*fetchedResultsController;

@property(strong) NSFetchedResultsController	*postsFetchedResultsController;

@end

@implementation XTProfileViewController

-(void)setupHeader
{
	User * tempUser;

	if(self.fetchedResultsController.fetchedObjects.count)
		tempUser = [self.fetchedResultsController.fetchedObjects lastObject];

	self.userNameLabel.text = [NSString stringWithFormat:@"%@ (%@)", tempUser.username, tempUser.id];

	self.userPostCountLabel.text = [NSString stringWithFormat:@"%@ posts", tempUser.postcount];

	XTImageObject * cover = tempUser.cover;
	if(cover)
	{
		[self.headerBackgroundImageView loadFromURL:cover.url
								   placeholderImage:[UIImage imageNamed:@"unknown"]
										  fromCache:(TMDiskCache*)[XTAppDelegate sharedInstance].userCoverArtCache];
	}

	XTImageObject * avatar = tempUser.avatar;
	if(avatar)
	{
		[self.userImageView loadFromURL:avatar.url
					   placeholderImage:[UIImage imageNamed:@"unknown"]
							  fromCache:(TMDiskCache*)[XTAppDelegate sharedInstance].userProfilePicCache];
	}
}

-(id)initWithUserID:(NSString*)userid
{
	self = [super initWithStyle:UITableViewStylePlain];
	if(self)
	{
		self.title = NSLocalizedString(@"Profile", @"");
		self.tabBarItem.tag = PROFILE_VIEW_TAG;

		self.internalUserID = userid;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:@"timelineback"]];
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;

	[[NSBundle mainBundle] loadNibNamed:@"XTProfileHeader"
                                  owner:self
                                options:nil];

	CALayer * l = self.userImageView.layer;

    l.masksToBounds = YES;
    l.cornerRadius  = 7;
    l.borderWidth   = 1;
    l.borderColor   = [UIColor darkGrayColor].CGColor;


	self.tableView.tableHeaderView = self.headerView;


	// Create and configure a fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
                                              inManagedObjectContext:[XTAppDelegate sharedInstance].managedObjectContext];

    [fetchRequest setEntity:entity];

	// limit to those entities to this ID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", self.internalUserID];
    [fetchRequest setPredicate:predicate];

	DLog(@"predicate: %@", predicate);

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];

	// we only want one object!
	[fetchRequest setFetchLimit:1];

    // Create and initialize the fetchedResultsController.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[XTAppDelegate sharedInstance].managedObjectContext
                                                                          sectionNameKeyPath:nil /* one section */
                                                                                   cacheName:nil];

    self.fetchedResultsController.delegate = self;

    NSError *error;
    [self.fetchedResultsController performFetch:&error];

	[self setupHeader];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	[self downloadUserDetails:self.internalUserID];
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
    return 10;
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
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - View Scrolling header thing

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if(scrollView.contentOffset.y < 0)
	{
		CGFloat extra = abs(scrollView.contentOffset.y);

		CGRect rect = self.headerView.frame;
		rect.origin.y = MIN(0, scrollView.contentOffset.y);
		rect.size.height = 200 + extra;
		self.headerView.frame = rect;
	}
}

-(void)downloadUserDetails:(NSString*)userID
{
	[[XTHTTPClient sharedClient] getPath:[NSString stringWithFormat:@"users/%@", self.internalUserID]
							  parameters:nil
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 DLog(@"got user: %@", responseObject);

									 if(responseObject && [responseObject isKindOfClass:[NSDictionary class]])
									 {
										 [[XTUserController sharedInstance] addUser:responseObject];
									 }
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {

								 }];
}

-(void)downloadPostsForUser:(NSString*)userID
{
	//https://alpha-api.app.net/stream/0/users/[user_id]/posts

	[[XTHTTPClient sharedClient] getPath:[NSString stringWithFormat:@"users/%@/posts", self.internalUserID]
							  parameters:nil
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 DLog(@"got posts: %@", responseObject);

								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {

								 }];

}

#pragma mark - fetched results stuff

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	DLog(@"controllerWillChangeContent");
	if(controller == self.postsFetchedResultsController)
	{

	}
	else
	{
		
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	DLog(@"controllerDidChangeContent");
	if(controller == self.postsFetchedResultsController)
	{

	}
	else
	{
		[self setupHeader];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	DLog(@"didChangeObject");
	if(controller == self.fetchedResultsController)
	{
		[self setupHeader];
		return;
	}

	//ok now we do the funky table stuff!
}


@end
