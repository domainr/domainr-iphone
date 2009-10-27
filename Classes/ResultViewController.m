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
		self.title = result.imageType == kTLD ? [NSString stringWithFormat:@".%@", newResult.domainName] : newResult.domainName;
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
		for (UIView* view in [cell.contentView subviews])
			[view removeFromSuperview];
		cell.imageView.image = nil;

		if(indexPath.section == kRegisterSection) {
			if (indexPath.row == 0) {
								
				CGRect rect = [[UIScreen mainScreen] bounds];
				UILabel *domainLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, rect.size.width - 40.0, 40.0)];
				domainLabel.text = [NSString stringWithFormat:@"%@%@", result.imageType == kTLD ? [NSString stringWithFormat:@".%@",result.domainName] : result.domainName, result.path ? result.path : @""];
				domainLabel.font = [UIFont boldSystemFontOfSize:24];
				domainLabel.textColor = [UIColor blackColor];
				domainLabel.backgroundColor = [UIColor clearColor];
				domainLabel.adjustsFontSizeToFitWidth = YES;
				[cell.contentView addSubview:domainLabel];
				Release(domainLabel);
				
				UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45.0, rect.size.width - 40.0, 30.0)];
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
				statusLabel.backgroundColor = [UIColor clearColor];
				statusLabel.font = [UIFont systemFontOfSize:18];
				statusLabel.adjustsFontSizeToFitWidth = YES;
				[cell.contentView addSubview:statusLabel];
				Release(statusLabel);
				
				[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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

				[[cell textLabel] setText:SDLocalizedString(buttonTitle)];
			}
		}
		else if(indexPath.section == kMailSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:SDLocalizedString(@"Save (via Email)")];
			}
		}
		else if(indexPath.section == kTLDSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:SDLocalizedString(@"TLD Info")];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			}
			if (tldInfoOpen) {
				if(indexPath.row == 1) {
					
				}
			}
		}
		else if(indexPath.section == kToolSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:SDLocalizedString(@"Tools")];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				[cell setAccessoryView:[[[UIImageView alloc] initWithImage:toolsOpen ? [SDImage imageNamed:@"RevealDisclosureIndicatorUp.png"] : [SDImage imageNamed:@"RevealDisclosureIndicatorDown.png"]] autorelease]];
				[[cell textLabel] setTextColor:toolsOpen ? [UIColor grayColor] : [UIColor blackColor]];
				cell.imageView.image = [SDImage imageNamed:toolsOpen ? @"tools_gray.png" : @"tools.png"];
				return cell;
			}
			else if([result isResolvable] && indexPath.row == 1) {
				[[cell textLabel] setText:SDLocalizedString(@"Visit Site")];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				[cell setAccessoryView:nil];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				cell.imageView.image = [SDImage imageNamed:@"web.png"];
			}
			else if((![result isResolvable] && indexPath.row == 1) || indexPath.row == 2) {
				[[cell textLabel] setText:SDLocalizedString(@"WHOIS")];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				[cell setAccessoryView:nil];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				cell.imageView.image = [SDImage imageNamed:@"magnifying_glass.png"];
			}
		}
		return cell;
	}

	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath; {
		if(indexPath.section == kRegisterSection) {
			if(indexPath.row == 1) {
				isGoingBack = NO;
				if(result.imageType == kTaken) {
					NSString *buyURL = [NSString stringWithFormat:@"http://domai.nr/%@/buy",result.domainName];
					WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:buyURL] autorelease];
					[self.navigationController pushViewController:webViewController animated:YES];
				}
				else if([result isResolvable]) {
					NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
					Result *newResult = [[Result alloc] init];
					newResult.availability = @"tld";
					newResult.domainName = [NSString stringWithFormat:@"%@",[subStrings objectAtIndex:1]];
					newResult.registrars = result.registrars;
					ResultViewController *resultViewController = [[ResultViewController alloc] initWithResult:newResult];
					resultViewController.isDeeper = YES;
					[self.navigationController pushViewController:resultViewController animated:YES];
				}
				else if([result isRegistrable]) {
					NSString *apiRegisterURL = [NSString stringWithFormat:@"http://domai.nr/api/register?domain=%@",result.domainName];
					WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:apiRegisterURL] autorelease];
					[self.navigationController pushViewController:webViewController animated:YES];
				}
				else {
					NSString *tldURL = [NSString stringWithFormat:@"http://domai.nr/about/tlds",result.domainName];
					WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:tldURL] autorelease];
					[self.navigationController pushViewController:webViewController animated:YES];
				}				
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
		[picker setSubject:SDLocalizedStringWithFormat(@"Domainr saved domain: %@",result.domainName)];
		
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
