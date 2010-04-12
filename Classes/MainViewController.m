#import "MainViewController.h"
#import "ResultCell.h"
#import	"Reachability.h"
#import "ResultViewController.h"
#import "DMAboutController.h"

@implementation MainViewController

	@synthesize myTableView, historyTableView;
	@synthesize mySearchBar;

	- (void)dealloc; {
		Release(myTableView);
		Release(historyTableView);
		Release(mySearchBar);
		Release(activityIndicator);
		Release(internetReach);
		[super dealloc];
	}

#pragma mark -

	- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation; {
		return YES;//interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	}

	- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation; {
		if(keyboardHidden) {
			[self setKeyboardState:NO];
		}
		else {
			[self setKeyboardState:YES];
		}
		[myTableView reloadData];
		[historyTableView reloadData];
	}

#pragma mark UIView methods

	- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; {
		if(self = [super initWithNibName:nibNameOrNil bundle: nil]) {
			//customize
		}		
		return self;
	}

	- (void)viewWillAppear:(BOOL)animated; {
		[myTableView deselectRowAtIndexPath:myTableView.indexPathForSelectedRow animated: YES];
		[super viewWillAppear: animated];
	}

	- (void)viewDidLoad; {
		internetReach = [[Reachability reachabilityForInternetConnection] retain];
		[internetReach startNotifer];
		
		// check for history
		historyArray = [[[Storage instance] recentHistory] retain];
		[historyTableView setHidden: [historyArray count] ? NO : YES];
		
		[myTableView setSeparatorColor:UIColorFromRGB(0xEEEEEE)];
		[historyTableView setSeparatorColor:UIColorFromRGB(0xEEEEEE)];

		[mySearchBar becomeFirstResponder];
		[self setKeyboardState:YES];
		[self toggleActivityIndicator:NO];
		
		infoButton.frame = CGRectMake(self.view.frame.size.width - 32, 11, 22, 22); 
		
		[super viewDidLoad];
	}

	- (void)viewDidUnload; {
		Release(internetReach);
		[super viewDidUnload];
	}

#pragma mark Various helpers

	- (BOOL)networkAvailable; {
		
		if ([internetReach currentReachabilityStatus] == NotReachable) {
			UIAlertViewQuick(@"Network Error", @"Sorry, the network is not available", @"OK");
			return NO;
		}
		return YES;
	}

	- (void)toggleActivityIndicator:(BOOL)show; {
		[self _hideClearButton];
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration: 0.1];
		[UIView setAnimationDelegate:self];
		if(show)
			[activityIndicator startAnimating];
		else
			[activityIndicator stopAnimating];
		[activityIndicator setAlpha:show ? 1 : 0];
		[UIView commitAnimations];
	}

	- (void)setKeyboardState:(BOOL)show; {
		keyboardHidden = !show;
		CGRect newFrame = [myTableView frame];
		if(show) {
			newFrame.size.height = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 460 - 44 - KEYBOARD_HEIGHT_PORTRAIT : 300 - 44 - KEYBOARD_HEIGHT_LANDSCAPE;
		}
		else {
			newFrame.size.height = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 460 - 44 : 300 - 44;
			[mySearchBar resignFirstResponder];
		}
		[myTableView setFrame:newFrame];
		[historyTableView setFrame:newFrame];
	}

	- (void)_showKeyboardWorkAround; {
		[self setKeyboardState:YES];
	}
	
#pragma mark UISearchBar methods

	- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar; { // return NO to not become first responder
		return YES;
	}

	- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar; {
		[self performSelector:@selector(_showKeyboardWorkAround) withObject:nil afterDelay:0.5];
	}

	- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText; {   // called when text changes (including clear)
		if(EmptyString(searchText)) {
			infoButton.hidden = NO;
			[self showHistory];
		}
		else {
			infoButton.hidden = YES;
			[historyTableView setHidden:YES];
			[myTableView setHidden:NO];
			[self search];			
		}
	}

	- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text; { // called before text changes
		if(![self networkAvailable]) return NO;
		
		if(([text isEqualToString:@""] && [[mySearchBar text] length] == 0)) {
			return NO;
		}

		if(loading && ![[mySearchBar text] length] == 0) {
			[theConnection cancel];
			Release(theConnection);
			Release(receivedData);		
		}
		return YES;
	}

	- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar; { // called when keyboard search button pressed
		[self setKeyboardState:NO];
		if(![self networkAvailable]) return;
		
//
		[[Storage instance] storeSearch:searchBar.text]; 
		
		[self search];
	}

	- (void)search; {
		NSString *searchText = [mySearchBar text];
		
		[self toggleActivityIndicator:YES];
		loading = YES;
		
		NSString *urlSearchString = [NSString stringWithFormat: @"http://domai.nr/api/json/search?q=%@", searchText];
		
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: [urlSearchString escapedString]]
																  cachePolicy: NSURLRequestUseProtocolCachePolicy
															  timeoutInterval: 60.0];
		[theRequest setHTTPMethod:@"GET"];
		
		theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if (theConnection) {
			receivedData=[[NSMutableData data] retain];
		} 
		else {
		}
	}

#pragma mark NSURLConnection methods 

	- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data; {
		[receivedData appendData:data];
	}

	- (void)connectionDidFinishLoading:(NSURLConnection *)connection; {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showClearButton) object:nil];
		NSError *error = nil;
		
//        NSLog(@"%@",[NSString stringWithData:receivedData]);
        
        NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:&error];
		
		if(results)
			Release(results);
		results = [[NSMutableArray alloc] init];
		
		for (NSDictionary *result in [dictionary objectForKey:@"results"]) {
			Result *newResult = [[Result alloc] init];
			newResult.domainName = [result objectForKey:@"domain"];
			newResult.availability = [result objectForKey:@"availability"];
			newResult.path = [result objectForKey:@"path"];
			newResult.registerURL = [result objectForKey:@"register_url"];
			NSMutableArray *registrars = [result objectForKey:@"registrars"];
			for (NSString *registrar in registrars) {
				[newResult.registrars addObject:registrar];				
			}
			[results addObject:newResult];
			Release(newResult);
		}
		
		[receivedData setLength:0];
		Release(receivedData);
		Release(connection);

		[myTableView reloadData];
		loading = NO;
		[self toggleActivityIndicator:NO];
		[self performSelector:@selector(_showClearButton) withObject:nil afterDelay:0];
	}

	- (void)_showClearButton; {
		[whiteBgView setHidden:YES];
	}

	- (void)_hideClearButton; {
		[whiteBgView setHidden:NO];
	}

#pragma mark Table view methods

	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
		if (tableView == myTableView) {
			if(results == nil) return 40;
			
			NSString *domainNameString = [[results objectAtIndexA:indexPath.row] domainName];
			CGSize aSize;	
			aSize = [domainNameString sizeWithFont:[UIFont systemFontOfSize:17] 
								 constrainedToSize:CGSizeMake(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 260.0 : 420, 1000)  
									 lineBreakMode:UILineBreakModeTailTruncation];  
			return aSize.height+21;				
		}
		else if (tableView == historyTableView) {
			
			if (indexPath.section == 1) {
				return 40;
			}
			
			if(results == nil) return 50;
			
			NSString *searchString = [historyArray objectAtIndexA:indexPath.row];
			CGSize aSize;	
			aSize = [searchString sizeWithFont:[UIFont systemFontOfSize:17] 
							 constrainedToSize:CGSizeMake(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 260.0 : 420, 1000)  
								 lineBreakMode:UILineBreakModeTailTruncation];  
			return aSize.height + 21;
		}
		return 40;		
	}

	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
		if (tableView == historyTableView) {
			return [historyArray count] > 0 ? 2 : 1;
		}
		return 1;
	}

	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
		if (tableView == myTableView) {
			return (results) ? [results count] : 0;
		}
		else if (tableView == historyTableView) {
			
			if (section == 1) {
				return 1; //clearall row
			}

			return (historyArray) ? [historyArray count] : 0;
		}
		return 0;
	}

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
		if (tableView == myTableView) {
			ResultCell *cell = (ResultCell *)[tableView cellForClass:[ResultCell class]];
			[cell setResult:[results objectAtIndexA:indexPath.row]];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			return cell;
		}
		else if (tableView == historyTableView) {
			
			if (indexPath.section == 1) {
				UITableViewCell *cell = (UITableViewCell *)[tableView cellForClass:[UITableViewCell class]];
				[[cell textLabel] setText:NSLocalizedString(@"Clear History", nil)];
				[[cell textLabel] setTextAlignment:UITextAlignmentCenter];
				[[cell textLabel] setFont:[UIFont systemFontOfSize:17]];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				cell.imageView.image = nil;
				return cell;
			}
			
			UITableViewCell *cell = (UITableViewCell *)[tableView cellForClass:[UITableViewCell class]];
			[[cell textLabel] setText:[historyArray objectAtIndexA:indexPath.row]];
			[[cell textLabel] setFont:[UIFont systemFontOfSize:17]];
			[[cell textLabel] setTextColor:[UIColor darkGrayColor]];
			[[cell textLabel] setTextAlignment:UITextAlignmentLeft];
			[[cell textLabel] setLineBreakMode:UILineBreakModeWordWrap];
			[[cell textLabel] setNumberOfLines:0];
			cell.imageView.image = [SDImage imageNamed:@"magnifying_glass_15x15.png"];
			return cell;
		}
		return nil;
	}

	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
		if (tableView == myTableView) {
			Result *chosenResult = [results objectAtIndex:indexPath.row];
			[[Storage instance] storeSearch: chosenResult.domainName];
			ResultViewController *resultViewController = [[[ResultViewController alloc] initWithResult:chosenResult] autorelease];
			[self.navigationController pushViewController:resultViewController animated:YES];
		}
		else if(tableView == historyTableView) {
			if (indexPath.section == 1) {
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				UIAlertView *_alert = [[[UIAlertView alloc] initWithTitle:@"Clear search history?" 
																 message:@"Your search history will be permanently deleted" 
																delegate:self 
													   cancelButtonTitle:@"Cancel" 
													   otherButtonTitles:@"Clear History", nil] autorelease];
				[_alert show];
				return;
			}
			
			mySearchBar.text = [historyArray objectAtIndexA:indexPath.row];
		}
	}

	- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath; {
		if (tableView == historyTableView) {
			//return 2;
		}
		return 0;
	}

#pragma mark -

	- (UITableViewCellEditingStyle) tableView:(UITableView*) theTableView editingStyleForRowAtIndexPath:(NSIndexPath*) indexPath; {
		if (indexPath.section == 1) {
			return UITableViewCellEditingStyleNone;
		}
		
		return (theTableView == historyTableView) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
	}

- (void) tableView:(UITableView*) theTableView commitEditingStyle:(UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath*) indexPath;
{
	if (theTableView == historyTableView && indexPath.section == 0) {
		if (editingStyle == UITableViewCellEditingStyleDelete) {				
			NSString *searchString = [historyArray objectAtIndex: indexPath.row];
			[[Storage instance] removeItem:searchString];
			
			[historyArray removeObjectAtIndex:indexPath.row];
			if ([historyArray count] == 0) {
				[historyTableView reloadData];
			} else {
				[historyTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
			}
		}			
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
	if (buttonIndex == 1) {
		[historyArray removeAllObjects];
		[Storage clearSearchHistory];
		[historyTableView reloadData];
	}
}

#pragma mark -

- (void) showHistory; {
	[self toggleActivityIndicator:NO];
	[results removeAllObjects];
	myTableView.hidden = YES;
	[myTableView reloadData];
	//historyArray = [[[Storage instance] recentHistory] retain];
	[historyArray setArray:[[Storage instance] recentHistory]]; 
	historyTableView.hidden = ([historyArray count] == 0);
	[historyTableView reloadData];
}

- (void)showAbout;
{
	DMAboutController *aboutController = [[[DMAboutController alloc] initWithNibName:@"DMAboutController" bundle:nil] autorelease];
	UINavigationController *presenter = [[[UINavigationController alloc] initWithRootViewController:aboutController] autorelease];
	[self.navigationController presentModalViewController:presenter animated:YES];
}

@end
