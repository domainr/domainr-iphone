#import "WebViewController.h"


@implementation WebViewController

@synthesize webView;

- (void)dealloc; {
	
	[_result release];
	[loadAddress release];
	[toolbar release];
    
	webView.delegate = nil;
	[webView stopLoading];
	[webView release];
	
	[super dealloc];
}

- (id) initWithAddress: (NSString*) theAddress result:(Result *)result; {
	self = [self initWithNibName: @"WebViewController" bundle: nil];
	loadAddress = [theAddress retain];
	_result = [result retain];
	return self;
}

- (void)viewWillAppear:(BOOL)animated; {
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
	
    if (webView.loading)
    {
        [webView stopLoading];
    }
}

- (void)viewDidLoad; {
		
	self.navigationItem.titleView = titleAndAddressView;
	forwardButton.enabled = NO;
	
	NSURL *url = [NSURL URLWithString:loadAddress];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];
	
	[addressField setText:loadAddress];

	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation; {
	return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark -

- (void) updateButtons; {
	backButton.enabled = YES;
	forwardButton.enabled = webView.canGoForward;
}

- (void)reloadAction:(id)sender; {
	[webView reload];
}

- (void) webViewDidStartLoad: (UIWebView*) theWebView; {
	
	[self updateButtons];
	
	toolBarItems = [toolbar.items mutableCopy];
	[toolBarItems removeObjectAtIndex:4];
	[toolBarItems insertObject:fixedSpace atIndex:4];
	[toolbar setItems:toolBarItems];
	[toolBarItems release];

	spinner.hidden = NO;
	[spinner startAnimating];
}

- (void) webViewDidFinishLoad: (UIWebView*) theWebView; {
	[self updateButtons];
	toolBarItems = [toolbar.items mutableCopy];
	[toolBarItems removeObjectAtIndex:4];
	[toolBarItems insertObject:reloadButton atIndex:4];
	[toolbar setItems:toolBarItems];
	[toolBarItems release];

	spinner.hidden = YES;
	
	titleField.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if (!titleField.text)
		titleField.text = SDLocalizedString(@"Untitled");
	
	if (titleField.alpha == 0) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration: 0.4];
		CGRect frame;
		
		titleField.alpha = 1;
		frame = [titleField frame];
		frame.origin.y = 3;
		titleField.frame = frame;
		
		frame = [addressField frame];
		frame.origin.y = 20;
		addressField.frame = frame;
		
		addressField.text = [webView.request.URL absoluteString];
		[UIView commitAnimations];
	}
}

- (void) webView: (UIWebView*) webView didFailLoadWithError: (NSError*) error; {
	[self updateButtons];
}

#pragma mark -

- (void) goBack: (id) sender; {
	if (webView.canGoBack)
		[webView goBack];
	else
		[self.navigationController popViewControllerAnimated: YES];
}

- (void) action: (id) sender; {
	UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle: nil delegate: self cancelButtonTitle: SDLocalizedString(@"Cancel") destructiveButtonTitle: nil otherButtonTitles: NSLocalizedString(@"Open in Safari", nil), NSLocalizedString(@"Email Link to this Page", nil), nil] autorelease];
	[sheet showInView: [webView window]];
}

- (void) actionSheet: (UIActionSheet*) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex; {
	if (buttonIndex == 0) {
		[[UIApplication sharedApplication] openURL: webView.request.URL];			
	}
	else if (buttonIndex == 1) {
		[self displayComposerSheet];
	}
}

#pragma mark -

- (void)displayComposerSheet; {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setToRecipients:nil];
	[picker setSubject:SDLocalizedStringWithFormat(@"Domainr: %@",_result.domainName)];
	
	NSString *emailBody = [NSString stringWithFormat:@"Registration URL: <strong>%@</strong><br/><br/>Found on Domainr:<br/><strong>http://domai.nr/%@</strong>", [webView.request.URL absoluteString] ? loadAddress : [webView.request.URL absoluteString], _result.domainName];
	[picker setMessageBody:emailBody isHTML:YES];		
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error; {
	[self becomeFirstResponder];
	[self dismissModalViewControllerAnimated:YES];
}



@end
