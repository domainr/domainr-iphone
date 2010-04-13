//
//  RegistrarSelectorViewController.m
//  Domainr
//
//  Created by Sahil Desai on 2/9/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RegistrarSelectorViewController.h"
#import "WebViewController.h"

@implementation RegistrarSelectorViewController

@synthesize result;


#pragma mark -
#pragma mark View lifecycle


- (id)initWithResult:(Result *)newResult; {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.result = newResult;
        self.title = SDLocalizedString(@"Registrars");
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [result.registrars count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForClass:[UITableViewCell class]];

    NSDictionary *registrar = [result.registrars objectAtIndexA:indexPath.row];
    [cell.textLabel setText:[registrar objectForKey:@"name"]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *registrar = [result.registrars objectAtIndexA:indexPath.row];
	//	WebViewController *webViewController = [[[WebViewController alloc] initWithResult:result] autorelease];
    WebViewController *webViewController = [[[WebViewController alloc] initWithAddress:[registrar objectForKey:@"register_url"] result:result] autorelease];

    [self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];    
}

- (void)viewDidUnload {

}


- (void)dealloc {
    [super dealloc];
}


@end

