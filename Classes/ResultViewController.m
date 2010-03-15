#import "ResultViewController.h"
#import "RegistrarSelectorViewController.h"
#import "Result.h"
#import <QuartzCore/QuartzCore.h>

@implementation ResultViewController

	@synthesize result, isDeeper, info;

	- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation; {
		return YES;//interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
	}

	- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation; {
		[self.tableView reloadData];
	}

	- (void)dealloc {
		Release(result);
		[super dealloc];
	}

	- (id)initWithResult:(Result *)newResult; {
		if (self = [super initWithStyle:UITableViewStyleGrouped]) {
            self.result = newResult;
            self.title = result.imageType == kTLD ? [NSString stringWithFormat:@".%@", newResult.domainName] : newResult.domainName;
        }
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
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setFrame:CGRectMake(145, 220, 30, 30)];
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        NSString *urlInfoString = [NSString stringWithFormat: @"http://domai.nr/api/json/info?q=%@", result.domainName];
		
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: [urlInfoString escapedString]]
																  cachePolicy: NSURLRequestUseProtocolCachePolicy
															  timeoutInterval: 60.0];
		[theRequest setHTTPMethod:@"GET"];
		
		theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
		if (theConnection) {
			receivedData=[[NSMutableData data] retain];
		} 
		else {
		}
        
        loading = YES;
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
		if (section == kRegisterSection) {
			return 90.0;
		}
        if (section == kToolSection || section == kTLDSection) {
            return 30;
        }
		return 0;
	}

    - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section; {
        if (section == kToolSection) {
            return @"Tools";
        }
        else if (section == kTLDSection) {
            return @"Top-level Domain Info";
        }

        return nil;
    }

	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView; {
        if (loading) {
            return 1;
        }        
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
			return 2;
		}
		else if(section == kToolSection) {
            if([result isResolvable]) {
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
				[[cell textLabel] setText:@""];
				[cell setAccessoryType:UITableViewCellAccessoryNone];
				CGRect rect = [[UIScreen mainScreen] bounds];
				UILabel *domainLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, rect.size.width - 35.0, 40.0)];
				domainLabel.text = [NSString stringWithFormat:@"%@%@", result.imageType == kTLD ? [NSString stringWithFormat:@".%@",result.domainName] : result.domainName, result.path ? result.path : @""];
				domainLabel.font = [UIFont boldSystemFontOfSize:24];
				domainLabel.textColor = [UIColor blackColor];
				domainLabel.backgroundColor = [UIColor clearColor];
				domainLabel.adjustsFontSizeToFitWidth = YES;
				[cell.contentView addSubview:domainLabel];
				Release(domainLabel);
                
				UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 42.0, rect.size.width - 34.0, 30.0)];
                statusLabel.layer.cornerRadius = 4;
				statusLabel.backgroundColor = [UIColor clearColor];
				statusLabel.font = [UIFont systemFontOfSize:17];
				statusLabel.adjustsFontSizeToFitWidth = YES;
                
				if(result.imageType == kAvailable) {
					statusLabel.text = @" This domain is available. ";
					statusLabel.textColor = UIColorFromRGB(0x23b000);
                    statusLabel.backgroundColor = UIColorFromRGB(0xffeeee);
				}
				else if(result.imageType == kUnavailable) {
					statusLabel.text = @" This domain is not available. ";
					statusLabel.textColor = UIColorFromRGB(0xff4d00);
                    statusLabel.backgroundColor = UIColorFromRGB(0xffeee6);
				}
				else if(result.imageType == kMaybe) {
					statusLabel.text = @" This domain might be available. ";
					statusLabel.textColor = UIColorFromRGB(0xd1ad69) ;
				}
				else if(result.imageType == kTaken) {
					statusLabel.text = @" This domain is taken. ";
                    statusLabel.textColor = [UIColor blackColor];
                    statusLabel.backgroundColor = UIColorFromRGB(0xffeeee);
                }
				else if(result.imageType == kTLD) {
					statusLabel.text = @" Top-Level Domain ";
//                  statusLabel.textColor = UIColorFromRGB(0xf5f7f4) ;				
                    statusLabel.textColor = [UIColor whiteColor];
                    statusLabel.backgroundColor = UIColorFromRGB(0x7a7d79);
                    statusLabel.font = [UIFont boldSystemFontOfSize:17];
                    statusLabel.shadowColor = [UIColor darkGrayColor];
                    statusLabel.shadowOffset = CGSizeMake(-1, 1);
				}
				else if(result.imageType == kSubdomain) {
					NSArray *subStrings = [result.domainName componentsSeparatedByString:@"."];
					statusLabel.text = [NSString stringWithFormat:@" Subdomain of .%@ ", [subStrings objectAtIndex:1]];
//					statusLabel.textColor = UIColorFromRGB(0xf5f7f4);
                    statusLabel.textColor = [UIColor whiteColor];
                    statusLabel.backgroundColor = UIColorFromRGB(0x7a7d79);
                    statusLabel.font = [UIFont boldSystemFontOfSize:17];
                    statusLabel.shadowColor = [UIColor darkGrayColor];
                    statusLabel.shadowOffset = CGSizeMake(-1, 1);
				}
                
                CGSize labelSize = [statusLabel.text sizeWithFont:statusLabel.font];
                [statusLabel setFrame:CGRectMake(7, 42, labelSize.width, 30)];
                
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
                    if (loading) {
                        [cell setAccessoryType:UITableViewCellAccessoryNone];
                    }
                    else {
                        [cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
                    }
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
                //cell.imageView.image = [SDImage imageNamed:@"at_symbol.png"];
			}
		}
		else if(indexPath.section == kTLDSection) {
			if(indexPath.row == 0) {
				[[cell textLabel] setText:SDLocalizedString(@"Wikipedia")];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                cell.imageView.image = [SDImage imageNamed:@"wiki_icon.png"];
			}
            else if(indexPath.row == 1) {
				[[cell textLabel] setText:SDLocalizedString(@"IANA")];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                cell.imageView.image = [SDImage imageNamed:@"iana_icon.png"];
			}            
		}
		else if(indexPath.section == kToolSection) {
            if([result isResolvable] && indexPath.row == 0) {
				[[cell textLabel] setText:SDLocalizedString(@"Visit Site")];
				[[cell textLabel] setTextColor:[UIColor blackColor]];
				[cell setAccessoryView:nil];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
				cell.imageView.image = [SDImage imageNamed:@"web.png"];
			}
			else if((![result isResolvable] && indexPath.row == 0) || indexPath.row == 1) {
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
                
                if (loading) {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    return;
                }
                
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
					ResultViewController *resultViewController = [[[ResultViewController alloc] initWithResult:newResult] autorelease];
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
                [self setDefaultEmailAddress];
				[self displayComposerSheet];
			}
		}
		else if(indexPath.section == kTLDSection) { //tld info
            isGoingBack = NO;

            NSDictionary *tldinfo = [info objectForKey:@"tld"];
            
            if (indexPath.row == 0) {
                //WIKI
                NSString *wikiUrl = [tldinfo objectForKey:@"wikipedia_url"];
                WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:wikiUrl] autorelease];
                [self.navigationController pushViewController:webViewController animated:YES];
            }
            else if (indexPath.row == 1) {
                //IANA
                NSString *ianaUrl = [tldinfo objectForKey:@"iana_url"];
                WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:ianaUrl] autorelease];
                [self.navigationController pushViewController:webViewController animated:YES];                
            }
        }
		else if(indexPath.section == kToolSection) { //tools
            isGoingBack = NO;

            if([result isResolvable] && indexPath.row == 0) {                
                //WWW
                NSString *wwwUrl = [info objectForKey:@"www_url"];
                WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:wwwUrl] autorelease];
                [self.navigationController pushViewController:webViewController animated:YES];
			}
			else if((![result isResolvable] && indexPath.row == 0) || indexPath.row == 1) {
                //WHOIS
                NSString *whoIsURL = [info objectForKey:@"whois_url"];
				WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:whoIsURL] autorelease];
				[self.navigationController pushViewController:webViewController animated:YES];				
			}
		}
		if(!(indexPath.section == kMailSection && indexPath.row == 0)) {
		//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}

    - (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath; {
        if (indexPath.section == kRegisterSection) {
            isGoingBack = NO;
            RegistrarSelectorViewController *registrarViewController = [[[RegistrarSelectorViewController alloc] initWithResult:result] autorelease];
            [self.navigationController pushViewController:registrarViewController animated:YES];
        }
    }

#pragma mark NSURLConnection

    - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data; {
        [receivedData appendData:data];
    }

    - (void)connectionDidFinishLoading:(NSURLConnection *)connection; {
        NSError *error = nil;
        
//        NSLog(@"%@",[NSString stringWithData:receivedData]);
        
        info = [[[CJSONDeserializer deserializer] deserializeAsDictionary:receivedData error:&error] retain];
        
        result.registrars = [info objectForKey:@"registrars"];
        
        [receivedData setLength:0];
        Release(receivedData);
        Release(connection);
        
        [activityIndicator stopAnimating];
        loading = NO;
        [self.tableView reloadData];
    }

#pragma mark -

    - (void)setDefaultEmailAddress; {
        //TODO: show alertview to ask for default email address
    }

	- (void)displayComposerSheet; {
		isGoingBack = NO; 
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		[picker setToRecipients:nil];
		[picker setSubject:SDLocalizedStringWithFormat(@"Domainr: %@",result.domainName)];
		
		NSString *emailBody = [NSString stringWithFormat:@"Found on Domainr:<br/><br/><strong>http://domai.nr/%@</strong>",result.domainName];
		[picker setMessageBody:emailBody isHTML:YES];		
		[self presentModalViewController:picker animated:YES];
		[picker release];
	}

	- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error; {
		[self becomeFirstResponder];
		isGoingBack = YES; 
		[self dismissModalViewControllerAnimated:YES];
	}

@end
