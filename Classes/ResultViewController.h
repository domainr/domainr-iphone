#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Reachability.h"
#import "CJSONDeserializer.h"

@class Result;

@interface ResultViewController : UITableViewController <MFMailComposeViewControllerDelegate> {
	Result *result;
	Reachability *internetReach;
	NetworkStatus status;
    
    NSData					*jsonData;
	NSURL					*jsonURL;
	NSMutableData			*receivedData;
	NSString				*jsonString;
	NSURLConnection			*theConnection;
    
    NSDictionary *info;
    
    BOOL loading;
    
	BOOL isGoingBack;	// to hide the navbar when returning to search view
	BOOL isDeeper;		// for a result that is from another result 
    
    UIActivityIndicatorView *activityIndicator;
}

@property (retain) Result *result;
@property BOOL isDeeper;

- (id)initWithResult:(Result*)newResult;
- (void)displayComposerSheet;
- (void)setDefaultEmailAddress;

@end