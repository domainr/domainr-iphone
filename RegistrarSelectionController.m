#import "RegistrarSelectionController.h"


@implementation RegistrarSelectionController

	@synthesize registrars;

	- (void)dealloc {
		Release(registrars);
		[super dealloc];
	}

	- (id)initWithRegistrars:(NSArray *)theRegistrars {
		// Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
		if (self = [super initWithStyle:UITableViewStyleGrouped]) {
			self.registrars = [theRegistrars retain];
		}
		return self;
	}

	- (void)viewDidLoad {
		[super viewDidLoad];
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

	- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
		return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	}

	- (void)viewDidUnload {
	}

	#pragma mark Table view methods

	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
		return 1;
	}


	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		return [registrars count];
	}

	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		UITableViewCell *cell = [tableView cellForClass:[UITableViewCell class]];
		
//		[cell.textLabel setText:
		
		return cell;
	}


	- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	}

@end

