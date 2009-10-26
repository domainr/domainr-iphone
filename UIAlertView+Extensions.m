#import "UIAlertView+Extensions.h"

void UIAlertViewQuick(NSString* title, NSString* message, NSString* dismissButtonTitle) {
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:SDLocalizedString(title) 
													message:SDLocalizedString(message) 
												   delegate:nil 
										  cancelButtonTitle:SDLocalizedString(dismissButtonTitle) 
										  otherButtonTitles:nil
						  ];
	[alert show];
	[alert autorelease];
}

@implementation UIAlertView (Helper)

@end
