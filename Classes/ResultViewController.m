#import "ResultViewController.h"
#import "Result.h"

@implementation ResultViewController

	@synthesize result, isDeeper;

	- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation; {
		return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	}

	- (void)dealloc {
		Release(result);
		[super dealloc];
	}

	- (id)initWithResult:(Result *)newResult; {
		self = [super initWithStyle:UITableViewStyleGrouped];
		self.result = newResult;
		self.title = [newResult domainName];
		return self;
	}

	- (void)viewWillAppear:(BOOL)animated; {
		isGoingBack = YES;
		[self.navigationController setNavigationBarHidden:NO animated:YES];
		[super viewWillAppear:animated];
	}

	- (void)viewWillDisappear:(BOOL)animated; {
		if(isGoingBack && !isDeeper) [self.navigationController setNavigationBarHidden:YES animated:YES];
		[super viewWillDisappear:animated];
	}

	- (void)viewDidLoad; {
		tldInfoOpen = toolsOpen = NO;
		[super viewDidLoad];
	}

	- (void)viewDidUnload; {
	}

#pragma mark UITableView methods

	enum kSections {
		kRegisterSection = 0,
		kMailSection,
		kTLDSection,
		kToolSection
	};


	- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section; {
		if (section == 0) {
			return 70.0;
		}
		return 0;
	}

	- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section; {
		
		if(section == -1) {
			CGRect rect = [[UIScreen mainScreen] bounds];
			UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 70.0)] autorelease];
			UILabel *statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 15.0, rect.size.width, 30.0)] autorelease];
			
			if(result.imageType == kAvailable) {
				statusLabel.text = @"This domain is available.";
				statusLabel.textColor = [UIColor greenColor];
			}
			else if(result.imageType == kUnavailable) {
				statusLabel.text = @"This domain is not available.";
				statusLabel.textColor = [UIColor redColor];
			}
			else if(result.imageType == kMaybe) {
				statusLabel.text = @"This domain might be available.";
				statusLabel.textColor = [UIColor greenColor];
			}
			else if(result.imageType == kTaken) {
				statusLabel.text = @"This domain is taken.";
				statusLabel.textColor = [UIColor blueColor];
			}
			else if(result.imageType == kTLD) {
				statusLabel.text = @"Top-Level Domain";
				statusLabel.textColor = [UIColor darkGrayColor];				
			}
			else if(result.imageType == kSubdomain) {
				NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
				statusLabel.text = [NSString stringWithFormat:@"Subdomain of .%@",[subStrings objectAtIndex:1]];
				statusLabel.textColor = [UIColor darkGrayColor];
			}
			statusLabel.textAlignment = UITextAlignmentCenter;
			statusLabel.backgroundColor = [UIColor clearColor];
			statusLabel.font = [UIFont systemFontOfSize:20];
			statusLabel.adjustsFontSizeToFitWidth = YES;
			statusLabel.shadowColor = [UIColor whiteColor];
			statusLabel.shadowOffset = CGSizeMake(0, 1);
			
			[headerView addSubview:statusLabel];
			return headerView;
		}
		return nil;
	}

	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
		return 4;
	}

	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
		return (indexPath.section == kRegisterSection && indexPath.row == 0) ? 80.0 : 44.0;
	}

	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
		if(section == kRegisterSection) {
			return result.imageType == kUnavailable ? 1 : 2;
		}
		else if(section == kMailSection) {
			return 1;
		}	
		else if(section == kTLDSection) {
			return 1;
		}
		else if(section == kToolSection) {
			if(toolsOpen) {
				if([result isResolvable]) {
					return 3;
				}
				return 2;
			}
			return 1;
		}
		return 0;
	}

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
		UITableViewCell *cell = (UITableViewCell *)[tableView cellForClass:[UITableViewCell class]];
		
		if(indexPath.section == kRegisterSection) {
			if (indexPath.row == 0) {
				
				for (UIView* view in [cell.contentView subviews])
					[view removeFromSuperview];
				
				CGRect rect = [[UIScreen mainScreen] bounds];
				UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45.0, rect.size.width - 20.0, 30.0)];
				
				if(result.imageType == kAvailable) {
					statusLabel.text = @"This domain is available.";
					statusLabel.textColor = [UIColor greenColor];
				}
				else if(result.imageType == kUnavailable) {
					statusLabel.text = @"This domain is not available.";
					statusLabel.textColor = [UIColor redColor];
				}
				else if(result.imageType == kMaybe) {
					statusLabel.text = @"This domain might be available.";
					statusLabel.textColor = [UIColor greenColor];
				}
				else if(result.imageType == kTaken) {
					statusLabel.text = @"This domain is taken.";
					statusLabel.textColor = [UIColor blueColor];
				}
				else if(result.imageType == kTLD) {
					statusLabel.text = @"Top-Level Domain";
					statusLabel.textColor = [UIColor darkGrayColor];				
				}
				else if(result.imageType == kSubdomain) {
					NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
					statusLabel.text = [NSString stringWithFormat:@"Subdomain of .%@",[subStrings objectAtIndex:1]];
					statusLabel.textColor = [UIColor darkGrayColor];
				}
//				statusLabel.textAlignment = UITextAlignmentCenter;
				statusLabel.backgroundColor = [UIColor clearColor];
				statusLabel.font = [UIFont systemFontOfSize:19];
				statusLabel.adjustsFontSizeToFitWidth = YES;
				
				[cell.contentView addSubview:statusLabel];
				Release(statusLabel);
			}
			else if (indexPath.row == 1) {
				
				NSString *buttonTitle = nil;
				if([result isResolvable]) {
					NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
					buttonTitle = result.imageType == kSubdomain ? [NSString stringWithFormat:@"See details for .%@",[subStrings objectAtIndex:1]] : @"Is it for sale?";
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				}
				else if([result isRegistrable]) {
					buttonTitle = @"Register";
					[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
				}
				else {
					buttonTitle = @"More info";
					[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				}

				[[cell textLabel] setText:NSLocalizedString(buttonTitle,nil)];
			}
		}
		else if(indexPath.section == kMailSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:NSLocalizedString(@"Save (via Email)",nil)];
			}
		}
		else if(indexPath.section == kTLDSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:NSLocalizedString(@"TLD Info",nil)];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			}
			if (tldInfoOpen) {
				if(indexPath.row == 1) {
					
				}
			}
		}
		else if(indexPath.section == kToolSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:NSLocalizedString(@"Tools",nil)];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				[cell setAccessoryView:[[[UIImageView alloc] initWithImage:toolsOpen ? [SDImage imageNamed:@"RevealDisclosureIndicatorUp.png"] : [SDImage imageNamed:@"RevealDisclosureIndicatorDown.png"]] autorelease]];
				[[cell textLabel] setTextColor:toolsOpen ? [UIColor grayColor] : [UIColor blackColor]];
				return cell;
			}
			else if([result isResolvable] && indexPath.row == 1) {
				[[cell textLabel] setText:NSLocalizedString(@"Visit Site (www)",nil)];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				[cell setAccessoryView:nil];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			}
			else if((![result isResolvable] && indexPath.row == 1) || indexPath.row == 2) {
				[[cell textLabel] setText:NSLocalizedString(@"WHOIS",nil)];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				[cell setAccessoryView:nil];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
			}
		}
		return cell;
	}

	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
		if(indexPath.section == kRegisterSection) {

			if([result isResolvable]) {
				isGoingBack = NO;
				NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
				Result *newResult = [[Result alloc] init];
				newResult.availability = @"tld";
				newResult.domainName = [NSString stringWithFormat:@"See details for .%@",[subStrings objectAtIndex:1]];
				newResult.registrars = result.registrars;
				ResultViewController *resultViewController = [[ResultViewController alloc] initWithResult:newResult];
				resultViewController.isDeeper = YES;
				[self.navigationController pushViewController:resultViewController animated:YES];
			}
			else if([result isRegistrable]) {
				isGoingBack = NO;
				NSString *apiRegisterURL = [NSString stringWithFormat:@"http://domai.nr/api/register?domain=%@",result.domainName];
				WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:apiRegisterURL] autorelease];
				[self.navigationController pushViewController:webViewController animated:YES];
			}
			else {
				isGoingBack = NO;
				NSString *tldURL = [NSString stringWithFormat:@"http://domai.nr/about/tlds",result.domainName];
				WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:tldURL] autorelease];
				[self.navigationController pushViewController:webViewController animated:YES];
			}
		}
		else if(indexPath.section == kMailSection) {
			if(indexPath.row == 0) {				//email
				[self displayComposerSheet];
			}
		}
		else if(indexPath.section == kTLDSection) { //tld info
			tldInfoOpen = !tldInfoOpen;
		}
		else if(indexPath.section == kToolSection) { //tools
			
			if(indexPath.row == 0) {
				toolsOpen = !toolsOpen;
				[tableView deselectRowAtIndexPath:indexPath animated:YES];
				[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]  withRowAnimation:UITableViewRowAnimationFade];	
			}
			else if([result isResolvable] && indexPath.row == 1) {
					isGoingBack = NO;
					WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:[NSString stringWithFormat:@"http://domai.nr/%@/www",result.domainName]] autorelease];
					[self.navigationController pushViewController:webViewController animated:YES];
			}
			else if((![result isResolvable] && indexPath.row == 1) || indexPath.row == 2) {
				isGoingBack = NO;
				WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:[NSString stringWithFormat:@"http://domai.nr/%@/whois",result.domainName]] autorelease];
				[self.navigationController pushViewController:webViewController animated:YES];				
			}
		}
		if(!(indexPath.section == kMailSection && indexPath.row == 0)) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}

#pragma mark -

	- (void)displayComposerSheet; {
		isGoingBack = NO; 
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		[picker setToRecipients:nil];
		[picker setSubject:[NSString stringWithFormat:NSLocalizedString(@"Domainr saved domain: %@",nil),result.domainName]];
		
		NSString *emailBody = [NSString stringWithFormat:@"%@",@""];
		[picker setMessageBody:emailBody isHTML:NO];		
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}

	- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error; {
		[self becomeFirstResponder];
		isGoingBack = YES; 
		[self dismissModalViewControllerAnimated:YES];
	}

@end
