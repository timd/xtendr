//
//  TMTwitterAccountPicker.m
//  ZummZumm
//
//  Created by Tony Million on 10/02/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import "TMTwitterAccountPicker.h"


@interface TMTwitterAccountPicker (private)

-(IBAction)cancel:(id)sender;

@end


@implementation TMTwitterAccountPicker

@synthesize twitterAccountPickerDelegate;

@synthesize accountStore;
@synthesize accounts;

-(id)init
{
    return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) 
    {
        // Custom initialization
        self.accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        self.accounts = [self.accountStore accountsWithAccountType:accountType];

        self.title = NSLocalizedString(@"Twitter Account", @"");
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.rowHeight = 54;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self 
                                                                                          action:@selector(cancel:)];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //TODO: request access to accounts here!
    
    // request access to twitter
    ACAccountType *accountType          = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [self.accountStore requestAccessToAccountsWithType:accountType 
                                 withCompletionHandler:^(BOOL granted, NSError *error) {
                                     if(granted)
                                     {
                                         self.accounts = [self.accountStore accountsWithAccountType:accountType];

                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView reloadData];
                                         });
                                     }
                                 }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    ACAccount * account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.accountDescription;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.twitterAccountPickerDelegate && [self.twitterAccountPickerDelegate respondsToSelector:@selector(twitterAccountPicker:didPickAccountWithIdentifier:)])
    {
        ACAccount * account = [self.accounts objectAtIndex:indexPath.row];

        [self.twitterAccountPickerDelegate twitterAccountPicker:self
                                   didPickAccountWithIdentifier:account.identifier];
    }
    
    [tableView deselectRowAtIndexPath:indexPath 
                             animated:YES];
}

#pragma mark - IBActions

-(IBAction)cancel:(id)sender
{
    if(self.twitterAccountPickerDelegate && [self.twitterAccountPickerDelegate respondsToSelector:@selector(twitterAccountPickerDidCancel:)])
    {
        [self.twitterAccountPickerDelegate twitterAccountPickerDidCancel:self];
    }
}

@end
