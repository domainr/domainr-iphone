#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Reachability.h"

@class Result;

@interface ResultViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
	Result *result;
	Reachability *internetReach;
	NetworkStatus status;
	
	BOOL tldInfoOpen;	//
	BOOL toolsOpen;		//
	BOOL isGoingBack;	// to hide the navbar when returning to search view
	BOOL isDeeper;		// for a result that is from another result 
}

@property (retain) Result *result;
@property BOOL isDeeper;

- (id)initWithResult:(Result*)newResult;
- (void)displayComposerSheet;

@end