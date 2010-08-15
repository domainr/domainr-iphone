#import "Result.h"

@implementation Result

	@synthesize domainName, availability, path, registerURL, registrars, resultCell, imageType;

	- (void)dealloc; {
		self.domainName = nil;
		self.availability = nil;
		self.registrars = nil;
		self.registerURL = nil;
		self.resultCell = nil;

		[super dealloc];
	}

	- (NSMutableArray *)registrars; {
		if(!registrars)
			registrars = [[NSMutableArray alloc] init];
		return registrars;
	}

	- (void)setAvailability:(NSString *)avail; {
		if(avail == availability)
			return;
		
		Release(availability);
		
		if([avail isEqualToString:SDLocalizedString(@"available")]){
			availability = [avail retain];
			imageType = kAvailable;
		}
		else if([avail isEqualToString:SDLocalizedString(@"maybe")]) {
			availability = [avail retain];
			imageType = kMaybe;
		}
		else if([avail isEqualToString:SDLocalizedString(@"taken")]) {
			availability = [avail retain];
			imageType = kTaken;
		}
		else if([avail isEqualToString:SDLocalizedString(@"tld")]) {
			imageType = kTLD;
			availability = [@"top-level domain" retain];
		}
		else if([avail isEqualToString:SDLocalizedString(@"known")]) {
			imageType = kSubdomain;
			availability = [@"subdomain" retain];
		}
		else if([avail isEqualToString:SDLocalizedString(@"unavailable")]) {
			availability = [avail retain];
			imageType = kUnavailable;
		}
		else {
			availability = [avail retain];
			imageType = kTaken;
		}
	}

	- (BOOL)isResolvable; {
		if(imageType == kAvailable || imageType == kUnavailable || imageType == kTLD || imageType == kMaybe) {
			return NO;
		}
		return YES;
	}

	- (BOOL)isRegistrable; {
		if(imageType == kTLD || imageType == kSubdomain) {
			return NO;
		}
		return YES;
	}

@end
