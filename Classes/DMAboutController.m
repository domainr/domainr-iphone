//
//  DMAboutController.m
//  Domainr
//
//  Created by Sahil Desai on 4/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DMAboutController.h"


@implementation DMAboutController


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"About", nil);
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" 
																			   style:UIBarButtonItemStyleDone 
																			  target:self
																			  action:@selector(close)] autorelease];
}

- (void)close;
{
	[self dismissModalViewControllerAnimated:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    // Return the number of sections.
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
	if (section == 0) {
		return @"About Domainr";
	}
	if (section == 1) {
		return @"Brought to you by...";
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
{
	if (section == 2) {
		return @"© nb.io";
	}
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if (section == 0) {
		return 3;
	}
	if (section == 1) {
		return 4;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [tableView cellForClass:[UITableViewCell class]];
    
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"Twitter";
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
		if (indexPath.row == 1) {
			cell.textLabel.text = @"Blog";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 2) {
			cell.textLabel.text = @"Contact us";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	if (indexPath.section == 1) {
		if (indexPath.row == 0) {
			cell.textLabel.text = @"@sahil";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 1) {
			cell.textLabel.text = @"@case";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 2) {
			cell.textLabel.text = @"@rr";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		if (indexPath.row == 3) {
			cell.textLabel.text = @"@ceedub";			
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			WebViewController *webView = [[[WebViewController alloc] initWithAddress:@"http://twitter.com/domainr" result:nil] autorelease];			
			[self.navigationController pushViewController:webView animated:YES];
		}
		if (indexPath.row == 1) {
			WebViewController *webView = [[[WebViewController alloc] initWithAddress:@"http://blog.domai.nr/" result:nil] autorelease];			
			[self.navigationController pushViewController:webView animated:YES];
		}
		if (indexPath.row == 2) {
			[self displayComposerSheet];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			return;
		}
	}
	if (indexPath.section == 1) {
		
		NSString *username = nil;
		if (indexPath.row == 0) {
			username = @"sahil";
		}
		if (indexPath.row == 1) {
			username = @"case";
		}
		if (indexPath.row == 2) {
			username = @"rr";
		}
		if (indexPath.row == 3) {
			username = @"ceedub";
		}
		
		WebViewController *webView = [[[WebViewController alloc] initWithAddress:[NSString stringWithFormat:@"http://twitter.com/%@", username] result:nil] autorelease];			
		[self.navigationController pushViewController:webView animated:YES];

	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
	if (indexPath.section == 0 && indexPath.row == 0) {
		WebViewController *webView = [[[WebViewController alloc] initWithAddress:@"http://search.twitter.com/search?q=domainr" result:nil] autorelease];			
		[self.navigationController pushViewController:webView animated:YES];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


- (void)displayComposerSheet; {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setToRecipients:[NSArray arrayWithObject:@"ping@domai.nr"]];
	[picker setSubject:SDLocalizedStringWithFormat(@"Hey Domainr Guys!")];
	
	NSString *emailBody = [NSString stringWithFormat:@""];
	[picker setMessageBody:emailBody isHTML:YES];		
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error; {
	[self dismissModalViewControllerAnimated:YES];
}


@end

