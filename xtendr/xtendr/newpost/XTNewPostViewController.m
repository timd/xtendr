//
//  XTNewPostViewController.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTNewPostViewController.h"

#import "XTNewPostCell.h"

#import "XTHTTPClient.h"

@interface XTNewPostViewController () <UITextViewDelegate>

@property(strong) XTNewPostCell			*theCell;
@property(assign) CGFloat               textHeight;

@end

@implementation XTNewPostViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"New Post", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.tableView.backgroundColor	= [UIColor colorWithPatternImage:[UIImage imageNamed:@"timelineback"]];
	self.tableView.separatorStyle	= UITableViewCellSeparatorStyleNone;

	[self.tableView registerNib:[UINib nibWithNibName:@"XTNewPostCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"XTNewPostCell"];

    self.theCell = [self.tableView dequeueReusableCellWithIdentifier:@"XTNewPostCell"];
	//self.theCell.finalDelegate = self;
    //self.theCell.user = [ZZProfileController sharedInstance].user;

    self.theCell.textView.delegate = self;

	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel:)];

	// add picture button!
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(save:)];

	self.navigationItem.rightBarButtonItem.enabled = NO;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	[self.theCell.textView becomeFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize requiredSize = self.theCell.textView.contentSize;
    return MAX(requiredSize.height+40, 200);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.theCell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - UITextViewDelegateness

- (void)tableViewNeedsToUpdateHeight
{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:NO];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [UIView setAnimationsEnabled:animationsEnabled];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }

    CGFloat newTextHeight = [textView contentSize].height;

    if(newTextHeight != self.textHeight)
    {
        self.textHeight = newTextHeight;
        [self tableViewNeedsToUpdateHeight];
    }
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender
{
	[self.parentViewController dismissViewControllerAnimated:YES
                                                  completion:^{

                                                  }];
}

-(IBAction)save:(id)sender
{
	self.navigationItem.rightBarButtonItem.enabled = NO;

	NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];

	[params setObject:self.theCell.textView.text
			   forKey:@"text"];

	if(self.replyToPostID)
	{
		[params setObject:self.replyToPostID
				   forKey:@"reply_to"];
	}

	[[XTHTTPClient sharedClient] postPath:@"posts"
							   parameters:params
								  success:^(TMHTTPRequest *operation, id responseObject) {
									  [self.parentViewController dismissViewControllerAnimated:YES
																					completion:^{

																					}];
								  }
								  failure:^(TMHTTPRequest *operation, NSError *error) {
									  DLog(@"ERROR: %@, %@", operation.responseString, error);
								  }];
}

@end
