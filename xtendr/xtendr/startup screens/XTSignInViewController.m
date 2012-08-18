//
//  XTSignInViewController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTSignInViewController.h"

#import "XTProfileController.h"

@interface XTSignInViewController () <UIWebViewDelegate>

@property(weak) IBOutlet UIWebView			*webView;

@end

@implementation XTSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Sign In", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

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

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];


    NSString *redirectURI		= @"xtendr://authcomplete";
    NSString *scopes			= @"stream write_post follow messages";
    NSString *authURLstring = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=%@&scope=%@", kANAPIClientID, redirectURI, scopes];
    NSURL *authURL = [NSURL URLWithString:[authURLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];


	NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:authURL];

	
	[self.webView loadRequest:req];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"shouldStartLoadWithRequest: %@", request.URL);

	NSArray *components = [[request URL].absoluteString  componentsSeparatedByString:@"#"];

    if([components count]) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {

            if([[component componentsSeparatedByString:@"="] count] > 1) {
				[parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
            }
        }

        if([parameters objectForKey:@"access_token"])
        {
			[[XTProfileController sharedInstance] loginWithToken:[parameters objectForKey:@"access_token"]];

			[self.parentViewController dismissViewControllerAnimated:YES
														  completion:^{}];

        }
    }

	return YES;
}

-(IBAction)cancel:(id)sender
{
    [self.parentViewController dismissViewControllerAnimated:YES
                                                  completion:^{}];
}

@end
